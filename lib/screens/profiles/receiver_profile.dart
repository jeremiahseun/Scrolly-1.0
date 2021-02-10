import 'package:flutter/material.dart';
import 'package:scrolly/models/user.dart';
import 'widgets/profile_bio.dart';
import 'widgets/profile_header.dart';
import 'widgets/profile_school_details.dart';
import 'widgets/profile_username.dart';

class ReceiverProfilePage extends StatelessWidget {
  final UserModel receiver;

  const ReceiverProfilePage({Key key, this.receiver}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: ListView(
          children: [
            ProfileHeader(
              theme: theme,
              receiver: receiver,
            ), // This contains the Display Picture of the user, the back button and the edit button
            Container(
              margin: EdgeInsets.symmetric(horizontal: 15),
              child: Column(
                children: [
                  ProfileUserName(
                    theme: theme,
                    receiver: receiver,
                  ), // This contains the Display Name, username and the message icon to message the user
                  SizedBox(
                    height: 10,
                  ),
                  ProfileBio(
                    theme: theme,
                    receiver: receiver,
                  ), // A short bio about the user
                  SizedBox(
                    height: 10,
                  ),
                  ProfileSchoolDetails(
                    theme: theme,
                    receiver: receiver,
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
        ),
      ),
    );
  }
}
