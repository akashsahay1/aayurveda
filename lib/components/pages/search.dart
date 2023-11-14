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

  WordPressPost({required this.id, required this.title, required this.date, required this.thumbnailUrl});
}

class Search extends StatefulWidget {
  const Search({super.key});

  @override
  State<Search> createState() => _SearchState();
}

class _SearchState extends State<Search> {

  Future<List<WordPressPost>> searchPosts(String query) async {
    final String searctApiUrl = searchApi + query.toString() + '&per_page=50';
    final response = await http.get(Uri.parse(searctApiUrl));

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data.map((post) => WordPressPost(
        id: post['id'],
        title: post['title']['rendered'],
        date: DateTime.parse(post['date']),
        thumbnailUrl: post['featured_image_url'] != null ? post['featured_image_url'] : '',
      )).toList();
    } else {
      throw Exception('Failed to load posts');
    }
  }

  final TextEditingController _searchController = TextEditingController();
  List<WordPressPost> _searchResults = [];

  void _search() async {
    final query = _searchController.text;
    final results = await this.searchPosts(query);

    print(results.length);

    setState(() {
      _searchResults = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Appbar(title: 'Search'),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(15.0),
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              SizedBox(
                height: 15.0,
              ),
              TextField(
                controller: _searchController,
                style: TextStyle(
                  color: Colors.white,
                ),
                decoration: InputDecoration(
                  hintText: "Search",
                  suffixIcon: IconButton(
                    onPressed: () => {
                      setState(() {
                        _searchController.clear();
                        _searchResults.clear();
                      })
                    }, 
                    icon: Icon(Icons.search)
                  ), 
                  hintStyle: TextStyle(color: Colors.white38),
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
                onSubmitted: (_) => _search(),
              ),
              SizedBox(height: 10),
              ListView.builder(
                padding: EdgeInsets.all(0.0),
                shrinkWrap: true,
                itemCount: _searchResults.length,
                itemBuilder: (context, index) {
                  final post = _searchResults[index];
                  final postid = post.id;
                  final posttitle = post.title;
                  final formattedDate = DateFormat('d-M-y h:mm a').format(post.date);
                  return InkWell(
                    onTap: () => {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => Post(postid: postid.toInt(), posttitle:posttitle),
                        ),
                      )
                    },
                    child: Card(
                      color: Colors.amber,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0), // Set the border radius here
                      ),
                      child: Container(
                        height: 100.0,
                        width: double.infinity,
                        padding: EdgeInsets.only(left: 0.0, right: 5.0),
                        child: Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 100.0,
                              width: 100.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.only(topLeft: Radius.circular(10.0), bottomLeft: Radius.circular(10.0)),
                                image: DecorationImage(
                                  image: NetworkImage(post.thumbnailUrl),
                                  fit: BoxFit.cover
                                ),
                  
                              ),
                            ),
                            SizedBox(width: 15.0,),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              mainAxisSize: MainAxisSize.max,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(height: 15.0,),
                                Text(post.title, style: TextStyle(fontSize: 20.0),),
                                SizedBox(height: 5.0,),
                                Text(formattedDate, style: TextStyle(fontSize: 16.0),)
                              ],
                            )
                          ],
                        ),
                      )
                    ),
                  );
                },
              ),             
              SizedBox(height: 10),
            ]
          )
        )
      ),
      bottomNavigationBar: Bottombar(currentIndex: 1),
    );
  }
}