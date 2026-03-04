import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/apis.dart';
import '../../models/bookmarks.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';
import 'post.dart';

class Bookmarks extends StatefulWidget {
  const Bookmarks({super.key});

  @override
  State<Bookmarks> createState() => _BookmarksState();
}

class _BookmarksState extends State<Bookmarks> {
  late Future<List<Map<String, dynamic>>> _bookmarksFuture;

  @override
  void initState() {
    super.initState();
    _bookmarksFuture = _fetchBookmarkedPosts();
  }

  Future<List<Map<String, dynamic>>> _fetchBookmarkedPosts() async {
    final bookmarkIds = await BookmarkService.getBookmarks();
    if (bookmarkIds.isEmpty) return [];

    final List<Map<String, dynamic>> posts = [];
    for (final id in bookmarkIds) {
      try {
        final response = await http.get(Uri.parse('$postApi$id'));
        if (response.statusCode == 200) {
          posts.add(json.decode(response.body));
        }
      } catch (_) {}
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Saved Articles'),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _bookmarksFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xfff7770f)),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load bookmarks.'),
            );
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bookmark_border, size: 64.0, color: Colors.grey),
                  SizedBox(height: 16.0),
                  Text(
                    'No saved articles yet',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Bookmark articles while reading to find them here.',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _bookmarksFuture = _fetchBookmarkedPosts();
              });
            },
            child: ListView.separated(
              separatorBuilder: (_, __) => const SizedBox(height: 10.0),
              padding: const EdgeInsets.all(15.0),
              itemCount: posts.length,
              itemBuilder: (context, index) {
                final post = posts[index];
                final title = post['title']['rendered'] ?? '';
                final imageUrl = post['featured_image_url'] ?? '';
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          Post(postid: post['id'], posttitle: title),
                    ),
                  ).then((_) {
                    setState(() {
                      _bookmarksFuture = _fetchBookmarkedPosts();
                    });
                  }),
                  child: Card(
                    color: const Color(0xfff7770f),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: SizedBox(
                      height: 100.0,
                      child: Row(
                        children: [
                          Container(
                            height: 100.0,
                            width: 100.0,
                            decoration: BoxDecoration(
                              borderRadius: const BorderRadius.only(
                                topLeft: Radius.circular(10.0),
                                bottomLeft: Radius.circular(10.0),
                              ),
                              image: imageUrl.isNotEmpty
                                  ? DecorationImage(
                                      image: NetworkImage(imageUrl),
                                      fit: BoxFit.cover,
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 15.0),
                          Expanded(
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 10.0),
                              child: Text(
                                title,
                                style: const TextStyle(
                                  fontSize: 18.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10.0),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 2),
    );
  }
}
