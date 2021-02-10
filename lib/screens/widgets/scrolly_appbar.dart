import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/screens/profile_page.dart';

AppBar scrollyAppBar(BuildContext context, ThemeData theme,
    {Widget title,
    PreferredSizeWidget bottom,
    Widget leading,
    actions,
    UserModel meUser}) {
  FirebaseAuth _auth = FirebaseAuth.instance;
  return AppBar(
    backgroundColor: Theme.of(context).dialogBackgroundColor,
    bottom: bottom,
    leading: leading != null
        ? leading
        : Container(
            margin: EdgeInsets.all(10),
            child: InkWell(
              onTap: () {},
              child: Image.asset(
                'assets/images/Scrolly-white.png',
                fit: BoxFit.contain,
                height: 25,
                width: 35,
                color: theme.textTheme.bodyText1.color,
              ),
            ),
          ),
    title: title != null
        ? title
        : InkWell(
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => UserProfilePage(
                  receiver: meUser,
                ),
              ),
            ),
            child: CircleAvatar(
              backgroundImage: NetworkImage(_auth.currentUser.photoURL),
            ),
          ),
    centerTitle: true,
    actions: [
      actions != null
          ? actions
          : Container(
              margin: EdgeInsets.all(10),
              child: InkWell(
                onTap: () {},
                child: Image.asset(
                  'assets/icons/search.png',
                  height: 25,
                  width: 25,
                ),
              ),
            ),
    ],
  );
}
