import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'dart:convert';
import '../../constants/apis.dart';
import '../../models/user.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';
import 'post.dart';
import 'login.dart';

class LikedPosts extends StatefulWidget {
  const LikedPosts({super.key});

  @override
  State<LikedPosts> createState() => _LikedPostsState();
}

class _LikedPostsState extends State<LikedPosts> {
  late Future<List<Map<String, dynamic>>> _likedFuture;

  @override
  void initState() {
    super.initState();
    _likedFuture = _fetchLikedPosts();
  }

  Future<List<Map<String, dynamic>>> _fetchLikedPosts() async {
    final userState = Provider.of<UserState>(context, listen: false);
    if (!userState.isLoggedIn || userState.token == null) return [];

    final response = await http.get(
      Uri.parse(likedPostsApi),
      headers: {'Authorization': 'Bearer ${userState.token}'},
    );

    if (response.statusCode != 200) return [];

    final data = jsonDecode(response.body);
    final List<int> postIds =
        (data['post_ids'] as List).map((e) => e as int).toList();

    if (postIds.isEmpty) return [];

    final List<Map<String, dynamic>> posts = [];
    for (final id in postIds) {
      try {
        final postResponse = await http.get(Uri.parse('$postApi$id'));
        if (postResponse.statusCode == 200) {
          posts.add(json.decode(postResponse.body));
        }
      } catch (_) {}
    }
    return posts;
  }

  @override
  Widget build(BuildContext context) {
    final userState = Provider.of<UserState>(context);

    if (!userState.isLoggedIn) {
      return Scaffold(
        appBar: const Appbar(title: 'Liked Articles'),
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.favorite_border,
                  size: 64.0, color: Colors.grey),
              const SizedBox(height: 16.0),
              const Text(
                'Log in to see your liked articles',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const Login()),
                ),
                style: const ButtonStyle(
                  backgroundColor:
                      WidgetStatePropertyAll(Color(0xfff7770f)),
                  foregroundColor: WidgetStatePropertyAll(Colors.white),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
        bottomNavigationBar: const Bottombar(currentIndex: 3),
      );
    }

    return Scaffold(
      appBar: const Appbar(title: 'Liked Articles'),
      backgroundColor: Colors.white,
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _likedFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xfff7770f)),
            );
          }
          if (snapshot.hasError) {
            return const Center(
              child: Text('Failed to load liked posts.'),
            );
          }
          final posts = snapshot.data ?? [];
          if (posts.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border,
                      size: 64.0, color: Colors.grey),
                  SizedBox(height: 16.0),
                  Text(
                    'No liked articles yet',
                    style: TextStyle(fontSize: 18.0, color: Colors.grey),
                  ),
                  SizedBox(height: 8.0),
                  Text(
                    'Like articles while reading to find them here.',
                    style: TextStyle(fontSize: 14.0, color: Colors.grey),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              setState(() {
                _likedFuture = _fetchLikedPosts();
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
                final likes = post['likes'] ?? '0';
                return InkWell(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          Post(postid: post['id'], posttitle: title),
                    ),
                  ).then((_) {
                    setState(() {
                      _likedFuture = _fetchLikedPosts();
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
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      fontSize: 18.0,
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4.0),
                                  Row(
                                    children: [
                                      const Icon(Icons.thumb_up,
                                          size: 14.0, color: Colors.white70),
                                      const SizedBox(width: 4.0),
                                      Text(
                                        '$likes likes',
                                        style: const TextStyle(
                                          fontSize: 13.0,
                                          color: Colors.white70,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
      bottomNavigationBar: const Bottombar(currentIndex: 3),
    );
  }
}
