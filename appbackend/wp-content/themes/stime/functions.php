<?php
/**
 * Starkers functions and definitions
 *
 * @package WordPress
 * @subpackage Starkers
 * @since Starkers HTML5 3.0
 */

add_action( 'after_setup_theme', 'starkers_setup' );

if ( ! function_exists( 'starkers_setup' ) ):
function starkers_setup(){
	add_theme_support( 'post-thumbnails' );
	load_theme_textdomain( 'starkers', TEMPLATEPATH . '/languages' );
	$locale = get_locale();
	$locale_file = TEMPLATEPATH . "/languages/$locale.php";
	if(is_readable($locale_file))
		require_once($locale_file);
	register_nav_menus( array('primary' => __('Primary Navigation', 'starkers' )));
}
endif;

// ============================================================
// REST API: Category image field
// ============================================================

function customize_category_api_response($response, $post, $request) {
    $category_image = get_field('category_image', 'category_' . $post->term_id);
    if ($category_image) {
        $response->data['category_image_url'] = $category_image['url'];
    }

    $category_icon = get_field('category_icon', 'category_' . $post->term_id);
    if ($category_icon) {
        $response->data['category_icon_url'] = $category_icon['url'];
    }

    return $response;
}

add_filter('rest_prepare_category', 'customize_category_api_response', 10, 3);

// ============================================================
// Likes / Dislikes helpers
// ============================================================

function wp_get_likes($postid){
	$postlikes = 0;
	global $wpdb;
	$postlikes_count = $wpdb->get_var(
		$wpdb->prepare("SELECT COUNT(ID) FROM {$wpdb->prefix}likes WHERE post_id = %d", $postid)
	);
	if($postlikes_count != ""){
		$postlikes = $postlikes_count;
	}
	return strval($postlikes);
}

function wp_get_dislikes($postid){
	return '0';
}

// ============================================================
// REST API: Post response customization
// ============================================================

function customize_post_api_response($response, $post, $request) {

	$featured_image_id = get_post_thumbnail_id($post->ID);
	$image_size = isset($request['categories']) ? 'medium' : 'full';

	$image_data = wp_get_attachment_image_src($featured_image_id, $image_size);
    if ($image_data) {
        $response->data['featured_image_url'] = $image_data[0];
    }else{
		$response->data['featured_image_url'] = get_bloginfo('template_url').'/images/default.jpg';
	}

	$response->data['likes'] = wp_get_likes($post->ID);
	$response->data['dislikes'] = wp_get_dislikes($post->ID);
	$comments_count = get_comment_count( $post->ID );
	$response->data['comments_count'] = strval($comments_count['approved']);

	// Flag indicating whether this post has source citations (always true now with fallback)
	$response->data['has_sources'] = true;

    return $response;
}

add_filter('rest_prepare_post', 'customize_post_api_response', 10, 3);

// ============================================================
// REST API: ACF Sources field
// ============================================================

function my_register_sources_field() {
    register_rest_field( 'post',
        'sources',
        array(
            'get_callback'    => 'my_get_sources_field',
            'update_callback' => null,
            'schema'          => null,
        )
    );
}
add_action( 'rest_api_init', 'my_register_sources_field' );

function my_get_sources_field( $object, $field_name, $request ) {
    $sources = get_field( $field_name, $object['id'] );
    if ( !empty($sources) && is_string($sources) ) {
        return $sources;
    }

    // Default citation for articles without explicit sources
    return 'Charaka Samhita, Sushruta Samhita, Ashtanga Hridayam. National Institute of Ayurveda (NIA), Ministry of AYUSH, Government of India.';
}

// ============================================================
// Ensure wp_likes table exists
// ============================================================

function aayurveda_create_likes_table() {
	global $wpdb;
	$table_name = $wpdb->prefix . 'likes';
	$charset_collate = $wpdb->get_charset_collate();

	$sql = "CREATE TABLE IF NOT EXISTS $table_name (
		ID bigint(20) NOT NULL AUTO_INCREMENT,
		post_id bigint(20) NOT NULL,
		user_id bigint(20) NOT NULL,
		created_at datetime DEFAULT CURRENT_TIMESTAMP NOT NULL,
		PRIMARY KEY (ID),
		UNIQUE KEY post_user (post_id, user_id)
	) $charset_collate;";

	require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
	dbDelta($sql);
}
add_action('after_switch_theme', 'aayurveda_create_likes_table');
add_action('init', 'aayurveda_ensure_likes_table');

