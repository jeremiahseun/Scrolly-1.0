import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/models/contact.dart';
import 'package:scrolly/provider/user_provider.dart';
import 'package:scrolly/resources/chat_methods.dart';
import 'package:scrolly/screens/search/search_screen.dart';
import 'package:scrolly/screens/widgets/contact_view.dart';
import 'package:scrolly/screens/widgets/quiet_box.dart';

class ChatListScreen extends StatefulWidget {
  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.cardColor,
      body: ChatListContainer(),
    );
  }
}

// ignore: must_be_immutable
class ChatListContainer extends StatelessWidget {
  final ChatMethods _chatMethods = ChatMethods();
  static final FirebaseAuth auth = FirebaseAuth.instance;
  String uid = auth.currentUser.uid;

  @override
  Widget build(BuildContext context) {
    final UserProvider userProvider = Provider.of<UserProvider>(context);

    return SafeArea(
      child: ListView(
        children: [
          Container(
            padding: EdgeInsets.all(15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Conversations',
                  style: GoogleFonts.poppins(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SearchScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          Container(
            child: StreamBuilder<QuerySnapshot>(
                stream: _chatMethods.fetchContacts(
                  userId: uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    var docList = snapshot.data.docs;

                    if (docList.isEmpty) {
                      return QuietBox();
                    }
                    return ListView.builder(
                      padding: EdgeInsets.all(10),
                      itemCount: docList.length,
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        Contact contact =
                            Contact.fromMap(docList[index].data());

                        return ContactView(contact);
                      },
                    );
                  }

                  return Center(child: CircularProgressIndicator());
                }),
          ),
        ],
      ),
    );
  }
}
