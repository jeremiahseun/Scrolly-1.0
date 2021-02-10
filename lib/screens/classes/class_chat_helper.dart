import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/resources/authentication.dart';
import 'package:scrolly/screens/classes/user_class/user_class_home.dart';

class ClassChatHelper with ChangeNotifier {
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool hasMemberJoined = false;
  bool isTyping = false;
  bool get getHasMemberJoined => hasMemberJoined;

  sendMessage(
      {BuildContext context,
      DocumentSnapshot documentSnapshot,
      TextEditingController messageController,
      String messageType}) {
    return FirebaseFirestore.instance
        .collection(CLASSES_COLLECTION)
        .doc(documentSnapshot.id)
        .collection('messages')
        .add({
      'message': messageController.text,
      'time': Timestamp.now(),
      'userUid': _auth.currentUser.uid,
      'username': _auth.currentUser.displayName,
      'userimage': _auth.currentUser.photoURL,
      'messagetype': messageType,
    });
  }

  Future checkIfJoined(
      BuildContext context, String className, String chatroomAdminName) async {
    return FirebaseFirestore.instance
        .collection(CLASSES_COLLECTION)
        .doc(className)
        .collection('members')
        .doc(_auth.currentUser.uid)
        .get()
        .then((value) {
      hasMemberJoined = false;
      print('Initial state => $hasMemberJoined');
      if (value.data()['joined'] != null) {
        hasMemberJoined = value.data()['joined'];
        print('Final state => $hasMemberJoined');
        notifyListeners();
      }
      if (_auth.currentUser.displayName == chatroomAdminName) {
        hasMemberJoined = true;
        notifyListeners();
      }
    });
  }

  askToJoin(BuildContext context, String className, ThemeData theme) {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: theme.cardColor,
            title: Text(
              'Join $className?',
              style: TextStyle(
                color: theme.textTheme.bodyText1.color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            actions: [
              MaterialButton(
                child: Text(
                  'No',
                  style: TextStyle(
                    color: theme.textTheme.bodyText1.color,
                    fontSize: 14,
                    decoration: TextDecoration.underline,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => UserClassHome(),
                    ),
                  );
                },
              ),
              MaterialButton(
                child: Text(
                  'Yes',
                  style: TextStyle(
                    color: Colors.purple,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                onPressed: () async {
                  FirebaseFirestore.instance
                      .collection(CLASSES_COLLECTION)
                      .doc(className)
                      .collection('members')
                      .doc(_auth.currentUser.uid)
                      .set({
                    'joined': true,
                    'admin': false,
                    'typing': false,
                    'username': _auth.currentUser.displayName,
                    'userimage': _auth.currentUser.photoURL,
                    'useruid': _auth.currentUser.uid,
                    'time': Timestamp.now()
                  }).whenComplete(() {
                    Navigator.of(context).pop();
                  });
                },
              ),
            ],
          );
        });
  }
}
