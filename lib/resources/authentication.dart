import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/utils/utilities.dart';

class Authentication extends ChangeNotifier {
  String initUserName, initUserUsername, initUserImage;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  String userUid;

  String get getUserUid => userUid;

  Future getUserDetails(BuildContext context) async {
    return FirebaseFirestore.instance
        .collection(USERS_COLLECTION)
        .doc(getUserUid)
        .get()
        .then((documentSnapshot) {
      print('Fetching user data');
      initUserName = documentSnapshot.data()['name'];
      initUserName = documentSnapshot.data()['profile_photo'];
      initUserName = documentSnapshot.data()['username'];
      notifyListeners();
    });
    // return UserModel.fromMap(documentSnapshot.data());
  }

  Future signInEmailAndPassword(String email, password) async {
    UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email, password: password);
    User currentUser = userCredential.user;
    userUid = currentUser.uid;
    print(userUid);
    notifyListeners();
  }

  Future createEmailAndPassword(
      {String email,
      password,
      name,
      schoolName,
      department,
      level,
      userBio,
      username,
      profilePhoto,
      gender}) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(email: email, password: password);
      User currentUser = userCredential.user;
      userUid = currentUser.uid;
      print(userUid);
      notifyListeners();
    } catch (e) {
      print("Email issue -$e");
    }
    return null;
  }

  Future signInwithGoogle() async {
    try {
      final GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication _signInAuthentication =
          await _signInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken,
      );

      User user = (await _auth.signInWithCredential(credential)).user;

      final User currentUser = user;
      assert(currentUser.uid != null);
      userUid = currentUser.uid;
      print(userUid);
      notifyListeners();
    } catch (e) {
      print(e);
    }
  }

  Future<void> addDataToDb(User currentUser) async {
    String username = Utils.getUsername(currentUser.email);

    UserModel userModel = UserModel(
      uid: currentUser.uid,
      email: currentUser.email,
      name: currentUser.displayName,
      profilePhoto: currentUser.photoURL,
      username: username,
    );

    _firestore
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .set(userModel.toMap(userModel));
  }

  Future signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  Future submitClassData({String classTitle, dynamic classData}) {
    return FirebaseFirestore.instance
        .collection(CLASSES_COLLECTION)
        .doc(classTitle)
        .set(classData);
  }

  Future addDataToDatabase(
      {String level, department, userBio, username, schoolName, uid, dateJoined}) async {
    User currentUser = _auth.currentUser;
    FirebaseFirestore.instance
        .collection(USERS_COLLECTION)
        .doc(currentUser.uid)
        .update({
      'department': department,
      'level': level,
      'school_name': schoolName,
      'user_bio': userBio,
      'date_joined': dateJoined,
      'username': username
    }).whenComplete(() {
      print('Database data added well!');
    });
    userUid = currentUser.uid;
    assert(currentUser.uid != null);
    print(userUid);
    notifyListeners();
  }
}
