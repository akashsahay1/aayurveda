import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_html/flutter_html.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../constants/apis.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';

class Post extends StatefulWidget {
  const Post({super.key, required this.postid, required this.posttitle});
  final int postid;
  final String posttitle;

  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {
  late int postid;
  late String posttitle;
  late String likes = '0';
  late String dislikes = '0';
  late String comments = '0';
  late bool likedIcon = false;

  late Future<dynamic> postFuture;

  _PostState();

  @override
  void initState() {
    super.initState();
    postid = widget.postid;
    posttitle = widget.posttitle;
    postFuture = fetchpost();
  }

  Future<dynamic> fetchpost() async {
    final String postApiUrl = postApi + postid.toString();
    final response = await http.get(Uri.parse(postApiUrl));

    if (response.statusCode == 200) {
      final post = json.decode(response.body);
      setState(() {});
      return post;
    } else {
      throw Exception(
        'Failed to fetch posts. Status code: ${response.statusCode}',
      );
    }
  }

  Future<dynamic> addLike() async {
    final Map<String, String> data = {
      'addlike': '1',
      'postid': postid.toString(),
      'userid': '1',
    };

    final response = await http.post(
      Uri.parse(ajaxApi),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: data,
    );

    if (!mounted) return;

    if (response.statusCode == 200) {
      final responseData = response.body;
      if (responseData.isNotEmpty) {
        final likeresponse = jsonDecode(responseData);
        if (likeresponse['status'] == 1) {
          debugPrint('log: $likeresponse');
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No data returned from API')),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to like')),
      );
    }
  }

  Future<dynamic> adddisLike() async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(title: widget.posttitle),
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              FutureBuilder(
                future: postFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xfff7770f),
                        ),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else {
                    final post = snapshot.data;
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            CachedNetworkImage(
                              imageUrl: post['featured_image_url'] ?? '',
                              fit: BoxFit.cover,
                              width: double.infinity,
                              height: 260.0,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xfff7770f),
                                ),
                              ),
                              errorWidget: (context, url, error) =>
                                  const Icon(Icons.error),
                            ),
                            Html(
                              data: (post['content']['rendered'] ?? '') +
                                  "<p style='font-weight: bold; font-size: 20px;'>Source: " +
                                  (post['sources'] ?? '') +
                                  "</p>",
                            ),
                            const SizedBox(
                              height: 5.0,
                            ),
                            const Divider(
                              height: 2.0,
                              color: Colors.black26,
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {
                                        addLike();
                                      },
                                      child: Row(
                                        children: [
                                          likedIcon
                                              ? const Icon(
                                                  Icons.thumb_up,
                                                  size: 28.0,
                                                  color: Color(0xfff7770f),
                                                )
                                              : const Icon(
                                                  Icons.thumb_up_alt_outlined,
                                                  size: 28.0,
                                                  color: Color(0xfff7770f),
                                                ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            post['likes'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 20.0,
                                    ),
                                    GestureDetector(
                                      onTap: () {
                                        adddisLike();
                                      },
                                      child: Row(
                                        children: [
                                          Text(
                                            post['dislikes'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          const Icon(
                                            Icons.thumb_down_alt_outlined,
                                            size: 28.0,
                                            color: Color(0xfff7770f),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    GestureDetector(
                                      onTap: () {},
                                      child: Row(
                                        children: [
                                          Text(
                                            post['comments_count'],
                                            style: const TextStyle(
                                              color: Colors.black,
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 5.0,
                                          ),
                                          Text(
                                            post['comments_count'] == '1'
                                                ? 'Comment'
                                                : 'Comments',
                                            style: const TextStyle(
                                              color: Color(0xfff7770f),
                                              fontSize: 18.0,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            const SizedBox(
                              height: 30.0,
                            ),
                          ],
                        ),
                      ),
                    );
                  }
                },
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 0),
    );
  }
}
