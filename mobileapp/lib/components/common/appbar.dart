import 'package:flutter/material.dart';

class Appbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool showbackicon;

  const Appbar({super.key, required this.title, this.showbackicon = true});

  @override
  Widget build(BuildContext context) {
    return AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xfff7770f),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: showbackicon);
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
