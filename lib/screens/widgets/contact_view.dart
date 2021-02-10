import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/models/contact.dart';
import 'package:scrolly/resources/auth_methods.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/resources/chat_methods.dart';
import 'package:scrolly/screens/chat_screen.dart';
import 'package:scrolly/screens/widgets/cached_image.dart';
import 'package:scrolly/screens/widgets/custom_tile.dart';
import 'package:scrolly/screens/widgets/last_message_container.dart';
import 'package:scrolly/screens/widgets/online_dot_container.dart';

// ignore: must_be_immutable
class ContactView extends StatelessWidget {
  final Contact contact;
  AuthMethods _authMethods = AuthMethods();

  ContactView(this.contact);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<UserModel>(
      future: _authMethods.getUserDetailsById(contact.uid),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
         UserModel duser = snapshot.data;
          return ViewLayout(
            contact: duser,
          );
        }
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );
  }
}

class ViewLayout extends StatelessWidget {
  final UserModel contact;
  final ChatMethods _chatMethods = ChatMethods();

  ViewLayout({
    @required this.contact,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    FirebaseAuth auth = FirebaseAuth.instance;

    return CustomTile(
      mini: false,
      onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatScreen(
              receiver: contact,
            ),
          )),
      title: Text(
        (contact != null ? contact.name : null) != null
            ? contact.name
            : "..",
        style:
            TextStyle(color: theme.textTheme.bodyText1.color, fontSize: 16, fontWeight: FontWeight.w600),
      ),
      subtitle: LastMessageContainer(
        stream: _chatMethods.fetchLastMessageBetween(
          senderId: auth.currentUser.uid,
          receiverId: contact.uid,
        ),
      ),
      leading: Container(
        constraints: BoxConstraints(maxHeight: 60, maxWidth: 60),
        child: Stack(
          children: <Widget>[
            CachedImage(
              contact.profilePhoto,
              radius: 60,
              isRound: true,
            ),
            OnlineDotIndicator(
              uid: contact.uid,
            ),
          ],
        ),
      ),
    );
  }
}
