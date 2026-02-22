<?php
    require_once('../../../wp-load.php');
    if(isset($_REQUEST['signup'])){
        $response = array();
        $fullname = $_REQUEST['fullname'];
        $username = $_REQUEST['username'];
        $password = $_REQUEST['password'];
        // if(!username_exists($username)){
        //     $userid = wp_create_user($username, $password, "");
        //     $fullnamearray = explode(" ", $fullname);
        //     $firstName = array_shift($fullnamearray);
        //     $lastName = implode(' ', $fullnamearray);
        //     update_user_meta($userid, 'first_name', $firstName);
        //     update_user_meta($userid, 'last_name', $lastName);
        //     $response['status'] = 1;
        //     $response['userid'] = $userid;
        // }else{
            $response['status'] = 1;
        //}
        echo json_encode($response);
        exit;
    }
    if(isset($_REQUEST['addlike'])){
        $response = array();
        global $wpdb;
        $postid = $_REQUEST['postid'];
        $userid = $_REQUEST['userid'];
        $likecount = $wpdb->get_var("SELECT count(*) FROM `wp_likes` WHERE `post_id`='$postid' AND `user_id`='$userid'");
        if($likecount == 0){
            //$wpdb->insert();
        }
        $response['status'] = 1;
        $response['likecount'] = $likecount;
        echo json_encode($response);
        exit;
    }
?>
