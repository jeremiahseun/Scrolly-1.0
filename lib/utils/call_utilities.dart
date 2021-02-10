import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scrolly/models/call.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/resources/call_methods.dart';

class CallUtils {
  static final CallMethods callMethods = CallMethods();

  static dial({UserModel from, UserModel to, context}) async {
    Call call = Call(
      callerId: from.uid,
      callerName: from.name,
      callerPic: from.profilePhoto,
      receiverId: to.uid,
      receiverName: to.name,
      receiverPic: to.profilePhoto,
      channelId: Random().nextInt(1000).toString(),
    );

    bool callMade = await callMethods.makeCall(call: call);

    call.hasDialled = true;

    if (callMade) {
      print('call made with agora!');
    }
  }
}
