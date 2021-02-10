import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/screens/classes/class_add.dart';
import 'package:scrolly/screens/classes/class_chat_body.dart';
import 'package:scrolly/screens/classes/widgets/chatroom_helper.dart';
import 'package:scrolly/screens/classes_home.dart';

class UserClassHome extends StatefulWidget {
  @override
  _UserClassHomeState createState() => _UserClassHomeState();
}

class _UserClassHomeState extends State<UserClassHome> {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static List<DocumentSnapshot> classes;
  static int i;
  static CollectionReference classChat = _db.collection(CLASSES_COLLECTION);
  ScrollController _controller;

  _scrollListener() {
    if (_controller.offset >= _controller.position.maxScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        //you can do anything here
      });
    }
    if (_controller.offset <= _controller.position.minScrollExtent &&
        !_controller.position.outOfRange) {
      setState(() {
        //you can do anything here
      });
    }
  }

  @override
  void initState() {
    _fetchClasses();
    _controller = ScrollController();
    _controller.addListener(_scrollListener); //the listener for up and down.
    super.initState();
  }

  // Future<QuerySnapshot> snapshot = _db
  //     .collection(CLASSES_COLLECTION)
  //     .doc(currentUserId)
  //     .collection('classes')
  //     .orderBy('course_level', descending: false)
  //     .get();

  _fetchClasses() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(CLASSES_COLLECTION)
          .orderBy('course_level', descending: false)
          .get();

      setState(() {
        classes = snapshot.docs;
      });
    } catch (e) {
      print(e);
    }
  }

  // deleteClass(index) {
  //   return classChat
  //       .doc()
  //       .delete()
  //       .then((value) => print("User Deleted"))
  //       .catchError((error) => print("Failed to delete user: $error"));
  // }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: ListView(
        controller: _controller,
        // shrinkWrap: true,

        children: [
          SizedBox(
            height: 30,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              'Your Classes',
              style:
                  GoogleFonts.neuton(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          SizedBox(
            height: 50,
          ),

          StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection(CLASSES_COLLECTION)
                // .doc()
                // .collection('members')
                // .where('members', arrayContains: _auth.currentUser.uid)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // _fetchClasses();
                print('Data gotten successfully');
                return GridView(
                  padding: EdgeInsets.all(12),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    crossAxisCount: 2,
                  ),
                  children: snapshot.data.docs
                      .map((DocumentSnapshot documentSnapshot) {
                    return InkWell(
                      splashColor: Colors.blueGrey,
                      onTap: () {
                        print('Class');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ClassChatBody(
                              documentSnapshot: documentSnapshot,
                            ),
                          ),
                        );
                      },
                      // onLongPress: () {
                      //   showDialog(
                      //       context: context,
                      //       child: AlertDialog(
                      //           content: Text(
                      //               "This chat and any related message will be deleted permanently."),
                      //           actions: [
                      //             TextButton(
                      //                 onPressed: () {
                      //                   Navigator.of(context).pop();
                      //                   //delete in DB, from the current list in memory and update UI
                      //                   // deleteClass(i);
                      //                 },
                      //                 child: Text("ok")),
                      //             Padding(
                      //               padding: EdgeInsets.only(left: 16),
                      //               child: TextButton(
                      //                   onPressed: () {
                      //                     Navigator.of(context).pop();
                      //                   },
                      //                   child: Text("cancel")),
                      //             ),
                      //           ]));
                      // },
                      child: Container(
                        alignment: Alignment.center,
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: theme.dialogBackgroundColor,
                          borderRadius: BorderRadius.circular(9),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Expanded(
                              child: Stack(
                                children: [
                                  Container(
                                    height: double.infinity,
                                    width: double.infinity,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(9),
                                        topRight: Radius.circular(9),
                                      ),
                                    ),
                                    child: Image(
                                      image: NetworkImage(
                                        "${documentSnapshot.data()['class_picture']}",
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                      right: 10,
                                      child: Icon(
                                        Icons.menu,
                                        color: Colors.white,
                                      )),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    height: 5,
                                  ),
                                  FittedBox(
                                    child: Row(
                                      children: [
                                        SizedBox(
                                          width: 15,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              right: 10.0),
                                          child: Text(
                                            "${documentSnapshot.data()['course_title']}",
                                            style: TextStyle(
                                                color: Colors.blue,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    margin:
                                        EdgeInsets.symmetric(horizontal: 15),
                                    child: Row(
                                      children: [
                                        Text(
                                          "${documentSnapshot.data()['course_code']}",
                                          style: TextStyle(
                                            color: Colors.blue,
                                          ),
                                        ),
                                        Spacer(),
                                        Icon(
                                          Icons.lock,
                                          size: 16,
                                        ),
                                      ],
                                    ),
                                  ),
                                  Spacer(),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      Image.asset(
                                        'assets/icons/homework.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                      Image.asset(
                                        'assets/icons/appointment-reminders.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                      Image.asset(
                                        'assets/icons/chat (1).png',
                                        height: 20,
                                        width: 20,
                                      ),
                                      Image.asset(
                                        'assets/icons/file.png',
                                        height: 20,
                                        width: 20,
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(growable: true),
                );
              } else if (snapshot.hasError) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return AlertDialog(
                      content: Text(
                          'Sorry, there seems to be no connection now... 😥'),
                      title: Text('Alert!'),
                    );
                  },
                );
              }
              return Center(
                child: Container(
                  child: Text(
                    "You haven't joined a class yet! 🙄",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
          // Provider.of<ChatroomHelper>(context, listen: false).showClasses(
          //   context,
          //   theme,
          // ),

          SizedBox(height: 30),
          InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddOnlineClass(),
              ),
            ),
            child: Container(
              margin: EdgeInsets.symmetric(horizontal: 60),
              height: 60,
              width: 100,
              decoration: BoxDecoration(
                  color: theme.cardColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10.0),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 1.2,
                        offset: Offset(0, 2),
                        color: Colors.grey,
                        spreadRadius: 0.5),
                  ]),
              child: Center(
                child: Text(
                  'Create a new class',
                  style: GoogleFonts.ubuntu(fontSize: 20),
                ),
              ),
            ),
          ),
          SizedBox(
            height: 50,
          ),
          RaisedButton(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ClassesHome(),
              ),
            ),
            child: Text('Search for classes'),
          ),
        ],
      ),
    );
  }
}
