<?php
/**
 * REST API integration tests for WordPress Plugin Template.
 *
 * @package WordPress_Plugin_Template
 */

/**
 * WordPress Plugin Template REST API test case.
 */
class Test_WordPress_Plugin_Template_REST_API extends WP_UnitTestCase {

	/**
	 * REST API instance.
	 *
	 * @var WordPress_Plugin_Template_REST_API
	 */
	protected $rest_api;

	/**
	 * Plugin instance.
	 *
	 * @var WordPress_Plugin_Template
	 */
	protected $plugin;

	/**
	 * Test user ID.
	 *
	 * @var int
	 */
	protected $user_id;

	/**
	 * Admin user ID.
	 *
	 * @var int
	 */
	protected $admin_user_id;

	/**
	 * Set up test environment.
	 */
	public function setUp(): void {
		parent::setUp();

		// Create test users.
		$this->user_id = $this->factory->user->create(
			array(
				'role' => 'editor',
			)
		);

		$this->admin_user_id = $this->factory->user->create(
			array(
				'role' => 'administrator',
			)
		);

		// Initialize plugin.
		$this->plugin = WordPress_Plugin_Template();
		$this->rest_api = $this->plugin->rest_api;

		// Ensure REST API server is set up.
		global $wp_rest_server;
		$this->server = $wp_rest_server = new WP_REST_Server();
		do_action( 'rest_api_init' );
	}

	/**
	 * Test plugin info endpoint (public access).
	 */
	public function test_get_plugin_info() {
		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/info' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertEquals( 'WordPress Plugin Template', $data['name'] );
		$this->assertEquals( 'wordpress-plugin-template/v1', $data['namespace'] );
		$this->assertArrayHasKey( 'endpoints', $data );
		$this->assertArrayHasKey( 'post_types', $data );
		$this->assertArrayHasKey( 'taxonomies', $data );
	}

	/**
	 * Test plugin status endpoint (admin access required).
	 */
	public function test_get_plugin_status_requires_admin() {
		// Test without authentication.
		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/status' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 401, $response->get_status() );
	}

	/**
	 * Test plugin status endpoint with admin user.
	 */
	public function test_get_plugin_status_with_admin() {
		wp_set_current_user( $this->admin_user_id );

		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/status' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertArrayHasKey( 'active', $data );
		$this->assertArrayHasKey( 'version', $data );
		$this->assertArrayHasKey( 'php_version', $data );
		$this->assertArrayHasKey( 'wp_version', $data );
		$this->assertArrayHasKey( 'rest_api_enabled', $data );
		$this->assertTrue( $data['rest_api_enabled'] );
	}

	/**
	 * Test get settings endpoint requires admin.
	 */
	public function test_get_settings_requires_admin() {
		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/settings' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 401, $response->get_status() );
	}

	/**
	 * Test get settings endpoint with admin user.
	 */
	public function test_get_settings_with_admin() {
		wp_set_current_user( $this->admin_user_id );

		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/settings' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );
		$this->assertTrue( is_array( $response->get_data() ) );
	}

