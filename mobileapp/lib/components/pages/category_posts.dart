import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/apis.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';
import 'post.dart';

class CategoryPosts extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const CategoryPosts({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<CategoryPosts> createState() => _CategoryPostsState();
}

class _CategoryPostsState extends State<CategoryPosts> {
  final List<dynamic> _posts = [];
  bool _loading = true;
  bool _hasMore = true;
  int _page = 1;

  @override
  void initState() {
    super.initState();
    _fetchPosts();
  }

  Future<void> _fetchPosts() async {
    if (!_hasMore) return;

    setState(() {
      _loading = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$postsApi${widget.categoryId}&per_page=10&page=$_page'),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          _posts.addAll(data);
          _page++;
          _hasMore = data.length >= 10;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _hasMore = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  String _timeAgo(String dateStr) {
    try {
      final date = DateTime.parse(dateStr);
      final diff = DateTime.now().difference(date);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      if (diff.inDays < 7) return '${diff.inDays}d ago';
      if (diff.inDays < 30) return '${(diff.inDays / 7).floor()}w ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (_) {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(title: widget.categoryName),
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: _posts.isEmpty && _loading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xfff7770f),
                ),
              )
            : _posts.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.article_outlined,
                            size: 56.0, color: Colors.grey[300]),
                        const SizedBox(height: 12.0),
                        Text(
                          'No posts found',
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
                    itemCount: _posts.length + (_hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == _posts.length) {
                        if (!_loading) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _fetchPosts();
                          });
                        }
                        return const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color(0xfff7770f),
                            ),
                          ),
                        );
                      }

                      final post = _posts[index];
                      final title = post['title']?['rendered'] ?? '';
                      final imageUrl = post['featured_image_url'] ?? '';
                      final postId = post['id'];
                      final date = post['date'] ?? '';
                      final likes = post['likes'] ?? '0';

                      // First post gets a large hero card
                      if (index == 0) {
                        return _buildHeroCard(
                          postId: postId,
                          title: title,
                          imageUrl: imageUrl,
                          date: date,
                          likes: likes,
                        );
                      }

                      return _buildPostCard(
                        postId: postId,
                        title: title,
                        imageUrl: imageUrl,
                        date: date,
                        likes: likes,
                      );
                    },
                  ),
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 0),
    );
  }

  Widget _buildHeroCard({
    required int postId,
    required String title,
    required String imageUrl,
    required String date,
    required String likes,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Post(postid: postId, posttitle: title),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 16.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(20),
              blurRadius: 12.0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16.0),
          child: Stack(
            children: [
              CachedNetworkImage(
                imageUrl: imageUrl,
                width: double.infinity,
                height: 220.0,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  height: 220.0,
                  color: Colors.orange[50],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xfff7770f),
                    ),
                  ),
                ),
                errorWidget: (_, __, ___) => Container(
                  height: 220.0,
                  color: Colors.orange[50],
                  child: const Icon(Icons.image, color: Colors.grey, size: 40.0),
                ),
              ),
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withAlpha(200),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 16.0,
                right: 16.0,
                bottom: 16.0,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        height: 1.3,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Icon(Icons.access_time,
                            size: 14.0, color: Colors.white.withAlpha(180)),
                        const SizedBox(width: 4.0),
                        Text(
                          _timeAgo(date),
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                        const SizedBox(width: 16.0),
                        Icon(Icons.thumb_up_outlined,
                            size: 14.0, color: Colors.white.withAlpha(180)),
                        const SizedBox(width: 4.0),
                        Text(
                          likes,
                          style: TextStyle(
                            fontSize: 12.0,
                            color: Colors.white.withAlpha(180),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPostCard({
    required int postId,
    required String title,
    required String imageUrl,
    required String date,
    required String likes,
  }) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => Post(postid: postId, posttitle: title),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12.0),
        padding: const EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14.0),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 8.0,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: CachedNetworkImage(
                imageUrl: imageUrl,
                width: 100.0,
                height: 100.0,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: 100.0,
                  height: 100.0,
                  color: Colors.orange[50],
                ),
                errorWidget: (_, __, ___) => Container(
                  width: 100.0,
                  height: 100.0,
                  color: Colors.orange[50],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
              ),
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8.0),
                  Row(
                    children: [
                      Icon(Icons.access_time,
                          size: 13.0, color: Colors.grey[400]),
                      const SizedBox(width: 4.0),
                      Text(
                        _timeAgo(date),
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(width: 14.0),
                      Icon(Icons.thumb_up_outlined,
                          size: 13.0, color: Colors.grey[400]),
                      const SizedBox(width: 4.0),
                      Text(
                        likes,
                        style: TextStyle(
                          fontSize: 12.0,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4.0),
            Icon(Icons.arrow_forward_ios, size: 14.0, color: Colors.grey[300]),
          ],
        ),
      ),
    );
  }
}