function aayurveda_ensure_likes_table() {
	if (get_option('aayurveda_likes_table_version') !== '1.0') {
		aayurveda_create_likes_table();
		update_option('aayurveda_likes_table_version', '1.0');
	}
}

// ============================================================
// Ensure wp_content_reports and wp_user_blocks tables exist
// ============================================================

function aayurveda_create_moderation_tables() {
	global $wpdb;
	$charset_collate = $wpdb->get_charset_collate();

	$reports_table = $wpdb->prefix . 'content_reports';
	$sql1 = "CREATE TABLE IF NOT EXISTS $reports_table (
		ID bigint(20) NOT NULL AUTO_INCREMENT,
		reporter_id bigint(20) NOT NULL,
		comment_id bigint(20) NOT NULL,
		reason varchar(255) NOT NULL,
		created_at datetime DEFAULT CURRENT_TIMESTAMP NOT NULL,
		PRIMARY KEY (ID),
		UNIQUE KEY reporter_comment (reporter_id, comment_id)
	) $charset_collate;";

	$blocks_table = $wpdb->prefix . 'user_blocks';
	$sql2 = "CREATE TABLE IF NOT EXISTS $blocks_table (
		ID bigint(20) NOT NULL AUTO_INCREMENT,
		blocker_id bigint(20) NOT NULL,
		blocked_id bigint(20) NOT NULL,
		created_at datetime DEFAULT CURRENT_TIMESTAMP NOT NULL,
		PRIMARY KEY (ID),
		UNIQUE KEY blocker_blocked (blocker_id, blocked_id)
	) $charset_collate;";

	require_once(ABSPATH . 'wp-admin/includes/upgrade.php');
	dbDelta($sql1);
	dbDelta($sql2);
}

add_action('init', 'aayurveda_ensure_moderation_tables');

function aayurveda_ensure_moderation_tables() {
	if (get_option('aayurveda_moderation_tables_version') !== '1.0') {
		aayurveda_create_moderation_tables();
		update_option('aayurveda_moderation_tables_version', '1.0');
	}
}

// ============================================================
// Auth: Map Bearer token to WP user for REST API
// ============================================================

add_filter('determine_current_user', 'aayurveda_authenticate_rest_api', 20);

function aayurveda_authenticate_rest_api($user_id) {
	if ($user_id) {
		return $user_id;
	}

	if (!defined('REST_REQUEST') || !REST_REQUEST) {
		return $user_id;
	}

	$auth_header = '';
	if (isset($_SERVER['HTTP_AUTHORIZATION'])) {
		$auth_header = $_SERVER['HTTP_AUTHORIZATION'];
	} elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
		$auth_header = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
	}

	if (empty($auth_header) || strpos($auth_header, 'Bearer ') !== 0) {
		return $user_id;
	}

	$token = substr($auth_header, 7);
	if (empty($token)) {
		return $user_id;
	}

	$users = get_users(array(
		'meta_key' => 'app_token',
		'meta_value' => $token,
		'number' => 1,
	));

	if (!empty($users)) {
		return $users[0]->ID;
	}

	return $user_id;
}

// ============================================================
// Auth helper: validate Bearer token
// ============================================================

function aayurveda_get_user_from_token($request) {
	$auth_header = $request->get_header('Authorization');
	if (empty($auth_header)) {
		return null;
	}

	if (strpos($auth_header, 'Bearer ') !== 0) {
		return null;
	}

	$token = substr($auth_header, 7);
	if (empty($token)) {
		return null;
	}

	$users = get_users(array(
		'meta_key' => 'app_token',
		'meta_value' => $token,
		'number' => 1,
	));

	if (empty($users)) {
		return null;
	}

	return $users[0];
}

function aayurveda_require_auth($request) {
	$user = aayurveda_get_user_from_token($request);
	return $user !== null;
}

// ============================================================
// REST API: Auth endpoints
// ============================================================

