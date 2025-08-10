<?php

if ( ! defined( 'ABSPATH' ) ) exit;

/**
 * WordPress Feature API Integration Class
 *
 * This class provides integration with the Automattic WordPress Feature API
 * for AI/LLM systems and agentic WordPress functionality.
 *
 * @package WordPress_Plugin_Template
 * @since 1.0.0
 */
class WordPress_Plugin_Template_Feature_API {

	/**
	 * The single instance of WordPress_Plugin_Template_Feature_API.
	 * @var 	object
	 * @access  private
	 * @since 	1.0.0
	 */
	private static $_instance = null;

	/**
	 * The main plugin object.
	 * @var 	object
	 * @access  public
	 * @since 	1.0.0
	 */
	public $parent = null;

	/**
	 * Whether Feature API is available and initialized.
	 * @var 	bool
	 * @access  private
	 * @since 	1.0.0
	 */
	private $_feature_api_available = false;

	/**
	 * Constructor function.
	 * @param WordPress_Plugin_Template $parent Main plugin object.
	 */
	public function __construct( $parent ) {
		$this->parent = $parent;

		// Check if Feature API is available
		$this->_feature_api_available = class_exists( 'WP_Feature_API' );

		if ( $this->_feature_api_available ) {
			// Hook into Feature API initialization
			add_action( 'wp_feature_api_init', array( $this, 'register_features' ) );
		}

		// Hook into plugins_loaded to initialize
		add_action( 'plugins_loaded', array( $this, 'init' ), 20 );
	}

	/**
	 * Initialize the Feature API integration.
	 * @since 1.0.0
	 */
	public function init() {
		if ( ! $this->_feature_api_available ) {
			return;
		}

		// Additional initialization if needed
		$this->add_hooks();
	}

	/**
	 * Add WordPress hooks for Feature API integration.
	 * @since 1.0.0
	 */
	private function add_hooks() {
		// Add hooks for feature discovery and execution
		add_filter( 'wp_feature_api_features', array( $this, 'filter_features' ) );
		add_action( 'wp_feature_api_execute_feature', array( $this, 'execute_feature' ), 10, 3 );
	}

	/**
	 * Register plugin features with the Feature API.
	 * This is called when the Feature API is ready to accept registrations.
	 * @since 1.0.0
	 */
	public function register_features() {
		if ( ! $this->is_feature_api_available() ) {
			return;
		}

		// Example: Register a feature to create a custom post
		$this->register_create_post_feature();

		// Example: Register a feature to list custom post types
		$this->register_list_post_types_feature();

		// Example: Register a feature for plugin settings
		$this->register_plugin_settings_feature();

		// Allow other parts of the plugin or other plugins to register features
		do_action( 'wordpress_plugin_template_register_features', $this );
	}

	/**
	 * Register a feature to create custom posts.
	 * @since 1.0.0
	 */
	private function register_create_post_feature() {
		$feature = array(
			'id' => $this->parent->_token . '_create_post',
			'name' => __( 'Create Custom Post', 'wordpress-plugin-template' ),
			'description' => __( 'Create a new post using the plugin\'s custom post types', 'wordpress-plugin-template' ),
			'category' => 'content',
			'input_schema' => array(
				'type' => 'object',
				'properties' => array(
					'title' => array(
						'type' => 'string',
						'description' => __( 'The title of the post', 'wordpress-plugin-template' ),
					),
					'content' => array(
						'type' => 'string',
						'description' => __( 'The content of the post', 'wordpress-plugin-template' ),
					),
					'post_type' => array(
						'type' => 'string',
						'description' => __( 'The custom post type to create', 'wordpress-plugin-template' ),
						'default' => 'post',
					),
				),
				'required' => array( 'title' ),
			),
			'callback' => array( $this, 'create_post_feature' ),
			'is_eligible' => array( $this, 'can_create_posts' ),
		);

		wp_feature_api_register_feature( $feature );
	}

