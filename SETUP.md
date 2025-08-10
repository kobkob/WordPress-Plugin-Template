# WordPress Plugin Template Setup Guide

This guide will help you set up your development environment and start using the WordPress Plugin Template for professional plugin development.

## 🚀 Quick Start

### Prerequisites

Before you begin, ensure you have the following tools installed:

#### Required Tools
- **PHP 8.1+** with the following extensions:
  - `curl`, `dom`, `hash`, `json`, `libxml`, `mbstring`, `openssl`, `pcre`, `xml`, `zip`
- **Composer** - PHP dependency manager
- **Node.js 18+** and **NPM** - For asset building
- **Git** - Version control

#### Optional but Recommended
- **MySQL/MariaDB** - For WordPress testing
- **VS Code** - With recommended extensions
- **Docker** - For containerized development (future feature)

### Installation Check

Run this command to verify your setup:

```bash
# Check PHP version and extensions
php -v
php -m | grep -E "(curl|dom|hash|json|libxml|mbstring|openssl|pcre|xml|zip)"

# Check Composer
composer --version

# Check Node.js and NPM
node --version
npm --version

# Check Git
git --version
```

### Creating Your First Plugin

1. **Clone the template:**
   ```bash
   git clone https://github.com/username/WordPress-Plugin-Template.git
   cd WordPress-Plugin-Template
   ```

2. **Run the creation script:**
   ```bash
   ./create-plugin.sh
   ```

3. **Follow the interactive prompts:**
   - Plugin name (e.g., "My Awesome Plugin")
   - Destination folder
   - Plugin description
   - Author information
   - Choose development tools (PHPUnit, PHPCS, GitHub Actions)

4. **Navigate to your new plugin:**
   ```bash
   cd /path/to/your/new-plugin
   ```

5. **Install dependencies:**
   ```bash
   composer install
   npm install
   ```

## 🛠 Development Environment Setup

### WordPress Test Environment

To run tests, you need a WordPress test environment:

```bash
# Create test database and install WordPress test suite
./bin/install-wp-tests.sh wordpress_test root password localhost latest

# Run tests to verify setup
composer test
```

### VS Code Configuration

If you're using VS Code, the template includes:

- **Settings**: Configured for WordPress development
- **Extensions**: Recommended extensions for PHP, WordPress, and testing
- **Tasks**: Pre-configured build tasks

Install recommended extensions when prompted, or manually:
```bash
code --install-extension bmewburn.vscode-intelephense-client
code --install-extension ikappas.phpcs
# ... (see .vscode/extensions.json for full list)
```

### Git Hooks (Optional)

Set up pre-commit hooks for code quality:

```bash
# Install pre-commit (requires Python)
pip install pre-commit
pre-commit install

# Or use Composer-based hooks
composer require --dev brianium/paratest
```

## 🧪 Testing Setup

### PHPUnit Configuration

The template includes comprehensive testing setup:

```bash
# Run all tests
composer test

# Run specific test types
vendor/bin/phpunit tests/unit
vendor/bin/phpunit tests/integration

# Generate coverage report
vendor/bin/phpunit --coverage-html coverage/
```

### Writing Tests

Create new tests in the appropriate directory:

```php
// tests/unit/test-my-feature.php
<?php
class Test_My_Feature extends WP_UnitTestCase {
    
    public function test_my_function_returns_expected_value() {
        $result = my_plugin_function();
        $this->assertEquals('expected', $result);
    }
}
```

### Test Database Setup

For integration tests that require database operations:

```bash
# MySQL/MariaDB setup
mysql -u root -p -e "CREATE DATABASE wordpress_test;"
mysql -u root -p -e "GRANT ALL PRIVILEGES ON wordpress_test.* TO 'wp_test'@'localhost' IDENTIFIED BY 'password';"

# Update test configuration if needed
export WP_TESTS_DIR=/tmp/wordpress-tests-lib
export WP_CORE_DIR=/tmp/wordpress/
```

## 📋 Code Quality

### WordPress Coding Standards

The template enforces WordPress coding standards:

```bash
# Check coding standards
composer cs

# Fix automatically fixable issues
composer cbf

# Check specific files
vendor/bin/phpcs path/to/file.php
```

### Custom PHPCS Configuration

Modify `phpcs.xml` to customize rules:

```xml
<!-- Exclude specific rules -->
<rule ref="WordPress">
    <exclude name="WordPress.Files.FileName.InvalidClassFileName"/>
</rule>

<!-- Set custom prefixes -->
<rule ref="WordPress.NamingConventions.PrefixAllGlobals">
    <properties>
        <property name="prefixes" type="array" value="my_plugin"/>
    </properties>
</rule>
```

