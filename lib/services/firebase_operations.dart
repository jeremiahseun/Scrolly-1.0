import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/constants/strings.dart';

class FirebaseOperations with ChangeNotifier {
  Future uploadPostData(String postId, dynamic data) async {
    return FirebaseFirestore.instance
        .collection(POSTS_COLLECTION)
        .doc(postId)
        .set(data);
  }
}
