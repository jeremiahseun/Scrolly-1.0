import 'package:flutter/material.dart';
import 'package:scrolly/screens/classes/class_chat_body.dart';
import 'package:scrolly/models/user.dart';

class ClassChatScreen extends StatelessWidget {
  final String threadId, threadName;
  final UserModel curentUserModel;

  const ClassChatScreen({Key key, this.threadId, this.threadName, this.curentUserModel})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back_ios),
      //     onPressed: () => Navigator.of(context).pop(),
      //   ),
      //   title: Text('threadName'),
      // ),
      body: ClassChatBody(
        threadId: threadId,
        userModel: curentUserModel,
        threadName: threadName,
      ),
          );
        }
      }
      
    
