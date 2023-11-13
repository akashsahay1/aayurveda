import 'package:flutter/material.dart';
import '../pages/categories.dart';
import '../pages/search.dart';
import '../pages/about.dart';

class Bottombar extends StatefulWidget {
  final int currentIndex;

  Bottombar({required this.currentIndex});

  @override
  State<Bottombar> createState() => _BottombarState(currentindex: currentIndex);

}

class _BottombarState extends State<Bottombar> {

  int currentindex;

  _BottombarState({required this.currentindex});

  @override
  Widget build(BuildContext context) {

    onItemSelected (index) {
      if(index == 0){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Categories(),
          ),
        );      
      }
      if(index == 1){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => Search(),
          ),
        );      
      }
      if(index == 2){
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => About(),
          ),
        );      
      }
    }

    if(currentindex == -1){
      setState(() {
        currentindex = 0;
      });
    }

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
      ],
      currentIndex: currentindex,
      selectedItemColor: Colors.black,
      onTap: onItemSelected,
    );
  }
}
