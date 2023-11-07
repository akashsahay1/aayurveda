import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/apis.dart';
import '../common/appbar.dart';

class Post extends StatefulWidget {
  Post({super.key, required this.postId, required this.pagetitle});
  final String postId;
  final String pagetitle;
  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  Future<List<dynamic>> fetchPost() async {
      final response = await http.get(Uri.parse(categoriesApi));
      if(response.statusCode == 200){   
        final List<dynamic> categories = json.decode(response.body);        
        return categories;
      }else{
        throw Exception('Failed to fetch categories. Status code: ${response.statusCode}');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Appbar(pagetitle: widget.pagetitle),
          FutureBuilder<List<dynamic>>(
              future: fetchPost(),
              builder:
              (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("Failed to load post!"),
                    ),
                  );
                } else {
                  return SliverPadding(
                    padding: const EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 2.5,
                        crossAxisSpacing: 7.0,
                        mainAxisSpacing: 7.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final category = snapshot.data![index];
                          final postId = category['id'];
                          final categoryName = category['name'];
                          return GestureDetector(
                            onTap: () => {
                              
                            },
                            child: Container(
                              color: Color.fromARGB(255, 102, 7, 255),
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(0.0),
                              child: Center(
                                child: Text(
                                  categoryName+" "+postId.toString(),
                                  style: const TextStyle(
                                    color: Color.fromARGB(255, 255, 255, 255),
                                    fontSize: 14.0,
                                    fontFamily: 'OpenSans',
                                    fontWeight: FontWeight.bold,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            )
                          );
                        },
                        childCount: snapshot.data!.length,
                      ),
                    ),
                  );
                }
              },
            ),
        ],
      ),
    );
  }
}