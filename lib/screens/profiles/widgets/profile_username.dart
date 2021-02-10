import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/models/user.dart';

class ProfileUserName extends StatelessWidget {
  final UserModel receiver;
 static final FirebaseAuth _auth = FirebaseAuth.instance;

  ProfileUserName({
    Key key,
    @required this.theme, this.receiver,
  }) : super(key: key);

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        RichText(
          text: TextSpan(
            style: TextStyle(
              color: theme.textTheme.bodyText1.color,
              fontWeight: FontWeight.bold,
              fontFamily: 'Poppins',
            ),
            children: [
              TextSpan(
                text: receiver.name,
                style: TextStyle(
                  fontSize: theme.textTheme.headline6.fontSize,
                ),
              ),
              TextSpan(text: '\n@${receiver.username}'),
            ],
          ),
        ),
     if(receiver.uid == _auth.currentUser.uid) 
       Container()
      else Image.asset(
          'assets/icons/chat.png',
          height: 30,
          width: 30,
        ),
      ],
    );
  }
}
