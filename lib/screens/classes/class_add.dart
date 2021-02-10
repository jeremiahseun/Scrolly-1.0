import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_switch/flutter_switch.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/resources/authentication.dart';
import 'package:scrolly/screens/classes_home.dart';

// ignore: must_be_immutable
class AddOnlineClass extends StatefulWidget {
  @override
  _AddOnlineClassState createState() => _AddOnlineClassState();
}

class _AddOnlineClassState extends State<AddOnlineClass> {
  final TextEditingController courseTitleController = TextEditingController();
  final TextEditingController courseCodeController = TextEditingController();
  final TextEditingController levelController = TextEditingController();
  final TextEditingController classBioController = TextEditingController();

  FirebaseFirestore firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  // final _formKey = GlobalKey<FormState>();
  bool isPublic = true;
  bool isLoading = false;
  String currentUserId = _auth.currentUser.uid;
  UserModel curentUserModel;
  String courseTitle;
  String get getCourseTitle => courseTitle;

  CollectionReference classes =
      FirebaseFirestore.instance.collection(CLASSES_COLLECTION);

  Future<void> addClass() {
    courseTitle = courseTitleController.text;
    setState(() {
      isLoading = true;
    });
    var threadId =
        currentUserId + DateTime.now().millisecondsSinceEpoch.toString();

    Provider.of<Authentication>(context, listen: false)
        .submitClassData(classTitle: courseTitleController.text, classData: {
      'time': Timestamp.now(),
      'course_title': courseTitle,
      'course_code': courseCodeController.text,
      'course_level': levelController.text,
      'class_bio': classBioController.text,
      'uid': threadId,
      'class_admin': _auth.currentUser.displayName,
      'class_picture':
          'https://i.guim.co.uk/img/media/34338ef925bc9e17266fcc4299ef9c602358f6a4/0_384_5760_3456/master/5760.jpg?width=300&quality=45&auto=format&fit=max&dpr=2&s=103cee4238c50e3abdc806946577784e',
    }).then((value) {
      print("Class Added to the general place");
      FirebaseFirestore.instance
          .collection(CLASSES_COLLECTION)
          .doc(courseTitle)
          .collection('members')
          .doc(_auth.currentUser.uid)
          .set({
        'joined': true,
        'username': _auth.currentUser.displayName,
        'userimage': _auth.currentUser.photoURL,
        'useruid': _auth.currentUser.uid,
        'time': Timestamp.now()
      }).whenComplete(() {
        Navigator.of(context)
            .push(
          MaterialPageRoute(
            builder: (context) => ClassesHome(
              threadId: threadId,
              threadName: courseTitle,
            ),
          ),
        )
            .catchError((error) {
          print("Failed to create class: $error");
          showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Unable to create a class 😥 Try again later!"),
                actions: [
                  FlatButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text('Okay'),
                  ),
                ],
              );
            },
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add a new class'),
        centerTitle: true,
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : Container(
              padding: EdgeInsets.all(10),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: 10,
                    ),
                    Center(
                      child: Text(
                        'Class Details',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 22,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (courseTitleController.text.trim() == '') {
                          return 'Enter Group name';
                        }
                        return null;
                      },
                      autocorrect: true,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      textCapitalization: TextCapitalization.words,
                      toolbarOptions: ToolbarOptions(
                          copy: true, paste: true, cut: true, selectAll: true),
                      controller: courseTitleController,
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Course Title",
                          hintText: 'e.g: Introduction to Lexis and Structure'),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (courseCodeController.text.trim() == '') {
                          return 'Enter Course code';
                        }
                        return null;
                      },
                      autocorrect: true,
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      textCapitalization: TextCapitalization.characters,
                      toolbarOptions: ToolbarOptions(
                          copy: true, paste: true, cut: true, selectAll: true),
                      controller: courseCodeController,
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Course Code",
                          hintText: 'e.g: ENG 125'),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      validator: (value) {
                        if (levelController.text.trim() == '') {
                          return 'Enter the level for this class';
                        }
                        return null;
                      },
                      autocorrect: true,
                      keyboardType: TextInputType.number,
                      minLines: 1,
                      textCapitalization: TextCapitalization.characters,
                      toolbarOptions: ToolbarOptions(
                          copy: true, paste: true, cut: true, selectAll: true),
                      controller: levelController,
                      decoration: InputDecoration(
                          alignLabelWithHint: true,
                          labelText: "Level",
                          hintText: 'e.g: 200'),
                    ),
                    SizedBox(
                      height: 30,
                    ),
                    TextFormField(
                      autocorrect: true,
                      validator: (value) {
                        if (classBioController.text.trim() == '') {
                          return 'Enter short introduction for this class';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.text,
                      minLines: 1,
                      maxLines: 5,
                      textCapitalization: TextCapitalization.sentences,
                      toolbarOptions: ToolbarOptions(
                          copy: true, paste: true, cut: true, selectAll: true),
                      controller: classBioController,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        labelText: "Short bio about this class",
                      ),
                    ),
                    SizedBox(
                      height: 40,
                    ),
                    FlutterSwitch(
                      width: 120.0,
                      height: 40.0,
                      activeText: 'Public',
                      inactiveText: 'Private',
                      valueFontSize: 17.0,
                      toggleSize: 20.0,
                      value: isPublic,
                      borderRadius: 15.0,
                      padding: 8.0,
                      showOnOff: true,
                      onToggle: (val) {
                        setState(() {
                          isPublic = val;
                        });
                      },
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(isPublic
                        ? 'This means that anyone can join this class'
                        : 'This means that students join by invitation'),
                    SizedBox(
                      height: 40,
                    ),
                    Center(
                      child: MaterialButton(
                        color: Colors.purple,
                        disabledColor: Colors.grey,
                        onPressed: () {
                          if (courseTitleController.text.isNotEmpty &&
                              courseCodeController.text.isNotEmpty &&
                              levelController.text.isNotEmpty &&
                              classBioController.text.isNotEmpty) {
                            addClass();
                          }
                        },
                        child: Text(
                          'Create Class!',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
    );
  }
}
