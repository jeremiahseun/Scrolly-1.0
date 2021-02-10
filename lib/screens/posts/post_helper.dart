import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:scrolly/constants/strings.dart';

class PostHelper with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;

  Future addLike(BuildContext context, String postId, userUid) async {
    return FirebaseFirestore.instance
        .collection(POSTS_COLLECTION)
        .doc(postId)
        .collection('likes')
        .doc(userUid)
        .set({
      'likes': FieldValue.increment(1),
      'username': _auth.currentUser.displayName,
      'userUid': _auth.currentUser.uid,
      'time': DateTime.now(),
    }).whenComplete(() {
      print('Like Added!');
      notifyListeners();
    });
  }

  Future removeLike(BuildContext context, String postId, userUid) async {
    return FirebaseFirestore.instance
        .collection(POSTS_COLLECTION)
        .doc(postId)
        .collection('likes')
        .doc(userUid)
        .delete()
        .whenComplete(() {
      print('Like Removed!');
      notifyListeners();
    });
  }
}
