import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import '../../constants/apis.dart';
import '../pages/post.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';

class WordPressPost {
  final int id;
  final String title;
  final DateTime date;
  final String thumbnailUrl;

  WordPressPost(
      {required this.id,
      required this.title,
      required this.date,
      required this.thumbnailUrl});
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {
  Future<List<WordPressPost>> searchPosts(String query) async {
    final String searctApiUrl = '$searchApi$query&per_page=50';
    final response = await http.get(Uri.parse(searctApiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data
          .map((post) => WordPressPost(
                id: post['id'],
                title: post['title']['rendered'],
                date: DateTime.parse(post['date']),
                thumbnailUrl: post['featured_image_url'] ?? '',
              ))
          .toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  List<WordPressPost> _searchResults = [];

  bool _isloading = false;

  void _search() async {
    setState(() {
      _isloading = true;
    });
    final query = _searchController.text;
    final results = await searchPosts(query);
    setState(() {
      _searchResults = results;
      _isloading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Search'),
      backgroundColor: Colors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              top: 25.0,
              left: 15.0,
              right: 15.0,
              bottom: 0.0,
            ),
            child: TextField(
              controller: _searchController,
              style: const TextStyle(color: Colors.black),
              decoration: InputDecoration(
                hintText: "Search",
                suffixIcon: _isloading
                    ? Container(
                        width: 20.0,
                        height: 20.0,
                        padding: const EdgeInsets.all(12.0),
                        child: const CircularProgressIndicator(
                          strokeWidth: 3.0,
                          color: Color(0xfff7770f),
                        ),
                      )
                    : const Icon(
                        Icons.search,
                        color: Color(0xfff7770f),
                      ),
                hintStyle: const TextStyle(color: Colors.white38),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderSide: const BorderSide(
                    color: Color(0xfff7770f),
                  ),
                  borderRadius: BorderRadius.circular(10.0),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                      color: Color(0xfff7770f)), // Enabled border color
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                      color: Color(0xfff7770f),
                      width: 2.0), // Focused border color
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                      color: Colors.red, width: 2.0), // Error border color
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  borderSide: const BorderSide(
                      color: Colors.red,
                      width: 2.0), // Focused error border color
                ),
              ),
              onSubmitted: (_) => _search(),
            ),
          ),
          Expanded(
            child: ListView.separated(
              separatorBuilder: (context, index) => const SizedBox(
                height: 10.0,
              ),
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(15.0),
              itemCount: _searchResults.length,
              itemBuilder: (context, index) {
                if (index < _searchResults.length) {
                  final post = _searchResults[index];
                  final postid = post.id;
                  final posttitle = post.title;
                  final formattedDate =
                      DateFormat('d-M-y h:mm a').format(post.date);
                  return InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => Post(
                          postid: postid.toInt(),
                          posttitle: posttitle,
                        ),
                      ),
                    ),
                    child: Card(
                      color: const Color(0xfff7770f),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Container(
                        height: 100.0,
                        width: double.infinity,
                        padding: const EdgeInsets.only(
                          left: 0.0,
                          right: 5.0,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(10.0),
                                  bottomLeft: Radius.circular(10.0),
                                ),
                                image: DecorationImage(
                                  image: NetworkImage(post.thumbnailUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 15.0),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  post.title,
                                  style: const TextStyle(
                                    fontSize: 20.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(
                                  height: 5.0,
                                ),
                                Text(
                                  formattedDate,
                                  style: const TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                } else {
                  if (_searchResults.isEmpty) {
                    return const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          "Search for the articles",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    );
                  } else {
                    return const SizedBox(
                      height: 50,
                      width: 50,
                      child: Center(
                        child: Text(
                          "",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 1),
    );
  }
}