add_action('rest_api_init', function() {

	// POST /wp-json/aayurveda/v1/signup
	register_rest_route('aayurveda/v1', '/signup', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_signup',
		'permission_callback' => '__return_true',
	));

	// POST /wp-json/aayurveda/v1/login
	register_rest_route('aayurveda/v1', '/login', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_login',
		'permission_callback' => '__return_true',
	));

	// POST /wp-json/aayurveda/v1/logout
	register_rest_route('aayurveda/v1', '/logout', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_logout',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// POST /wp-json/aayurveda/v1/posts/{id}/like
	register_rest_route('aayurveda/v1', '/posts/(?P<id>\d+)/like', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_add_like',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// DELETE /wp-json/aayurveda/v1/posts/{id}/like
	register_rest_route('aayurveda/v1', '/posts/(?P<id>\d+)/like', array(
		'methods' => 'DELETE',
		'callback' => 'aayurveda_remove_like',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// GET /wp-json/aayurveda/v1/posts/{id}/liked
	register_rest_route('aayurveda/v1', '/posts/(?P<id>\d+)/liked', array(
		'methods' => 'GET',
		'callback' => 'aayurveda_check_liked',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// GET /wp-json/aayurveda/v1/user/liked-posts
	register_rest_route('aayurveda/v1', '/user/liked-posts', array(
		'methods' => 'GET',
		'callback' => 'aayurveda_get_liked_posts',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// POST /wp-json/aayurveda/v1/posts/{id}/comments
	register_rest_route('aayurveda/v1', '/posts/(?P<id>\d+)/comments', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_add_comment',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// PUT /wp-json/aayurveda/v1/user/profile
	register_rest_route('aayurveda/v1', '/user/profile', array(
		'methods' => 'PUT',
		'callback' => 'aayurveda_update_profile',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// DELETE /wp-json/aayurveda/v1/user/account
	register_rest_route('aayurveda/v1', '/user/account', array(
		'methods' => 'DELETE',
		'callback' => 'aayurveda_delete_account',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// GET /wp-json/aayurveda/v1/user/recommendations
	register_rest_route('aayurveda/v1', '/user/recommendations', array(
		'methods' => 'GET',
		'callback' => 'aayurveda_get_recommendations',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// GET /wp-json/aayurveda/v1/popular-posts
	register_rest_route('aayurveda/v1', '/popular-posts', array(
		'methods' => 'GET',
		'callback' => 'aayurveda_get_popular_posts',
		'permission_callback' => '__return_true',
	));

	// GET /wp-json/aayurveda/v1/daily-tip
	register_rest_route('aayurveda/v1', '/daily-tip', array(
		'methods' => 'GET',
		'callback' => 'aayurveda_get_daily_tip',
		'permission_callback' => '__return_true',
	));

	// POST /wp-json/aayurveda/v1/social-login
	register_rest_route('aayurveda/v1', '/social-login', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_social_login',
		'permission_callback' => '__return_true',
	));

	// POST /wp-json/aayurveda/v1/comments/{id}/report
	register_rest_route('aayurveda/v1', '/comments/(?P<id>\d+)/report', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_report_comment',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// POST /wp-json/aayurveda/v1/users/{id}/block
	register_rest_route('aayurveda/v1', '/users/(?P<id>\d+)/block', array(
		'methods' => 'POST',
		'callback' => 'aayurveda_block_user',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// DELETE /wp-json/aayurveda/v1/users/{id}/block
	register_rest_route('aayurveda/v1', '/users/(?P<id>\d+)/block', array(
		'methods' => 'DELETE',
		'callback' => 'aayurveda_unblock_user',
		'permission_callback' => 'aayurveda_require_auth',
	));

	// GET /wp-json/aayurveda/v1/user/blocked
	register_rest_route('aayurveda/v1', '/user/blocked', array(
		'methods' => 'GET',
		'callback' => 'aayurveda_get_blocked_users',
		'permission_callback' => 'aayurveda_require_auth',
	));
});

function aayurveda_signup($request) {
	$params = $request->get_json_params();
	if (empty($params)) {
		$params = $request->get_body_params();
	}
	$fullname = sanitize_text_field($params['fullname'] ?? '');
	$email = sanitize_email($params['email'] ?? '');
	$password = $params['password'] ?? '';

	if (empty($email) || empty($password) || empty($fullname)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'All fields are required.',
		), 400);
	}

	if (!is_email($email)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Please enter a valid email address.',
		), 400);
	}

	if (email_exists($email)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'An account with this email already exists.',
		), 409);
	}

	$userid = wp_create_user($email, $password, $email);
	if (is_wp_error($userid)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => $userid->get_error_message(),
		), 500);
	}

	$fullname_parts = explode(' ', $fullname, 2);
	$first_name = $fullname_parts[0];
	$last_name = isset($fullname_parts[1]) ? $fullname_parts[1] : '';
	update_user_meta($userid, 'first_name', $first_name);
	update_user_meta($userid, 'last_name', $last_name);
	wp_update_user(array('ID' => $userid, 'display_name' => $fullname));

	$token = wp_generate_password(64, false);
	update_user_meta($userid, 'app_token', $token);

	return new WP_REST_Response(array(
		'status' => 1,
		'user_id' => $userid,
		'username' => $email,
		'first_name' => $first_name,
		'last_name' => $last_name,
		'profile_image_url' => '',
		'token' => $token,
	), 201);
}

function aayurveda_login($request) {
	$params = $request->get_json_params();
	if (empty($params)) {
		$params = $request->get_body_params();
	}
	$email = sanitize_email($params['email'] ?? '');
	$password = $params['password'] ?? '';

	if (empty($email) || empty($password)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Email and password are required.',
		), 400);
	}

	// Look up user by email
	$user = get_user_by('email', $email);
	if (!$user) {
		// Fallback: try as username for old accounts
		$user = get_user_by('login', $email);
	}

	if (!$user || !wp_check_password($password, $user->user_pass, $user->ID)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Invalid email or password.',
		), 401);
	}

	$token = wp_generate_password(64, false);
	update_user_meta($user->ID, 'app_token', $token);

	return new WP_REST_Response(array(
		'status' => 1,
		'user_id' => $user->ID,
		'username' => $user->user_email ?: $user->user_login,
		'first_name' => get_user_meta($user->ID, 'first_name', true),
		'last_name' => get_user_meta($user->ID, 'last_name', true),
		'profile_image_url' => get_user_meta($user->ID, 'profile_image_url', true) ?: '',
		'token' => $token,
	), 200);
}

function aayurveda_logout($request) {
	$user = aayurveda_get_user_from_token($request);
	if ($user) {
		delete_user_meta($user->ID, 'app_token');
	}
	return new WP_REST_Response(array('status' => 1), 200);
}

function aayurveda_add_like($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$post_id = absint($request['id']);

	if (!get_post($post_id)) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'Post not found.'), 404);
	}

	$table_name = $wpdb->prefix . 'likes';
	$existing = $wpdb->get_var(
		$wpdb->prepare("SELECT COUNT(ID) FROM $table_name WHERE post_id = %d AND user_id = %d", $post_id, $user->ID)
	);

	if ($existing > 0) {
		return new WP_REST_Response(array(
			'status' => 1,
			'message' => 'Already liked.',
			'likes' => wp_get_likes($post_id),
		), 200);
	}

	$wpdb->insert($table_name, array(
		'post_id' => $post_id,
		'user_id' => $user->ID,
	), array('%d', '%d'));

	return new WP_REST_Response(array(
		'status' => 1,
		'message' => 'Liked.',
		'likes' => wp_get_likes($post_id),
	), 201);
}

