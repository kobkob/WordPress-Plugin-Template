<?php
/**
 * REST API functionality for WordPress Plugin Template.
 *
 * Provides comprehensive REST API endpoints with authentication,
 * CRUD operations, pagination, and error handling.
 *
 * @package WordPress_Plugin_Template
 * @subpackage REST_API
 * @since 1.0.0
 */

if ( ! defined( 'ABSPATH' ) ) {
	exit;
}

/**
 * WordPress Plugin Template REST API class.
 *
 * Handles all REST API endpoints for the plugin including:
 * - Authentication and permissions
 * - CRUD operations for custom post types
 * - Settings management
 * - Data validation and sanitization
 * - Error handling and responses
 *
 * @since 1.0.0
 */
class WordPress_Plugin_Template_REST_API {

	/**
	 * The single instance of WordPress_Plugin_Template_REST_API.
	 *
	 * @var WordPress_Plugin_Template_REST_API
	 * @since 1.0.0
	 */
	private static $_instance = null;

	/**
	 * The main plugin object.
	 *
	 * @var WordPress_Plugin_Template
	 * @since 1.0.0
	 */
	public $parent = null;

	/**
	 * REST API namespace.
	 *
	 * @var string
	 * @since 1.0.0
	 */
	private $namespace = 'wordpress-plugin-template/v1';

	/**
	 * Constructor function.
	 *
	 * @param WordPress_Plugin_Template $parent Parent object.
	 * @since 1.0.0
	 */
	public function __construct( $parent ) {
		$this->parent = $parent;

		// Register REST API endpoints.
		add_action( 'rest_api_init', array( $this, 'register_routes' ) );
	}

	/**
	 * Register all REST API routes.
	 *
	 * @since 1.0.0
	 */
	public function register_routes() {
		// Settings endpoints.
		$this->register_settings_routes();

		// Custom post type endpoints.
		$this->register_post_type_routes();

		// Plugin info endpoints.
		$this->register_info_routes();

		// Batch operations endpoints.
		$this->register_batch_routes();

		/**
		 * Action hook for registering additional REST API routes.
		 *
		 * @param WordPress_Plugin_Template_REST_API $rest_api REST API instance.
		 * @since 1.0.0
		 */
		do_action( 'wordpress_plugin_template_rest_api_register_routes', $this );
	}

	/**
	 * Register settings-related REST API routes.
	 *
	 * @since 1.0.0
	 */
	private function register_settings_routes() {
		// GET /wp-json/wordpress-plugin-template/v1/settings
		register_rest_route(
			$this->namespace,
			'/settings',
			array(
				'methods'             => WP_REST_Server::READABLE,
				'callback'            => array( $this, 'get_settings' ),
				'permission_callback' => array( $this, 'check_admin_permissions' ),
				'args'                => array(),
			)
		);

		// POST /wp-json/wordpress-plugin-template/v1/settings
		register_rest_route(
			$this->namespace,
			'/settings',
			array(
				'methods'             => WP_REST_Server::EDITABLE,
				'callback'            => array( $this, 'update_settings' ),
				'permission_callback' => array( $this, 'check_admin_permissions' ),
				'args'                => $this->get_settings_schema(),
			)
		);

		// GET /wp-json/wordpress-plugin-template/v1/settings/(?P<key>[a-zA-Z0-9_-]+)
		register_rest_route(
			$this->namespace,
			'/settings/(?P<key>[a-zA-Z0-9_-]+)',
			array(
				'methods'             => WP_REST_Server::READABLE,
				'callback'            => array( $this, 'get_setting' ),
				'permission_callback' => array( $this, 'check_admin_permissions' ),
				'args'                => array(
					'key' => array(
						'description' => __( 'Setting key', 'wordpress-plugin-template' ),
						'type'        => 'string',
						'required'    => true,
					),
				),
			)
		);
	}

