# Contributing to WordPress Plugin Template

Thank you for considering contributing to the WordPress Plugin Template! This document outlines the process for contributing and helps maintain consistency across the project.

## 🎯 How to Contribute

### Types of Contributions

We welcome several types of contributions:

1. **Bug Reports** - Help us identify and fix issues
2. **Feature Requests** - Suggest new functionality
3. **Code Contributions** - Submit bug fixes or new features
4. **Documentation** - Improve README, code comments, or guides
5. **Testing** - Help test new features and report issues

### Before You Start

- Check existing [issues](https://github.com/kobkob/WordPress-Plugin-Template/issues) to avoid duplicates
- Read through this contributing guide
- Ensure you have the necessary development tools installed

## 🛠 Development Setup

### Prerequisites

- PHP 8.1 or higher
- Composer
- Node.js and NPM
- Git
- WordPress development environment

### Initial Setup

1. **Fork the repository**
   ```bash
   # Fork on GitHub, then clone your fork
   git clone https://github.com/kobkob/WordPress-Plugin-Template.git
   cd WordPress-Plugin-Template
   ```

2. **Install dependencies**
   ```bash
   # PHP dependencies
   composer install
   
   # Node.js dependencies  
   npm install
   ```

3. **Set up pre-commit hooks** (optional but recommended)
   ```bash
   # Install pre-commit (requires Python)
   pip install pre-commit
   pre-commit install
   ```

## 📝 Coding Standards

### PHP Standards

We follow WordPress Coding Standards strictly:

- **WordPress-Extra** coding standards
- **WordPress-Docs** documentation standards
- **PHPCompatibilityWP** for WordPress compatibility
- **PHP 8.1+** compatibility

Run coding standards checks:
```bash
composer cs        # Check standards
composer cbf       # Fix automatically fixable issues
```

### JavaScript Standards

- Use ES6+ features where appropriate
- Follow WordPress JavaScript coding standards
- Ensure compatibility with supported browsers

### CSS/LESS Standards

- Follow WordPress CSS coding standards
- Use LESS preprocessing for maintainability
- Ensure responsive design principles

## 🧪 Testing Requirements

### PHP Testing

All PHP code contributions must include tests:

```bash
# Run all tests
composer test

# Run specific test suites
vendor/bin/phpunit tests/unit
vendor/bin/phpunit tests/integration

# Generate coverage report
vendor/bin/phpunit --coverage-html coverage/
```

### Test Guidelines

- **Unit tests** for individual functions/methods
- **Integration tests** for WordPress-specific functionality
- **Minimum 80% code coverage** for new features
- **Test edge cases** and error conditions
- **Use descriptive test method names**

Example test structure:
```php
class Test_New_Feature extends WP_UnitTestCase {
    
    public function setUp(): void {
        parent::setUp();
        // Setup code
    }
    
    public function test_feature_works_correctly() {
        // Test implementation
        $result = new_feature_function();
        $this->assertTrue($result);
    }
    
    public function test_feature_handles_invalid_input() {
        // Test error conditions
        $result = new_feature_function('invalid');
        $this->assertFalse($result);
    }
}
```

## 📋 Pull Request Process

### Before Submitting

1. **Create a feature branch**
   ```bash
   git checkout -b feature/your-feature-name
   ```

2. **Make your changes**
   - Write clean, well-documented code
   - Add/update tests as needed
   - Update documentation if necessary

3. **Test thoroughly**
   ```bash
   composer test
   composer cs
   npm run build
   ```

4. **Commit with clear messages**
   ```bash
   git commit -m "feat: add new feature for X
   
   - Implements functionality Y
   - Adds tests for edge cases
   - Updates documentation
   
   Fixes #123"
   ```

### Commit Message Format

We follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>(<scope>): <subject>

<body>

<footer>
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Build process or auxiliary tool changes

**Examples:**
```
feat(api): add post type registration helper

Adds a new helper function to simplify custom post type registration
with sensible defaults and better error handling.

Closes #45

fix(settings): prevent XSS in admin forms

Sanitizes user input in settings forms to prevent XSS attacks.
Adds validation for all form fields.

Fixes #67

docs(readme): update installation instructions

Updates the quick start guide with clearer steps and adds
troubleshooting section.
```

### Pull Request Template

When creating a pull request, please include:

- **Clear title** describing the change
- **Description** of what was changed and why
- **Testing instructions** for reviewers
- **Screenshots** for UI changes (if applicable)
- **Related issues** that are addressed
- **Breaking changes** (if any)

## 🔍 Code Review Process

### What We Look For

- **Code quality** and adherence to standards
- **Test coverage** for new functionality
- **Documentation** updates where needed
- **Security considerations** for any user input/output
- **Performance implications** of changes
- **Backward compatibility** maintenance

### Review Timeline

- Initial review within 3-5 days
- Follow-up reviews within 1-2 days
- Maintainers may request changes or provide feedback
- Once approved, changes will be merged

## 🚀 Release Process

### Versioning

We follow [Semantic Versioning](https://semver.org/):

- **MAJOR**: Incompatible API changes
- **MINOR**: Backward-compatible functionality additions  
- **PATCH**: Backward-compatible bug fixes

### Release Workflow

1. Updates merged to `develop` branch
2. Testing and validation on `develop`
3. Release preparation and version bumping
4. Merge to `main` and tag release
5. GitHub release with changelog

## 📚 Documentation Guidelines

### Code Documentation

- **PHPDoc blocks** for all functions, classes, and methods
- **Inline comments** for complex logic
- **Examples** for public APIs
- **Type hints** where appropriate

Example:
```php
/**
 * Registers a custom post type with the WordPress API.
 *
 * @since 1.0.0
 * 
 * @param string $post_type   The post type name.
 * @param string $plural      Plural name for the post type.
 * @param string $single      Singular name for the post type.
 * @param string $description Optional. Post type description.
 * @param array  $options     Optional. Additional post type options.
 * 
 * @return WordPress_Plugin_Template_Post_Type|null Post type object on success, null on failure.
 */
public function register_post_type( $post_type = '', $plural = '', $single = '', $description = '', $options = array() ) {
    // Implementation
}
```

### README Updates

- Keep examples current and working
- Update feature lists for new functionality  
- Add troubleshooting information when needed
- Include migration guides for breaking changes

## ❓ Getting Help

### Where to Ask Questions

- **GitHub Discussions** for general questions
- **GitHub Issues** for bug reports and feature requests
- **WordPress.org Forums** for WordPress-specific questions

### Response Time

- We aim to respond to questions within 48 hours
- Complex issues may take longer to resolve
- Maintainers are volunteers, please be patient

## 🎉 Recognition

Contributors will be:

- **Credited** in the changelog for their contributions
- **Added** to the contributors list in README
- **Mentioned** in release notes for significant contributions

## 📞 Contact

- **Maintainer**: [Your Name](mailto:your-email@example.com)
- **Project Repository**: https://github.com/username/WordPress-Plugin-Template
- **Issues**: https://github.com/username/WordPress-Plugin-Template/issues

---

Thank you for contributing to WordPress Plugin Template! 🚀
