import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/apis.dart';
import '../common/horizontalposts.dart';
import '../common/appbar.dart';
import '../common/bottombar.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});
  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  
  Future<Map<String, List<dynamic>>> fetchPosts() async {
      const String postsapiurl = '${postsApi}3,9,2,6,7&per_page=50';
      final response = await http.get(Uri.parse(postsapiurl));
      if(response.statusCode == 200){ 
        final List<dynamic> posts = json.decode(response.body);
        Map<String, List<Map<String, dynamic>>> categorizedPosts = {};
        for (var post in posts) {
          int categoryid = post['categories'][0];
          String categoryName = 'category_$categoryid';
          if(!categorizedPosts.containsKey(categoryName)) {
            categorizedPosts[categoryName] = [];
          }
          categorizedPosts[categoryName]!.add(post);          
        }
        
        return categorizedPosts;
      }else{
        throw Exception('Failed to fetch categories. Status code: ${response.statusCode}');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(title: 'Categories'),
      backgroundColor: Colors.black,
      body: SafeArea(
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              FutureBuilder<Map<String, List<dynamic>>>(
                future: fetchPosts(),
                builder: (BuildContext context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Column(
                      children: [
                        Container(
                          height: 400.0,
                          alignment: Alignment.center,
                          child: const CircularProgressIndicator(color: Color.fromARGB(255, 222, 205, 252)),
                        )
                      ]
                    );
                  } else if (snapshot.hasError) {
                    return Container(
                      height: 400.0,
                      alignment: Alignment.center,
                      child: const Text("Error loading posts"),
                    );                    
                  } else {
                    Map<String, List>? categorizedPosts = snapshot.data;
                    if(categorizedPosts == null){
                      return const Text("No posts");
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            HorizontalPosts('Ayurvedic Medicines', categorizedPosts['category_3']),
                            HorizontalPosts('Beauty Tips', categorizedPosts['category_9']),
                            HorizontalPosts('Dry Fruits', categorizedPosts['category_2']),
                            HorizontalPosts('Fit Daily Rutines', categorizedPosts['category_6']),
                            HorizontalPosts('Fruits', categorizedPosts['category_7']),                          
                          ],
                        )
                      ),
                    );
                  }
                },
              )              
            ]
          )
        )
      ),
      bottomNavigationBar: const Bottombar(currentIndex: 0),
    );
  }
}