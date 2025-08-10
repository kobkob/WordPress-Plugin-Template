# 🐳 Docker Development Environment

This WordPress Plugin Template includes a comprehensive Docker development environment that provides everything you need to develop, test, and debug WordPress plugins efficiently.

## 🚀 Quick Start

### Prerequisites

- **Docker** (20.10.0+)
- **Docker Compose** (2.0.0+)
- **Git**

### Start Development Environment

```bash
# Clone the repository
git clone https://github.com/kobkob/WordPress-Plugin-Template.git
cd WordPress-Plugin-Template

# Start the development environment
docker-compose up -d

# Wait for services to start (about 30-60 seconds)
docker-compose logs -f wordpress

# Set up WordPress for development
docker-compose exec wp-cli wp-dev-setup
```

### Access Your Environment

- **WordPress**: http://localhost:8000
- **WordPress Admin**: http://localhost:8000/wp-admin
- **phpMyAdmin**: http://localhost:8080
- **Database**: `wordpress` / `wordpress_password`
- **Development User**: `dev-user` / `dev123`

## 🏗️ Services Overview

### Core Services

| Service | Port | Description |
|---------|------|-------------|
| **wordpress** | 8000 | WordPress with PHP 8.3, Xdebug, development tools |
| **db** | 3306 | MySQL 8.0 database server |
| **phpmyadmin** | 8080 | Database management interface |
| **wp-cli** | - | WordPress CLI for management tasks |

### Optional Services (Profiles)

| Service | Port | Profile | Description |
|---------|------|---------|-------------|
| **redis** | 6379 | `cache` | Redis caching server |
| **mailhog** | 8025, 1025 | `mail` | Email testing service |
| **node** | - | `assets` | Node.js for asset building |

### Enable Optional Services

```bash
# Enable caching with Redis
docker-compose --profile cache up -d

# Enable email testing
docker-compose --profile mail up -d

# Enable asset building
docker-compose --profile assets up -d

# Enable all profiles
docker-compose --profile cache --profile mail --profile assets up -d
```

## 🔧 Development Features

### PHP Development

- **PHP 8.3** with all necessary extensions
- **Xdebug 3.x** configured for step debugging
- **Composer** for dependency management
- **Error reporting** enabled for development
- **Memory limit**: 512M
- **Upload limit**: 64M

### WordPress Configuration

- **Debug mode** enabled by default
- **Query debugging** with SAVEQUERIES
- **Development plugins** pre-installed:
  - Query Monitor
  - Debug Bar
  - Developer
  - Theme Check

### Database Management

- **Multiple databases**: `wordpress`, `wordpress_test`, `wordpress_staging`
- **phpMyAdmin** for visual database management
- **Optimized** MySQL configuration for development

## 🐛 Debugging

### Xdebug Setup

The environment comes with Xdebug 3.x pre-configured:

```ini
; Xdebug is configured to:
xdebug.mode=debug,develop,profile
xdebug.client_host=host.docker.internal
xdebug.client_port=9003
xdebug.idekey=PHPSTORM
```

### IDE Configuration

#### PhpStorm

1. Go to **Settings** → **PHP** → **Debug**
2. Set Xdebug port to `9003`
3. Go to **Settings** → **PHP** → **Servers**
4. Add server:
   - Name: `Docker`
   - Host: `localhost`
   - Port: `8000`
   - Debugger: `Xdebug`
   - Use path mappings: ✅
   - Map your project root to `/var/www/html/wp-content/plugins/wordpress-plugin-template`

#### VS Code

Install the **PHP Debug** extension and add to `.vscode/launch.json`:

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Listen for Xdebug (Docker)",
            "type": "php",
            "request": "launch",
            "port": 9003,
            "pathMappings": {
                "/var/www/html/wp-content/plugins/wordpress-plugin-template": "${workspaceFolder}"
            }
        }
    ]
}
```

### Profiling

Xdebug profiling is enabled. Profile files are saved to `/tmp` inside the container:

```bash
# Access profile files
docker-compose exec wordpress ls -la /tmp/cachegrind.out.*

# Copy profile files to host
docker-compose cp wordpress:/tmp/cachegrind.out.123456-789 ./
```

## 🧪 Testing

### PHPUnit Tests

```bash
# Install test suite
docker-compose exec wp-cli bash -c "cd /var/www/html/wp-content/plugins/wordpress-plugin-template && ./bin/install-wp-tests.sh wordpress_test root root_password db latest"

# Run tests
docker-compose exec wp-cli bash -c "cd /var/www/html/wp-content/plugins/wordpress-plugin-template && composer test"

# Run specific test suite
docker-compose exec wp-cli bash -c "cd /var/www/html/wp-content/plugins/wordpress-plugin-template && vendor/bin/phpunit tests/unit"
```

### Code Quality

```bash
# Check coding standards
docker-compose exec wp-cli bash -c "cd /var/www/html/wp-content/plugins/wordpress-plugin-template && composer cs"

# Fix coding standards
docker-compose exec wp-cli bash -c "cd /var/www/html/wp-content/plugins/wordpress-plugin-template && composer cbf"
```

## 📋 Common Commands

### WordPress Management

```bash
# WordPress CLI commands
docker-compose exec wp-cli wp --allow-root core version
docker-compose exec wp-cli wp --allow-root plugin list
docker-compose exec wp-cli wp --allow-root user list

