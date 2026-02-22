<?php
/**
 * Template Name: Acount Activate
 *
 * @package WordPress
 * @subpackage Starkers
 * @since Starkers HTML5 3.0
 */
 
get_header(); ?>

<div class="main_container">
<center>

<?php if($_GET['emailid'] && $_GET['activation']){

	global $wpdb;
	$user_email = $_GET['emailid']; $activatin_key = $_GET['activation']; $activation_date = current_time('j F Y', $gmt = 0);
	$userdetail = $wpdb->get_row("SELECT * FROM wp_custom_users WHERE user_email = '$user_email'");
	if($userdetail->currentstatus == "pending"){
		if(($userdetail->user_email == $user_email) && ($userdetail->activation_key == $activatin_key)){
			if($wpdb->update("wp_custom_users", array('currentstatus' => 'active', 'activation_date' => $activation_date), array('user_email' => $user_email), array('%s', '%s'), array('%s'))){ ?>
				<div class="succesmsg usersuccess">
					<h2 class="success_thank">Thank you. Your email is now verified.</h2>
					Your account has been activated successfully. Please log in to setup your account <a href='<?php bloginfo('url'); ?>'>here</a>.
				</div>
			<?php }else{
				echo "<div class='error usererror'>Your account was not activated. Since there was an error occurred during activation.</div>";
			}
		}else{
			echo "<div class='error usererror'>Your account was not activated. Since this email and activation key was not found.</div>";
		}
	}else{ ?>
		<div class='error usererror'>This account is already active. Please log in to your account <a href="<?php bloginfo('url'); ?>">here</a>.</div>
	<?php }

} ?>

</center>
</div> 

<?php get_footer(); ?>