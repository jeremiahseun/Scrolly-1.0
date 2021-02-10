import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/screens/classes/class_chat_body.dart';

class ChatroomHelper with ChangeNotifier {
  
  showClasses(
    BuildContext context,
    ThemeData theme,
  ) {
    StreamBuilder<QuerySnapshot>(
      stream:
          FirebaseFirestore.instance.collection(CLASSES_COLLECTION).snapshots(),
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
            children:
                snapshot.data.docs.map((DocumentSnapshot documentSnapshot) {
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
                                  // deleteClass(i);
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
                            Row(
                              children: [
                                SizedBox(
                                  width: 15,
                                ),
                                Text(
                                  "${documentSnapshot.data()['course_title']}",
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Container(
                              margin: EdgeInsets.symmetric(horizontal: 15),
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
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                content:
                    Text('Sorry, there seems to be no connection now... 😥'),
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
    );
  }
}
