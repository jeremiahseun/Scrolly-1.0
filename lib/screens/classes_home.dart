import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/screens/classes/class_add.dart';
import 'package:scrolly/screens/classes/class_chat_body.dart';
import 'package:scrolly/screens/classes/class_chat_screen.dart';

class ClassesHome extends StatefulWidget {
  final String threadId, threadName;

  const ClassesHome({Key key, this.threadId, this.threadName})
      : super(key: key);
  _ClassesHomeState createState() => _ClassesHomeState();
}

class _ClassesHomeState extends State<ClassesHome> {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  List<DocumentSnapshot> classes;
  CollectionReference classChat =
      FirebaseFirestore.instance.collection(CLASSES_COLLECTION);

  Future<QuerySnapshot> snapshot = _db
      .collection(CLASSES_COLLECTION)
      .orderBy('course_level', descending: false)
      .get();

  @override
  void initState() {
    _fetchClasses();
    super.initState();
  }

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

  deleteClass(index) {
    String documentId;
    return classChat
        .doc(documentId)
        .delete()
        .then((value) => print("User Deleted"))
        .catchError((error) => print("Failed to delete user: $error"));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('All Classes'),
      ),
      body: ListView(
        children: [
          SizedBox(
            height: 30,
          ),
          // Padding(
          //   padding: const EdgeInsets.all(8.0),
          //   child: Text(
          //     'All Classes',
          //     style:
          //         GoogleFonts.neuton(fontSize: 32, fontWeight: FontWeight.bold),
          //   ),
          // ),
          // SizedBox(
          //   height: 50,
          // ),
          FutureBuilder<DocumentSnapshot>(
            future: classChat.doc().get(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                // classesList = snapshot.data.docs;
                // _fetchClasses();
                print('Data gotten successfully');
                return GridView.builder(
                  padding: EdgeInsets.all(12),
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    mainAxisSpacing: 20,
                    crossAxisSpacing: 20,
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, i) {
                    return InkWell(
                      splashColor: Colors.blueGrey,
                      onTap: () {
                        print('Class');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => ClassChatBody(
                              i: i,
                              classes: classes,
                              threadId: widget.threadId,
                              threadName: widget.threadName,
                            ),
                          ),
                        );
                      },
                      onLongPress: () {
                        showDialog(
                            context: context,
                            child: AlertDialog(
                                content: Text(
                                    "This chat and any related message will be deleted permanently."),
                                actions: [
                                  TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        //delete in DB, from the current list in memory and update UI
                                        deleteClass(i);
                                      },
                                      child: Text("ok")),
                                  Padding(
                                    padding: EdgeInsets.only(left: 16),
                                    child: TextButton(
                                        onPressed: () {
                                          Navigator.of(context).pop();
                                        },
                                        child: Text("cancel")),
                                  ),
                                ]));
                      },
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
                                        "${classes[i].data()['class_picture']}",
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
                                            right: 10.0,
                                          ),
                                          child: Text(
                                            "${classes[i].data()['course_title']}",
                                            style: TextStyle(
                                                fontSize: 10,
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
                                          "${classes[i].data()['course_code']}",
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
                  },
                  itemCount: classes.length < 1 ? 0 : classes.length,
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
              return Container();
            },
          ),
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
        ],
      ),
    );
  }
}
