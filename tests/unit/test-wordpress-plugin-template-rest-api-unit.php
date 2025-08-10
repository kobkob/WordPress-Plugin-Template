<?php
/**
 * Unit tests for WordPress Plugin Template REST API class.
 *
 * @package WordPress_Plugin_Template
 */

/**
 * WordPress Plugin Template REST API unit test case.
 */
class Test_WordPress_Plugin_Template_REST_API_Unit extends WP_UnitTestCase {

	/**
	 * REST API instance.
	 *
	 * @var WordPress_Plugin_Template_REST_API
	 */
	protected $rest_api;

	/**
	 * Settings instance.
	 *
	 * @var WordPress_Plugin_Template_Settings
	 */
	protected $settings;

	/**
	 * Set up test environment.
	 */
	public function setUp(): void {
		parent::setUp();

		// Mock settings instance.
		$this->settings = $this->createMock( 'WordPress_Plugin_Template_Settings' );

		// Initialize REST API class.
		$this->rest_api = new WordPress_Plugin_Template_REST_API( $this->settings );
	}

	/**
	 * Test REST API class initialization.
	 */
	public function test_rest_api_initialization() {
		$this->assertInstanceOf( 'WordPress_Plugin_Template_REST_API', $this->rest_api );
		$this->assertEquals( 'wordpress-plugin-template/v1', $this->rest_api->namespace );
	}

	/**
	 * Test format post data method.
	 */
	public function test_format_post_data() {
		// Create a test post.
		$post_id = $this->factory->post->create(
			array(
				'post_type'    => 'wordpress_plugin_template_item',
				'post_title'   => 'Test Post',
				'post_content' => 'Test content',
				'post_status'  => 'publish',
			)
		);

		$post = get_post( $post_id );
		$formatted = $this->rest_api->format_post_data( $post );

		$this->assertArrayHasKey( 'id', $formatted );
		$this->assertArrayHasKey( 'title', $formatted );
		$this->assertArrayHasKey( 'content', $formatted );
		$this->assertArrayHasKey( 'status', $formatted );
		$this->assertArrayHasKey( 'date', $formatted );
		$this->assertArrayHasKey( 'modified', $formatted );
		$this->assertArrayHasKey( 'author', $formatted );
		$this->assertArrayHasKey( 'meta', $formatted );

		$this->assertEquals( $post_id, $formatted['id'] );
		$this->assertEquals( 'Test Post', $formatted['title'] );
		$this->assertEquals( 'Test content', $formatted['content'] );
		$this->assertEquals( 'publish', $formatted['status'] );
	}

	/**
	 * Test post validation method.
	 */
	public function test_validate_post_data() {
		$valid_data = array(
			'title'   => 'Valid Title',
			'content' => 'Valid content',
			'status'  => 'publish',
		);

		$result = $this->rest_api->validate_post_data( $valid_data );
		$this->assertTrue( $result );

		// Test empty title.
		$invalid_data = array(
			'title'   => '',
			'content' => 'Content',
			'status'  => 'publish',
		);

		$result = $this->rest_api->validate_post_data( $invalid_data );
		$this->assertFalse( $result );

		// Test invalid status.
		$invalid_data = array(
			'title'   => 'Title',
			'content' => 'Content',
			'status'  => 'invalid_status',
		);

		$result = $this->rest_api->validate_post_data( $invalid_data );
		$this->assertFalse( $result );
	}

	/**
	 * Test sanitize post data method.
	 */
	public function test_sanitize_post_data() {
		$raw_data = array(
			'title'   => '<script>alert("test")</script>Clean Title',
			'content' => '<p>Paragraph</p><script>bad_script()</script>',
			'status'  => 'publish',
			'meta'    => array(
				'test_field' => '<script>alert("meta")</script>clean_value',
			),
		);

		$sanitized = $this->rest_api->sanitize_post_data( $raw_data );

		$this->assertEquals( 'Clean Title', $sanitized['title'] );
		$this->assertEquals( '<p>Paragraph</p>', $sanitized['content'] );
		$this->assertEquals( 'publish', $sanitized['status'] );
		$this->assertEquals( 'clean_value', $sanitized['meta']['test_field'] );
	}

