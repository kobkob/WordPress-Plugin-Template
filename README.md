# WordPress Plugin Template 🚀

A modern, robust, and GPL-licensed code template for creating standards-compliant WordPress plugins with professional development practices.

[![CI](https://github.com/kobkob/WordPress-Plugin-Template/actions/workflows/ci.yml/badge.svg)](https://github.com/username/WordPress-Plugin-Template/actions/workflows/ci.yml)
[![PHP Version](https://img.shields.io/badge/PHP-8.1%2B-blue.svg)](https://php.net)
[![WordPress Version](https://img.shields.io/badge/WordPress-6.0%2B-blue.svg)](https://wordpress.org)
[![License](https://img.shields.io/badge/License-GPL--2.0%2B-green.svg)](LICENSE)

## 🌟 Features

### Core Plugin Architecture
- **Modern PHP 8.1+ Support** with type declarations and latest features
- **Plugin headers** as required by WordPress & WordPress.org
- **Singleton pattern** main plugin class
- **Object-oriented design** with proper namespacing
- **PSR-4 autoloading** ready structure
- **WordPress Coding Standards** compliant

### Development Tools
- **PHPUnit** test suite with unit and integration tests
- **WordPress Coding Standards (PHPCS)** configuration
- **GitHub Actions** CI/CD pipeline
- **Composer** dependency management
- **PHPStan** static analysis ready
- **WordPress test environment** setup scripts

### AI/LLM Integration
- **WordPress Feature API** integration for AI-powered functionality
- **Automattic WP Feature API** support (v0.1.8+) 
- **MCP-compatible** feature registry for LLM agents
- **Pre-built features** for content management and plugin settings
- **Extensible architecture** for custom AI features

### Built-in Libraries
- **Settings API** wrapper for easy admin options
- **Post Type API** for one-line custom post type registration
- **Taxonomy API** for one-line taxonomy registration
- **Admin API** for meta boxes and custom fields
- **Asset management** with proper enqueuing

### Frontend Assets
- **Grunt.js** build system
- **LESS** preprocessing
- **JavaScript minification**
- **CSS optimization**
- **Development and production builds**

## 🚀 Quick Start

### Prerequisites

Ensure you have the following tools installed:
- **PHP 8.1+** with required extensions
- **Composer** for dependency management
- **Node.js & NPM** for asset building
- **Git** for version control

### Using the Enhanced Creation Script

The enhanced `create-plugin.sh` script automates the entire setup process:

```bash
# Clone this repository
git clone https://github.com/username/WordPress-Plugin-Template.git
cd WordPress-Plugin-Template

# Run the creation script
./create-plugin.sh
```

The script will guide you through:
1. **Plugin Information**: Name, description, author details
2. **Development Setup**: PHPUnit tests, PHPCS, GitHub Actions
3. **File Generation**: All necessary config files and boilerplate
4. **Dependency Installation**: Composer packages
5. **Git Initialization**: Clean repository setup

### Manual Setup

If you prefer manual setup:

1. Copy the template files to your new plugin directory
2. Rename `wordpress-plugin-template.php` to your plugin slug
3. Update all class names, function names, and text domains
4. Run `composer install` for development dependencies
5. Configure your test environment

## 🧪 Testing

### Setting Up Tests

```bash
# Install WordPress test suite
./bin/install-wp-tests.sh wordpress_test root password localhost latest

# Run all tests
composer test

# Run specific test suites
vendor/bin/phpunit tests/unit
vendor/bin/phpunit tests/integration
```

### Test Structure

```
tests/
├── bootstrap.php          # Test bootstrap
├── unit/                  # Unit tests
│   └── test-plugin.php   # Main plugin tests
└── integration/          # Integration tests
    └── test-integration.php
```

### Writing Tests

```php
class Test_My_Plugin extends WP_UnitTestCase {
    public function test_plugin_activation() {
        $this->assertTrue(is_plugin_active('my-plugin/my-plugin.php'));
    }
    
    public function test_custom_functionality() {
        // Your test code here
    }
}
```

## 📋 Code Quality

### WordPress Coding Standards

```bash
# Check coding standards
composer cs

# Fix coding standards automatically
composer cbf
```

### Configuration

The template includes a `phpcs.xml` configuration file that enforces:
- WordPress-Extra coding standards
- WordPress documentation standards
- PHP 8.1+ compatibility
- Custom prefix validation

## 🔧 API Usage

### Registering Custom Post Types

```php
// Simple registration
My_Plugin()->register_post_type(
    'product',
    __('Products', 'my-plugin'),
    __('Product', 'my-plugin')
);

// With custom options
My_Plugin()->register_post_type(
    'product',
    __('Products', 'my-plugin'),
    __('Product', 'my-plugin'),
    __('Custom product post type', 'my-plugin'),
    [
        'public' => true,
        'supports' => ['title', 'editor', 'thumbnail'],
        'has_archive' => true
    ]
);
```

### Registering Taxonomies

```php
// Simple registration
My_Plugin()->register_taxonomy(
    'product_category',
    __('Product Categories', 'my-plugin'),
    __('Product Category', 'my-plugin'),
    ['product']
);
```

### Settings Management

```php
// Get plugin options
$value = get_option('my_plugin_option_name');

// The plugin automatically prefixes options
// Check the settings class for the prefix being used
```

### WordPress Feature API (AI/LLM Integration)

The template includes built-in support for the [Automattic WordPress Feature API](https://github.com/automattic/wp-feature-api), enabling your plugin to work seamlessly with AI systems and LLM agents.

```php
// The Feature API is automatically loaded if available
// Access it through the main plugin instance
$plugin = My_Plugin();
if ( $plugin->feature_api && $plugin->feature_api->is_feature_api_available() ) {
    // Feature API is available
    $features = $plugin->feature_api->get_plugin_features();
}
```

#### Pre-built Features

The template includes several ready-to-use features:

- **Create Posts**: Allow AI agents to create content using your custom post types
- **List Post Types**: Provide information about available post types
- **Plugin Settings**: Enable AI access to plugin configuration

#### Custom Feature Registration

```php
// Register custom features for your plugin
add_action('wordpress_plugin_template_register_features', function($feature_api) {
    // Register a custom feature
    wp_feature_api_register_feature([
        'id' => 'my_plugin_custom_action',
        'name' => __('Custom Action', 'my-plugin'),
        'description' => __('Performs a custom action', 'my-plugin'),
        'category' => 'custom',
        'input_schema' => [
            'type' => 'object',
            'properties' => [
                'action_type' => [
                    'type' => 'string',
                    'description' => __('Type of action to perform', 'my-plugin')
                ]
            ]
        ],
        'callback' => 'my_custom_feature_callback',
        'is_eligible' => 'current_user_can_edit_posts'
    ]);
});
```

#### MCP Compatibility

Features registered through this template are compatible with the [Model Context Protocol (MCP)](https://modelcontextprotocol.io/), making them discoverable and usable by:

- **AI Assistants** (Claude, ChatGPT, etc.)
- **LLM Agents** and automation tools
- **WordPress AI plugins** and extensions
- **Custom MCP clients**

## 🏗️ Build Process

### Asset Building with Grunt

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

### Asset Structure

```
assets/
├── css/
│   ├── admin.css         # Admin styles
│   ├── admin.less        # Admin LESS source
│   ├── frontend.css      # Frontend styles
│   └── frontend.less     # Frontend LESS source
└── js/
    ├── admin.js          # Admin scripts
    ├── admin.min.js      # Minified admin scripts
    ├── frontend.js       # Frontend scripts
    └── frontend.min.js   # Minified frontend scripts
```

## 🚀 CI/CD with GitHub Actions

The template includes a comprehensive GitHub Actions workflow that:

- **Tests multiple PHP versions** (8.1, 8.2, 8.3)
- **Tests multiple WordPress versions** (latest, 6.0)
- **Runs coding standards checks**
- **Executes PHPUnit tests**
- **Provides test coverage reports**
- **Caches dependencies** for faster builds

### Workflow Configuration

The workflow is automatically created in `.github/workflows/ci.yml` and triggers on:
- Push to `main` and `develop` branches
- Pull requests to `main` and `develop` branches

## 📁 Directory Structure

```
my-plugin/
├── .github/
│   └── workflows/
│       └── ci.yml            # GitHub Actions workflow
├── assets/                   # Frontend assets
├── bin/
│   └── install-wp-tests.sh  # WordPress test setup
├── includes/
│   ├── lib/                 # Plugin libraries
│   ├── class-plugin.php     # Main plugin class
│   └── class-settings.php   # Settings class
├── lang/                    # Translation files
├── tests/
│   ├── unit/               # Unit tests
│   ├── integration/        # Integration tests
│   └── bootstrap.php       # Test bootstrap
├── vendor/                 # Composer dependencies
├── composer.json           # Composer configuration
├── phpcs.xml              # Coding standards config
├── phpunit.xml            # PHPUnit configuration
├── package.json           # Node.js dependencies
├── Gruntfile.js          # Grunt build configuration
├── my-plugin.php         # Main plugin file
└── README.md             # Plugin documentation
```

## 🔒 Security Best Practices

The template includes several security measures:

- **ABSPATH checks** in all PHP files
- **Nonce verification** in forms
- **Capability checks** for admin functions
- **Data sanitization** and validation
- **SQL injection prevention**
- **XSS protection**

## 🌐 Internationalization (i18n)

The template is translation-ready:

- **Text domains** properly set
- **POT file** included for translators
- **Load text domain** function
- **Proper string escaping**

```php
// Example usage
__('Hello World', 'my-plugin');
esc_html__('Safe Output', 'my-plugin');
sprintf(
    /* translators: %s: plugin name */
    __('Welcome to %s', 'my-plugin'),
    'My Plugin'
);
```

## 📝 Contributing

We welcome contributions! Please:

1. **Fork** the repository
2. **Create** a feature branch
3. **Follow** WordPress coding standards
4. **Write** tests for new features
5. **Submit** a pull request

### Development Setup

```bash
# Clone your fork
git clone https://github.com/yourusername/WordPress-Plugin-Template.git
cd WordPress-Plugin-Template

# Install dependencies
composer install
npm install

# Set up pre-commit hooks (optional)
composer require --dev dealerdirect/phpcodesniffer-composer-installer
```

## 📄 License

This template is released under the [GPL-2.0+ License](LICENSE). Feel free to use it for any project, commercial or personal.

## 🆘 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: [GitHub Issues](https://github.com/username/WordPress-Plugin-Template/issues)
- **Discussions**: [GitHub Discussions](https://github.com/username/WordPress-Plugin-Template/discussions)
- **WordPress Forums**: [WordPress Plugin Development](https://wordpress.org/support/forum/plugins/)

## 🎯 Roadmap

- [ ] **PHP 8.4** compatibility testing
- [ ] **Block editor** integration examples
- [ ] **REST API** endpoints template
- [ ] **WP-CLI** command examples
- [ ] **Docker** development environment
- [ ] **Automated** plugin submission tools

---

**Happy Plugin Development!** 🎉

*This template saves you hours of setup time and provides a solid foundation for professional WordPress plugin development.*
