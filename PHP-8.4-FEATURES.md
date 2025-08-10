# PHP 8.4 Compatibility Features

This template is tested for compatibility with PHP 8.4. Here are the key PHP 8.4 features and changes that you can safely use in your plugins created from this template.

## 🚀 New PHP 8.4 Features You Can Use

### Property Hooks (Read/Write)
PHP 8.4 introduces property hooks that allow you to define custom get and set logic:

```php
class WordPress_Plugin_Template_Settings {
    private string $_cached_option = '';
    
    // Virtual property with hooks
    public string $option {
        get {
            if (empty($this->_cached_option)) {
                $this->_cached_option = get_option('my_plugin_option', '');
            }
            return $this->_cached_option;
        }
        set {
            $this->_cached_option = $value;
            update_option('my_plugin_option', $value);
        }
    }
}
```

### Array Find Function
New array functions for finding elements:

```php
// Find first matching post type
$post_types = get_post_types(['public' => true]);
$first_public = array_find($post_types, fn($type) => $type !== 'attachment');

// Check if any post type matches condition
$has_custom = array_any($post_types, fn($type) => !in_array($type, ['post', 'page']));

// Check if all post types match condition
$all_public = array_all($post_types, fn($type) => is_post_type_viewable($type));
```

### Multibyte String Trim
Enhanced string handling for internationalization:

```php
class WordPress_Plugin_Template_Utils {
    public static function sanitize_multilingual_input(string $input): string {
        // Trim multibyte whitespace characters
        return mb_trim($input);
    }
    
    public static function clean_user_content(string $content): string {
        // Remove multibyte whitespace from both ends
        return mb_trim($content, " \t\n\r\0\x0B\xA0");
    }
}
```

### New Without Parentheses
Simplified object instantiation syntax:

```php
// Traditional way (still works)
$post_type = new WordPress_Plugin_Template_Post_Type();

// PHP 8.4 way - cleaner syntax
$taxonomy = new WordPress_Plugin_Template_Taxonomy;
$settings = new WordPress_Plugin_Template_Settings;
```

### Improved Type Declarations
Enhanced type system support:

```php
class WordPress_Plugin_Template_API {
    // More precise return types
    public function get_posts(): array|WP_Error {
        $posts = get_posts(['post_type' => $this->post_type]);
        return empty($posts) ? new WP_Error('no_posts', 'No posts found') : $posts;
    }
    
    // Better nullable handling
    public function get_option(string $key): ?string {
        $value = get_option($key);
        return $value !== false ? $value : null;
    }
}
```

## 🔧 Compatibility Testing

Our template includes comprehensive PHP 8.4 testing through:

### GitHub Actions Matrix
```yaml
strategy:
  matrix:
    php: ['8.1', '8.2', '8.3', '8.4']
    wp: ['latest', '6.0']
    exclude:
      # Exclude PHP 8.4 with older WordPress versions until better support
      - php: '8.4'
        wp: '6.0'
```

### PHPCS Configuration
```xml
<!-- Check for PHP compatibility -->
<rule ref="PHPCompatibilityWP"/>
<config name="testVersion" value="8.1-8.4"/>
```

### Composer Requirements
```json
{
    "require": {
        "php": ">=8.1"
    }
}
```

## 🛠️ Development Considerations

### Backward Compatibility
While using PHP 8.4 features, maintain compatibility with older versions:

```php
class WordPress_Plugin_Template_Compat {
    public function safe_array_find(array $array, callable $callback): mixed {
        // Use PHP 8.4 array_find if available
        if (function_exists('array_find')) {
            return array_find($array, $callback);
        }
        
        // Fallback for older PHP versions
        foreach ($array as $key => $value) {
            if ($callback($value, $key)) {
                return $value;
            }
        }
        return null;
    }
}
```

### WordPress Compatibility
Ensure WordPress compatibility when using modern PHP features:

```php
class WordPress_Plugin_Template_Modern {
    public function register_hooks(): void {
        // Use modern syntax while maintaining WP compatibility
        add_action('init', $this->init_plugin(...));
        add_filter('the_content', $this->filter_content(...));
    }
    
    private function init_plugin(): void {
        // Modern PHP 8.4 syntax
        $this->post_type = new WordPress_Plugin_Template_Post_Type;
        $this->settings = new WordPress_Plugin_Template_Settings;
    }
}
```

## 🔍 Static Analysis

The template supports modern static analysis tools:

```bash
# PHPStan with PHP 8.4 support
composer require --dev phpstan/phpstan
phpstan analyse --level=8 includes/

# Psalm with modern PHP features
composer require --dev vimeo/psalm
psalm --init
psalm
```

## 📚 Resources

- [PHP 8.4 Release Notes](https://www.php.net/releases/8.4/)
- [Property Hooks RFC](https://wiki.php.net/rfc/property-hooks)
- [Array Find RFC](https://wiki.php.net/rfc/array_find)
- [WordPress PHP Compatibility](https://make.wordpress.org/core/handbook/references/php-compatibility-and-wordpress-versions/)

## ⚠️ Important Notes

1. **WordPress Core Support**: While our template supports PHP 8.4, ensure WordPress core supports it in your target environment.

2. **Plugin Repository Requirements**: WordPress.org may have different PHP version requirements for submitted plugins.

3. **Hosting Compatibility**: Not all WordPress hosting providers support PHP 8.4 immediately upon release.

4. **Feature Flags**: Consider using feature detection for PHP 8.4-specific functionality:

```php
if (PHP_VERSION_ID >= 80400) {
    // Use PHP 8.4 features
} else {
    // Fallback implementation
}
```

## 🧪 Testing Your Plugin

When developing with PHP 8.4 features:

1. **Local Testing**: Use PHP 8.4 in your local development environment
2. **CI/CD Testing**: Our GitHub Actions test against PHP 8.4
3. **Compatibility Testing**: Test with older PHP versions for backward compatibility
4. **WordPress Testing**: Test with multiple WordPress versions

The template's automated testing ensures your plugin works correctly across all supported PHP versions while taking advantage of modern language features.
