<?php
/**
 * Template Name: Sign Up
 *
 * @package WordPress
 * @subpackage Starkers
 * @since Starkers HTML5 3.0
 */

get_header(); ?>

<div class="center_area">
		<div class="signup_page_content">
			<p>Don't just share, have fun with sharing. Sign up to see your timeline, add friends, join groups. What is shared is what you get.</p>
		</div>
		<div class="signup_form_container">
			<div class="container">
				<center class="slogan_text center">Create Your Account</center>
				<div class="signup_form">
					<div class="row_full">
						<label class="row_full">Name</label>
						<input type="text" value="" class="fname row_half" placeholder="First"/>
						<input type="text" value="" class="lname row_half" placeholder="Last"/>
					</div>		
					<div class="row_full">
						<label class="row_full">Email Address</label>
						<input type="email" value="" class="user_email row_full" placeholder="Email Address"/>
						<div class="error_email full_row"></div>
					</div>
					<div class="row_full">
						<label class="row_full">Password</label>
						<input type="password" value="" placeholder="Password" class="upasswordsignup row_full" />
						<div class="error_password row_full"></div>
					</div>
					<div class="row_full">
						<input type="button" value="Sign Up" class="signupbtn button" />
						
					</div>
					<div class="success_msg full_row"></div>
				</div>
			</div>
		</div>
	</div>

<?php get_footer(); ?>