	/**
	 * Register custom post type REST API routes.
	 *
	 * @since 1.0.0
	 */
	private function register_post_type_routes() {
		// GET /wp-json/wordpress-plugin-template/v1/posts
		register_rest_route(
			$this->namespace,
			'/posts',
			array(
				'methods'             => WP_REST_Server::READABLE,
				'callback'            => array( $this, 'get_posts' ),
				'permission_callback' => array( $this, 'check_read_permissions' ),
				'args'                => $this->get_posts_query_args(),
			)
		);

		// GET /wp-json/wordpress-plugin-template/v1/posts/(?P<id>\d+)
		register_rest_route(
			$this->namespace,
			'/posts/(?P<id>\d+)',
			array(
				'methods'             => WP_REST_Server::READABLE,
				'callback'            => array( $this, 'get_post' ),
				'permission_callback' => array( $this, 'check_read_post_permissions' ),
				'args'                => array(
					'id' => array(
						'description' => __( 'Post ID', 'wordpress-plugin-template' ),
						'type'        => 'integer',
						'required'    => true,
					),
				),
			)
		);

		// POST /wp-json/wordpress-plugin-template/v1/posts
		register_rest_route(
			$this->namespace,
			'/posts',
			array(
				'methods'             => WP_REST_Server::CREATABLE,
				'callback'            => array( $this, 'create_post' ),
				'permission_callback' => array( $this, 'check_create_permissions' ),
				'args'                => $this->get_post_schema(),
			)
		);

		// PUT /wp-json/wordpress-plugin-template/v1/posts/(?P<id>\d+)
		register_rest_route(
			$this->namespace,
			'/posts/(?P<id>\d+)',
			array(
				'methods'             => WP_REST_Server::EDITABLE,
				'callback'            => array( $this, 'update_post' ),
				'permission_callback' => array( $this, 'check_edit_post_permissions' ),
				'args'                => $this->get_post_schema(),
			)
		);

		// DELETE /wp-json/wordpress-plugin-template/v1/posts/(?P<id>\d+)
		register_rest_route(
			$this->namespace,
			'/posts/(?P<id>\d+)',
			array(
				'methods'             => WP_REST_Server::DELETABLE,
				'callback'            => array( $this, 'delete_post' ),
				'permission_callback' => array( $this, 'check_delete_post_permissions' ),
				'args'                => array(
					'id' => array(
						'description' => __( 'Post ID', 'wordpress-plugin-template' ),
						'type'        => 'integer',
						'required'    => true,
					),
					'force' => array(
						'description' => __( 'Whether to force delete (skip trash)', 'wordpress-plugin-template' ),
						'type'        => 'boolean',
						'default'     => false,
					),
				),
			)
		);
	}

	/**
	 * Register plugin information REST API routes.
	 *
	 * @since 1.0.0
	 */
	private function register_info_routes() {
		// GET /wp-json/wordpress-plugin-template/v1/info
		register_rest_route(
			$this->namespace,
			'/info',
			array(
				'methods'             => WP_REST_Server::READABLE,
				'callback'            => array( $this, 'get_plugin_info' ),
				'permission_callback' => '__return_true',
				'args'                => array(),
			)
		);

		// GET /wp-json/wordpress-plugin-template/v1/status
		register_rest_route(
			$this->namespace,
			'/status',
			array(
				'methods'             => WP_REST_Server::READABLE,
				'callback'            => array( $this, 'get_plugin_status' ),
				'permission_callback' => array( $this, 'check_admin_permissions' ),
				'args'                => array(),
			)
		);
	}

	/**
	 * Register batch operation REST API routes.
	 *
	 * @since 1.0.0
	 */
	private function register_batch_routes() {
		// POST /wp-json/wordpress-plugin-template/v1/batch
		register_rest_route(
			$this->namespace,
			'/batch',
			array(
				'methods'             => WP_REST_Server::CREATABLE,
				'callback'            => array( $this, 'handle_batch_request' ),
				'permission_callback' => array( $this, 'check_admin_permissions' ),
				'args'                => array(
					'requests' => array(
						'description' => __( 'Array of requests to process', 'wordpress-plugin-template' ),
						'type'        => 'array',
						'required'    => true,
						'items'       => array(
							'type'       => 'object',
							'properties' => array(
								'method' => array(
									'type' => 'string',
									'enum' => array( 'GET', 'POST', 'PUT', 'DELETE' ),
								),
								'path'   => array(
									'type' => 'string',
								),
								'body'   => array(
									'type' => 'object',
								),
							),
						),
					),
				),
			)
		);
	}

