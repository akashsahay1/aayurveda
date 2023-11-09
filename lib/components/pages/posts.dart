import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/apis.dart';
import '../pages/post.dart';
import '../common/appbar.dart';

class Posts extends StatefulWidget {
  const Posts({super.key, required this.catid, required this.catname});
  final String catid;
  final String catname;
  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {

  Future<List<dynamic>> fetchposts() async {
    final response = await http.get(Uri.parse(postsApi + widget.catid));
    if(response.statusCode == 200){   
      final List<dynamic> posts = json.decode(response.body);      
      return posts;
    }else{
      throw Exception('Failed to fetch posts. Status code: ${response.statusCode}');
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          Appbar(pagetitle: widget.catname),
          FutureBuilder<List<dynamic>>(
              future: fetchposts(),
              builder:
              (BuildContext context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return SliverToBoxAdapter(
                    child: Center(                      
                      child: Column(
                        children: [
                          SizedBox(height: 60.0),
                          CircularProgressIndicator(color: Colors.deepPurple),
                          SizedBox(height: 10.0),
                          Text(
                            "Loading posts...", 
                            style: TextStyle(
                              color: Colors.black
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text("Failed to load posts!"),
                    ),
                  );
                } else {
                  if(snapshot.data!.length > 0){
                    return SliverPadding(
                      padding: const EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
                      sliver: SliverGrid(
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 1,
                          childAspectRatio: 2.0,
                          crossAxisSpacing: 7.0,
                          mainAxisSpacing: 7.0,
                        ),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            final post = snapshot.data![index];
                            final postId = post['id'];
                            final postName = post['title']['rendered'];
                            final postThumbnail = post['featured_image_url'];
                            return InkWell(
                              onTap: () => {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => Post(postId: postId.toString(), pagetitle: postName),
                                  ),
                                )
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage(postThumbnail), 
                                    fit: BoxFit.cover
                                  ),
                                  borderRadius: BorderRadius.circular(5.0)
                                ),
                                padding: const EdgeInsets.all(0.0),
                                margin: const EdgeInsets.all(0.0),
                                child: Center(
                                  child: Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      color: Colors.black.withOpacity(0.4),
                                      borderRadius: BorderRadius.circular(5.0)
                                    ),
                                    child: Center(
                                      child: Text(
                                        postName,
                                        style: const TextStyle(
                                          color: Color.fromARGB(255, 255, 255, 255),
                                          fontSize: 14.0,
                                          fontFamily: 'OpenSans',
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            );
                          },
                          childCount: snapshot.data!.length,
                        ),
                      ),
                    );
                  }else{
                    return SliverToBoxAdapter(
                      child: Center(                      
                        child: Column(
                          children: [
                            SizedBox(height: 60.0),
                            Icon(Icons.error, size: 30.0, color: Colors.greenAccent),
                            SizedBox(height: 10.0,),
                            Text(
                              "No Posts!", 
                              style: TextStyle(
                                color: Colors.black
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 10.0),                            
                          ],
                        ),
                      ),
                    );
                  }
                }
              },
            ),
        ],
      ),
    );
  }
}