import 'package:flutter/material.dart';

class Appbar extends StatefulWidget {
  const Appbar({super.key, required this.pagetitle});
  final String pagetitle;
  @override
  State<Appbar> createState() => _AppbarState();
}

class _AppbarState extends State<Appbar> {
   @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      backgroundColor: Colors.amber,
      iconTheme: IconThemeData(color: Colors.black),
      flexibleSpace: Container(
        padding: const EdgeInsets.all(16.0),
        alignment: Alignment.bottomCenter,
        child: Text(
          widget.pagetitle,
          style: TextStyle(
            fontSize: 16.0,
            fontFamily: 'OpenSans',
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          textAlign: TextAlign.center,
        ),
      ),
      floating: true,
      pinned: true,
    );
  }
}