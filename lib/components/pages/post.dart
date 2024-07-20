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
  // ignore: no_logic_in_create_state
  State<Post> createState() => _PostState(postid: postid, posttitle: posttitle);
}

class _PostState extends State<Post> {
  final int postid;
  final String posttitle;

  _PostState({required this.postid, required this.posttitle});

  Future<dynamic> fetchpost() async {
    final String postApiUrl = postApi + postid.toString();
    final response = await http.get(Uri.parse(postApiUrl));

    if(response.statusCode == 200){ 
      final post = json.decode(response.body);
      return post;
    } else {
      throw Exception('Failed to fetch posts. Status code: ${response.statusCode}');
    }
  }

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
                future: fetchpost(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const SizedBox(
                      height: 300,
                      width: double.infinity,
                      child: Center(
                        child: CircularProgressIndicator(color:Colors.amber)
                      )
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
                                  child: CircularProgressIndicator(color: Colors.amber),
                                ),
                                errorWidget: (context, url, error) => const Icon(Icons.error),
                              ),
                              Html(data: post['content']['rendered'] ?? '')
                            ],
                          ),
                        ),
                    );
                  }
                },
              )
            ]
          )
        )
      ),
      bottomNavigationBar: const Bottombar(currentIndex: -1),
    );
  }
}