	/**
	 * Test permission check methods.
	 */
	public function test_permission_checks() {
		// Test without user.
		$this->assertFalse( $this->rest_api->check_admin_permissions() );

		// Test with regular user.
		$user_id = $this->factory->user->create( array( 'role' => 'subscriber' ) );
		wp_set_current_user( $user_id );
		$this->assertFalse( $this->rest_api->check_admin_permissions() );

		// Test with admin user.
		$admin_id = $this->factory->user->create( array( 'role' => 'administrator' ) );
		wp_set_current_user( $admin_id );
		$this->assertTrue( $this->rest_api->check_admin_permissions() );

		// Test post permissions.
		wp_set_current_user( 0 );
		$this->assertFalse( $this->rest_api->check_post_permissions() );

		wp_set_current_user( $user_id );
		$this->assertFalse( $this->rest_api->check_post_permissions() );

		$editor_id = $this->factory->user->create( array( 'role' => 'editor' ) );
		wp_set_current_user( $editor_id );
		$this->assertTrue( $this->rest_api->check_post_permissions() );
	}

	/**
	 * Test error response method.
	 */
	public function test_error_response() {
		$error = $this->rest_api->error_response( 'test_error', 'Test error message', 400 );

		$this->assertInstanceOf( 'WP_Error', $error );
		$this->assertEquals( 'test_error', $error->get_error_code() );
		$this->assertEquals( 'Test error message', $error->get_error_message() );
	}

	/**
	 * Test success response method.
	 */
	public function test_success_response() {
		$data = array( 'test' => 'value' );
		$response = $this->rest_api->success_response( $data, 'Success message' );

		$expected = array(
			'success' => true,
			'message' => 'Success message',
			'data'    => $data,
		);

		$this->assertEquals( $expected, $response );
	}

	/**
	 * Test pagination calculation.
	 */
	public function test_calculate_pagination() {
		$pagination = $this->rest_api->calculate_pagination( 25, 10, 2 );

		$expected = array(
			'total'       => 25,
			'per_page'    => 10,
			'page'        => 2,
			'total_pages' => 3,
			'has_next'    => true,
			'has_prev'    => true,
		);

		$this->assertEquals( $expected, $pagination );

		// Test first page.
		$pagination = $this->rest_api->calculate_pagination( 25, 10, 1 );
		$this->assertFalse( $pagination['has_prev'] );
		$this->assertTrue( $pagination['has_next'] );

		// Test last page.
		$pagination = $this->rest_api->calculate_pagination( 25, 10, 3 );
		$this->assertTrue( $pagination['has_prev'] );
		$this->assertFalse( $pagination['has_next'] );
	}

	/**
	 * Test batch request validation.
	 */
	public function test_validate_batch_request() {
		// Valid batch request.
		$valid_request = array(
			'requests' => array(
				array(
					'method' => 'GET',
					'path'   => '/wp-json/wordpress-plugin-template/v1/posts',
				),
				array(
					'method' => 'POST',
					'path'   => '/wp-json/wordpress-plugin-template/v1/posts',
					'body'   => array( 'title' => 'Test' ),
				),
			),
		);

		$this->assertTrue( $this->rest_api->validate_batch_request( $valid_request ) );

		// Invalid - missing requests.
		$invalid_request = array();
		$this->assertFalse( $this->rest_api->validate_batch_request( $invalid_request ) );

		// Invalid - too many requests.
		$too_many_requests = array(
			'requests' => array_fill( 0, 11, array( 'method' => 'GET', 'path' => '/test' ) ),
		);
		$this->assertFalse( $this->rest_api->validate_batch_request( $too_many_requests ) );

		// Invalid - malformed request.
		$malformed_request = array(
			'requests' => array(
				array( 'method' => 'GET' ), // Missing path.
			),
		);
		$this->assertFalse( $this->rest_api->validate_batch_request( $malformed_request ) );
	}