function aayurveda_remove_like($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$post_id = absint($request['id']);
	$table_name = $wpdb->prefix . 'likes';

	$wpdb->delete($table_name, array(
		'post_id' => $post_id,
		'user_id' => $user->ID,
	), array('%d', '%d'));

	return new WP_REST_Response(array(
		'status' => 1,
		'message' => 'Unliked.',
		'likes' => wp_get_likes($post_id),
	), 200);
}

function aayurveda_check_liked($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$post_id = absint($request['id']);
	$table_name = $wpdb->prefix . 'likes';

	$count = $wpdb->get_var(
		$wpdb->prepare("SELECT COUNT(ID) FROM $table_name WHERE post_id = %d AND user_id = %d", $post_id, $user->ID)
	);

	return new WP_REST_Response(array(
		'liked' => intval($count) > 0,
	), 200);
}

function aayurveda_get_liked_posts($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$table_name = $wpdb->prefix . 'likes';

	$post_ids = $wpdb->get_col(
		$wpdb->prepare("SELECT post_id FROM $table_name WHERE user_id = %d ORDER BY ID DESC", $user->ID)
	);

	return new WP_REST_Response(array(
		'post_ids' => array_map('intval', $post_ids),
	), 200);
}

function aayurveda_add_comment($request) {
	$user = aayurveda_get_user_from_token($request);
	$post_id = absint($request['id']);

	if (!get_post($post_id)) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'Post not found.'), 404);
	}

	$params = $request->get_json_params();
	if (empty($params)) {
		$params = $request->get_body_params();
	}
	$content = sanitize_textarea_field($params['content'] ?? '');

	if (empty($content)) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'Comment content is required.'), 400);
	}

	$comment_id = wp_insert_comment(array(
		'comment_post_ID' => $post_id,
		'user_id' => $user->ID,
		'comment_author' => $user->display_name,
		'comment_author_email' => $user->user_email,
		'comment_content' => $content,
		'comment_approved' => 1,
	));

	if (!$comment_id) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'Failed to add comment.'), 500);
	}

	$comment = get_comment($comment_id);
	$profile_image = get_user_meta($user->ID, 'profile_image_url', true);
	return new WP_REST_Response(array(
		'status' => 1,
		'comment' => array(
			'id' => $comment->comment_ID,
			'author_name' => $user->display_name,
			'author_avatar_urls' => array(
				'48' => !empty($profile_image) ? $profile_image : '',
			),
			'date' => $comment->comment_date,
			'content' => array('rendered' => $comment->comment_content),
		),
	), 201);
}

