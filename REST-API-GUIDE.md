# WordPress Plugin Template REST API Guide

This template includes a comprehensive REST API system that provides full CRUD operations, authentication, validation, and error handling. The API follows WordPress REST API conventions and best practices.

## 🚀 Quick Start

All REST API endpoints are available under the namespace:
```
/wp-json/wordpress-plugin-template/v1/
```

### Base URL Structure
```
https://yoursite.com/wp-json/wordpress-plugin-template/v1/endpoint
```

## 📋 Available Endpoints

### Plugin Information
- `GET /info` - Get plugin information (public)
- `GET /status` - Get plugin status (admin only)

### Settings Management
- `GET /settings` - Get all plugin settings (admin only)
- `POST /settings` - Update plugin settings (admin only)
- `GET /settings/{key}` - Get specific setting (admin only)

### Post Management (Custom Post Types)
- `GET /posts` - List posts with pagination and filtering
- `GET /posts/{id}` - Get specific post
- `POST /posts` - Create new post
- `PUT /posts/{id}` - Update existing post
- `DELETE /posts/{id}` - Delete post

### Batch Operations
- `POST /batch` - Process multiple requests in a single call (admin only)

## 🔐 Authentication & Permissions

### Authentication Methods

The REST API supports multiple authentication methods:

1. **WordPress Cookies** (for logged-in users)
2. **Application Passwords** (WordPress 5.6+)
3. **Basic Authentication** (with plugins)
4. **JWT Authentication** (with plugins)

### Permission Levels

- **Public**: No authentication required
- **User**: Requires logged-in user (`current_user_can('read')`)
- **Admin**: Requires administrator privileges (`current_user_can('manage_options')`)
- **Post-specific**: Requires specific post permissions (`current_user_can('read_post', $post_id)`)

## 📖 Detailed Endpoint Documentation

### Plugin Information

#### Get Plugin Info
```http
GET /wp-json/wordpress-plugin-template/v1/info
```

**Response:**
```json
{
  "name": "WordPress Plugin Template",
  "version": "1.0.0",
  "namespace": "wordpress-plugin-template/v1",
  "post_types": ["wordpress_plugin_template_item"],
  "taxonomies": ["wordpress_plugin_template_category"],
  "endpoints": {
    "info": {
      "GET /info": "Get plugin information"
    },
    "settings": {
      "GET /settings": "Get all settings"
    }
  }
}
```

#### Get Plugin Status
```http
GET /wp-json/wordpress-plugin-template/v1/status
```
*Requires: Admin permissions*

**Response:**
```json
{
  "active": true,
  "version": "1.0.0",
  "php_version": "8.2.0",
  "wp_version": "6.4.0",
  "rest_api_enabled": true,
  "post_count": {
    "publish": 15,
    "draft": 3,
    "private": 1
  },
  "settings_count": 8
}
```

### Settings Management

#### Get All Settings
```http
GET /wp-json/wordpress-plugin-template/v1/settings
```
*Requires: Admin permissions*

**Response:**
```json
{
  "text_field": "Sample text",
  "checkbox_field": true,
  "select_field": "option1",
  "number_field": 42
}
```

#### Update Settings
```http
POST /wp-json/wordpress-plugin-template/v1/settings
Content-Type: application/json
```
*Requires: Admin permissions*

**Request Body:**
```json
{
  "text_field": "Updated text",
  "checkbox_field": false,
  "number_field": 100
}
```

**Response:**
```json
{
  "success": true,
  "message": "Settings updated successfully",
  "data": {
    "text_field": "Updated text",
    "checkbox_field": false,
    "select_field": "option1",
    "number_field": 100
  }
}
```

#### Get Specific Setting
```http
GET /wp-json/wordpress-plugin-template/v1/settings/text_field
```
*Requires: Admin permissions*

**Response:**
```json
{
  "key": "text_field",
  "value": "Sample text"
}
```

### Post Management

#### List Posts
```http
GET /wp-json/wordpress-plugin-template/v1/posts
```

**Query Parameters:**
- `page` (int) - Page number (default: 1)
- `per_page` (int) - Items per page (default: 10, max: 100)
- `search` (string) - Search term
- `orderby` (string) - Sort field: date, title, modified, menu_order
- `order` (string) - Sort direction: ASC, DESC
- `meta_key` (string) - Meta key to filter by
- `meta_value` (string) - Meta value to filter by
- `meta_compare` (string) - Meta comparison operator: =, !=, >, >=, <, <=, LIKE, NOT LIKE

**Example:**
```http
GET /wp-json/wordpress-plugin-template/v1/posts?page=1&per_page=5&orderby=title&order=ASC
```

