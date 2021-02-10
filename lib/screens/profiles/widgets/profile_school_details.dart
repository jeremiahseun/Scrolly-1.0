import 'package:flutter/material.dart';
import 'package:scrolly/models/user.dart';

class ProfileSchoolDetails extends StatelessWidget {
  final UserModel receiver;
  const ProfileSchoolDetails({
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
            'Name of School',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            receiver.schoolName,
            style: TextStyle(
              color: theme.textTheme.headline1.color,
              fontFamily: 'Poppins',
              
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Department',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            receiver.department,
            style: TextStyle(
              color: theme.textTheme.headline1.color,
              fontFamily: 'Poppins',
              
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Level',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            receiver.level,
            style: TextStyle(
              color: theme.textTheme.headline1.color,
              fontFamily: 'Poppins',
             
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Text(
            'Date Joined',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Text(
            receiver.dateJoined,
            style: TextStyle(
              color: theme.textTheme.headline1.color,
              fontFamily: 'Poppins',
              
            ),
          ),
        ],
      ),
    );
  }
}