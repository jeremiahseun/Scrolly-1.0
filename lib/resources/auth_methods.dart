import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/enum/user_state.dart';
import 'package:scrolly/models/post.dart';
import 'package:scrolly/models/post_comment.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/utils/utilities.dart';

class AuthMethods {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _firebaseStorage = FirebaseStorage.instance;

  static final CollectionReference _userCollection =
      _firestore.collection(USERS_COLLECTION);

  Future<User> getCurrentUser() async {
    User currentUser;
    currentUser = _auth.currentUser;
    return currentUser;
  }

  Future<UserModel> getUserDetails() async {
    User currentUser = await getCurrentUser();
    DocumentSnapshot documentSnapshot =
        await _userCollection.doc(currentUser.uid).get();
    return UserModel.fromMap(documentSnapshot.data());
  }

  Future<UserModel> getUserDetailsById(id) async {
    try {
      DocumentSnapshot documentSnapshot = await _userCollection.doc(id).get();
      return UserModel.fromMap(documentSnapshot.data());
    } catch (e) {
      print(e);
      return null;
    }
  }

  String userUid;
  String get getUserUid => userUid;

  // Future signInEmailAndPassword(String email, password) async {
  //   UserCredential userCredential = await _auth.signInWithEmailAndPassword(
  //       email: email, password: password);
  //   User user = userCredential.user;
  //   userUid = user.uid;
  // }

  // Future<User> createEmailAndPassword(String email, password) async {
  //   try {
  //     UserCredential userCredential = await _auth
  //         .createUserWithEmailAndPassword(email: email, password: password);
  //     User user = userCredential.user;
  //     userUid = user.uid;
  //     return user;
  //   } catch (e) {
  //     print("Email issue -$e");
  //   }
  //   return null;
  // }

  Future<User> signIn() async {
    try {
      final GoogleSignInAccount _signInAccount = await _googleSignIn.signIn();
      final GoogleSignInAuthentication _signInAuthentication =
          await _signInAccount.authentication;

      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: _signInAuthentication.accessToken,
        idToken: _signInAuthentication.idToken,
      );

      User user = (await _auth.signInWithCredential(credential)).user;
      return user;
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool> authenticateUser(User user) async {
    QuerySnapshot result = await _firestore
        .collection(USERS_COLLECTION)
        .where(EMAIL_FIELD, isEqualTo: user.email)
        .get();

    final List<DocumentSnapshot> docs = result.docs;

    //if user is registered then length of list > 0 else less than 0
    return docs.length == 0 ? true : false;
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

  Future<List<UserModel>> fetchAllUsers(User currentUser) async {
    List<UserModel> userList = List<UserModel>();

    QuerySnapshot querySnapshot =
        await _firestore.collection(USERS_COLLECTION).get();
    for (var i = 0; i < querySnapshot.docs.length; i++) {
      if (querySnapshot.docs[i].id != currentUser.uid) {
        userList.add(UserModel.fromMap(querySnapshot.docs[i].data()));
      }
    }
    return Future.value(userList);
  }

  Future<bool> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _auth.signOut();
      return true;
    } catch (e) {
      print(e);
      return false;
    }
  }

  void setUserState({@required String userId, @required UserState userState}) {
    int stateNum = Utils.stateToNum(userState);

    _userCollection.doc(userId).update({
      "state": stateNum,
    });
  }

  Stream<DocumentSnapshot> getUserStream({@required String uid}) =>
      _userCollection.doc(uid).snapshots();

  Future<Post> addPostToDb(Post post) async {
    post = Post(
      uid: post.uid,
      caption: post.caption,
      name: post.name,
      photoUrl: post.photoUrl,
      location: post.location,
      date: DateTime.now().toString(),
    );

    _firestore.collection(POSTS_COLLECTION).doc(post.uid).set(
          post.toMap(post),
        );
    return null;
  }

  Future<Post> addPostCommentToDb(PostComment postComment) async {
    Post post;
    postComment = PostComment(
      postUid: postComment.postUid,
      userUid: postComment.userUid,
      caption: postComment.caption,
      name: postComment.name,
      photoUrl: postComment.photoUrl,
      date: DateTime.now().toString(),
    );

    _firestore
        .collection(POSTS_COLLECTION)
        .doc(post.uid)
        .collection(POSTS_COMMENT_COLLECTION)
        .doc(postComment.postUid)
        .set(
          postComment.toMap(postComment),
        );
    return null;
  }
}
