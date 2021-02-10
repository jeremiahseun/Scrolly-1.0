import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/screens/posts/upload_post.dart';

class Feed extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo_outlined),
        onPressed: () {
          
        },
        elevation: 30,
      ),
    );
  }
}