	/**
	 * Test update settings endpoint.
	 */
	public function test_update_settings() {
		wp_set_current_user( $this->admin_user_id );

		$request = new WP_REST_Request( 'POST', '/wordpress-plugin-template/v1/settings' );
		$request->set_header( 'Content-Type', 'application/json' );
		$request->set_body(
			wp_json_encode(
				array(
					'text_field'     => 'Test value',
					'checkbox_field' => true,
				)
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertTrue( $data['success'] );
		$this->assertArrayHasKey( 'data', $data );
		$this->assertEquals( 'Test value', $data['data']['text_field'] );
	}

	/**
	 * Test get specific setting endpoint.
	 */
	public function test_get_specific_setting() {
		wp_set_current_user( $this->admin_user_id );

		// First set a value.
		update_option( 'wpt_text_field', 'specific_test_value' );

		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/settings/text_field' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertEquals( 'text_field', $data['key'] );
		$this->assertEquals( 'specific_test_value', $data['value'] );
	}

	/**
	 * Test get non-existent setting returns 404.
	 */
	public function test_get_nonexistent_setting() {
		wp_set_current_user( $this->admin_user_id );

		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/settings/nonexistent_field' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 404, $response->get_status() );
		$this->assertEquals( 'setting_not_found', $response->get_data()['code'] );
	}

	/**
	 * Test get posts endpoint.
	 */
	public function test_get_posts() {
		// Create test posts.
		$post_ids = $this->factory->post->create_many(
			3,
			array(
				'post_type' => 'wordpress_plugin_template_item',
			)
		);

		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/posts' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );
		$this->assertCount( 3, $response->get_data() );

		// Test pagination headers.
		$headers = $response->get_headers();
		$this->assertArrayHasKey( 'X-WP-Total', $headers );
		$this->assertEquals( 3, $headers['X-WP-Total'] );
	}

	/**
	 * Test get posts with pagination.
	 */
	public function test_get_posts_pagination() {
		// Create test posts.
		$this->factory->post->create_many(
			5,
			array(
				'post_type' => 'wordpress_plugin_template_item',
			)
		);

		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/posts' );
		$request->set_query_params(
			array(
				'per_page' => 2,
				'page'     => 1,
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );
		$this->assertCount( 2, $response->get_data() );

		$headers = $response->get_headers();
		$this->assertEquals( 5, $headers['X-WP-Total'] );
		$this->assertEquals( 3, $headers['X-WP-TotalPages'] );
	}

	/**
	 * Test get single post.
	 */
	public function test_get_single_post() {
		$post_id = $this->factory->post->create(
			array(
				'post_type'  => 'wordpress_plugin_template_item',
				'post_title' => 'Test Post',
			)
		);

		$request = new WP_REST_Request( 'GET', "/wordpress-plugin-template/v1/posts/{$post_id}" );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertEquals( $post_id, $data['id'] );
		$this->assertEquals( 'Test Post', $data['title'] );
	}

	/**
	 * Test get non-existent post returns 404.
	 */
	public function test_get_nonexistent_post() {
		$request = new WP_REST_Request( 'GET', '/wordpress-plugin-template/v1/posts/99999' );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 404, $response->get_status() );
		$this->assertEquals( 'post_not_found', $response->get_data()['code'] );
	}

	/**
	 * Test create post.
	 */
	public function test_create_post() {
		wp_set_current_user( $this->user_id );

		$request = new WP_REST_Request( 'POST', '/wordpress-plugin-template/v1/posts' );
		$request->set_header( 'Content-Type', 'application/json' );
		$request->set_body(
			wp_json_encode(
				array(
					'title'   => 'API Created Post',
					'content' => 'This post was created via the API',
					'status'  => 'publish',
					'meta'    => array(
						'test_field' => 'test_value',
					),
				)
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 201, $response->get_status() );

		$data = $response->get_data();
		$this->assertEquals( 'API Created Post', $data['title'] );
		$this->assertEquals( 'This post was created via the API', $data['content'] );
		$this->assertEquals( 'publish', $data['status'] );

		// Verify meta was saved.
		$this->assertEquals( 'test_value', get_post_meta( $data['id'], 'test_field', true ) );
	}

	/**
	 * Test create post requires proper permissions.
	 */
	public function test_create_post_requires_permissions() {
		$request = new WP_REST_Request( 'POST', '/wordpress-plugin-template/v1/posts' );
		$request->set_header( 'Content-Type', 'application/json' );
		$request->set_body(
			wp_json_encode(
				array(
					'title'   => 'Unauthorized Post',
					'content' => 'This should not be created',
				)
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 401, $response->get_status() );
	}

	/**
	 * Test update post.
	 */
	public function test_update_post() {
		wp_set_current_user( $this->user_id );

		$post_id = $this->factory->post->create(
			array(
				'post_type'   => 'wordpress_plugin_template_item',
				'post_title'  => 'Original Title',
				'post_author' => $this->user_id,
			)
		);

		$request = new WP_REST_Request( 'PUT', "/wordpress-plugin-template/v1/posts/{$post_id}" );
		$request->set_header( 'Content-Type', 'application/json' );
		$request->set_body(
			wp_json_encode(
				array(
					'title' => 'Updated Title',
					'meta'  => array(
						'updated_field' => 'updated_value',
					),
				)
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertEquals( 'Updated Title', $data['title'] );

		// Verify meta was updated.
		$this->assertEquals( 'updated_value', get_post_meta( $post_id, 'updated_field', true ) );
	}

	/**
	 * Test delete post.
	 */
	public function test_delete_post() {
		wp_set_current_user( $this->user_id );

		$post_id = $this->factory->post->create(
			array(
				'post_type'   => 'wordpress_plugin_template_item',
				'post_author' => $this->user_id,
			)
		);

		$request = new WP_REST_Request( 'DELETE', "/wordpress-plugin-template/v1/posts/{$post_id}" );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertTrue( $data['deleted'] );
		$this->assertArrayHasKey( 'previous', $data );

		// Verify post was moved to trash.
		$post = get_post( $post_id );
		$this->assertEquals( 'trash', $post->post_status );
	}

	/**
	 * Test force delete post.
	 */
	public function test_force_delete_post() {
		wp_set_current_user( $this->user_id );

		$post_id = $this->factory->post->create(
			array(
				'post_type'   => 'wordpress_plugin_template_item',
				'post_author' => $this->user_id,
			)
		);

		$request = new WP_REST_Request( 'DELETE', "/wordpress-plugin-template/v1/posts/{$post_id}" );
		$request->set_query_params( array( 'force' => true ) );
		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertTrue( $data['deleted'] );

		// Verify post was completely deleted.
		$post = get_post( $post_id );
		$this->assertNull( $post );
	}

	/**
	 * Test batch operations.
	 */
	public function test_batch_operations() {
		wp_set_current_user( $this->admin_user_id );

		$post_id = $this->factory->post->create(
			array(
				'post_type'  => 'wordpress_plugin_template_item',
				'post_title' => 'Batch Test Post',
			)
		);

		$request = new WP_REST_Request( 'POST', '/wordpress-plugin-template/v1/batch' );
		$request->set_header( 'Content-Type', 'application/json' );
		$request->set_body(
			wp_json_encode(
				array(
					'requests' => array(
						array(
							'method' => 'GET',
							'path'   => "/wp-json/wordpress-plugin-template/v1/posts/{$post_id}",
						),
						array(
							'method' => 'POST',
							'path'   => '/wp-json/wordpress-plugin-template/v1/posts',
							'body'   => array(
								'title'   => 'Batch Created Post',
								'content' => 'Created via batch operation',
							),
						),
					),
				)
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 200, $response->get_status() );

		$data = $response->get_data();
		$this->assertArrayHasKey( 0, $data );
		$this->assertArrayHasKey( 1, $data );

		// Verify first request (GET) was successful.
		$this->assertEquals( 200, $data[0]['status'] );
		$this->assertEquals( 'Batch Test Post', $data[0]['data']['title'] );

		// Verify second request (POST) was successful.
		$this->assertEquals( 201, $data[1]['status'] );
		$this->assertEquals( 'Batch Created Post', $data[1]['data']['title'] );
	}

	/**
	 * Test batch operations require admin permissions.
	 */
	public function test_batch_operations_require_admin() {
		$request = new WP_REST_Request( 'POST', '/wordpress-plugin-template/v1/batch' );
		$request->set_header( 'Content-Type', 'application/json' );
		$request->set_body(
			wp_json_encode(
				array(
					'requests' => array(
						array(
							'method' => 'GET',
							'path'   => '/wp-json/wordpress-plugin-template/v1/info',
						),
					),
				)
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 401, $response->get_status() );
	}

	/**
	 * Test API validation with invalid data.
	 */
	public function test_api_validation() {
		wp_set_current_user( $this->admin_user_id );

		// Test invalid settings update.
		$request = new WP_REST_Request( 'POST', '/wordpress-plugin-template/v1/settings' );
		$request->set_header( 'Content-Type', 'application/json' );
		$request->set_body(
			wp_json_encode(
				array(
					'number_field' => 'not_a_number',
				)
			)
		);

		$response = $this->server->dispatch( $request );

		$this->assertEquals( 400, $response->get_status() );
		$this->assertEquals( 'settings_update_failed', $response->get_data()['code'] );
	}
}
