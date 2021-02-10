import 'dart:async';

import 'package:blurrycontainer/blurrycontainer.dart';

import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/models/message.dart';
import 'package:scrolly/models/user.dart';
import 'dart:io';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:image_picker/image_picker.dart';
import 'package:scrolly/resources/storage_methods.dart';
import 'package:scrolly/screens/classes/class_chat_helper.dart';
import 'package:scrolly/utils/utilities.dart';
import 'package:scrolly/resources/class_chat_methods.dart';
import 'package:scrolly/screens/widgets/cached_image.dart';
import 'package:scrolly/utils/universal_variables.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:scrolly/screens/widgets/cached_image.dart';
import 'package:linkwell/linkwell.dart';
import 'package:scrolly/provider/image_upload_provider.dart';
import 'package:scrolly/screens/widgets/modal_tile.dart';
import 'package:scrolly/services/image_services.dart';
import 'package:scrolly/enum/view_state.dart';
import 'package:scrolly/screens/classes/classes_info.dart';
import 'package:google_fonts/google_fonts.dart';

class ClassChatBody extends StatefulWidget {
  final String threadId, threadName;
  final UserModel userModel;
  final DocumentSnapshot documentSnapshot;
  final List<DocumentSnapshot> classes;
  final int i;

  const ClassChatBody(
      {Key key,
      this.threadId,
      this.userModel,
      this.threadName,
      this.classes,
      this.i,
      this.documentSnapshot})
      : super(key: key);
  @override
  _ClassChatBodyState createState() => _ClassChatBodyState();
}

class _ClassChatBodyState extends State<ClassChatBody> {
  UserModel selectedUser;
  static FirebaseAuth _auth = FirebaseAuth.instance;
  String currentUserId = _auth.currentUser.uid;
  String currentUserPhoto = _auth.currentUser.photoURL;
  String currentUserName = _auth.currentUser.displayName;

  List<DocumentSnapshot> classesMessages;
  ImageUploadProvider _imageUploadProvider;

  bool isGroupMessage = true;
  bool isAnnouncementMessage = false;
  bool isHomeworkMessage = false;
  bool isCurrentlyTyping = false;

  isMessage() {
    setState(() {
      isGroupMessage = true;
      isAnnouncementMessage = false;
      isHomeworkMessage = false;
    });

    print('Group Message');
  }

  isAnnouncement() {
    setState(() {
      isGroupMessage = false;
      isAnnouncementMessage = true;
      isHomeworkMessage = false;
    });

    print('Group Announcement');
  }

  isHomework() {
    setState(() {
      isGroupMessage = false;
      isAnnouncementMessage = false;
      isHomeworkMessage = true;
    });

    print('Group Homework');
  }

  final StorageMethods _storageMethods = StorageMethods();

  var listMessage;
  SharedPreferences prefs;
  bool isLoading = false;
  bool showEmojiPicker = false;
  bool isWriting = false;

  final TextEditingController textEditingController = TextEditingController();
  final ScrollController listScrollController = ScrollController();
  final FocusNode focusNode = FocusNode();

