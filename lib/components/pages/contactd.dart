import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../constants/apis.dart';

class Contactd extends StatefulWidget {
  const Contactd({super.key});
  @override
  State<Contactd> createState() => _ContactdState();
}

class _ContactdState extends State<Contactd> {

  Future<List<Widget>> fetchparentCategories() async {
      final String childcatsapiurl = childcategoriesApi+"13";
      final response = await http.get(Uri.parse(childcatsapiurl));
      if(response.statusCode == 200){   
        final List<Widget> categories = json.decode(response.body);  
        print(categories);           
        return categories;
      }else{
        throw Exception('Failed to fetch categories. Status code: ${response.statusCode}');
      }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [ 

          FutureBuilder(
            future: fetchparentCategories(), 
            builder: (BuildContext context, snapshot) {
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
                          final categoryName = "";
                          final categoryImage = "";
                          return InkWell(
                            onTap: () => {
                              
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
            }
          ),


          SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              children: [
                SizedBox(height: 35.0,),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 50.0,                    
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Aayurveda Categories",                   
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white                      
                    )
                  )
                ),          
                SizedBox(height: 5.0,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      15,
                      (index) => Container(
                        height: 180,
                        width: 150,
                        margin: EdgeInsets.all(8),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            'Item $index',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0,),
                Container(
                  alignment: Alignment.centerLeft,
                  height: 50.0,
                  color: Colors.deepPurple,
                  width: double.infinity,
                  padding: EdgeInsets.only(left: 15.0),
                  child: Text(
                    "Popular Cure Techniques",                   
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.white                      
                    )
                  )
                ),          
                SizedBox(height: 5.0,),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(
                      15,
                      (index) => Container(
                        height: 180,
                        width: 150,
                        margin: EdgeInsets.all(8),
                        color: Colors.blue,
                        child: Center(
                          child: Text(
                            'Item $index',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5.0,),                                  
              ],
            )
          )
        ]
      ),
    );

  }
}