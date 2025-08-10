#!/bin/bash

# WordPress Development Setup Script
# This script helps set up a development environment with useful plugins and configurations

set -e

echo "🚀 Setting up WordPress for plugin development..."

# Wait for WordPress to be ready
while ! wp --allow-root core is-installed 2>/dev/null; do
    echo "⏳ Waiting for WordPress to be installed..."
    sleep 5
done

echo "✅ WordPress is ready!"

# Install development plugins
echo "📦 Installing development plugins..."

# Query Monitor for debugging
if ! wp --allow-root plugin is-installed query-monitor; then
    wp --allow-root plugin install query-monitor --activate
    echo "✅ Query Monitor installed and activated"
fi

# Debug Bar
if ! wp --allow-root plugin is-installed debug-bar; then
    wp --allow-root plugin install debug-bar --activate
    echo "✅ Debug Bar installed and activated"
fi

# Developer plugin for additional development tools
if ! wp --allow-root plugin is-installed developer; then
    wp --allow-root plugin install developer --activate
    echo "✅ Developer plugin installed and activated"
fi

# Theme Check for theme development
if ! wp --allow-root plugin is-installed theme-check; then
    wp --allow-root plugin install theme-check --activate
    echo "✅ Theme Check installed and activated"
fi

# Configure WordPress for development
echo "⚙️ Configuring WordPress for development..."

# Set timezone
wp --allow-root option update timezone_string 'UTC'

# Set permalink structure
wp --allow-root rewrite structure '/%postname%/' --hard

# Flush rewrite rules
wp --allow-root rewrite flush --hard

# Create development pages
echo "📄 Creating development pages..."

# Create a test page if it doesn't exist
if ! wp --allow-root post exists --post_type=page --post_title="Plugin Test Page"; then
    wp --allow-root post create --post_type=page --post_title="Plugin Test Page" --post_content="<h1>Plugin Test Page</h1><p>This page is for testing plugin functionality.</p>" --post_status=publish
    echo "✅ Plugin Test Page created"
fi

# Create sample posts for testing
echo "📝 Creating sample content..."

for i in {1..5}; do
    title="Sample Post $i"
    if ! wp --allow-root post exists --post_title="$title"; then
        wp --allow-root post create --post_title="$title" --post_content="<p>This is sample content for testing. Lorem ipsum dolor sit amet, consectetur adipiscing elit.</p>" --post_status=publish --post_author=1
    fi
done

echo "✅ Sample posts created"

# Set up development user
echo "👤 Setting up development user..."

if ! wp --allow-root user get dev-user --field=ID 2>/dev/null; then
    wp --allow-root user create dev-user developer@example.com --role=administrator --user_pass=dev123 --display_name="Developer" --first_name="Dev" --last_name="User"
    echo "✅ Development user created (username: dev-user, password: dev123)"
else
    echo "✅ Development user already exists"
fi

echo "🎉 WordPress development setup complete!"
echo ""
echo "📋 Development Information:"
echo "  • WordPress URL: http://localhost:8000"
echo "  • Admin URL: http://localhost:8000/wp-admin"
echo "  • phpMyAdmin: http://localhost:8080"
echo "  • Database: wordpress / wordpress_password"
echo "  • Dev User: dev-user / dev123"
echo "  • Mail Testing: http://localhost:8025 (if mailhog profile is enabled)"
echo ""
echo "🔧 Useful Commands:"
echo "  • docker-compose exec wp-cli wp --allow-root [command]"
echo "  • docker-compose exec wordpress bash"
echo "  • docker-compose logs -f wordpress"
echo ""
