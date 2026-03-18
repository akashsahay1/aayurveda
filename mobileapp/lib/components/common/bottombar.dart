import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../pages/home.dart';
import '../pages/search.dart';
import '../pages/bookmarks.dart';
import '../pages/liked_posts.dart';
import '../pages/login.dart';
import '../pages/account.dart';

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

  void onItemSelected(int index) {
    if (index == widget.currentIndex) return;
    setState(() {
      currentindex = index;
    });
    Widget page;
    switch (index) {
      case 0:
        page = const Home();
        break;
      case 1:
        page = const Search();
        break;
      case 2:
        page = const Bookmarks();
        break;
      case 3:
        page = const LikedPosts();
        break;
      case 4:
        final isLoggedIn =
            Provider.of<UserState>(context, listen: false).isLoggedIn;
        page = isLoggedIn ? const Account() : const Login();
        break;
      default:
        return;
    }
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: const Color(0xfff7770f),
      showSelectedLabels: true,
      showUnselectedLabels: true,
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
          icon: Icon(Icons.bookmark),
          label: 'Saved',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.favorite),
          label: 'Liked',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Account',
        ),
      ],
      currentIndex: currentindex,
      selectedItemColor: Colors.black,
      unselectedItemColor: Colors.white,
      onTap: onItemSelected,
    );
  }
}
