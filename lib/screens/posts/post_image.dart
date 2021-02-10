import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_crop/image_crop.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_indicator/loading_indicator.dart';
import 'package:scrolly/resources/auth_methods.dart';

class PostImageScreen extends StatefulWidget {
  @override
  _PostImageState createState() => _PostImageState();
}

class _PostImageState extends State<PostImageScreen> {
  File _image;
  final cropKey = GlobalKey<CropState>();

  final picker = ImagePicker();
  bool _isUploading = false;

  double _uploadProgress = 0.0;
  TextEditingController _captionController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  final AuthMethods _authMethods = AuthMethods();
  firebase_storage.FirebaseStorage storage =
      firebase_storage.FirebaseStorage.instance;

  pickFromCamera() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.camera);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
        cropImage(_image);
      });
    } catch (e) {
      print(e);
    }
  }

  pickFromFileManager() async {
    try {
      final pickedFile = await picker.getImage(source: ImageSource.gallery);
      setState(() {
        if (pickedFile != null) {
          _image = File(pickedFile.path);
        } else {
          print('No image selected.');
        }
        cropImage(_image);
      });
    } catch (e) {
      print(e);
    }
  }

  cropImage(File _image) async {
    try {
      File croppedImage = await ImageCropper.cropImage(
        sourcePath: _image.path,
        maxHeight: 30,
        aspectRatioPresets: [
          CropAspectRatioPreset.square,
          CropAspectRatioPreset.ratio3x2,
          CropAspectRatioPreset.original,
          CropAspectRatioPreset.ratio4x3,
          CropAspectRatioPreset.ratio16x9
        ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Cropper',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            showCropGrid: true,
            lockAspectRatio: false),
        iosUiSettings: IOSUiSettings(
          minimumAspectRatio: 1.0,
        ),
        cropStyle: CropStyle.rectangle,
        compressQuality: 50,
      );
      setState(() {
        _image = croppedImage;
      });
    } catch (e) {
      print(e);
    }
  }

  uploadImage() async {
    try {
      if (_image != null) {
        setState(() {
          _isUploading = true;
          _uploadProgress = 0;
        });
        User user = await _authMethods.getCurrentUser();

        // Directory appDocDir = await getApplicationDocumentsDirectory();
        // String filePath = '${appDocDir.absolute}/file-to-upload.png';

        // try {
        //   await firebase_storage.FirebaseStorage.instance
        //       .ref('files/${user.uid}')
        //       .putFile(_image);
        // } catch (e) {
        //   print(e);
        // }

        Reference ref = FirebaseStorage.instance.ref();
        TaskSnapshot addImg = await ref
            .child("image/img")
            .putFile(_image)
            .whenComplete(() => print('second completed'));

        // String fileName = DateTime.now().millisecondsSinceEpoch.toString() +
        //     path.basename(_image.path);

        firebase_storage.Reference reference =
            firebase_storage.FirebaseStorage.instance
                .ref()
                .child('posts')
                .child(user.uid)
                // .child(DateTime.now().toString())
                .child(_image.path);

        UploadTask task = reference.putFile(_image);

        TaskSnapshot snapshot =
            await task.whenComplete(() => print('task Completed'));

        // FirebaseStorage.instance.ref('posts').child(user.uid).putFile(_image);

        String downloadURL = await snapshot.ref.getDownloadURL();

        // String downloadURL = await firebase_storage.FirebaseStorage.instance
        //     .ref('posts')
        //     .child(user.uid)
        //     .child(_image.path)
        //     .getDownloadURL();

        final time = DateTime.now().toString();

        await FirebaseFirestore.instance.collection('posts').add({
          'name': user.displayName,
          'caption': _captionController.text,
          'profile_photo': user.photoURL,
          'location': _locationController.text,
          'photoUrl': downloadURL,
          'date': time,
          'uploadedBy': user.uid
        });

        task.snapshotEvents.listen((TaskSnapshot snapshot) {
          var totalBytes = task.snapshot.totalBytes;
          var bytesTransferred = task.snapshot.bytesTransferred;

          double progress = ((bytesTransferred * 100) / totalBytes) / 100;

          setState(() {
            _uploadProgress = progress;
          });

          print(
              'Snapshot state: ${snapshot.state}'); // paused, running, complete
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

        // Post post;

        // print("SO I AM !! $downloadURL");

        // try {
        //   firebaseRepository.addPostToDb(post).then(
        //         (value) => print("Real Post Added"),
        //       );
        // } catch (e) {
        //   print(e);
        // }

        // _db
        //     .collection('posts')
        //     .add({
        //       'photoUrl': downloadURL,
        //       'name': user.displayName,
        //       'caption': _captionController.text,
        //       'date': DateTime.now(),
        //       'uploadedBy': user.uid
        //     })
        //     .then((value) => print("Post Added"))
        //     .catchError((error) => print("Failed to add post: $error"));

        // try {
        //   await FirebaseFirestore.instance
        //       .collection('posts')
        //       .add(
        //         post.toMap(post),
        //       )
        //       .whenComplete(() {
        //     Navigator.of(context).pop();
        //     print('done uploading $reference and ${_captionController.text}');
        //   });
        // } catch (e) {
        //   print('CHAI $e');
        // }
      } else {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text("Hey!"),
            content: Text('Please select an Image'),
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
      }
    } catch (e) {
      print(e);
    }
  }

//   Future<Position> _determinePosition() async {
//   bool serviceEnabled;
//   LocationPermission permission = await Geolocator.checkPermission();

//   serviceEnabled = await Geolocator.isLocationServiceEnabled();
//   if (!serviceEnabled) {
//     return Future.error('Location services are disabled.');
//   }

//   permission = await Geolocator.checkPermission();
//   if (permission == LocationPermission.deniedForever) {
//     return Future.error(
//         'Location permissions are permantly denied, we cannot request permissions.');
//   }

//   if (permission == LocationPermission.denied) {
//     permission = await Geolocator.requestPermission();
//     if (permission != LocationPermission.whileInUse &&
//         permission != LocationPermission.always) {
//       return Future.error(
//           'Location permissions are denied (actual value: $permission).');
//     }
//   }

//   return await Geolocator.getCurrentPosition();
// }

  getUserLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);
    Placemark placemark = placemarks[0];
    String formatedAdress = "${placemark.locality}, ${placemark.country}";
    _locationController.text = formatedAdress;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Select Image'),
      ),
      body: _image == null
          ? Container(
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: pickFromCamera,
                    child: Column(
                      children: [
                        Icon(
                          Icons.camera_alt_rounded,
                          size: 120,
                        ),
                        Text(
                          'Snap from camera',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    onTap: pickFromFileManager,
                    child: Column(
                      children: [
                        Image.asset('assets/icons/ios-photos.png'),
                        Text(
                          'Choose from your pictures',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w800,
                              height: 1.2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
          : Container(
              child: ListView(
                children: [
                  _image != null
                      ? Image.file(
                          _image,
                          height: 400,
                          width: double.infinity,
                        )
                      : Image(
                          image: AssetImage(
                            'assets/images/placeholder.png',
                          ),
                        ),
                  SizedBox(
                    height: 10,
                  ),
                  _isUploading
                      ? LinearProgressIndicator(
                          value: _uploadProgress,
                        )
                      : Container(),
                  _isUploading
                      ? Container(
                          height: 50,
                          width: 50,
                          child: LoadingIndicator(
                            indicatorType: Indicator.ballClipRotate,
                            colors: [
                              Color(0xffed1317),
                              Color(0xffba6c6d),
                              Color(0xffb006cf),
                            ],
                          ),
                        )
                      : Container(),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _captionController,
                      maxLines: 6,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Write Caption here',
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                      controller: _locationController,
                      minLines: 1,
                      decoration: InputDecoration(
                        hintText: 'Put your location',
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: (){},
                    child: Row(
                      children: [
                        Icon(Icons.location_on_rounded),
                        Text(
                          "Get Current Location",
                          style: GoogleFonts.barlow(),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                    child: RaisedButton(
                      onPressed: uploadImage,
                      child: Text('Done'),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
