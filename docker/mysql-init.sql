-- MySQL initialization script for WordPress development

-- Create additional databases for testing
CREATE DATABASE IF NOT EXISTS wordpress_test CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE DATABASE IF NOT EXISTS wordpress_staging CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- Grant permissions
GRANT ALL PRIVILEGES ON wordpress_test.* TO 'wordpress'@'%';
GRANT ALL PRIVILEGES ON wordpress_staging.* TO 'wordpress'@'%';

-- Flush privileges
FLUSH PRIVILEGES;

-- Optimize MySQL for development
SET GLOBAL innodb_buffer_pool_size = 128 * 1024 * 1024;
SET GLOBAL max_connections = 200;
SET GLOBAL wait_timeout = 28800;
