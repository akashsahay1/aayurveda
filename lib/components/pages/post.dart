import 'package:flutter/material.dart';

class Post extends StatefulWidget {
  Post({Key? key, required this.postid, required this.posttitle}) : super(key: key);
  final int postid;
  final String posttitle;
  @override
  State<Post> createState() => _PostState();
}

class _PostState extends State<Post> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.posttitle),
        backgroundColor: Colors.amber,
        foregroundColor: Colors.deepPurple,
      ),
      body: Text(widget.posttitle),
    );
  }
}