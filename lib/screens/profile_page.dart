import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/models/user.dart';

import 'profiles/widgets/profile_bio.dart';
import 'profiles/widgets/profile_header.dart';
import 'profiles/widgets/profile_school_details.dart';
import 'profiles/widgets/profile_username.dart';

class UserProfilePage extends StatefulWidget {
  final UserModel receiver;

  const UserProfilePage({Key key, this.receiver}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  @override
  Widget build(BuildContext context) {
    FirebaseAuth _auth = FirebaseAuth.instance;
    var meUser = FirebaseFirestore.instance
        .collection(USERS_COLLECTION)
        .doc(_auth.currentUser.uid);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: StreamBuilder<Object>(
            stream: meUser.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(),
                );
              } else
              return ListView(
                children: [
                  Container(
                    height: 270,
                    width: double.infinity,
                    child: Stack(
                      children: [
                        Container(
                          height: 230,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            image: DecorationImage(
                                alignment: Alignment.topCenter,
                                image: NetworkImage(''),
                                fit: BoxFit.cover),
                          ),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 7.0,
                              sigmaY: 7.0,
                            ),
                            child: Container(
                              height: 40,
                              width: double.infinity,
                              color: Colors.transparent,
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: InkWell(
                            onTap: () => Navigator.of(context).pop(),
                            child: Image.asset(
                              'assets/icons/back.png',
                              height: 45,
                              width: 45,
                            ),
                          ),
                        ),
                        Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          child: Container(
                            height: 180,
                            width: 180,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: NetworkImage(''),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // ProfileHeader(
                  //   theme: theme,
                  //   receiver: widget.receiver,
                  // ), // This contains the Display Picture of the user, the back button and the edit button
                  Container(
                    margin: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      children: [
                        ProfileUserName(
                          theme: theme,
                          receiver: widget.receiver,
                        ), // This contains the Display Name, username and the message icon to message the user
                        SizedBox(
                          height: 10,
                        ),
                        ProfileBio(
                          theme: theme,
                          receiver: widget.receiver,
                        ), // A short bio about the user
                        SizedBox(
                          height: 10,
                        ),
                        ProfileSchoolDetails(
                          theme: theme,
                          receiver: widget.receiver,
                        ), // This contains Name of school, Department, Level and Date Joined
                        SizedBox(
                          height: 10,
                        ),
                        Row(
                          // This is the user's location
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/user-location.png',
                              height: 30,
                              width: 30,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: theme.textTheme.bodyText1.color,
                                ),
                                children: [
                                  TextSpan(text: 'Lagos, '),
                                  TextSpan(
                                    text: 'Nigeria',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Row(
                          // This is the user's date of birth
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Image.asset(
                              'assets/icons/calendar (1).png',
                              height: 30,
                              width: 30,
                            ),
                            SizedBox(
                              width: 10,
                            ),
                            RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  color: theme.textTheme.bodyText1.color,
                                ),
                                children: [
                                  TextSpan(
                                    text: '13th May',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 30,
                  ),
                ],
              );
            }),
      ),
    );
  }
}
