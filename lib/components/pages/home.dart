import 'package:flutter/material.dart';
import '../../constants/texts.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<String>> fetchCategories() async {
      //final response = await http.get(Uri.parse(categoriesApi));
      //if (response.statusCode == 200) {        
        //final List<dynamic> data = json.decode(response.body);
        //final List<String> categories = data.map((category) => category['name'] as String).toList();
        final List<String> categories = [
          AppCategories.categories["cat1"]!,
          AppCategories.categories["cat2"]!,
          AppCategories.categories["cat3"]!,
          AppCategories.categories["cat4"]!,
          AppCategories.categories["cat5"]!,
          AppCategories.categories["cat6"]!,
          AppCategories.categories["cat7"]!,
          AppCategories.categories["cat8"]!,
          AppCategories.categories["cat9"]!,
          AppCategories.categories["cat10"]!,
          AppCategories.categories["cat11"]!,
          AppCategories.categories["cat12"]!,
        ];

        return categories;
      //} else {
        //throw Exception('Failed to fetch categories. Status code: ${response.statusCode}');
      //}
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
          FutureBuilder<List<String>>(
              future: fetchCategories(),
              builder:
                (BuildContext context, AsyncSnapshot<List<String>> snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return const SliverToBoxAdapter(
                    child: Center(
                      child: Text('Failed to load categories'),
                    ),
                  );
                } else {
                  return SliverPadding(
                    padding: const EdgeInsets.only(top: 7.0, left: 7.0, right: 7.0),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 1.5,
                        crossAxisSpacing: 7.0,
                        mainAxisSpacing: 7.0,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (BuildContext context, int index) {
                          final category = snapshot.data![index];
                          return Padding(
                            padding: const EdgeInsets.all(0.0),
                            child: Container(
                              color: Color.fromARGB(255, 255, 7, 222),
                              padding: const EdgeInsets.all(0.0),
                              margin: const EdgeInsets.all(0.0),
                              child: Center(
                                child: Text(
                                  category,
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