	/**
	 * Get plugin settings.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function get_settings( $request ) {
		$settings = $this->parent->settings->get_all_settings();

		if ( empty( $settings ) ) {
			return new WP_Error(
				'no_settings',
				__( 'No settings found', 'wordpress-plugin-template' ),
				array( 'status' => 404 )
			);
		}

		return rest_ensure_response( $settings );
	}

	/**
	 * Update plugin settings.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function update_settings( $request ) {
		$settings = $request->get_json_params();

		if ( empty( $settings ) ) {
			return new WP_Error(
				'invalid_settings',
				__( 'No valid settings provided', 'wordpress-plugin-template' ),
				array( 'status' => 400 )
			);
		}

		$updated = $this->parent->settings->update_settings( $settings );

		if ( is_wp_error( $updated ) ) {
			return $updated;
		}

		return rest_ensure_response(
			array(
				'success' => true,
				'message' => __( 'Settings updated successfully', 'wordpress-plugin-template' ),
				'data'    => $this->parent->settings->get_all_settings(),
			)
		);
	}

	/**
	 * Get a specific setting.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function get_setting( $request ) {
		$key = $request->get_param( 'key' );
		$value = $this->parent->settings->get_setting( $key );

		if ( null === $value ) {
			return new WP_Error(
				'setting_not_found',
				sprintf( __( 'Setting "%s" not found', 'wordpress-plugin-template' ), $key ),
				array( 'status' => 404 )
			);
		}

		return rest_ensure_response(
			array(
				'key'   => $key,
				'value' => $value,
			)
		);
	}

	/**
	 * Get posts with pagination and filtering.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function get_posts( $request ) {
		$args = array(
			'post_type'      => $this->get_plugin_post_type(),
			'post_status'    => 'publish',
			'posts_per_page' => $request->get_param( 'per_page' ) ?: 10,
			'paged'          => $request->get_param( 'page' ) ?: 1,
			'orderby'        => $request->get_param( 'orderby' ) ?: 'date',
			'order'          => $request->get_param( 'order' ) ?: 'DESC',
		);

		// Add search parameter if provided.
		if ( $request->get_param( 'search' ) ) {
			$args['s'] = sanitize_text_field( $request->get_param( 'search' ) );
		}

		// Add meta query if provided.
		if ( $request->get_param( 'meta_key' ) && $request->get_param( 'meta_value' ) ) {
			$args['meta_query'] = array(
				array(
					'key'     => sanitize_text_field( $request->get_param( 'meta_key' ) ),
					'value'   => sanitize_text_field( $request->get_param( 'meta_value' ) ),
					'compare' => $request->get_param( 'meta_compare' ) ?: '=',
				),
			);
		}

		$query = new WP_Query( $args );
		$posts = array();

		if ( $query->have_posts() ) {
			while ( $query->have_posts() ) {
				$query->the_post();
				$posts[] = $this->prepare_post_for_response( get_post(), $request );
			}
			wp_reset_postdata();
		}

		$response = rest_ensure_response( $posts );

		// Add pagination headers.
		$response->header( 'X-WP-Total', $query->found_posts );
		$response->header( 'X-WP-TotalPages', $query->max_num_pages );

		return $response;
	}

	/**
	 * Get a single post.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function get_post( $request ) {
		$post_id = (int) $request->get_param( 'id' );
		$post = get_post( $post_id );

		if ( ! $post || $this->get_plugin_post_type() !== $post->post_type ) {
			return new WP_Error(
				'post_not_found',
				__( 'Post not found', 'wordpress-plugin-template' ),
				array( 'status' => 404 )
			);
		}

		return rest_ensure_response( $this->prepare_post_for_response( $post, $request ) );
	}

	/**
	 * Create a new post.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function create_post( $request ) {
		$data = $request->get_json_params();

		$post_args = array(
			'post_type'    => $this->get_plugin_post_type(),
			'post_title'   => sanitize_text_field( $data['title'] ?? '' ),
			'post_content' => wp_kses_post( $data['content'] ?? '' ),
			'post_status'  => sanitize_text_field( $data['status'] ?? 'publish' ),
			'post_author'  => get_current_user_id(),
		);

		$post_id = wp_insert_post( $post_args );

		if ( is_wp_error( $post_id ) ) {
			return $post_id;
		}

		// Handle meta data.
		if ( isset( $data['meta'] ) && is_array( $data['meta'] ) ) {
			foreach ( $data['meta'] as $meta_key => $meta_value ) {
				update_post_meta( $post_id, sanitize_key( $meta_key ), $meta_value );
			}
		}

		$post = get_post( $post_id );
		
		$response = rest_ensure_response( $this->prepare_post_for_response( $post, $request ) );
		$response->set_status( 201 );

		return $response;
	}

	/**
	 * Update an existing post.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function update_post( $request ) {
		$post_id = (int) $request->get_param( 'id' );
		$post = get_post( $post_id );

		if ( ! $post || $this->get_plugin_post_type() !== $post->post_type ) {
			return new WP_Error(
				'post_not_found',
				__( 'Post not found', 'wordpress-plugin-template' ),
				array( 'status' => 404 )
			);
		}

		$data = $request->get_json_params();

		$post_args = array(
			'ID' => $post_id,
		);

		if ( isset( $data['title'] ) ) {
			$post_args['post_title'] = sanitize_text_field( $data['title'] );
		}

		if ( isset( $data['content'] ) ) {
			$post_args['post_content'] = wp_kses_post( $data['content'] );
		}

		if ( isset( $data['status'] ) ) {
			$post_args['post_status'] = sanitize_text_field( $data['status'] );
		}

		$result = wp_update_post( $post_args );

		if ( is_wp_error( $result ) ) {
			return $result;
		}

		// Handle meta data.
		if ( isset( $data['meta'] ) && is_array( $data['meta'] ) ) {
			foreach ( $data['meta'] as $meta_key => $meta_value ) {
				update_post_meta( $post_id, sanitize_key( $meta_key ), $meta_value );
			}
		}

		$updated_post = get_post( $post_id );
		
		return rest_ensure_response( $this->prepare_post_for_response( $updated_post, $request ) );
	}

	/**
	 * Delete a post.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response|WP_Error Response object on success, or WP_Error object on failure.
	 * @since 1.0.0
	 */
	public function delete_post( $request ) {
		$post_id = (int) $request->get_param( 'id' );
		$force = (bool) $request->get_param( 'force' );
		$post = get_post( $post_id );

		if ( ! $post || $this->get_plugin_post_type() !== $post->post_type ) {
			return new WP_Error(
				'post_not_found',
				__( 'Post not found', 'wordpress-plugin-template' ),
				array( 'status' => 404 )
			);
		}

		$previous = $this->prepare_post_for_response( $post, $request );

		if ( $force ) {
			$result = wp_delete_post( $post_id, true );
		} else {
			$result = wp_trash_post( $post_id );
		}

		if ( ! $result ) {
			return new WP_Error(
				'cant_delete',
				__( 'The post cannot be deleted', 'wordpress-plugin-template' ),
				array( 'status' => 500 )
			);
		}

		return rest_ensure_response(
			array(
				'deleted'  => true,
				'previous' => $previous,
			)
		);
	}

