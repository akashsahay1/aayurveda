import 'package:ayurveda/components/common/appbar.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/apis.dart';
import '../common/horizontalposts.dart';
import '../common/bottombar.dart';

class Categories extends StatefulWidget {
  const Categories({super.key});
  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Future<Map<String, List<dynamic>>> fetchPosts() async {
    const String postsapiurl =
        '${postsApi}2,3,4,5,6,7,8,9,10,11,12&per_page=50';
    final response = await http.get(Uri.parse(postsapiurl));
    if (response.statusCode == 200) {
      final List<dynamic> posts = json.decode(response.body);
      Map<String, List<Map<String, dynamic>>> categorizedPosts = {};
      for (var post in posts) {
        int categoryid = post['categories'][0];
        String categoryName = 'category_$categoryid';
        if (!categorizedPosts.containsKey(categoryName)) {
          categorizedPosts[categoryName] = [];
        }
        categorizedPosts[categoryName]!.add(post);
      }

      return categorizedPosts;
    } else {
      throw Exception(
          'Failed to fetch categories. Status code: ${response.statusCode}');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Appbar(
        title: 'Categories',
        showbackicon: false,
      ),
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
                    return Column(children: [
                      Container(
                        height: 400.0,
                        alignment: Alignment.center,
                        child: const CircularProgressIndicator(
                          color: Color.fromARGB(255, 222, 205, 252),
                        ),
                      )
                    ]);
                  } else if (snapshot.hasError) {
                    return Container(
                      height: 400.0,
                      alignment: Alignment.center,
                      child: const Text("Error loading posts"),
                    );
                  } else {
                    Map<String, List>? categorizedPosts = snapshot.data;
                    if (categorizedPosts == null) {
                      return const Text("No posts");
                    }
                    return SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            HorizontalPosts(
                              key: const Key('dry_fruits'),
                              categoryName: 'Dry Fruits',
                              posts: categorizedPosts['category_2'],
                            ),
                            HorizontalPosts(
                              key: const Key('ayurvedic_medicines'),
                              categoryName: 'Ayurvedic Medicines',
                              posts: categorizedPosts['category_3'],
                            ),
                            HorizontalPosts(
                              key: const Key('home_remedies'),
                              categoryName: 'Home Remedies',
                              posts: categorizedPosts['category_4'],
                            ),
                            HorizontalPosts(
                              key: const Key('yoga'),
                              categoryName: 'Yoga',
                              posts: categorizedPosts['category_5'],
                            ),
                            HorizontalPosts(
                              key: const Key('fit_daily_rutines'),
                              categoryName: 'Fit Daily Rutines',
                              posts: categorizedPosts['category_6'],
                            ),
                            HorizontalPosts(
                              key: const Key('fruits'),
                              categoryName: 'Fruits',
                              posts: categorizedPosts['category_7'],
                            ),
                            HorizontalPosts(
                              key: const Key('vegitables'),
                              categoryName: 'Vegetables',
                              posts: categorizedPosts['category_8'],
                            ),
                            HorizontalPosts(
                              key: const Key('beauty_tips'),
                              categoryName: 'Beauty Tips',
                              posts: categorizedPosts['category_9'],
                            ),
                            HorizontalPosts(
                              key: const Key('skin_fitness'),
                              categoryName: 'Skin Fitness',
                              posts: categorizedPosts['category_10'],
                            ),
                            HorizontalPosts(
                              key: const Key('skin_routine'),
                              categoryName: 'Skin Routine',
                              posts: categorizedPosts['category_11'],
                            ),
                            HorizontalPosts(
                              key: const Key('herbal_cure'),
                              categoryName: 'Herbal Cure',
                              posts: categorizedPosts['category_12'],
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
