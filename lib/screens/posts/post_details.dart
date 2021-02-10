import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/models/post.dart';
import 'package:scrolly/resources/auth_methods.dart';
import 'package:scrolly/utils/universal_variables.dart';

// ignore: must_be_immutable
class PostDetails extends StatefulWidget {
  PostDetails({
    Key key,
    @required this.theme,
    @required this.text,
    this.postComment,
    this.documentSnapshot,
  }) : super(key: key);

  final ThemeData theme;
  final List<DocumentSnapshot> postComment;
  final DocumentSnapshot documentSnapshot;
  final String text;

  @override
  _PostDetailsState createState() => _PostDetailsState();
}

class _PostDetailsState extends State<PostDetails> {
  TextEditingController _commentController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  FirebaseFirestore _db = FirebaseFirestore.instance;
  static FirebaseAuth _auth = FirebaseAuth.instance;
  final user = _auth.currentUser;

  Post post;

  List<DocumentSnapshot> postComment;

  @override
  void initState() {
    _fetchComments();
    super.initState();
  }

  _fetchComments() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(POSTS_COLLECTION)
          .doc("${widget.documentSnapshot.id}")
          .collection(POSTS_COMMENT_COLLECTION)
          .orderBy('date', descending: true)
          .get();

      setState(() {
        postComment = snapshot.docs;
      });
    } catch (e) {
      print(e);
    }
  }

  void postNow() async {
    if (_commentController.text.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hey!"),
          content: Text("You haven't added a text 😏"),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Okay'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      print('${_commentController.text}');
      final String postText = _commentController.text;
      User user = await _authMethods.getCurrentUser();

      UploadTask task = FirebaseStorage.instance
          .ref(POSTS_COLLECTION)
          .child("${widget.documentSnapshot.id}")
          .child(POSTS_COMMENT_COLLECTION)
          .putString(postText);

      // firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
      //     .ref()
      //     .child('posts')
      //     .child(user.uid)
      //     .child(postText);

      FirebaseFirestore.instance
          .collection(POSTS_COLLECTION)
          .doc("${widget.documentSnapshot.id}")
          .collection(POSTS_COMMENT_COLLECTION)
          .add({
        'name': user.displayName,
        'caption': _commentController.text,
        'profile_photo': user.photoURL,
        'date': DateTime.now(),
        'uploadedBy': user.uid
      });

      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        var totalBytes = task.snapshot.totalBytes;
        var bytesTransferred = task.snapshot.bytesTransferred;
        double progress = ((bytesTransferred * 100) / totalBytes) / 100;

        print('Snapshot state: ${snapshot.state}'); // paused, running, complete
        print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
      }, onError: (Object e) {
        print(e); // FirebaseException
      });

      task.then((TaskSnapshot snapshot) {
        print('Upload complete!');
      }).catchError((Object e) {
        print(e); // FirebaseException
      });
    }
  }

  sendComment() async {
    User user = await _authMethods.getCurrentUser();
    if (_commentController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection(POSTS_COLLECTION)
          .doc("${widget.documentSnapshot.id}")
          .collection(POSTS_COMMENT_COLLECTION)
          .add({
        'name': user.displayName,
        'comment': _commentController.text,
        'profile_photo': user.photoURL,
        'date': DateTime.now(),
        'uid': user.uid
      }).whenComplete(
        () => print('Post Comment added successfully!'),
      );
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Sorry, no comments? 😥'),
            title: Text('Alert!'),
          );
        },
      );
    }
  }

  FocusNode textFieldFocus = FocusNode();
  bool showEmojiPicker = false;

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        _commentController.text = _commentController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  @override
  Widget build(BuildContext context) {
    // var format = DateFormat("EEE, MMM d 'at' h:mm a");
    // // DateFormat("${'MMMd '}at${' HH:mm vvvv'}");
    // var postTime = format.format(
    //   DateTime.parse(
    //     widget.documentSnapshot.data()['time'],
    //   ),
    // );
    return Scaffold(
      backgroundColor: widget.theme.scaffoldBackgroundColor,
      // alignment: Alignment.center,
      body: SafeArea(
        child: ListView(
          children: [
            Stack(
              children: [
                CachedNetworkImage(
                  imageUrl: "${widget.documentSnapshot.data()['picture_post']}",
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                  // height: 300,
                  width: double.infinity,
                  fit: BoxFit.fill,
                ),
                Positioned(
                  top: 10,
                  left: 10,
                  child: IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: widget.theme.cardColor),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 10,
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                widget.text,
                style: TextStyle(
                    fontSize: 20,
                    color: widget.theme.textTheme.bodyText1.color),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    "postTime",
                    style: TextStyle(fontWeight: FontWeight.w400),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        "${widget.documentSnapshot.data()['profile_photo']}"),
                    radius: 16,
                  ),
                  SizedBox(
                    width: 10,
                  ),
                  Text(
                    "${widget.documentSnapshot.data()['name']}",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: TextField(
                textCapitalization: TextCapitalization.sentences,
                keyboardType: TextInputType.text,
                focusNode: textFieldFocus,
                onTap: () => hideEmojiContainer(),
                style: TextStyle(
                  color: widget.theme.textTheme.bodyText1.color,
                ),
                controller: _commentController,
                maxLines: 6,
                minLines: 1,
                decoration: InputDecoration(
                    suffixIcon: IconButton(
                      icon: Icon(Icons.send),
                      onPressed: () {
                        sendComment();
                        Future.delayed(Duration(milliseconds: 100))
                            .whenComplete(() => _commentController.clear());
                      },
                    ),
                    border: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          const Radius.circular(50.0),
                        ),
                        borderSide: BorderSide.none),
                    contentPadding:
                        EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                    filled: true,
                    labelText: 'Your comment...'),
              ),
            ),
            StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(POSTS_COLLECTION)
                    .doc("${widget.documentSnapshot.id}")
                    .collection(POSTS_COMMENT_COLLECTION)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    // _fetchComments();
                    return ListView(
                      children: snapshot.data.docs
                          .map((DocumentSnapshot documentSnapshot) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15.0, vertical: 5),
                          child: Container(
                            padding: const EdgeInsets.only(
                                left: 7, top: 7, bottom: 10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: widget.theme.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.blueGrey,
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(
                                          "${documentSnapshot.data()['profile_photo']}"),
                                      radius: 13,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Text(
                                      "${documentSnapshot.data()['name']}",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Text(
                                      "${documentSnapshot.data()['comment']}"),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(right: 5, top: 3),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      Text(
                                        "postTime",
                                        style: TextStyle(fontSize: 11),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  return Container();
                }),
          ],
        ),
      ),
    );
  }
}