	/**
	 * Get plugin information.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response Response object.
	 * @since 1.0.0
	 */
	public function get_plugin_info( $request ) {
		$info = array(
			'name'        => 'WordPress Plugin Template',
			'version'     => $this->parent->_version,
			'namespace'   => $this->namespace,
			'post_types'  => $this->get_plugin_post_types(),
			'taxonomies'  => $this->get_plugin_taxonomies(),
			'endpoints'   => $this->get_available_endpoints(),
		);

		return rest_ensure_response( $info );
	}

	/**
	 * Get plugin status.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response Response object.
	 * @since 1.0.0
	 */
	public function get_plugin_status( $request ) {
		$status = array(
			'active'           => is_plugin_active( plugin_basename( $this->parent->file ) ),
			'version'          => $this->parent->_version,
			'php_version'      => PHP_VERSION,
			'wp_version'       => get_bloginfo( 'version' ),
			'rest_api_enabled' => true,
			'post_count'       => wp_count_posts( $this->get_plugin_post_type() ),
			'settings_count'   => count( $this->parent->settings->get_all_settings() ),
		);

		return rest_ensure_response( $status );
	}

	/**
	 * Handle batch requests.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return WP_REST_Response Response object.
	 * @since 1.0.0
	 */
	public function handle_batch_request( $request ) {
		$requests = $request->get_param( 'requests' );
		$responses = array();

		foreach ( $requests as $index => $batch_request ) {
			$method = $batch_request['method'] ?? 'GET';
			$path = $batch_request['path'] ?? '';
			$body = $batch_request['body'] ?? array();

			// Create a new WP_REST_Request for this batch item.
			$internal_request = new WP_REST_Request( $method, $path );
			
			if ( ! empty( $body ) ) {
				$internal_request->set_body( wp_json_encode( $body ) );
				$internal_request->set_header( 'Content-Type', 'application/json' );
			}

			// Process the request.
			$response = rest_do_request( $internal_request );
			
			$responses[ $index ] = array(
				'status'  => $response->get_status(),
				'headers' => $response->get_headers(),
				'data'    => $response->get_data(),
			);
		}

		return rest_ensure_response( $responses );
	}

