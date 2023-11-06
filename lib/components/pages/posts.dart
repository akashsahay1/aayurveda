import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/texts.dart';
import '../../constants/apis.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required this.catid});
  final String catid;
  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {

  Future<List<dynamic>> fetchposts() async {
      final response = await http.get(Uri.parse(postsApi + widget.catid));
      if(response.statusCode == 200){   
        final List<dynamic> categories = json.decode(response.body);        
        return categories;
      }else{
        throw Exception('Failed to fetch posts. Status code: ${response.statusCode}');
      }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            backgroundColor: Colors.deepPurple,
            flexibleSpace: Container(
              padding: const EdgeInsets.all(16.0),
              alignment: Alignment.bottomCenter,
              child: const Text(
                AppStrings.appTitle,
                style: TextStyle(
                  fontSize: 16.0,
                  fontFamily: 'OpenSans',
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            expandedHeight: 50.0,
            pinned: true,
            floating: true,
          ),
          FutureBuilder<List<dynamic>>(
              future: fetchposts(),
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
                      child: Text("Failed to load categories!"),
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
                          final categoryId = category['id'];
                          final categoryName = category['name'];
                          return GestureDetector(
                            onTap: () => {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Posts(catid: categoryId),
                                ),
                              )
                            },
                            child: Container(
                              color: Color.fromARGB(255, 102, 7, 255),
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(0.0),
                              child: Center(
                                child: Text(
                                  categoryName+" "+categoryId.toString(),
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