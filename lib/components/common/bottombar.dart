import 'package:flutter/material.dart';
import '../pages/categories.dart';
import '../pages/search.dart';
import '../pages/about.dart';
import '../pages/help.dart';

class Bottombar extends StatefulWidget {
  final int currentIndex;

  const Bottombar({super.key, required this.currentIndex});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  late int currentindex;
  final List<Widget> _pages = [const Categories(), const Search(), const About(), const Help()];

  @override
  void initState() {
    super.initState();
    currentindex = widget.currentIndex;
  }

  void onItemSelected(int index) {
    setState(() {
      currentindex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[currentindex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.amber,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'About',
          ),
        ],
        currentIndex: currentindex,
        selectedItemColor: Colors.black,
        onTap: onItemSelected,
      ),
    );
  }
}