	/**
	 * Register a feature to list available post types.
	 * @since 1.0.0
	 */
	private function register_list_post_types_feature() {
		$feature = array(
			'id' => $this->parent->_token . '_list_post_types',
			'name' => __( 'List Post Types', 'wordpress-plugin-template' ),
			'description' => __( 'Get a list of available custom post types created by this plugin', 'wordpress-plugin-template' ),
			'category' => 'information',
			'input_schema' => array(
				'type' => 'object',
				'properties' => array(),
			),
			'callback' => array( $this, 'list_post_types_feature' ),
			'is_eligible' => '__return_true', // Always available
		);

		wp_feature_api_register_feature( $feature );
	}

	/**
	 * Register a feature for plugin settings management.
	 * @since 1.0.0
	 */
	private function register_plugin_settings_feature() {
		$feature = array(
			'id' => $this->parent->_token . '_get_settings',
			'name' => __( 'Get Plugin Settings', 'wordpress-plugin-template' ),
			'description' => __( 'Retrieve current plugin settings and configuration', 'wordpress-plugin-template' ),
			'category' => 'settings',
			'input_schema' => array(
				'type' => 'object',
				'properties' => array(
					'setting_key' => array(
						'type' => 'string',
						'description' => __( 'Specific setting key to retrieve (optional)', 'wordpress-plugin-template' ),
					),
				),
			),
			'callback' => array( $this, 'get_settings_feature' ),
			'is_eligible' => array( $this, 'can_manage_settings' ),
		);

		wp_feature_api_register_feature( $feature );
	}

	/**
	 * Feature callback: Create a new post.
	 * @param array $params The parameters for creating the post.
	 * @return array Result of the post creation.
	 * @since 1.0.0
	 */
	public function create_post_feature( $params ) {
		$title = sanitize_text_field( $params['title'] ?? '' );
		$content = wp_kses_post( $params['content'] ?? '' );
		$post_type = sanitize_key( $params['post_type'] ?? 'post' );

		if ( empty( $title ) ) {
			return array(
				'success' => false,
				'message' => __( 'Post title is required', 'wordpress-plugin-template' ),
			);
		}

		$post_data = array(
			'post_title' => $title,
			'post_content' => $content,
			'post_type' => $post_type,
			'post_status' => 'draft',
		);

		$post_id = wp_insert_post( $post_data );

		if ( is_wp_error( $post_id ) ) {
			return array(
				'success' => false,
				'message' => $post_id->get_error_message(),
			);
		}

		return array(
			'success' => true,
			'message' => sprintf( __( 'Post "%s" created successfully', 'wordpress-plugin-template' ), $title ),
			'data' => array(
				'post_id' => $post_id,
				'post_url' => get_permalink( $post_id ),
				'edit_url' => get_edit_post_link( $post_id ),
			),
		);
	}

	/**
	 * Feature callback: List available post types.
	 * @param array $params The parameters (unused for this feature).
	 * @return array List of available post types.
	 * @since 1.0.0
	 */
	public function list_post_types_feature( $params ) {
		$post_types = get_post_types( array( 'public' => true ), 'objects' );
		$formatted_types = array();

		foreach ( $post_types as $post_type ) {
			$formatted_types[] = array(
				'name' => $post_type->name,
				'label' => $post_type->label,
				'description' => $post_type->description,
				'supports' => get_all_post_type_supports( $post_type->name ),
			);
		}

		return array(
			'success' => true,
			'message' => __( 'Post types retrieved successfully', 'wordpress-plugin-template' ),
			'data' => $formatted_types,
		);
	}

	/**
	 * Feature callback: Get plugin settings.
	 * @param array $params The parameters for retrieving settings.
	 * @return array Plugin settings data.
	 * @since 1.0.0
	 */
	public function get_settings_feature( $params ) {
		$setting_key = $params['setting_key'] ?? null;

		if ( $setting_key ) {
			$value = get_option( $this->parent->_token . '_' . $setting_key );
			return array(
				'success' => true,
				'message' => sprintf( __( 'Setting "%s" retrieved', 'wordpress-plugin-template' ), $setting_key ),
				'data' => array(
					'key' => $setting_key,
					'value' => $value,
				),
			);
		}

		// Get all plugin settings
		$settings = array();
		$option_prefix = $this->parent->_token . '_';

		// This would typically iterate through known settings
		// For demo purposes, we'll return a sample structure
		$settings = array(
			'version' => $this->parent->_version,
			'token' => $this->parent->_token,
			'settings_page_url' => admin_url( 'options-general.php?page=' . $this->parent->_token . '_settings' ),
		);

		return array(
			'success' => true,
			'message' => __( 'Plugin settings retrieved successfully', 'wordpress-plugin-template' ),
			'data' => $settings,
		);
	}