  Container classMessageType(String content) {
    final theme = Theme.of(context);
    return Container(
      // margin: EdgeInsets.only(left: 15, bottom: 5),
      alignment: Alignment.center,
      height: 40,
      width: 140,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(15.0),
        ),
        color: Colors.white.withOpacity(.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0x29000000),
            offset: Offset(0, 3),
            blurRadius: 6,
          ),
        ],
      ),
      child: Text(
        content,
        style: TextStyle(
            color: theme.textTheme.caption.color, fontWeight: FontWeight.bold),
      ),
    );
  }

  showKeyboard() {
    focusNode.requestFocus();
  }

  hideKeyboard() {
    focusNode.unfocus();
  }

  hideEmojiContainer() {
    setState(() {
      showEmojiPicker = false;
    });
  }

  showEmojiContainer() {
    setState(() {
      showEmojiPicker = true;
    });
  }

  @override
  void initState() {
    Provider.of<ClassChatHelper>(context, listen: false)
        .checkIfJoined(context, widget.documentSnapshot.id,
            widget.documentSnapshot.data()['class_admin'])
        .whenComplete(() async {
      if (Provider.of<ClassChatHelper>(context, listen: false)
              .getHasMemberJoined ==
          false) {
        Timer(
          Duration(milliseconds: 10),
          () => Provider.of<ClassChatHelper>(context, listen: false).askToJoin(
            context,
            widget.documentSnapshot.id,
            ThemeData(),
          ),
        );
      }
    });

    super.initState();

    // readLocal();
    initializeDateFormatting();
  }

  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }

  // readLocal() async {
  //   prefs = await SharedPreferences.getInstance();
  //   currentUserId = prefs.getString('uid') ?? '';
  //   currentUserPhoto = prefs.getString('profile_photo');
  //   currentUserName = prefs.getString('name') ?? '';

  //   imageServices = ImageServices(
  //       threadId: widget.threadId,
  //       selectedUser: selectedUser,
  //       currentUserId: currentUserId,
  //       currentUserName: currentUserName,
  //       currentUserPhoto: currentUserPhoto);
  //   setState(() {});
  // }

  addMediaModal(context) {
    final theme = Theme.of(context);
    showModalBottomSheet(
        context: context,
        elevation: 0,
        backgroundColor: theme.cardColor,
        builder: (context) {
          return Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 15),
                child: Row(
                  children: <Widget>[
                    FlatButton(
                      child: Icon(
                        Icons.close,
                      ),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Content and tools",
                          style: TextStyle(
                              color: theme.textTheme.bodyText1.color,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Flexible(
                child: ListView(
                  children: <Widget>[
                    ModalTile(
                        title: "Media",
                        subtitle: "Share Photos and Video",
                        icon: Icons.image,
                        onTap: () {
                          Navigator.of(context).pop();
                        }),
                    ModalTile(
                      title: "File",
                      subtitle: "Share files",
                      icon: Icons.tab,
                    ),
                    ModalTile(
                      title: "Contact",
                      subtitle: "Share contacts",
                      icon: Icons.contacts,
                    ),
                    ModalTile(
                      title: "Location",
                      subtitle: "Share a location",
                      icon: Icons.add_location,
                    ),
                    ModalTile(
                      title: "Schedule Call",
                      subtitle: "Arrange a skype call and get reminders",
                      icon: Icons.schedule,
                    ),
                    ModalTile(
                      title: "Create Poll",
                      subtitle: "Share polls",
                      icon: Icons.poll,
                    )
                  ],
                ),
              ),
            ],
          );
        });
  }

  _onPickImages() {
    showModalBottomSheet(
        context: context,
        builder: (builder) {
          return Container(
            height: MediaQuery.of(context).size.height * 0.30,
            padding: EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              children: <Widget>[
                Expanded(
                    child: Text(
                  'Select the image source',
                  style: TextStyle(
                      fontSize: 20.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple),
                )),
                Expanded(
                  child: FlatButton(
                      child: Text(
                        "Camera",
                        style: TextStyle(fontSize: 15.0, color: Colors.blue),
                      ),
                      onPressed: () async {
                        pickImage(source: ImageSource.camera);
                      }),
                ),
                Expanded(
                  child: FlatButton(
                      child: Text(
                        "Gallery",
                        style: TextStyle(fontSize: 15.0, color: Colors.blue),
                      ),
                      onPressed: () async {
                        pickImage(source: ImageSource.gallery);
                      }),
                )
              ],
            ),
          );
        });
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
        image: selectedImage,
        receiverId: widget.threadName,
        senderId: currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }

  Future<bool> onBackPress() {
    if (showEmojiPicker) {
      setState(() {
        showEmojiPicker = false;
      });
    } else {
      // FirebaseFirestore.instance
      //     .collection('users')
      //     .doc(currentUserId)
      //     .update({'chattingWith': null});
      // Navigator.pop(context);
      // Navigator.pushReplacementNamed(context, HomeScreen.routeName);
      Navigator.popUntil(context, (route) {
        return route.settings.arguments;
      });
    }

    return Future.value(false);
  }

  void onSendMessage({var content, int type, String recorderTime}) {
    // type: 0 = text, 1 = image, 2 = sticker, 3 = record
    if (type != 1 && content.trim() == '') {
      Fluttertoast.showToast(msg: 'Nothing to send');
    } else {
      Provider.of<ClassChatHelper>(context, listen: false).sendMessage(
          context: context,
          documentSnapshot: widget.documentSnapshot,
          messageController: textEditingController,
          messageType: isHomeworkMessage
              ? 'Homework'
              : isAnnouncementMessage
                  ? 'Announcement'
                  : isGroupMessage
                      ? 'Group Message'
                      : 'Group Message');
      // Message _message = Message(
      //   receiverId: widget.threadName,
      //   senderId: _auth.currentUser.uid,
      //   message: textEditingController.text,
      //   timestamp: Timestamp.now(),
      //   currentUserName: currentUserName,
      //   photoUrl: currentUserPhoto,
      //   type: 'text',
      // );

      textEditingController.text = "";

      // _classChatMethods.addMessageToDb(_message).whenComplete(() {
      //   print('message sent');
      // });
      // listScrollController.animateTo(0.0,
      //     duration: Duration(milliseconds: 300), curve: Curves.easeOut);
    }
    if (type == 1) {}
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
        // extendBodyBehindAppBar: true,

        appBar: AppBar(
          elevation: 0,
          leadingWidth: 50,
          // backgroundColor: theme.primaryColor,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ClassInfo(
                    documentSnapshot: widget.documentSnapshot,
                  ),
                ),
              );
            },
            child: FittedBox(
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                        widget.documentSnapshot.data()['class_picture']),
                    radius: 16,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.documentSnapshot.data()['course_code'],
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Text(
                        widget.documentSnapshot.data()['course_title'],
                        softWrap: true,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 13),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: () => addMediaModal(context),
              child: Image.asset(
                'assets/icons/google-classroom.png',
                height: 25,
                width: 25,
              ),
            ),
            SizedBox(
              width: 20,
            )
          ],
        ),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/scrolly-portrait.jpg',
                fit: BoxFit.cover,
              ),
            ),

            Column(
              children: [
                // List of messages
                buildListMessage(),
                //  _imageUploadProvider.getViewState == ViewState.LOADING
                // ? Container(
                //     alignment: Alignment.centerRight,
                //     margin: EdgeInsets.only(right: 15),
                //     child: CircularProgressIndicator(),
                //   )
                // : Container(),
                // Sticker
                Container(
                  // height: 80,
                  alignment: Alignment.bottomRight,
                  margin: EdgeInsets.only(right: 10),
                  child: StreamBuilder(
                    stream: FirebaseFirestore.instance
                        .collection(CLASSES_COLLECTION)
                        .doc(widget.documentSnapshot.id)
                        .collection('members')
                        .where('typing', isEqualTo: true)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return SizedBox();
                      } else {
                        return RichText(
                          text: TextSpan(
                            // mainAxisAlignment: MainAxisAlignment.end,
                            children: snapshot.data.docs.map<Widget>(
                                (DocumentSnapshot documentSnapshot) {
                              return Text(
                                  "${documentSnapshot.data()['username']} is typing");
                            }),
                          ),
                        );
                      }
                    },
                  ),
                ),
                // Input content
                buildInput(),
                showEmojiPicker
                    ? Container(child: emojiContainer())
                    : Container(),
              ],
            ),
            // Loading
            buildLoading()
          ],
        ));
  }

  emojiContainer() {
    return EmojiPicker(
      bgColor: UniversalVariables.separatorColor,
      indicatorColor: UniversalVariables.blueColor,
      rows: 3,
      columns: 7,
      onEmojiSelected: (emoji, category) {
        setState(() {
          isWriting = true;
        });

        textEditingController.text = textEditingController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  Widget buildLoading() {
    return Positioned(
      child: isLoading
          ? Container(
              child: Center(
                child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)),
              ),
              color: Colors.white.withOpacity(0.8),
            )
          : Container(),
    );
  }

  Widget buildListMessage() {
    return Flexible(
      child: widget.threadId == ''
          ? Center(
              child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.purple)))
          : StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(CLASSES_COLLECTION)
                  .doc(widget.documentSnapshot.id)
                  .collection(MESSAGES_COLLECTION)
                  .orderBy('time', descending: true)
                  // .limit(20)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                      child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.purple)));
                } else {
                  listMessage = snapshot.data.docs;
                  return ListView.builder(
                    padding:
                        EdgeInsets.symmetric(horizontal: 13.0, vertical: 8.0),
                    itemBuilder: (context, index) =>
                        chatMessageItem(snapshot.data.docs[index]),
                    itemCount: listMessage.length,
                    reverse: true,
                    controller: listScrollController,
                  );
                }
              },
            ),
    );
  }

  Widget buildInput() {
    return Container(
        width: double.infinity,
        height: 90.0,
        decoration: BoxDecoration(
            border: Border(top: BorderSide(color: Colors.blue, width: 0.5)),
            color: Colors.white),
        child: Stack(
          children: <Widget>[
            _buildNormalInput(),
          ],
        ));
  }

  Widget _buildNormalInput() {
    final theme = Theme.of(context);
    hideEmojiContainer() {
      setState(() {
        showEmojiPicker = false;
      });
    }

    return Container(
      color: theme.cardColor,
      child: ListView(
        children: [
          Row(
            children: <Widget>[
              // Button send image
              // Container(
              //   margin: EdgeInsets.symmetric(horizontal: 1.0),
              //   decoration:
              //       BoxDecoration(color: Colors.purple, shape: BoxShape.circle),
              //   child: IconButton(
              //     icon: Icon(Icons.mic),
              //     onPressed: () {},
              //     color: Colors.white,
              //   ),
              // ),
              // Container(
              //   margin: EdgeInsets.symmetric(horizontal: 1.0),
              //   child: IconButton(
              //     icon: Icon(Icons.image),
              //     onPressed: _onPickImages,
              //     color: theme.textTheme.bodyText1.color,
              //   ),
              // ),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 1.0),
                child: IconButton(
                  icon:
                      Icon(Icons.face, color: theme.textTheme.bodyText1.color),
                  onPressed: () {
                    if (!showEmojiPicker) {
                      // keyboard is visible
                      hideKeyboard();
                      showEmojiContainer();
                    } else {
                      //keyboard is hidden
                      showKeyboard();
                      hideEmojiContainer();
                    }
                  },
                  color: theme.textTheme.bodyText1.color,
                ),
              ),
              // Edit text
              Flexible(
                child: Container(
                  child: TextField(
                    onChanged: (text) {
                      if (!isCurrentlyTyping) {
                        isCurrentlyTyping = true;
                        FirebaseFirestore.instance
                            .collection(CLASSES_COLLECTION)
                            .doc(widget.documentSnapshot.id)
                            .collection('members')
                            .doc(_auth.currentUser.uid)
                            .update({'typing': true}).whenComplete(() {
                          print('Typing set to true - Enabled');
                        });
                        // setState(() {});
                        Future.delayed(Duration(seconds: 2)).whenComplete(() {
                          isCurrentlyTyping = false;
                          FirebaseFirestore.instance
                              .collection(CLASSES_COLLECTION)
                              .doc(widget.documentSnapshot.id)
                              .collection('members')
                              .doc(_auth.currentUser.uid)
                              .update({'typing': false}).whenComplete(() {
                            print('Typing set to false - Disabled');
                          });
                          // setState(() {});
                        });
                      }
                    },
                    onTap: () {
                      hideEmojiContainer();
                    },
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 9,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    toolbarOptions: ToolbarOptions(
                        copy: true, paste: true, cut: true, selectAll: true),
                    style: TextStyle(color: theme.textTheme.bodyText1.color),
                    controller: textEditingController,
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      hintText: "Type a message",
                      hintStyle: TextStyle(
                        color: theme.textTheme.subtitle2.color,
                      ),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      filled: true,
                      fillColor: theme.cardColor.withOpacity(0.8),
                    ),
                    focusNode: focusNode,
                  ),
                ),
              ),
              // Button send message
              _buildMsgBtn(
                onPreesed: () =>
                    onSendMessage(content: textEditingController.text, type: 0),
              ),
            ],
          ),
          SizedBox(
            height: 7,
          ),
          Container(
            padding: const EdgeInsets.only(left: 20.0),
            margin: const EdgeInsets.only(left: 20.0),
            child: Row(
              children: [
                InkWell(
                  onTap: isMessage,
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isGroupMessage ? Colors.blue : Colors.grey),
                    child: Text(
                      'M',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: isAnnouncement,
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isAnnouncementMessage
                            ? Colors.orange
                            : Colors.grey),
                    child: Text(
                      'A',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                InkWell(
                  onTap: isHomework,
                  child: Container(
                    alignment: Alignment.center,
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isHomeworkMessage ? Colors.purple : Colors.grey),
                    child: Text(
                      'H',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  _buildMsgBtn({Function onPreesed}) {
    final theme = Theme.of(context);
    return Material(
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        child: IconButton(
          icon: Icon(Icons.send),
          onPressed: onPreesed,
          color: theme.textTheme.bodyText1.color,
        ),
      ),
      color: theme.cardColor,
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        alignment: _message.senderId == currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == currentUserId
            ? senderLayout(_message, snapshot)
            : receiverLayout(_message, snapshot, ThemeData()),
      ),
    );
  }

  Widget senderLayout(Message message, DocumentSnapshot snapshot) {
    Radius messageRadius = Radius.circular(10);

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.only(
            top: 9,
            left: 6,
          ),
          child: BlurryContainer(
            bgColor: Colors.purple[900],
            padding: EdgeInsets.all(0),
            borderRadius: BorderRadius.only(
              topLeft: messageRadius,
              topRight: messageRadius,
              bottomLeft: messageRadius,
            ),
            blur: 10,
            child: Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomRight: messageRadius,
                  topRight: messageRadius,
                  bottomLeft: messageRadius,
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: getMessage(message, snapshot),
              ),
            ),
          ),
        ),
        Positioned(
          left: 0,
          child: CircleAvatar(
            maxRadius: 11,
            backgroundColor: Colors.blue,
            child: Center(
              child: Text(
                'M',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 10,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  getMessage(Message message, DocumentSnapshot snapshot) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? LinkWell(
            message.message,
            style: TextStyle(
              color: Colors.black,
              fontSize: 16.0,
            ),
            linkStyle: TextStyle(
              color: Colors.blue,
              fontSize: 16.0,
            ),
          )
        : message.photoUrl != null
            ? CachedImage(
                message.photoUrl,
                height: 250,
                width: 250,
                radius: 4,
              )
            : Text('Unable to complete your request');
  }

  Widget receiverLayout(
      Message message, DocumentSnapshot snapshot, ThemeData theme) {
    Radius messageRadius = Radius.circular(10);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(snapshot.data()['userimage']),
            ),
            _auth.currentUser.displayName ==
                        widget.documentSnapshot.data()['class_admin'] ||
                    _auth.currentUser.displayName == snapshot.data()['username']
                ? IconButton(
                    icon: Icon(Icons.delete_sweep_outlined),
                    onPressed: () {
                      showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: theme.cardColor,
                              title: Text(
                                'Delete Message?',
                                style: TextStyle(
                                  color: theme.textTheme.bodyText1.color,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              actions: [
                                MaterialButton(
                                  child: Text(
                                    'No',
                                    style: TextStyle(
                                      color: theme.textTheme.bodyText1.color,
                                      fontSize: 14,
                                      decoration: TextDecoration.underline,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                                MaterialButton(
                                  child: Text(
                                    'Yes',
                                    style: TextStyle(
                                      color: Colors.purple,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  onPressed: () async {
                                    FirebaseFirestore.instance
                                        .collection(CLASSES_COLLECTION)
                                        .doc(widget.documentSnapshot.id)
                                        .collection(MESSAGES_COLLECTION)
                                        .doc(snapshot.id)
                                        .delete()
                                        .whenComplete(() {
                                      print('Message deleted');
                                      Fluttertoast.showToast(
                                          msg: 'Message Deleted',
                                          gravity: ToastGravity.CENTER,
                                          timeInSecForIosWeb: 2);
                                      Navigator.of(context).pop();
                                    });
                                  },
                                ),
                              ],
                            );
                          });
                    },
                    color: Colors.red,
                  )
                : SizedBox(),
          ],
        ),
        SizedBox(
          width: 5,
        ),
        Stack(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 5,
                right: 6,
              ),
              child: BlurryContainer(
                bgColor: Color(0xFFEBEBEB),
                padding: EdgeInsets.all(0),
                borderRadius: BorderRadius.only(
                  topLeft: messageRadius,
                  topRight: messageRadius,
                  bottomLeft: messageRadius,
                ),
                blur: 5,
                child: Container(
                  constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.65),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomRight: messageRadius,
                      topRight: messageRadius,
                      bottomLeft: messageRadius,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(
                          left: 10,
                          right: 10,
                          top: 10,
                        ),
                        child: Text(
                          snapshot.data()['username'],
                          style: TextStyle(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10),
                        child: getMessage(message, snapshot),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            snapshot.data()['messagetype'] == 'Group Message'
                ? Positioned(
                    right: 0,
                    child: CircleAvatar(
                      maxRadius: 11,
                      backgroundColor: Colors.blue,
                      child: Center(
                        child: Text(
                          'M',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  )
                : snapshot.data()['messagetype'] == 'Announcement'
                    ? Positioned(
                        right: 0,
                        child: CircleAvatar(
                          maxRadius: 11,
                          backgroundColor: Colors.orange,
                          child: Center(
                            child: Text(
                              'A',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                              ),
                            ),
                          ),
                        ),
                      )
                    : snapshot.data()['messagetype'] == 'Homework'
                        ? Positioned(
                            right: 0,
                            child: CircleAvatar(
                              maxRadius: 11,
                              backgroundColor: Colors.purple,
                              child: Center(
                                child: Text(
                                  'H',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          )
                        : Positioned(
                            right: 0,
                            child: CircleAvatar(
                              maxRadius: 11,
                              backgroundColor: Colors.blue,
                              child: Center(
                                child: Text(
                                  'M',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                            ),
                          ),
            _auth.currentUser.displayName ==
                    widget.documentSnapshot.data()['class_admin']
                ? Positioned(
                    bottom: 0,
                    right: 6,
                    child: Text(
                      'admin',
                      style:
                          TextStyle(fontSize: 9, fontStyle: FontStyle.italic),
                    ),
                  )
                : SizedBox(),
          ],
        ),
      ],
    );
  }

  // _onRecordCancel() {
  //   stopRecorder();
  // }

  // _onSendRecord() async {
  //   stopRecorder();
  //   File recordFile = File(_path);
  //   bool isExist = await recordFile.exists();

  //   if (isExist) {
  //     String fileName = DateTime.now().millisecondsSinceEpoch.toString();
  //     Reference reference =
  //         FirebaseStorage.instance.ref().child(fileName);

  //     UploadTask uploadTask = reference.putFile(recordFile);
  //     TaskSnapshot storageTaskSnapshot = await uploadTask.whenComplete((){});

  //     storageTaskSnapshot.ref.getDownloadURL().then((recordUrl) {
  //       print('download record File: $recordUrl');
  //       // setState(() {
  //       //   isLoading = false;
  //       print('Recorder text: $_recorderTxt');
  //       onSendMessage(content: recordUrl, type: 3, recorderTime: _recorderTxt);
  //       Fluttertoast.showToast(msg: 'Upload record...');
  //       // });
  //     }, onError: (err) {
  //       // setState(() {
  //       //   isLoading = false;
  //       // });
  //       Fluttertoast.showToast(msg: 'This file is not an record');
  //     });
  //   }
  // }
}
