import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/resources/auth_methods.dart';


class PostTextScreen extends StatefulWidget {
  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostTextScreen> {
  final AuthMethods _authMethods = AuthMethods();
  TextEditingController postEditingController = TextEditingController();
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  void postNow() async {
    if (postEditingController.text.isEmpty) {
      return showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text("Hey!"),
          content: Text("You haven't added a text 😏"),
          actions: [
            FlatButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Okay'),
            ),
          ],
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      setState(() {
        _isUploading = true;
        _uploadProgress = 0;
      });
      print('${postEditingController.text}');
      final String postText = postEditingController.text;
      User user = await _authMethods.getCurrentUser();

      UploadTask task = FirebaseStorage.instance
          .ref(POSTS_COLLECTION)
          .child(user.uid)
          .child(POSTS_COMMENT_COLLECTION)
          .putString(postText);

      // firebase_storage.Reference ref = firebase_storage.FirebaseStorage.instance
      //     .ref()
      //     .child('posts')
      //     .child(user.uid)
      //     .child(postText);

      FirebaseFirestore.instance.collection(POSTS_COLLECTION).doc(user.uid).collection(POSTS_COMMENT_COLLECTION).add({
        'name': user.displayName,
        'caption': postEditingController.text,
        'profile_photo': user.photoURL,
        'date': DateTime.now(),
        'uploadedBy': user.uid
      });

      task.snapshotEvents.listen((TaskSnapshot snapshot) {
        var totalBytes = task.snapshot.totalBytes;
        var bytesTransferred = task.snapshot.bytesTransferred;
        double progress = ((bytesTransferred * 100) / totalBytes) / 100;

        setState(() {
          _uploadProgress = progress;
        });

        print('Snapshot state: ${snapshot.state}'); // paused, running, complete
        print('Progress: ${snapshot.totalBytes / snapshot.bytesTransferred}');
      }, onError: (Object e) {
        print(e); // FirebaseException
      });

      task.then((TaskSnapshot snapshot) {
        print('Upload complete!');
        Navigator.of(context).pop();
      }).catchError((Object e) {
        print(e); // FirebaseException
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
        actions: [
          FlatButton(
            onPressed: postNow,
            child: Text('POST'),
          ),
        ],
      ),
      body: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        child: Column(
          children: [
            SizedBox(
              height: 5,
            ),
            _isUploading
                ? LoadingIndicator(
                    indicatorType: Indicator.ballClipRotate,
                  )
                : Container(),
            SizedBox(
              height: 10,
            ),
            Row(
              // mainAxisSize: MainAxisSize.min,
              children: [
                CircleAvatar(),
                SizedBox(
                  width: 10,
                ),
                Text(
                  'Jeremiah Seun',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(
              height: 5,
            ),
            Expanded(
              child: TextField(
                controller: postEditingController,
                maxLines: 20,
                minLines: 1,
                decoration: InputDecoration(hintText: "Be creative! 😎"),
              ),
            ),
            Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Add to your post'),
                IconButton(icon: Icon(Icons.add_location), onPressed: () {})
              ],
            ),
            SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }
}