	/**
	 * Check admin permissions.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return bool True if the request has admin access, false otherwise.
	 * @since 1.0.0
	 */
	public function check_admin_permissions( $request ) {
		return current_user_can( 'manage_options' );
	}

	/**
	 * Check read permissions.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return bool True if the request has read access, false otherwise.
	 * @since 1.0.0
	 */
	public function check_read_permissions( $request ) {
		return current_user_can( 'read' );
	}

	/**
	 * Check read post permissions.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return bool True if the request has read access to the post, false otherwise.
	 * @since 1.0.0
	 */
	public function check_read_post_permissions( $request ) {
		$post_id = (int) $request->get_param( 'id' );
		$post = get_post( $post_id );

		if ( ! $post ) {
			return new WP_Error(
				'post_not_found',
				__( 'Post not found', 'wordpress-plugin-template' ),
				array( 'status' => 404 )
			);
		}

		return current_user_can( 'read_post', $post_id );
	}

	/**
	 * Check create permissions.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return bool True if the request can create posts, false otherwise.
	 * @since 1.0.0
	 */
	public function check_create_permissions( $request ) {
		$post_type = get_post_type_object( $this->get_plugin_post_type() );
		
		if ( ! $post_type ) {
			return false;
		}

		return current_user_can( $post_type->cap->create_posts );
	}

	/**
	 * Check edit post permissions.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return bool True if the request can edit the post, false otherwise.
	 * @since 1.0.0
	 */
	public function check_edit_post_permissions( $request ) {
		$post_id = (int) $request->get_param( 'id' );
		$post = get_post( $post_id );

		if ( ! $post ) {
			return new WP_Error(
				'post_not_found',
				__( 'Post not found', 'wordpress-plugin-template' ),
				array( 'status' => 404 )
			);
		}

		return current_user_can( 'edit_post', $post_id );
	}

	/**
	 * Check delete post permissions.
	 *
	 * @param WP_REST_Request $request Full details about the request.
	 * @return bool True if the request can delete the post, false otherwise.
	 * @since 1.0.0
	 */
	public function check_delete_post_permissions( $request ) {
		$post_id = (int) $request->get_param( 'id' );
		$post = get_post( $post_id );

		if ( ! $post ) {
			return new WP_Error(
				'post_not_found',
				__( 'Post not found', 'wordpress-plugin-template' ),
				array( 'status' => 404 )
			);
		}

		return current_user_can( 'delete_post', $post_id );
	}

