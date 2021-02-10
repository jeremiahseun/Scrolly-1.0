import 'package:flutter/material.dart';
import 'package:scrolly/models/user.dart';

class ProfileBio extends StatelessWidget {
  final UserModel receiver;
  const ProfileBio({
    Key key,
    @required this.theme, this.receiver,
  }) : super(key: key);

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.topLeft,
      width: double.infinity,
      padding:
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        color: theme.dialogBackgroundColor,
        boxShadow: [
          BoxShadow(
            color: theme.textTheme.headline1.color,
            offset: Offset(-2, 2),
            blurRadius: 3,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bio',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            receiver.userBio,
            style: TextStyle(
              color: theme.textTheme.headline1.color,
              wordSpacing: 1.5,
              fontFamily: 'Poppins',
            ),
          ),
        ],
      ),
    );
  }
}