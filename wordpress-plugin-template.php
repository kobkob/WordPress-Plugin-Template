<?php
/*
 * Plugin Name: WordPress Plugin Template
 * Version: 1.0
 * Plugin URI: https://github.com/kobkob/WordPress-Plugin-Template
 * Description: This is your starter template for your next WordPress plugin.
 * Author: Hugh Lashbrooke
 * Author URI: http://www.hughlashbrooke.com/
 * Requires at least: 4.0
 * Tested up to: 4.0
 *
 * Text Domain: wordpress-plugin-template
 * Domain Path: /lang/
 *
 * @package WordPress
 * @author Hugh Lashbrooke
 * @since 1.0.0
 */

if ( ! defined( 'ABSPATH' ) ) exit;

// Load plugin class files
require_once( 'includes/class-wordpress-plugin-template.php' );
require_once( 'includes/class-wordpress-plugin-template-settings.php' );

// Load plugin libraries
require_once( 'includes/lib/class-wordpress-plugin-template-admin-api.php' );
require_once( 'includes/lib/class-wordpress-plugin-template-post-type.php' );
require_once( 'includes/lib/class-wordpress-plugin-template-taxonomy.php' );
require_once( 'includes/lib/class-wordpress-plugin-template-feature-api.php' );
require_once( 'includes/lib/class-wordpress-plugin-template-rest-api.php' );

// Load WordPress Feature API if available
if ( file_exists( __DIR__ . '/vendor/automattic/wp-feature-api/wp-feature-api.php' ) ) {
	require_once( __DIR__ . '/vendor/automattic/wp-feature-api/wp-feature-api.php' );
}

/**
 * Returns the main instance of WordPress_Plugin_Template to prevent the need to use globals.
 *
 * @since  1.0.0
 * @return object WordPress_Plugin_Template
 */
function WordPress_Plugin_Template () {
	$instance = WordPress_Plugin_Template::instance( __FILE__, '1.0.0' );

	if ( is_null( $instance->settings ) ) {
		$instance->settings = WordPress_Plugin_Template_Settings::instance( $instance );
	}

	// Initialize Feature API integration if available
	if ( is_null( $instance->feature_api ) && file_exists( __DIR__ . '/vendor/automattic/wp-feature-api/wp-feature-api.php' ) ) {
		$instance->feature_api = WordPress_Plugin_Template_Feature_API::instance( $instance );
	}

	// Initialize REST API
	if ( is_null( $instance->rest_api ) ) {
		$instance->rest_api = WordPress_Plugin_Template_REST_API::instance( $instance );
	}

	return $instance;
}

WordPress_Plugin_Template();