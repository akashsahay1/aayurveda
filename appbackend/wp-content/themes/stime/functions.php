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

	// Flag indicating whether this post has source citations
	$sources = get_field('sources', $post->ID);
	$response->data['has_sources'] = !empty($sources) && is_array($sources);

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
    if (is_array($sources)) {
        $labels = array_map(function($source) {
            return $source['label'];
        }, $sources);
        return implode(', ', $labels);
    }
    return '';
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
});

function aayurveda_signup($request) {
	$params = $request->get_json_params();
	if (empty($params)) {
		$params = $request->get_body_params();
	}
	$fullname = sanitize_text_field($params['fullname'] ?? '');
	$username = sanitize_user($params['username'] ?? '');
	$password = $params['password'] ?? '';

	if (empty($username) || empty($password) || empty($fullname)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'All fields are required.',
		), 400);
	}

	if (username_exists($username)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Username already exists.',
		), 409);
	}

	$userid = wp_create_user($username, $password, '');
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

	$token = wp_generate_password(64, false);
	update_user_meta($userid, 'app_token', $token);

	return new WP_REST_Response(array(
		'status' => 1,
		'user_id' => $userid,
		'username' => $username,
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
	$username = sanitize_user($params['username'] ?? '');
	$password = $params['password'] ?? '';

	if (empty($username) || empty($password)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Username and password are required.',
		), 400);
	}

	$user = wp_authenticate($username, $password);
	if (is_wp_error($user)) {
		return new WP_REST_Response(array(
			'status' => 0,
			'message' => 'Invalid username or password.',
		), 401);
	}

	$token = wp_generate_password(64, false);
	update_user_meta($user->ID, 'app_token', $token);

	return new WP_REST_Response(array(
		'status' => 1,
		'user_id' => $user->ID,
		'username' => $user->user_login,
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
	return new WP_REST_Response(array(
		'status' => 1,
		'comment' => array(
			'id' => $comment->comment_ID,
			'author_name' => $comment->comment_author,
			'date' => $comment->comment_date,
			'content' => array('rendered' => $comment->comment_content),
		),
	), 201);
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
		$sources = get_field('sources', $post->ID);

		$posts[] = array(
			'id' => $post->ID,
			'title' => array('rendered' => $post->post_title),
			'featured_image_url' => $image_data ? $image_data[0] : get_bloginfo('template_url') . '/images/default.jpg',
			'date' => $post->post_date,
			'likes' => wp_get_likes($post->ID),
			'has_sources' => !empty($sources) && is_array($sources),
		);
	}

	return new WP_REST_Response($posts, 200);
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
