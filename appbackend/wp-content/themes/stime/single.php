<?php
/**
 * The Template for displaying all single posts.
 *
 * @package WordPress
 * @subpackage Starkers
 * @since Starkers HTML5 3.0
 */

get_header(); ?>

<?php if ( have_posts() ) while ( have_posts() ) : the_post(); ?>

<article class="single-post" id="post-<?php the_ID(); ?>">

	<?php if ( has_post_thumbnail() ) : ?>
		<div class="single-post__hero">
			<?php the_post_thumbnail( 'full' ); ?>
		</div>
	<?php endif; ?>

	<div class="single-post__container">

		<header class="single-post__header">
			<div class="single-post__meta">
				<span class="single-post__date"><?php echo get_the_date(); ?></span>
				<span class="single-post__reading-time"><?php echo ceil( str_word_count( get_the_content() ) / 200 ); ?> min read</span>
			</div>
			<h1 class="single-post__title"><?php the_title(); ?></h1>
		</header>

		<div class="single-post__content">
			<?php the_content(); ?>
		</div>

		<div class="single-post__sources">
			<h3>Sources &amp; References</h3>
			<p>
				<?php
					$sources = get_field('sources', get_the_ID());
					if ( !empty($sources) && is_string($sources) ) {
						echo esc_html($sources);
					} else {
						echo 'Charaka Samhita, Sushruta Samhita, Ashtanga Hridayam. National Institute of Ayurveda (NIA), Ministry of AYUSH, Government of India.';
					}
				?>
			</p>
		</div>

		<div class="single-post__disclaimer">
			<p><strong>Disclaimer:</strong> This content is for informational purposes only and is not medical advice. Always consult a healthcare professional before acting on any information.</p>
		</div>

		<nav class="single-post__nav">
			<div class="single-post__nav-prev"><?php previous_post_link( '%link', '&larr; %title' ); ?></div>
			<div class="single-post__nav-next"><?php next_post_link( '%link', '%title &rarr;' ); ?></div>
		</nav>

	</div>

</article>

<?php endwhile; ?>

<?php get_footer(); ?>