	/**
	 * Check if the current user can create posts.
	 * @return bool Whether the user can create posts.
	 * @since 1.0.0
	 */
	public function can_create_posts() {
		return current_user_can( 'edit_posts' );
	}

	/**
	 * Check if the current user can manage plugin settings.
	 * @return bool Whether the user can manage settings.
	 * @since 1.0.0
	 */
	public function can_manage_settings() {
		return current_user_can( 'manage_options' );
	}

	/**
	 * Filter registered features to add context or modify them.
	 * @param array $features Existing registered features.
	 * @return array Modified features array.
	 * @since 1.0.0
	 */
	public function filter_features( $features ) {
		// Add plugin-specific context to features
		foreach ( $features as &$feature ) {
			if ( strpos( $feature['id'], $this->parent->_token ) === 0 ) {
				$feature['plugin'] = array(
					'name' => 'WordPress Plugin Template',
					'version' => $this->parent->_version,
					'namespace' => $this->parent->_token,
				);
			}
		}

		return $features;
	}

	/**
	 * Execute a specific feature by ID.
	 * @param string $feature_id The ID of the feature to execute.
	 * @param array $params Parameters for the feature.
	 * @param mixed $context Additional context for feature execution.
	 * @return mixed Result of feature execution.
	 * @since 1.0.0
	 */
	public function execute_feature( $feature_id, $params, $context ) {
		// This would typically handle plugin-specific feature execution logic
		// The Feature API handles most of this automatically, but this hook
		// allows for additional processing or logging
		
		if ( strpos( $feature_id, $this->parent->_token ) === 0 ) {
			// Log feature execution for debugging
			error_log( sprintf( 'Executing feature: %s with params: %s', $feature_id, wp_json_encode( $params ) ) );
		}
	}

	/**
	 * Check if WordPress Feature API is available and initialized.
	 * @return bool Whether Feature API is available.
	 * @since 1.0.0
	 */
	public function is_feature_api_available() {
		return $this->_feature_api_available && function_exists( 'wp_feature_api_register_feature' );
	}

	/**
	 * Get the plugin's registered features.
	 * @return array Array of registered features.
	 * @since 1.0.0
	 */
	public function get_plugin_features() {
		if ( ! $this->is_feature_api_available() ) {
			return array();
		}

		$all_features = wp_feature_api_get_features();
		$plugin_features = array();

		foreach ( $all_features as $feature ) {
			if ( strpos( $feature['id'], $this->parent->_token ) === 0 ) {
				$plugin_features[] = $feature;
			}
		}

		return $plugin_features;
	}

	/**
	 * Main WordPress_Plugin_Template_Feature_API Instance
	 *
	 * Ensures only one instance of WordPress_Plugin_Template_Feature_API is loaded or can be loaded.
	 *
	 * @since 1.0.0
	 * @static
	 * @see WordPress_Plugin_Template()
	 * @param WordPress_Plugin_Template $parent Main plugin object.
	 * @return WordPress_Plugin_Template_Feature_API instance
	 */
	public static function instance( $parent ) {
		if ( is_null( self::$_instance ) ) {
			self::$_instance = new self( $parent );
		}
		return self::$_instance;
	}

	/**
	 * Cloning is forbidden.
	 * @since 1.0.0
	 */
	public function __clone() {
		_doing_it_wrong( __FUNCTION__, __( 'Cloning of WordPress_Plugin_Template_Feature_API is forbidden' ), $this->parent->_version );
	}

	/**
	 * Unserializing instances of this class is forbidden.
	 * @since 1.0.0
	 */
	public function __wakeup() {
		_doing_it_wrong( __FUNCTION__, __( 'Unserializing instances of WordPress_Plugin_Template_Feature_API is forbidden' ), $this->parent->_version );
	}
}