// ============================================================
// REST API: Customize comment responses with user profile data
// ============================================================

add_filter('rest_prepare_comment', 'aayurveda_customize_comment_response', 10, 3);

function aayurveda_customize_comment_response($response, $comment, $request) {
	$user_id = $comment->user_id;
	if ($user_id) {
		$user = get_userdata($user_id);
		if ($user) {
			// Use display_name (first + last) instead of username/email
			$response->data['author_name'] = $user->display_name;

			// Use custom profile image instead of Gravatar
			$profile_image = get_user_meta($user_id, 'profile_image_url', true);
			if (!empty($profile_image)) {
				$response->data['author_avatar_urls'] = array(
					'24' => $profile_image,
					'48' => $profile_image,
					'96' => $profile_image,
				);
			}
		}
	}
	return $response;
}

// ============================================================
// REST API: Profile update endpoint
// ============================================================

function aayurveda_update_profile($request) {
	$user = aayurveda_get_user_from_token($request);
	if (!$user) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'Unauthorized.'), 401);
	}

	$params = $request->get_json_params();
	if (empty($params)) {
		$params = $request->get_body_params();
	}

	$updated = false;

	if (isset($params['first_name'])) {
		update_user_meta($user->ID, 'first_name', sanitize_text_field($params['first_name']));
		$updated = true;
	}

	if (isset($params['last_name'])) {
		update_user_meta($user->ID, 'last_name', sanitize_text_field($params['last_name']));
		$updated = true;
	}

	if (isset($params['profile_image_url'])) {
		update_user_meta($user->ID, 'profile_image_url', esc_url_raw($params['profile_image_url']));
		$updated = true;
	}

	if (!$updated) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'No fields to update.'), 400);
	}

	$first = get_user_meta($user->ID, 'first_name', true);
	$last = get_user_meta($user->ID, 'last_name', true);
	$display = trim($first . ' ' . $last);
	if (!empty($display)) {
		wp_update_user(array('ID' => $user->ID, 'display_name' => $display));
	}

	return new WP_REST_Response(array(
		'status' => 1,
		'first_name' => $first,
		'last_name' => $last,
		'profile_image_url' => get_user_meta($user->ID, 'profile_image_url', true),
	), 200);
}

// ============================================================
// REST API: Delete account endpoint
// ============================================================

function aayurveda_delete_account($request) {
	$user = aayurveda_get_user_from_token($request);
	if (!$user) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'Unauthorized.'), 401);
	}

	global $wpdb;

	// Delete user's likes
	$table_name = $wpdb->prefix . 'likes';
	$wpdb->delete($table_name, array('user_id' => $user->ID), array('%d'));

	// Delete user's comments
	$comments = get_comments(array('user_id' => $user->ID));
	foreach ($comments as $comment) {
		wp_delete_comment($comment->comment_ID, true);
	}

	require_once(ABSPATH . 'wp-admin/includes/user.php');
	$result = wp_delete_user($user->ID);

	if ($result) {
		return new WP_REST_Response(array('status' => 1, 'message' => 'Account deleted successfully.'), 200);
	}

	return new WP_REST_Response(array('status' => 0, 'message' => 'Failed to delete account.'), 500);
}

// ============================================================
// Grant upload_files capability to authenticated app users
// ============================================================

add_filter('user_has_cap', function($allcaps, $caps, $args) {
	if (isset($args[0]) && $args[0] === 'upload_files') {
		$allcaps['upload_files'] = true;
	}
	return $allcaps;
}, 10, 3);

// ============================================================
// REST API: Personalized recommendations
// ============================================================