**Response:**
```json
[
  {
    "id": 123,
    "title": "Sample Post",
    "content": "Post content here",
    "excerpt": "Post excerpt",
    "status": "publish",
    "date": "2024-01-15T10:30:00",
    "date_gmt": "2024-01-15T15:30:00",
    "modified": "2024-01-16T09:15:00",
    "modified_gmt": "2024-01-16T14:15:00",
    "author": 1,
    "slug": "sample-post",
    "link": "https://example.com/sample-post/",
    "meta": {
      "custom_field": "custom_value"
    }
  }
]
```

**Headers:**
- `X-WP-Total`: Total number of posts
- `X-WP-TotalPages`: Total number of pages

#### Get Single Post
```http
GET /wp-json/wordpress-plugin-template/v1/posts/123
```

**Response:** Same structure as individual post in list

#### Create Post
```http
POST /wp-json/wordpress-plugin-template/v1/posts
Content-Type: application/json
```
*Requires: Create post permissions*

**Request Body:**
```json
{
  "title": "New Post Title",
  "content": "Post content goes here",
  "status": "publish",
  "meta": {
    "custom_field": "custom_value",
    "another_field": "another_value"
  }
}
```

**Response:** (201 Created)
```json
{
  "id": 124,
  "title": "New Post Title",
  "content": "Post content goes here",
  "status": "publish",
  // ... full post data
}
```

#### Update Post
```http
PUT /wp-json/wordpress-plugin-template/v1/posts/123
Content-Type: application/json
```
*Requires: Edit post permissions*

**Request Body:**
```json
{
  "title": "Updated Post Title",
  "content": "Updated content",
  "meta": {
    "custom_field": "updated_value"
  }
}
```

**Response:** Full updated post data

#### Delete Post
```http
DELETE /wp-json/wordpress-plugin-template/v1/posts/123
```
*Requires: Delete post permissions*

**Query Parameters:**
- `force` (boolean) - Whether to force delete (skip trash)

**Response:**
```json
{
  "deleted": true,
  "previous": {
    // Previous post data before deletion
  }
}
```

### Batch Operations

#### Process Batch Requests
```http
POST /wp-json/wordpress-plugin-template/v1/batch
Content-Type: application/json
```
*Requires: Admin permissions*

**Request Body:**
```json
{
  "requests": [
    {
      "method": "GET",
      "path": "/wp-json/wordpress-plugin-template/v1/posts/123"
    },
    {
      "method": "POST",
      "path": "/wp-json/wordpress-plugin-template/v1/posts",
      "body": {
        "title": "Batch Created Post",
        "content": "Created via batch API"
      }
    },
    {
      "method": "PUT",
      "path": "/wp-json/wordpress-plugin-template/v1/posts/124",
      "body": {
        "title": "Updated via Batch"
      }
    }
  ]
}
```

**Response:**
```json
{
  "0": {
    "status": 200,
    "headers": {},
    "data": {
      // Post 123 data
    }
  },
  "1": {
    "status": 201,
    "headers": {},
    "data": {
      // New post data
    }
  },
  "2": {
    "status": 200,
    "headers": {},
    "data": {
      // Updated post data
    }
  }
}
```

## 🛡️ Error Handling

### Standard Error Response Format
```json
{
  "code": "error_code",
  "message": "Human-readable error message",
  "data": {
    "status": 400
  }
}
```

### Common Error Codes

#### Authentication Errors
- `rest_forbidden` (403) - Insufficient permissions
- `rest_not_logged_in` (401) - Authentication required

#### Validation Errors
- `rest_invalid_param` (400) - Invalid parameter value
- `rest_missing_callback_param` (400) - Required parameter missing

#### Custom Plugin Errors
- `no_settings` (404) - No settings found
- `setting_not_found` (404) - Specific setting not found
- `post_not_found` (404) - Post not found
- `invalid_settings` (400) - Invalid settings data
- `settings_update_failed` (400) - Settings update failed
- `cant_delete` (500) - Cannot delete post

### Example Error Response
```json
{
  "code": "post_not_found",
  "message": "Post not found",
  "data": {
    "status": 404
  }
}
```

## 🧪 Testing the API

### Using curl

#### Get Plugin Info
```bash
curl -X GET https://yoursite.com/wp-json/wordpress-plugin-template/v1/info
```

#### Create a Post (with authentication)
```bash
curl -X POST https://yoursite.com/wp-json/wordpress-plugin-template/v1/posts \
  -H "Content-Type: application/json" \
  -u username:application_password \
  -d '{
    "title": "API Test Post",
    "content": "This post was created via the REST API"
  }'
```

### Using WordPress JavaScript

