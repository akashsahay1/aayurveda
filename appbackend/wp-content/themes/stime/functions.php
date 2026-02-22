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

function customize_category_api_response($response, $post, $request) {
    $category_image = get_field('category_image', 'category_' . $post->term_id);

    if ($category_image) {
        $response->data['category_image_url'] = $category_image['url'];
    }

    return $response;
}

add_filter('rest_prepare_category', 'customize_category_api_response', 10, 3);

function wp_get_likes($postid){
	$postlikes = 0;
	global $wpdb;
	$postlikes_count = $wpdb->get_var("SELECT COUNT(`ID`) FROM `wp_likes` WHERE `post_id`='$postid'");
	if($postlikes_count != ""){
		$postlikes = $postlikes_count;
	}
	return strval($postlikes);
}

function wp_get_dislikes($postid){
	$postdislikes = 0;
	// global $wpdb;
	// $postlikes_count = $wpdb->get_var("SELECT COUNT(`ID`) FROM `wp_likes` WHERE `post_id`='$postid'");
	// if($postlikes_count != ""){
	// 	$postlikes = $postlikes_count;
	// }
	return strval($postdislikes);
}

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

    return $response;
}

add_filter('rest_prepare_post', 'customize_post_api_response', 10, 3);

function my_register_acf_fields() {
    register_rest_field( 'post',
        'sources',
        array(
            'get_callback'    => 'my_get_acf_sources',
            'update_callback' => null,
            'schema'          => null,
        )
    );
}
add_action( 'rest_api_init', 'my_register_acf_fields' );

function my_register_sources_field() {
    register_rest_field( 'post',
        'sources',
        array(
            'get_callback'    => 'my_get_sources_field',
            'update_callback' => null,  // If you don't need to update via REST API
            'schema'          => null,
        )
    );
}
add_action( 'rest_api_init', 'my_register_sources_field' );

function my_get_sources_field( $object, $field_name, $request ) {
    // Use get_field from ACF to retrieve the sources field
    $sources = get_field( $field_name, $object['id'] );
    if (is_array($sources)) {
        $labels = array_map(function($source) {
            return $source['label'];
        }, $sources);
        return implode(', ', $labels);
    }
    return '';
}