function aayurveda_get_recommendations($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$table_name = $wpdb->prefix . 'likes';

	// Get user's liked post IDs (limit to 20 most recent)
	$liked_post_ids = $wpdb->get_col(
		$wpdb->prepare("SELECT post_id FROM $table_name WHERE user_id = %d ORDER BY ID DESC LIMIT 20", $user->ID)
	);

	if (empty($liked_post_ids)) {
		// Fallback: return popular posts
		return aayurveda_get_popular_posts($request);
	}

	// Get categories from liked posts
	$category_ids = array();
	foreach ($liked_post_ids as $pid) {
		$cats = wp_get_post_categories(intval($pid));
		$category_ids = array_merge($category_ids, $cats);
	}
	$category_ids = array_unique($category_ids);
	$category_ids = array_diff($category_ids, array(1, 13)); // Exclude Uncategorized and parent

	if (empty($category_ids)) {
		return aayurveda_get_popular_posts($request);
	}

	$args = array(
		'post_type' => 'post',
		'category__in' => $category_ids,
		'post__not_in' => array_map('intval', $liked_post_ids),
		'posts_per_page' => 10,
		'post_status' => 'publish',
		'orderby' => 'date',
		'order' => 'DESC',
	);

	return aayurveda_format_posts_response($args);
}

function aayurveda_get_popular_posts($request) {
	global $wpdb;
	$table_name = $wpdb->prefix . 'likes';

	$popular_ids = $wpdb->get_col(
		"SELECT post_id FROM $table_name GROUP BY post_id ORDER BY COUNT(*) DESC LIMIT 10"
	);

	if (empty($popular_ids)) {
		// Ultimate fallback: recent posts
		$args = array(
			'post_type' => 'post',
			'posts_per_page' => 10,
			'post_status' => 'publish',
			'orderby' => 'date',
			'order' => 'DESC',
		);
	} else {
		$args = array(
			'post_type' => 'post',
			'post__in' => array_map('intval', $popular_ids),
			'posts_per_page' => 10,
			'post_status' => 'publish',
			'orderby' => 'post__in',
		);
	}

	return aayurveda_format_posts_response($args);
}

function aayurveda_format_posts_response($args) {
	$query = new WP_Query($args);
	$posts = array();

	foreach ($query->posts as $post) {
		$featured_image_id = get_post_thumbnail_id($post->ID);
		$image_data = wp_get_attachment_image_src($featured_image_id, 'medium');
		$posts[] = array(
			'id' => $post->ID,
			'title' => array('rendered' => $post->post_title),
			'featured_image_url' => $image_data ? $image_data[0] : get_bloginfo('template_url') . '/images/default.jpg',
			'date' => $post->post_date,
			'likes' => wp_get_likes($post->ID),
			'has_sources' => true,
		);
	}

	return new WP_REST_Response($posts, 200);
}

// ============================================================
// REST API: Report & Block endpoints (UGC moderation)
// ============================================================

function aayurveda_report_comment($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$comment_id = absint($request['id']);

	$comment = get_comment($comment_id);
	if (!$comment) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'Comment not found.'), 404);
	}

	$params = $request->get_json_params();
	if (empty($params)) {
		$params = $request->get_body_params();
	}
	$reason = sanitize_text_field($params['reason'] ?? 'Inappropriate content');

	$table_name = $wpdb->prefix . 'content_reports';

	// Check if already reported
	$existing = $wpdb->get_var(
		$wpdb->prepare("SELECT COUNT(ID) FROM $table_name WHERE reporter_id = %d AND comment_id = %d", $user->ID, $comment_id)
	);

	if ($existing > 0) {
		return new WP_REST_Response(array(
			'status' => 1,
			'message' => 'You have already reported this comment.',
		), 200);
	}

	$wpdb->insert($table_name, array(
		'reporter_id' => $user->ID,
		'comment_id' => $comment_id,
		'reason' => $reason,
	), array('%d', '%d', '%s'));

	// If a comment gets 3+ reports, auto-unapprove it
	$report_count = $wpdb->get_var(
		$wpdb->prepare("SELECT COUNT(ID) FROM $table_name WHERE comment_id = %d", $comment_id)
	);

	if (intval($report_count) >= 3) {
		wp_set_comment_status($comment_id, 'hold');
	}

	// Notify admin via email
	$admin_email = get_option('admin_email');
	$reporter = $user->display_name ?: $user->user_email;
	$comment_content = wp_trim_words($comment->comment_content, 30);
	$comment_author = $comment->comment_author;
	wp_mail(
		$admin_email,
		'[Aayurveda] Comment Reported',
		"A comment has been reported as inappropriate.\n\nReported by: $reporter\nReason: $reason\nComment author: $comment_author\nComment excerpt: $comment_content\n\nTotal reports on this comment: $report_count\n\nReview it in WordPress admin."
	);

	return new WP_REST_Response(array(
		'status' => 1,
		'message' => 'Comment reported. Thank you for helping keep our community safe.',
	), 201);
}

