import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/provider/image_upload_provider.dart';
import 'package:scrolly/resources/chat_methods.dart';

class StorageMethods {
  static final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Reference ref = FirebaseStorage.instance.ref();

  //user class
  UserModel userModel = UserModel();

  Future<String> uploadImageToStorage(File imageFile) async {
    // mention try catch later on

    try {
      ref = FirebaseStorage.instance.ref().child('chat_pictures');
      UploadTask storageUploadTask = ref
          .child('${DateTime.now().millisecondsSinceEpoch}')
          .putFile(imageFile);
      var url = await (await storageUploadTask
              .whenComplete(() => print('storage done')))
          .ref
          .getDownloadURL();
      // print(url);
      return url;
    } catch (e) {
      return null;
    }
  }

  void uploadImage({
    @required File image,
    @required String receiverId,
    @required String senderId,
    @required ImageUploadProvider imageUploadProvider,
  }) async {
    final ChatMethods chatMethods = ChatMethods();

    // Set some loading value to db and show it to user
    imageUploadProvider.setToLoading();

    // Get url from the image bucket
    String url = await uploadImageToStorage(image);

    // Hide loading
    imageUploadProvider.setToIdle();

    chatMethods.setImageMsg(url, receiverId, senderId);
  }
}