### Pre-commit Quality Checks

Add this to your development workflow:

```bash
#!/bin/bash
# .git/hooks/pre-commit

# Run coding standards check
composer cs || exit 1

# Run tests
composer test || exit 1

echo "✅ All checks passed!"
```

## 🏗️ Build Process

### Asset Building

The template includes Grunt for asset processing:

```bash
# Install Node dependencies
npm install

# Development build (unminified)
grunt dev

# Production build (minified)
grunt build

# Watch for changes during development
grunt watch
```

### Custom Grunt Tasks

Modify `Gruntfile.js` to add custom tasks:

```javascript
// Example: Add image optimization
grunt.loadNpmTasks('grunt-contrib-imagemin');

grunt.config('imagemin', {
    dynamic: {
        files: [{
            expand: true,
            cwd: 'assets/images/',
            src: ['**/*.{png,jpg,gif}'],
            dest: 'assets/images/'
        }]
    }
});
```

### Build Scripts

Add custom build scripts to `package.json`:

```json
{
  "scripts": {
    "build": "grunt build",
    "dev": "grunt dev",
    "watch": "grunt watch",
    "lint:js": "eslint assets/js/",
    "lint:css": "stylelint assets/css/"
  }
}
```

## 🚀 Deployment

### GitHub Actions CI/CD

The template includes a GitHub Actions workflow that:

- Tests on multiple PHP versions (8.1, 8.2, 8.3)
- Tests on multiple WordPress versions
- Runs coding standards checks
- Executes the test suite
- Generates coverage reports

### Manual Deployment

For manual deployment to WordPress.org:

```bash
# Build production assets
npm run build

# Create plugin zip
zip -r my-plugin.zip . -x "*.git*" "node_modules/*" "vendor/*" "tests/*" "*.json" "*.xml" "Gruntfile.js"
```

### Automated Deployment

Set up automated deployment with GitHub Actions:

```yaml
# .github/workflows/deploy.yml
name: Deploy to WordPress.org
on:
  release:
    types: [published]
jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Deploy to WordPress.org
        uses: 10up/action-wordpress-plugin-deploy@stable
        env:
          SVN_PASSWORD: ${{ secrets.SVN_PASSWORD }}
          SVN_USERNAME: ${{ secrets.SVN_USERNAME }}
```

## 🔧 Troubleshooting

### Common Issues

#### PHP Memory Limit
```bash
# Increase memory limit for Composer
php -d memory_limit=512M /usr/local/bin/composer install
```

#### Permission Issues
```bash
# Fix file permissions
chmod +x create-plugin.sh
chmod +x bin/install-wp-tests.sh
```

#### Test Database Connection
```bash
# Test database connection
mysql -u root -p -e "SHOW DATABASES;"
```

#### Asset Build Failures
```bash
# Clear npm cache
npm cache clean --force
rm -rf node_modules
npm install
```

### Getting Help

- **Documentation**: Check README.md and inline comments
- **Issues**: [GitHub Issues](https://github.com/username/WordPress-Plugin-Template/issues)
- **Community**: [WordPress Plugin Development Forum](https://wordpress.org/support/forum/plugins/)

## 📚 Resources

### WordPress Development
- [WordPress Plugin Developer Handbook](https://developer.wordpress.org/plugins/)
- [WordPress Coding Standards](https://developer.wordpress.org/coding-standards/)
- [WordPress Plugin Security](https://developer.wordpress.org/plugins/security/)

### Testing
- [PHPUnit Documentation](https://phpunit.de/documentation.html)
- [WordPress Testing Guide](https://make.wordpress.org/core/handbook/testing/)
- [WP Test Utils](https://github.com/Yoast/wp-test-utils)

### Code Quality
- [PHP_CodeSniffer](https://github.com/squizlabs/PHP_CodeSniffer)
- [WordPress Coding Standards](https://github.com/WordPress/WordPress-Coding-Standards)
- [PHPCompatibility](https://github.com/PHPCompatibility/PHPCompatibility)

## 🎯 Next Steps

1. **Explore the Template**: Review the generated plugin structure
2. **Read the Code**: Understand the architecture and patterns
3. **Write Tests**: Start with test-driven development
4. **Build Features**: Use the APIs to add functionality
5. **Deploy**: Set up CI/CD for automated testing and deployment

---

**Happy Plugin Development!** 🎉

For more advanced topics and best practices, see our [Contributing Guidelines](CONTRIBUTING.md) and [Changelog](CHANGELOG.md).
