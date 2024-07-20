import 'package:flutter/material.dart';
import '../pages/categories.dart';
import '../pages/search.dart';
import '../pages/about.dart';
import '../pages/login.dart';

class Bottombar extends StatefulWidget {
  final int currentIndex;

  const Bottombar({super.key, required this.currentIndex});

  @override
  State<Bottombar> createState() => _BottombarState();
}

class _BottombarState extends State<Bottombar> {
  late int currentindex;

  @override
  void initState() {
    super.initState();
    currentindex = widget.currentIndex;
  }

  void onItemSelected(index) {
    if (index == 0) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Categories(),
        ),
      );
    }
    if (index == 1) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Search(),
        ),
      );
    }
    if (index == 2) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const About(),
        ),
      );
    }
    if (index == 3) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => const Login(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
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
          icon: Icon(Icons.question_mark),
          label: 'About',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.people),
          label: 'User',
        ),
      ],
      currentIndex: currentindex,
      selectedItemColor: Colors.black,
      onTap: onItemSelected,
    );
  }
}
