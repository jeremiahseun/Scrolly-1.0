import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker_gallery_camera/image_picker_gallery_camera.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/services/firebase_operations.dart';

class UploadPost with ChangeNotifier {
  File uploadPostImage;
  File get getUploadPostImage => uploadPostImage;
  String uploadPostImageUrl;
  DocumentSnapshot documentSnapshot;
  String get getUploadPostImageUrl => uploadPostImageUrl;
  UploadTask imagePostUploadTask;
  TextEditingController captionController = TextEditingController();
  FirebaseAuth _auth = FirebaseAuth.instance;
  bool isLoading = false;

  // final picker = ImagePickerGC();

  Future pickUploadPostImage(BuildContext context, ImgSource source) async {
    final uploadPostImageVal =
        await ImagePickerGC.pickImage(source: source, context: context);
    uploadPostImageVal == null
        ? print('Select Image')
        : uploadPostImage = File(uploadPostImageVal.path);
    print(uploadPostImageVal.path);

    uploadPostImage != null
        ? selectPostImage(context, ThemeData(), isLoading)
        : print('Image upload error');

    notifyListeners();
  }

  Future uploadPostImageToFirebase() async {
    Reference imageReference = FirebaseStorage.instance.ref().child(
        'posts/${_auth.currentUser.uid}${uploadPostImage.path}/${TimeOfDay.now()}');
    imagePostUploadTask = imageReference.putFile(uploadPostImage);
    await imagePostUploadTask.whenComplete(() {
      print('Post image uploaded to storage');
    });
    imageReference.getDownloadURL().then((imageUrl) {
      uploadPostImageUrl = imageUrl;
      print(uploadPostImageUrl);
    });
    notifyListeners();
  }

  selectPostImage(BuildContext context, ThemeData theme, bool isLoading) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return isLoading
              ? Container(
                  child: LinearProgressIndicator(),
                )
              : Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: theme.primaryColor,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 150),
                        child: Divider(
                          thickness: 4.0,
                          color: theme.scaffoldBackgroundColor,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        margin: EdgeInsets.only(top: 8, left: 8, right: 8),
                        height: 200.0,
                        width: 400,
                        child: Image.file(
                          uploadPostImage,
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            MaterialButton(
                              color: Colors.transparent,
                              onPressed: () {
                                Navigator.of(context).pop();
                                selectPostImageType(context, theme);
                              },
                              child: Text(
                                'Reselect',
                                style: TextStyle(
                                  color: theme.cardColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                            MaterialButton(
                              color: Colors.purple,
                              onPressed: () {
                                Fluttertoast.showToast(
                                    msg: 'Uploading in progress',
                                    gravity: ToastGravity.CENTER,
                                    timeInSecForIosWeb: 2);
                                isLoading = true;
                                uploadPostImageToFirebase().whenComplete(() {
                                  Navigator.of(context).pop();
                                  Fluttertoast.showToast(
                                      msg: 'Done!',
                                      gravity: ToastGravity.SNACKBAR,
                                      timeInSecForIosWeb: 1);
                                  isLoading = false;
                                  editPostSheet(context, theme, isLoading);
                                  print('image uploaded!');
                                });
                              },
                              child: Text(
                                'Confirm Image',
                                style: TextStyle(
                                  color: theme.cardColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
        });
  }

  selectPostImageType(BuildContext context, ThemeData theme) {
    return showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.12,
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: theme.primaryColor,
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Column(
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 150),
                  child: Divider(
                    thickness: 4.0,
                    color: theme.scaffoldBackgroundColor,
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    MaterialButton(
                      color: theme.accentColor,
                      onPressed: () {
                        pickUploadPostImage(context, ImgSource.Gallery);
                      },
                      child: Text(
                        'Gallery',
                        style: TextStyle(
                          color: theme.cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                    MaterialButton(
                      color: theme.accentColor,
                      onPressed: () {
                        pickUploadPostImage(context, ImgSource.Camera);
                      },
                      child: Text(
                        'Camera',
                        style: TextStyle(
                          color: theme.cardColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          );
        });
  }

  editPostSheet(BuildContext context, ThemeData theme, bool isLoading) {
    return showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) {
          return isLoading
              ? Container(
                  child: LinearProgressIndicator(),
                )
              : Container(
                  child: Column(
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 150),
                        child: Divider(
                          thickness: 4.0,
                          color: theme.scaffoldBackgroundColor,
                        ),
                      ),
                      Container(
                        child: Row(
                          children: [
                            Container(
                              child: Column(
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      Icons.image_aspect_ratio,
                                      color: Colors.green,
                                    ),
                                    onPressed: () {},
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      Icons.fit_screen,
                                      color: Colors.yellow,
                                    ),
                                    onPressed: () {},
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 200,
                              width: 300,
                              child: Image.file(
                                uploadPostImage,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ],
                        ),
                      ),
                      FittedBox(
                        child: Container(
                          child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Image.asset(
                                      'assets/icons/saving-book.png'),
                                ),
                                Container(
                                  height: 110,
                                  width: 5,
                                  color: theme.accentColor,
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 8,
                                      bottom: MediaQuery.of(context)
                                          .viewInsets
                                          .bottom),
                                  height: 120,
                                  width: MediaQuery.of(context).size.width * .8,
                                  child: TextField(
                                    maxLines: 5,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(100),
                                    ],
                                    maxLengthEnforced: true,
                                    maxLength: 100,
                                    controller: captionController,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Add a caption...',
                                    ),
                                  ),
                                ),
                              ]),
                        ),
                      ),
                      MaterialButton(
                        child: Text(
                          'Share',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        color: theme.accentColor,
                        onPressed: () async {
                          isLoading = true;
                          Fluttertoast.showToast(
                              msg: 'Sharing in progress',
                              gravity: ToastGravity.CENTER,
                              timeInSecForIosWeb: 2);
                          Provider.of<FirebaseOperations>(context,
                                  listen: false)
                              .uploadPostData(
                                  '${DateTime.now()} - ${captionController.text}',
                                  {
                                'caption': captionController.text,
                                'name': _auth.currentUser.displayName,
                                'picture_post': uploadPostImageUrl,
                                'profile_photo': _auth.currentUser.photoURL,
                                'uploadedBy': _auth.currentUser.uid,
                                'time': DateTime.now(),
                              }).whenComplete(() {
                            Navigator.of(context).pop();
                            Fluttertoast.showToast(
                                msg: 'Sharing completed',
                                gravity: ToastGravity.SNACKBAR,
                                timeInSecForIosWeb: 1);
                            isLoading = false;
                            print('All done! Good to go!');
                          });
                        },
                      ),
                    ],
                  ),
                  height: MediaQuery.of(context).size.height * .7,
                  width: MediaQuery.of(context).size.width,
                  decoration: BoxDecoration(
                    color: Colors.blueGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                );
        });
  }
}