	/**
	 * Test plugin info generation.
	 */
	public function test_get_plugin_info_data() {
		$info = $this->rest_api->get_plugin_info_data();

		$this->assertArrayHasKey( 'name', $info );
		$this->assertArrayHasKey( 'namespace', $info );
		$this->assertArrayHasKey( 'endpoints', $info );
		$this->assertArrayHasKey( 'post_types', $info );
		$this->assertArrayHasKey( 'taxonomies', $info );

		$this->assertEquals( 'WordPress Plugin Template', $info['name'] );
		$this->assertEquals( 'wordpress-plugin-template/v1', $info['namespace'] );
		$this->assertIsArray( $info['endpoints'] );
	}

	/**
	 * Test plugin status generation.
	 */
	public function test_get_plugin_status_data() {
		$status = $this->rest_api->get_plugin_status_data();

		$this->assertArrayHasKey( 'active', $status );
		$this->assertArrayHasKey( 'version', $status );
		$this->assertArrayHasKey( 'php_version', $status );
		$this->assertArrayHasKey( 'wp_version', $status );
		$this->assertArrayHasKey( 'rest_api_enabled', $status );

		$this->assertTrue( $status['active'] );
		$this->assertTrue( $status['rest_api_enabled'] );
		$this->assertIsString( $status['version'] );
		$this->assertIsString( $status['php_version'] );
		$this->assertIsString( $status['wp_version'] );
	}

	/**
	 * Test meta data handling.
	 */
	public function test_handle_post_meta() {
		$post_id = $this->factory->post->create(
			array(
				'post_type' => 'wordpress_plugin_template_item',
			)
		);

		$meta_data = array(
			'text_field'   => 'text_value',
			'number_field' => 123,
			'array_field'  => array( 'a', 'b', 'c' ),
		);

		$this->rest_api->handle_post_meta( $post_id, $meta_data );

		// Verify meta was saved.
		$this->assertEquals( 'text_value', get_post_meta( $post_id, 'text_field', true ) );
		$this->assertEquals( 123, get_post_meta( $post_id, 'number_field', true ) );
		$this->assertEquals( array( 'a', 'b', 'c' ), get_post_meta( $post_id, 'array_field', true ) );
	}

	/**
	 * Test query parameters parsing.
	 */
	public function test_parse_query_params() {
		$request = new WP_REST_Request();
		$request->set_query_params(
			array(
				'per_page' => '5',
				'page'     => '2',
				'search'   => 'test query',
				'status'   => 'publish',
				'orderby'  => 'date',
				'order'    => 'desc',
			)
		);

		$params = $this->rest_api->parse_query_params( $request );

		$this->assertEquals( 5, $params['per_page'] );
		$this->assertEquals( 2, $params['page'] );
		$this->assertEquals( 'test query', $params['search'] );
		$this->assertEquals( 'publish', $params['status'] );
		$this->assertEquals( 'date', $params['orderby'] );
		$this->assertEquals( 'desc', $params['order'] );
	}

	/**
	 * Test rate limiting check.
	 */
	public function test_check_rate_limit() {
		// Should pass for first call.
		$this->assertTrue( $this->rest_api->check_rate_limit() );

		// Mock heavy usage to trigger rate limit.
		$user_id = get_current_user_id();
		if ( ! $user_id ) {
			$user_id = 'anonymous';
		}

		// Simulate multiple rapid requests.
		for ( $i = 0; $i < 100; $i++ ) {
			set_transient( "wpt_api_rate_limit_{$user_id}_" . time(), 1, 60 );
		}

		// Rate limit should now be triggered.
		$this->assertFalse( $this->rest_api->check_rate_limit() );
	}

	/**
	 * Clean up after tests.
	 */
	public function tearDown(): void {
		// Clean up any transients set during testing.
		$user_id = get_current_user_id();
		if ( ! $user_id ) {
			$user_id = 'anonymous';
		}

		// Clean up rate limit transients.
		for ( $i = 0; $i < 100; $i++ ) {
			delete_transient( "wpt_api_rate_limit_{$user_id}_" . ( time() - $i ) );
		}

		parent::tearDown();
	}
}