	/**
	 * Get settings schema for validation.
	 *
	 * @return array Settings schema.
	 * @since 1.0.0
	 */
	private function get_settings_schema() {
		return array(
			'text_field' => array(
				'description' => __( 'Text field setting', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'sanitize_callback' => 'sanitize_text_field',
			),
			'textarea_field' => array(
				'description' => __( 'Textarea field setting', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'sanitize_callback' => 'sanitize_textarea_field',
			),
			'checkbox_field' => array(
				'description' => __( 'Checkbox field setting', 'wordpress-plugin-template' ),
				'type'        => 'boolean',
			),
			'select_field' => array(
				'description' => __( 'Select field setting', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'enum'        => array( 'option1', 'option2', 'option3' ),
			),
		);
	}

	/**
	 * Get post schema for validation.
	 *
	 * @return array Post schema.
	 * @since 1.0.0
	 */
	private function get_post_schema() {
		return array(
			'title' => array(
				'description' => __( 'Post title', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'sanitize_callback' => 'sanitize_text_field',
			),
			'content' => array(
				'description' => __( 'Post content', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'sanitize_callback' => 'wp_kses_post',
			),
			'status' => array(
				'description' => __( 'Post status', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'enum'        => array( 'publish', 'draft', 'private' ),
				'default'     => 'publish',
			),
			'meta' => array(
				'description' => __( 'Post meta data', 'wordpress-plugin-template' ),
				'type'        => 'object',
			),
		);
	}

	/**
	 * Get posts query arguments schema.
	 *
	 * @return array Query arguments schema.
	 * @since 1.0.0
	 */
	private function get_posts_query_args() {
		return array(
			'page' => array(
				'description' => __( 'Current page of the collection', 'wordpress-plugin-template' ),
				'type'        => 'integer',
				'default'     => 1,
				'minimum'     => 1,
			),
			'per_page' => array(
				'description' => __( 'Maximum number of items to return', 'wordpress-plugin-template' ),
				'type'        => 'integer',
				'default'     => 10,
				'minimum'     => 1,
				'maximum'     => 100,
			),
			'search' => array(
				'description' => __( 'Limit results to those matching a string', 'wordpress-plugin-template' ),
				'type'        => 'string',
			),
			'orderby' => array(
				'description' => __( 'Sort collection by post attribute', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'enum'        => array( 'date', 'title', 'modified', 'menu_order' ),
				'default'     => 'date',
			),
			'order' => array(
				'description' => __( 'Order sort attribute ascending or descending', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'enum'        => array( 'asc', 'desc', 'ASC', 'DESC' ),
				'default'     => 'DESC',
			),
			'meta_key' => array(
				'description' => __( 'Meta key to query by', 'wordpress-plugin-template' ),
				'type'        => 'string',
			),
			'meta_value' => array(
				'description' => __( 'Meta value to query by', 'wordpress-plugin-template' ),
				'type'        => 'string',
			),
			'meta_compare' => array(
				'description' => __( 'Meta comparison operator', 'wordpress-plugin-template' ),
				'type'        => 'string',
				'enum'        => array( '=', '!=', '>', '>=', '<', '<=', 'LIKE', 'NOT LIKE', 'IN', 'NOT IN' ),
				'default'     => '=',
			),
		);
	}

	/**
	 * Prepare post for REST response.
	 *
	 * @param WP_Post         $post    Post object.
	 * @param WP_REST_Request $request Request object.
	 * @return array Prepared post data.
	 * @since 1.0.0
	 */
	private function prepare_post_for_response( $post, $request ) {
		$data = array(
			'id'           => $post->ID,
			'title'        => $post->post_title,
			'content'      => $post->post_content,
			'excerpt'      => $post->post_excerpt,
			'status'       => $post->post_status,
			'date'         => mysql2date( 'c', $post->post_date, false ),
			'date_gmt'     => mysql2date( 'c', $post->post_date_gmt, false ),
			'modified'     => mysql2date( 'c', $post->post_modified, false ),
			'modified_gmt' => mysql2date( 'c', $post->post_modified_gmt, false ),
			'author'       => (int) $post->post_author,
			'slug'         => $post->post_name,
			'link'         => get_permalink( $post->ID ),
			'meta'         => get_post_meta( $post->ID ),
		);

		/**
		 * Filter the post data for the REST response.
		 *
		 * @param array           $data    Post data.
		 * @param WP_Post         $post    Post object.
		 * @param WP_REST_Request $request Request object.
		 * @since 1.0.0
		 */
		return apply_filters( 'wordpress_plugin_template_rest_prepare_post', $data, $post, $request );
	}

	/**
	 * Get the plugin's main post type.
	 *
	 * @return string Post type name.
	 * @since 1.0.0
	 */
	private function get_plugin_post_type() {
		return $this->parent->_token . '_item';
	}

	/**
	 * Get all plugin post types.
	 *
	 * @return array Post type names.
	 * @since 1.0.0
	 */
	private function get_plugin_post_types() {
		return array( $this->get_plugin_post_type() );
	}

	/**
	 * Get all plugin taxonomies.
	 *
	 * @return array Taxonomy names.
	 * @since 1.0.0
	 */
	private function get_plugin_taxonomies() {
		return array( $this->parent->_token . '_category' );
	}

	/**
	 * Get available REST API endpoints.
	 *
	 * @return array Available endpoints.
	 * @since 1.0.0
	 */
	private function get_available_endpoints() {
		return array(
			'info'     => array(
				'GET /info'   => __( 'Get plugin information', 'wordpress-plugin-template' ),
				'GET /status' => __( 'Get plugin status', 'wordpress-plugin-template' ),
			),
			'settings' => array(
				'GET /settings'       => __( 'Get all settings', 'wordpress-plugin-template' ),
				'POST /settings'      => __( 'Update settings', 'wordpress-plugin-template' ),
				'GET /settings/{key}' => __( 'Get specific setting', 'wordpress-plugin-template' ),
			),
			'posts'    => array(
				'GET /posts'       => __( 'Get all posts', 'wordpress-plugin-template' ),
				'POST /posts'      => __( 'Create new post', 'wordpress-plugin-template' ),
				'GET /posts/{id}'  => __( 'Get specific post', 'wordpress-plugin-template' ),
				'PUT /posts/{id}'  => __( 'Update specific post', 'wordpress-plugin-template' ),
				'DELETE /posts/{id}' => __( 'Delete specific post', 'wordpress-plugin-template' ),
			),
			'batch'    => array(
				'POST /batch' => __( 'Process batch requests', 'wordpress-plugin-template' ),
			),
		);
	}

	/**
	 * Main WordPress_Plugin_Template_REST_API Instance.
	 *
	 * Ensures only one instance of WordPress_Plugin_Template_REST_API is loaded or can be loaded.
	 *
	 * @param WordPress_Plugin_Template $parent Parent object.
	 * @return WordPress_Plugin_Template_REST_API instance.
	 * @since 1.0.0
	 * @static
	 */
	public static function instance( $parent ) {
		if ( is_null( self::$_instance ) ) {
			self::$_instance = new self( $parent );
		}
		return self::$_instance;
	}

	/**
	 * Cloning is forbidden.
	 *
	 * @since 1.0.0
	 */
	public function __clone() {
		_doing_it_wrong( __FUNCTION__, __( 'Cheatin&#8217; huh?', 'wordpress-plugin-template' ), $this->parent->_version );
	}

	/**
	 * Unserializing instances of this class is forbidden.
	 *
	 * @since 1.0.0
	 */
	public function __wakeup() {
		_doing_it_wrong( __FUNCTION__, __( 'Cheatin&#8217; huh?', 'wordpress-plugin-template' ), $this->parent->_version );
	}
}
