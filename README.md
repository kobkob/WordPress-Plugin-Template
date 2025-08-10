# WordPress Plugin Template 🚀

A modern, robust, and GPL-licensed code template for creating standards-compliant WordPress plugins with professional development practices.

[![CI](https://github.com/kobkob/WordPress-Plugin-Template/actions/workflows/ci.yml/badge.svg)](https://github.com/kobkob/WordPress-Plugin-Template/actions/workflows/ci.yml)
[![PHP Version](https://img.shields.io/badge/PHP-8.1%2B-blue.svg)](https://php.net)
[![WordPress Version](https://img.shields.io/badge/WordPress-6.0%2B-blue.svg)](https://wordpress.org)
[![License](https://img.shields.io/badge/License-GPL--3.0%2B-green.svg)](LICENSE)

## ⚡ **TL;DR - Get Started in 30 Seconds**

```bash
# Create a modern WordPress plugin with all features in one command
curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash
```

Included: PHPUnit Tests ✅ Docker Environment ✅ GitHub Actions ✅ Agile/XP Framework ✅ REST API ✅ AI Integration ✅

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
- **Agile/XP methodology** with sprint management and TDD workflow

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
- **REST API** endpoints with full CRUD operations
- **Asset management** with proper enqueuing

### Frontend Assets
- **Grunt.js** build system
- **LESS** preprocessing
- **JavaScript minification**
- **CSS optimization**
- **Development and production builds**

## 🚀 Quick Start

### One-liner Installation

The fastest way to get started is with our one-liner installer:

```bash
# Interactive installation
curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash
```

#### Non-interactive Installation

For automated setups or CI/CD pipelines:

```bash
# Non-interactive installation with all features
curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash -s -- \
  --name "My Awesome Plugin" \
  --dir ./my-awesome-plugin \
  --non-interactive
```

#### Installation Options

```bash
# Show help and options
curl -sSL https://raw.githubusercontent.com/kobkob/WordPress-Plugin-Template/refs/heads/master/install.sh | bash -s -- --help
```

**Available Options:**
- `--name NAME` - Plugin name (e.g., 'My Awesome Plugin')
- `--dir DIRECTORY` - Destination directory
- `--non-interactive` - Skip interactive prompts (requires --name and --dir)
- `--help, -h` - Show help message

#### Automatic Dependency Installation 🔧

The installer automatically detects and installs missing dependencies on supported systems:

- **Ubuntu/Debian**: Uses `apt-get` package manager
- **RHEL/CentOS**: Uses `yum` package manager
- **Fedora**: Uses `dnf` package manager
- **Arch Linux**: Uses `pacman` package manager
- **Alpine Linux**: Uses `apk` package manager
- **macOS**: Uses Homebrew (installs it first if missing)
- **Windows**: Provides manual installation instructions

**Auto-installed dependencies:**
- PHP 8.1+ with required extensions (curl, zip, xml, mbstring)
- Composer (latest stable version)
- Node.js LTS + npm
- Git version control
- curl for downloads

For unsupported systems, the installer provides clear manual installation instructions.

The one-liner installer automatically includes all modern features:
- ✅ PHPUnit tests and WordPress Coding Standards
- ✅ GitHub Actions CI/CD pipeline
- ✅ Docker development environment
- ✅ REST API endpoints and WordPress Feature API
- ✅ Agile/XP methodology framework
- ✅ Complete dependency setup

### Prerequisites

The one-liner installer automatically installs missing dependencies on supported systems. For manual setup or unsupported systems, ensure you have:

- **PHP 8.1+** with required extensions (curl, zip, xml, mbstring)
- **Composer** for dependency management
- **Node.js & NPM** for asset building
- **Git** for version control
- **curl** for downloads

### Using the Enhanced Creation Script (Alternative)

The enhanced `create-plugin.sh` script automates the entire setup process:

```bash
# Clone this repository
git clone https://github.com/kobkob/WordPress-Plugin-Template.git
cd WordPress-Plugin-Template

# Run the creation script
./create-plugin.sh
```

The script will guide you through:
1. **Plugin Information**: Name, description, author details
2. **Development Setup**: PHPUnit tests, PHPCS, GitHub Actions
3. **API Integration**: WordPress Feature API, REST API endpoints
4. **Docker Environment**: Complete containerized development setup
5. **File Generation**: All necessary config files and boilerplate
6. **Dependency Installation**: Composer packages
7. **Git Initialization**: Clean repository setup

### Docker Development Environment

For the quickest setup, use the included Docker environment:

```bash
# After running create-plugin.sh with Docker option
cd your-plugin-directory

# Start the development environment
docker-compose up -d

# Access your WordPress development site
open http://localhost:8000
```

See [DOCKER.md](DOCKER.md) for complete documentation.

### Agile/XP Development Methodology

The template includes a complete Agile/XP workflow framework for professional plugin development:

```bash
# After creating your plugin with Agile framework
cd your-plugin-directory

# Start your first sprint
./agile/scripts/start-sprint.sh

# Use AI assistance for development
./agile/scripts/ai-implement.sh
```

See [AGILE-GUIDE.md](AGILE-GUIDE.md) for the complete methodology guide.

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

### REST API Endpoints

The template includes a comprehensive REST API system with full CRUD operations, authentication, and validation:

```php
// Access the REST API through the main plugin instance
$plugin = My_Plugin();
if ( $plugin->rest_api ) {
    // REST API is available at /wp-json/my-plugin/v1/
    // See REST-API-GUIDE.md for complete documentation
}
```

#### Available Endpoints

- **Plugin Info**: `GET /info` - Get plugin information
- **Settings**: `GET|POST /settings` - Manage plugin settings
- **Posts**: `GET|POST|PUT|DELETE /posts` - Full CRUD for custom post types
- **Batch**: `POST /batch` - Process multiple requests

#### Example Usage

```javascript
// Create a new post via REST API
wp.apiFetch({
  path: '/my-plugin/v1/posts',
  method: 'POST',
  data: {
    title: 'API Created Post',
    content: 'This post was created via the REST API',
    meta: {
      custom_field: 'custom_value'
    }
  }
}).then(post => {
  console.log('Created post:', post);
});

// Update plugin settings
wp.apiFetch({
  path: '/my-plugin/v1/settings',
  method: 'POST',
  data: {
    text_field: 'Updated value',
    checkbox_field: true
  }
}).then(response => {
  console.log('Settings updated:', response);
});
```

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

- **Tests multiple PHP versions** (8.1, 8.2, 8.3, 8.4)
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
├── agile/                   # Agile/XP methodology framework
│   ├── scripts/            # Automation scripts
│   ├── templates/          # User story & sprint templates
│   ├── docs/              # Methodology documentation
│   └── ai/                # AI collaboration prompts
├── assets/                  # Frontend assets
├── bin/
│   └── install-wp-tests.sh # WordPress test setup
├── includes/
│   ├── lib/                # Plugin libraries
│   ├── class-plugin.php    # Main plugin class
│   └── class-settings.php  # Settings class
├── lang/                   # Translation files
├── tests/
│   ├── unit/              # Unit tests
│   ├── integration/       # Integration tests
│   └── bootstrap.php      # Test bootstrap
├── vendor/                # Composer dependencies
├── composer.json          # Composer configuration
├── phpcs.xml             # Coding standards config
├── phpunit.xml           # PHPUnit configuration
├── package.json          # Node.js dependencies
├── Gruntfile.js         # Grunt build configuration
├── AGILE-GUIDE.md       # Agile methodology guide
├── my-plugin.php        # Main plugin file
└── README.md            # Plugin documentation
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
git clone https://github.com/kobkob/WordPress-Plugin-Template.git
cd WordPress-Plugin-Template

# Install dependencies
composer install
npm install

# Set up pre-commit hooks (optional)
composer require --dev dealerdirect/phpcodesniffer-composer-installer
```

## 📄 License

This template is released under the [GPL-3.0+ License](LICENSE). Feel free to use it for any project, commercial or personal.

## 🆘 Support

- **Documentation**: Check this README and inline code comments
- **Issues**: [GitHub Issues](https://github.com/kobkob/WordPress-Plugin-Template/issues)
- **Discussions**: [GitHub Discussions](https://github.com/kobkob/WordPress-Plugin-Template/discussions)
- **WordPress Forums**: [WordPress Plugin Development](https://wordpress.org/support/forum/plugins/)

## 🎯 Roadmap

- [x] **PHP 8.4** compatibility testing
- [x] **REST API** endpoints template
- [x] **Docker** development environment
- [x] **Agile/XP** methodology with TDD and sprint management
- [ ] **Block editor** integration examples
- [ ] **WP-CLI** command examples
- [ ] **Automated** plugin submission tools

---

**Happy Plugin Development!** 🎉

*This template saves you hours of setup time and provides a solid foundation for professional WordPress plugin development.*