```javascript
// Get plugin info
wp.apiFetch({
  path: '/wordpress-plugin-template/v1/info'
}).then(data => {
  console.log('Plugin info:', data);
});

// Create a post
wp.apiFetch({
  path: '/wordpress-plugin-template/v1/posts',
  method: 'POST',
  data: {
    title: 'JavaScript Created Post',
    content: 'This post was created using wp.apiFetch'
  }
}).then(post => {
  console.log('Created post:', post);
});

// Update settings (admin only)
wp.apiFetch({
  path: '/wordpress-plugin-template/v1/settings',
  method: 'POST',
  data: {
    text_field: 'Updated via JavaScript',
    checkbox_field: true
  }
}).then(response => {
  console.log('Settings updated:', response);
});
```

### Using PHP

```php
// Get plugin info
$response = wp_remote_get('https://yoursite.com/wp-json/wordpress-plugin-template/v1/info');
$data = json_decode(wp_remote_retrieve_body($response), true);

// Create a post with authentication
$response = wp_remote_post('https://yoursite.com/wp-json/wordpress-plugin-template/v1/posts', [
    'headers' => [
        'Authorization' => 'Basic ' . base64_encode('username:application_password'),
        'Content-Type' => 'application/json'
    ],
    'body' => json_encode([
        'title' => 'PHP Created Post',
        'content' => 'This post was created using PHP'
    ])
]);

$post = json_decode(wp_remote_retrieve_body($response), true);
```

## 🔌 Extending the API

### Adding Custom Endpoints

```php
// Add custom endpoint via action hook
add_action('wordpress_plugin_template_rest_api_register_routes', function($rest_api) {
    register_rest_route('wordpress-plugin-template/v1', '/custom-endpoint', [
        'methods' => 'GET',
        'callback' => 'my_custom_endpoint_callback',
        'permission_callback' => '__return_true'
    ]);
});

function my_custom_endpoint_callback($request) {
    return rest_ensure_response([
        'message' => 'Custom endpoint response',
        'data' => get_custom_data()
    ]);
}
```

### Filtering API Responses

```php
// Filter post data in API responses
add_filter('wordpress_plugin_template_rest_prepare_post', function($data, $post, $request) {
    // Add custom field to API response
    $data['custom_field'] = get_post_meta($post->ID, 'my_custom_field', true);
    
    // Remove sensitive data for non-admin users
    if (!current_user_can('manage_options')) {
        unset($data['meta']['private_field']);
    }
    
    return $data;
}, 10, 3);
```

## 🔒 Security Best Practices

### Input Validation
- All input is validated and sanitized using WordPress functions
- Schema validation ensures correct data types
- Custom validation for specific field types

### Permission Checks
- Granular permissions for different operations
- Post-level permission checking
- Admin-only endpoints for sensitive operations

### Rate Limiting
Consider implementing rate limiting for production use:

```php
// Example rate limiting (requires additional implementation)
add_action('rest_api_init', function() {
    if (!apply_filters('wordpress_plugin_template_rate_limit_check', true)) {
        wp_die('Rate limit exceeded', 'Too Many Requests', ['response' => 429]);
    }
});
```

### CORS Configuration
For cross-origin requests, configure CORS headers:

```php
add_action('rest_api_init', function() {
    remove_filter('rest_pre_serve_request', 'rest_send_cors_headers');
    add_filter('rest_pre_serve_request', function($value) {
        header('Access-Control-Allow-Origin: https://trusted-domain.com');
        header('Access-Control-Allow-Methods: GET, POST, PUT, DELETE');
        header('Access-Control-Allow-Headers: Authorization, Content-Type');
        return $value;
    });
});
```

## 📊 Response Formats

### Success Responses
- `200 OK` - Successful GET, PUT, DELETE
- `201 Created` - Successful POST
- `204 No Content` - Successful DELETE with no body

### Pagination Headers
```http
X-WP-Total: 150
X-WP-TotalPages: 15
```

### Data Format Consistency
All timestamps use ISO 8601 format:
```json
{
  "date": "2024-01-15T10:30:00",
  "date_gmt": "2024-01-15T15:30:00"
}
```

## 🚀 Performance Optimization

### Caching
Consider implementing caching for frequently accessed endpoints:

```php
// Example caching implementation
add_filter('wordpress_plugin_template_rest_cache_key', function($cache_key, $request) {
    return 'wpt_api_' . md5(serialize($request->get_params()));
}, 10, 2);
```

### Database Optimization
- Use efficient database queries
- Implement proper indexing for custom meta fields
- Consider pagination limits for large datasets

### Response Optimization
- Only include necessary data in responses
- Use field filtering for large objects
- Implement response compression

This REST API system provides a solid foundation for building modern WordPress plugins with full API capabilities. It follows WordPress best practices and provides extensive customization options for your specific needs.
