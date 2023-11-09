import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/texts.dart';
import '../../constants/apis.dart';
import '../../components/pages/posts.dart';
import '../../components/common/appbar.dart';

class Categories extends StatefulWidget {
  const Categories({super.key, required this.title});
  final String title;
  @override 
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  Future<List<dynamic>> fetchCategories() async {
      final String childcatsapiurl = childcategoriesApi+"13";
      final response = await http.get(Uri.parse(childcatsapiurl));
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
          Appbar(pagetitle: AppStrings.appTitle),
          FutureBuilder<List<dynamic>>(
              future: fetchCategories(),
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
                            "Loading categories...", 
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
                      child: Text("Failed to load categories!"),
                    ),
                  );
                } else {
                  return SliverPadding(
                    padding: const EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0, bottom: 7.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.8,
                        crossAxisSpacing: 7.0,
                        mainAxisSpacing: 7.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final category = snapshot.data![index];
                          final categoryId = category['id'];
                          final categoryName = category['name'];
                          final categoryImage = category['category_image_url'];
                          return InkWell(
                            onTap: () => {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) => Posts(catid: categoryId.toString(), catname: categoryName),
                                ),
                              )
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(categoryImage),
                                  fit: BoxFit.cover
                                ),
                                color: Colors.black.withOpacity(0.5),
                                borderRadius: BorderRadius.circular(5.0)
                              ),
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(0.0),
                              child: Center(
                                child: Container(
                                  width: double.infinity,
                                  height: double.infinity,
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.5),
                                    borderRadius: BorderRadius.circular(5.0)
                                  ),
                                  child: Center(
                                    child: Text(
                                      categoryName,
                                      style: const TextStyle(
                                        color: Color.fromARGB(255, 255, 255, 255),
                                        fontSize: 14.0,
                                        fontFamily: 'OpenSans',
                                        fontWeight: FontWeight.bold,
                                      ), 
                                      textAlign: TextAlign.center,
                                    ),
                                  )
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