# Install plugins
docker-compose exec wp-cli wp --allow-root plugin install woocommerce --activate

# Create sample content
docker-compose exec wp-cli wp --allow-root post generate --count=10

# Flush rewrite rules
docker-compose exec wp-cli wp --allow-root rewrite flush

# Search and replace URLs
docker-compose exec wp-cli wp --allow-root search-replace 'oldurl.com' 'newurl.com'
```

### Container Management

```bash
# View logs
docker-compose logs -f wordpress
docker-compose logs -f db

# Execute commands in containers
docker-compose exec wordpress bash
docker-compose exec wp-cli bash

# Restart services
docker-compose restart wordpress
docker-compose restart db

# Stop all services
docker-compose down

# Stop and remove volumes (⚠️ destroys data)
docker-compose down -v
```

### Database Operations

```bash
# Backup database
docker-compose exec db mysqldump -u wordpress -pwordpress_password wordpress > backup.sql

# Restore database
docker-compose exec -T db mysql -u wordpress -pwordpress_password wordpress < backup.sql

# Access MySQL directly
docker-compose exec db mysql -u wordpress -pwordpress_password wordpress
```

## 📁 File Structure

```
├── docker/
│   ├── Dockerfile.wordpress     # WordPress container with dev tools
│   ├── Dockerfile.wp-cli        # WP-CLI container
│   ├── apache-wordpress.conf    # Apache configuration
│   ├── php-wordpress.ini        # PHP configuration
│   ├── xdebug.ini              # Xdebug configuration
│   ├── uploads.ini             # File upload settings
│   ├── mysql-init.sql          # Database initialization
│   └── wp-dev-setup.sh         # WordPress dev setup script
├── docker-compose.yml          # Main compose configuration
└── DOCKER.md                   # This documentation
```

## 🔧 Customization

### Environment Variables

Create a `.env` file to customize settings:

```env
# Database Configuration
MYSQL_DATABASE=wordpress
MYSQL_USER=wordpress
MYSQL_PASSWORD=your_secure_password
MYSQL_ROOT_PASSWORD=your_root_password

# WordPress Configuration
WP_DEBUG=true
WP_DEBUG_LOG=true
WP_DEBUG_DISPLAY=true

# Port Configuration
WP_PORT=8000
PMA_PORT=8080
DB_PORT=3306

# PHP Configuration
PHP_VERSION=8.3
```

### Custom PHP Configuration

Add custom PHP settings to `docker/php-wordpress.ini`:

```ini
; Your custom PHP settings
max_execution_time = 600
memory_limit = 1024M
```

### Custom WordPress Configuration

Extend the WordPress configuration in `docker-compose.yml`:

```yaml
environment:
  WORDPRESS_CONFIG_EXTRA: |
    define('WP_DEBUG', true);
    define('YOUR_CUSTOM_CONSTANT', 'value');
```

## 🚀 Performance Tips

### Development Optimizations

1. **Use Docker volumes** for persistent data
2. **Enable OPcache** (already configured)
3. **Use Redis** caching (enable with `--profile cache`)
4. **Optimize MySQL** (already configured)

### Host System Optimizations

```bash
# Increase Docker resources (Docker Desktop)
# - Memory: 4GB+
# - CPU: 2+ cores
# - Disk space: 10GB+

# Linux: Optimize Docker performance
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

## 🔧 Troubleshooting

### Common Issues

#### Port Already in Use
```bash
# Check what's using the port
lsof -i :8000

# Use different port
WP_PORT=8001 docker-compose up -d
```

#### Database Connection Issues
```bash
# Wait for database to be ready
docker-compose exec db mysqladmin ping -h localhost -u root -proot_password

# Reset database
docker-compose down
docker volume rm wordpress-plugin-template_db_data
docker-compose up -d
```

#### WordPress Installation Issues
```bash
# Reinstall WordPress
docker-compose exec wp-cli wp --allow-root core download --force
docker-compose exec wp-cli wp --allow-root core install --url="http://localhost:8000" --title="Dev Site" --admin_user="admin" --admin_password="admin" --admin_email="admin@example.com"
```

#### Xdebug Not Working
```bash
# Check Xdebug status
docker-compose exec wordpress php -m | grep -i xdebug

# Verify Xdebug configuration
docker-compose exec wordpress php -i | grep -i xdebug

# Check IDE configuration
# - Port: 9003
# - Path mappings: /var/www/html/wp-content/plugins/wordpress-plugin-template → your-project-path
```

#### File Permission Issues
```bash
# Fix file permissions
docker-compose exec wordpress chown -R www-data:www-data /var/www/html
docker-compose exec wordpress chmod -R 755 /var/www/html
```

### Getting Help

- **Docker logs**: `docker-compose logs -f [service]`
- **Container shell**: `docker-compose exec [service] bash`
- **WordPress debug log**: Check `/wp-content/debug.log`
- **PHP error log**: `docker-compose logs wordpress | grep "PHP"`

## 🔒 Security Notes

⚠️ **This environment is for DEVELOPMENT ONLY**

- Default passwords are used for convenience
- Debug mode exposes sensitive information
- Services are accessible without authentication
- Never use in production

## 📚 Next Steps

1. **Customize** the environment for your needs
2. **Install** your preferred IDE extensions
3. **Configure** your debugging workflow  
4. **Set up** automated testing
5. **Create** your plugin with the enhanced template

Happy developing! 🎉