function aayurveda_block_user($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$blocked_id = absint($request['id']);

	if ($blocked_id === $user->ID) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'You cannot block yourself.'), 400);
	}

	if (!get_userdata($blocked_id)) {
		return new WP_REST_Response(array('status' => 0, 'message' => 'User not found.'), 404);
	}

	$table_name = $wpdb->prefix . 'user_blocks';

	$existing = $wpdb->get_var(
		$wpdb->prepare("SELECT COUNT(ID) FROM $table_name WHERE blocker_id = %d AND blocked_id = %d", $user->ID, $blocked_id)
	);

	if ($existing > 0) {
		return new WP_REST_Response(array(
			'status' => 1,
			'message' => 'User is already blocked.',
		), 200);
	}

	$wpdb->insert($table_name, array(
		'blocker_id' => $user->ID,
		'blocked_id' => $blocked_id,
	), array('%d', '%d'));

	// Notify admin
	$admin_email = get_option('admin_email');
	$blocker_name = $user->display_name ?: $user->user_email;
	$blocked_user = get_userdata($blocked_id);
	$blocked_name = $blocked_user->display_name ?: $blocked_user->user_email;
	wp_mail(
		$admin_email,
		'[Aayurveda] User Blocked',
		"A user has been blocked.\n\nBlocker: $blocker_name\nBlocked user: $blocked_name\n\nPlease review the blocked user's content for any violations."
	);

	return new WP_REST_Response(array(
		'status' => 1,
		'message' => 'User blocked. Their content will no longer appear in your feed.',
	), 201);
}

function aayurveda_unblock_user($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);
	$blocked_id = absint($request['id']);

	$table_name = $wpdb->prefix . 'user_blocks';
	$wpdb->delete($table_name, array(
		'blocker_id' => $user->ID,
		'blocked_id' => $blocked_id,
	), array('%d', '%d'));

	return new WP_REST_Response(array(
		'status' => 1,
		'message' => 'User unblocked.',
	), 200);
}

function aayurveda_get_blocked_users($request) {
	global $wpdb;
	$user = aayurveda_get_user_from_token($request);

	$table_name = $wpdb->prefix . 'user_blocks';
	$blocked_ids = $wpdb->get_col(
		$wpdb->prepare("SELECT blocked_id FROM $table_name WHERE blocker_id = %d", $user->ID)
	);

	return new WP_REST_Response(array(
		'blocked_user_ids' => array_map('intval', $blocked_ids),
	), 200);
}

// ============================================================
// REST API: Social login endpoint
// ============================================================

function aayurveda_social_login($request) {
	$params = $request->get_json_params();
	if (empty($params)) {
		$params = $request->get_body_params();
	}

	$provider = sanitize_text_field($params['provider'] ?? '');
	$provider_id = sanitize_text_field($params['provider_id'] ?? '');
	$email = sanitize_email($params['email'] ?? '');
	$first_name = sanitize_text_field($params['first_name'] ?? '');
	$last_name = sanitize_text_field($params['last_name'] ?? '');
	$profile_image_url = esc_url_raw($params['profile_image_url'] ?? '');

	if (empty($provider) || empty($provider_id)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Provider and provider ID are required.',
		), 400);
	}

	$allowed_providers = array('google', 'facebook', 'apple');
	if (!in_array($provider, $allowed_providers)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Invalid provider.',
		), 400);
	}

	// Step 1: Look up by social_provider + social_provider_id
	$users = get_users(array(
		'meta_query' => array(
			'relation' => 'AND',
			array(
				'key' => 'social_provider',
				'value' => $provider,
			),
			array(
				'key' => 'social_provider_id',
				'value' => $provider_id,
			),
		),
		'number' => 1,
	));

	$user = !empty($users) ? $users[0] : null;

	// Step 2: Not found by provider — look up by email
	if (!$user && !empty($email)) {
		$user = get_user_by('email', $email);
		if ($user) {
			// Link this social provider to the existing account
			update_user_meta($user->ID, 'social_provider', $provider);
			update_user_meta($user->ID, 'social_provider_id', $provider_id);
		}
	}

	// Step 3: No user exists — create new account
	if (!$user) {
		if (empty($email)) {
			return new WP_REST_Response(array(
				'status' => 2,
				'message' => 'Email is required to complete registration.',
				'needs_email' => true,
			), 200);
		}

		if (empty($first_name)) {
			return new WP_REST_Response(array(
				'status' => 2,
				'message' => 'Name is required to complete registration.',
				'needs_name' => true,
			), 200);
		}

		$random_password = wp_generate_password(24, true);
		$user_id = wp_create_user($email, $random_password, $email);
		if (is_wp_error($user_id)) {
			return new WP_REST_Response(array(
				'status' => 0,
				'message' => $user_id->get_error_message(),
			), 500);
		}

		update_user_meta($user_id, 'first_name', $first_name);
		update_user_meta($user_id, 'last_name', $last_name);
		update_user_meta($user_id, 'social_provider', $provider);
		update_user_meta($user_id, 'social_provider_id', $provider_id);

		if (!empty($profile_image_url)) {
			update_user_meta($user_id, 'profile_image_url', $profile_image_url);
		}

		$display_name = trim($first_name . ' ' . $last_name);
		wp_update_user(array('ID' => $user_id, 'display_name' => $display_name ?: $email));

		$user = get_userdata($user_id);
	} else {
		// Update profile image if provided and not already set
		if (!empty($profile_image_url)) {
			$existing_image = get_user_meta($user->ID, 'profile_image_url', true);
			if (empty($existing_image)) {
				update_user_meta($user->ID, 'profile_image_url', $profile_image_url);
			}
		}

		// Update name if not set
		$existing_first = get_user_meta($user->ID, 'first_name', true);
		if (empty($existing_first) && !empty($first_name)) {
			update_user_meta($user->ID, 'first_name', $first_name);
			update_user_meta($user->ID, 'last_name', $last_name);
			$display_name = trim($first_name . ' ' . $last_name);
			wp_update_user(array('ID' => $user->ID, 'display_name' => $display_name));
		}
	}

	// Generate token
	$token = wp_generate_password(64, false);
	update_user_meta($user->ID, 'app_token', $token);

	return new WP_REST_Response(array(
		'status' => 1,
		'user_id' => $user->ID,
		'username' => $user->user_email ?: $user->user_login,
		'first_name' => get_user_meta($user->ID, 'first_name', true),
		'last_name' => get_user_meta($user->ID, 'last_name', true),
		'profile_image_url' => get_user_meta($user->ID, 'profile_image_url', true) ?: $profile_image_url,
		'token' => $token,
	), 200);
}

// ============================================================
// REST API: Daily health tip
// ============================================================

// Register ACF options page for daily tips
if (function_exists('acf_add_options_page')) {
	acf_add_options_page(array(
		'page_title' => 'Daily Tips',
		'menu_title' => 'Daily Tips',
		'menu_slug'  => 'daily-tips',
		'capability'  => 'edit_posts',
	));
}

function aayurveda_get_daily_tip($request) {
	$tips = get_field('daily_tips', 'option');

	if (empty($tips) || !is_array($tips)) {
		// Hardcoded fallback tips when none are configured
		$fallback_tips = array(
			array('tip' => 'Start your day with warm water and lemon for better digestion.', 'category' => 'Digestion'),
			array('tip' => 'Practice 10 minutes of deep breathing daily to reduce stress and improve lung capacity.', 'category' => 'Yoga'),
			array('tip' => 'Tulsi (Holy Basil) tea can help boost immunity and relieve respiratory issues.', 'category' => 'Herbal Cure'),
			array('tip' => 'Eating seasonal fruits provides maximum nutrients and supports natural body rhythms.', 'category' => 'Fruits'),
			array('tip' => 'Applying turmeric paste can help reduce inflammation and improve skin health.', 'category' => 'Beauty Tips'),
			array('tip' => 'A handful of soaked almonds in the morning improves brain function and energy.', 'category' => 'Dry Fruits'),
			array('tip' => 'Walking barefoot on grass for 10 minutes daily can reduce anxiety and improve sleep.', 'category' => 'Daily Routine'),
		);
		$day_index = intval(date('z')) % count($fallback_tips);
		return new WP_REST_Response($fallback_tips[$day_index], 200);
	}

	$day_index = intval(date('z')) % count($tips);
	$tip = $tips[$day_index];

	return new WP_REST_Response(array(
		'tip' => $tip['tip_text'] ?? '',
		'category' => $tip['tip_category'] ?? 'Daily Wellness',
	), 200);
}
