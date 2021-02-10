import 'dart:io';

import 'package:animations/animations.dart';
import 'package:blurrycontainer/blurrycontainer.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:emoji_picker/emoji_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:scrolly/screens/widgets/modal_tile.dart';
import 'package:flutter/scheduler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/calls/pickup/pickup_layout.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/enum/view_state.dart';
import 'package:scrolly/models/message.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/provider/image_upload_provider.dart';
import 'package:scrolly/resources/auth_methods.dart';
import 'package:scrolly/resources/chat_methods.dart';
import 'package:scrolly/resources/storage_methods.dart';
import 'package:scrolly/screens/chats/chat_list_screen.dart';
import 'package:scrolly/screens/widgets/cached_image.dart';
import 'package:scrolly/screens/widgets/custom_tile.dart';
import 'package:scrolly/utils/universal_variables.dart';
import 'package:scrolly/utils/utilities.dart';

import 'profiles/receiver_profile.dart';

class ChatScreen extends StatefulWidget {
  final UserModel receiver;

  ChatScreen({this.receiver});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  ImageUploadProvider _imageUploadProvider;
  // bool isMessageSent = false;

  final StorageMethods _storageMethods = StorageMethods();
  final ChatMethods _chatMethods = ChatMethods();
  AuthMethods _authMethods = AuthMethods();

  TextEditingController textFieldController = TextEditingController();
  FocusNode textFieldFocus = FocusNode();
  ScrollController _listScrollController = ScrollController();
  bool isWriting = false;
  bool showEmojiPicker = false;

  UserModel sender;
  String _currentUserId;

  @override
  void initState() {
    super.initState();
    _authMethods.getCurrentUser().then((User u) {
      _currentUserId = u.uid;

      setState(() {
        sender = UserModel(
          uid: u.uid,
          name: u.displayName,
          profilePhoto: u.photoURL,
        );
      });
    });
  }

  showKeyboard() => textFieldFocus.requestFocus();

  hideKeyboard() => textFieldFocus.unfocus();

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

  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    _imageUploadProvider = Provider.of<ImageUploadProvider>(context);

    return
        // PickupLayout( scaffold:

        Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: theme.primaryColor,
        elevation: 20,
        leading: Row(
          children: [
            IconButton(
              icon: Icon(
                Icons.arrow_back_ios,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        centerTitle: false,
        leadingWidth: 50,
        title: OpenContainer(
            closedColor: theme.primaryColor,
            openColor: theme.scaffoldBackgroundColor,
            closedElevation: 0,
            openElevation: 0,
            closedBuilder: (context, openWidget) {
              return Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(
                      widget.receiver.profilePhoto,
                    ),
                    radius: 18,
                  ),
                  SizedBox(width: 15),
                  Text(
                    widget.receiver.name,
                    style: GoogleFonts.righteous(fontSize: 16),
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              );
            },
            openBuilder: (context, closeWidget) {
              return ReceiverProfilePage(
                receiver: widget.receiver,
              );
            }),
        actions: <Widget>[
          // IconButton(
          //   icon: Icon(
          //     Icons.video_call,
          //   ),
          //   onPressed: () {},
          // ),
          IconButton(
            icon: Icon(
              Icons.phone,
            ),
            onPressed: () {},
          )
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image:
                NetworkImage('https://cdn.hipwallpaper.com/i/24/38/eMYlmT.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Column(
          children: <Widget>[
            Flexible(
              child: messageList(),
            ),
            _imageUploadProvider.getViewState == ViewState.LOADING
                ? Container(
                    alignment: Alignment.centerRight,
                    margin: EdgeInsets.only(right: 15),
                    child: CircularProgressIndicator(),
                  )
                : Container(),
            chatControls(),
            showEmojiPicker ? Container(child: emojiContainer()) : Container(),
          ],
        ),
      ),
      // ),
    );
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

        textFieldController.text = textFieldController.text + emoji.emoji;
      },
      recommendKeywords: ["face", "happy", "party", "sad"],
      numRecommended: 50,
    );
  }

  Widget messageList() {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(MESSAGES_COLLECTION)
          .doc(_currentUserId)
          .collection(widget.receiver.uid)
          .orderBy(TIMESTAMP_FIELD, descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.data == null) {
          return Center(child: CircularProgressIndicator());
        }

        // SchedulerBinding.instance.addPostFrameCallback((_) {
        //   _listScrollController.animateTo(
        //     _listScrollController.position.minScrollExtent,
        //     duration: Duration(milliseconds: 250),
        //     curve: Curves.easeInOut,
        //   );
        // });

        return ListView.builder(
          padding: EdgeInsets.all(10),
          controller: _listScrollController,
          reverse: true,
          itemCount: snapshot.data.docs.length,
          itemBuilder: (context, index) {
            // mention the arrow syntax if you get the time
            return chatMessageItem(snapshot.data.docs[index]);
          },
        );
      },
    );
  }

  Widget chatMessageItem(DocumentSnapshot snapshot) {
    Message _message = Message.fromMap(snapshot.data());

    return Container(
      margin: EdgeInsets.symmetric(vertical: 6),
      child: Container(
        alignment: _message.senderId == _currentUserId
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: _message.senderId == _currentUserId
            ? senderLayout(_message)
            : receiverLayout(_message),
      ),
    );
  }

  Widget senderLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return BlurryContainer(
      bgColor: Colors.purple[900],
      padding: EdgeInsets.all(0),
      borderRadius: BorderRadius.only(
        topLeft: messageRadius,
        topRight: messageRadius,
        bottomLeft: messageRadius,
      ),
      blur: 10,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(15),
          child: Stack(
            children: [
              Column(
                children: [
                  getMessage(message),
                  SizedBox(height: 20),
                ],
              ),
              // isMessageSent
              //     ? Positioned(
              //         bottom: 0,
              //         right: 0,
              //         child: Text(
              //           'Sent',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 10.0,
              //           ),
              //         ),
              //       )
              //     : Positioned(
              //         bottom: 0,
              //         right: 0,
              //         child: Text(
              //           'Not sent',
              //           style: TextStyle(
              //             color: Colors.white,
              //             fontSize: 10.0,
              //           ),
              //         ),
              //       ),
            ],
          ),
        ),
      ),
    );
  }

  getMessage(Message message) {
    return message.type != MESSAGE_TYPE_IMAGE
        ? Text(
          message.message,
          style: TextStyle(
            color: Colors.white,
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

  Widget receiverLayout(Message message) {
    Radius messageRadius = Radius.circular(10);

    return BlurryContainer(
      bgColor: Colors.blue[900],
      padding: EdgeInsets.all(0),
      borderRadius: BorderRadius.only(
        topLeft: messageRadius,
        topRight: messageRadius,
        bottomLeft: messageRadius,
      ),
      blur: 10,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.65),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            bottomRight: messageRadius,
            topRight: messageRadius,
            bottomLeft: messageRadius,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(10),
          child: getMessage(message),
        ),
      ),
    );
  }

  Widget chatControls() {
    setWritingTo(bool val) {
      setState(() {
        isWriting = val;
      });
    }

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
                        onTap: () => pickImage(source: ImageSource.gallery),
                      ),
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

    sendMessage() {
      var text = textFieldController.text;

      Message _message = Message(
        receiverId: widget.receiver.uid,
        senderId: sender.uid,
        message: text,
        timestamp: Timestamp.now(),
        type: 'text',
      );

      setState(() {
        isWriting = false;
      });

      textFieldController.text = "";

      _chatMethods.addMessageToDb(_message).whenComplete(() {
        print('message sent');
      });
    }

    final theme = Theme.of(context);
    return Container(
      // color: Colors.white,
      padding: EdgeInsets.all(10),
      child: Row(
        children: <Widget>[
          GestureDetector(
            onTap: () => addMediaModal(context),
            child: Container(
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                gradient: UniversalVariables.fabGradient,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.add),
            ),
          ),
          SizedBox(
            width: 5,
          ),
          Expanded(
            child: Stack(
              alignment: Alignment.centerRight,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    autocorrect: true,
                    keyboardType: TextInputType.multiline,
                    maxLines: 9,
                    minLines: 1,
                    textCapitalization: TextCapitalization.sentences,
                    toolbarOptions: ToolbarOptions(
                        copy: true, paste: true, cut: true, selectAll: true),
                    controller: textFieldController,
                    focusNode: textFieldFocus,
                    onTap: () => hideEmojiContainer(),
                    style: TextStyle(
                      color: theme.textTheme.bodyText1.color,
                    ),
                    onChanged: (val) {
                      (val.length > 0 && val.trim() != "")
                          ? setWritingTo(true)
                          : setWritingTo(false);
                    },
                    decoration: InputDecoration(
                      alignLabelWithHint: true,
                      hintText: "Type a message",
                      hintStyle: TextStyle(
                        color: theme.textTheme.subtitle2.color,
                      ),
                      border: OutlineInputBorder(
                          borderRadius: const BorderRadius.all(
                            const Radius.circular(50.0),
                          ),
                          borderSide: BorderSide.none),
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 5),
                      filled: true,
                      fillColor: theme.cardColor,
                    ),
                  ),
                ),
                IconButton(
                  splashColor: Colors.transparent,
                  highlightColor: Colors.transparent,
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
                  icon:
                      Icon(Icons.face, color: theme.textTheme.bodyText1.color),
                ),
              ],
            ),
          ),
          isWriting
              ? Container()
              : Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Icon(Icons.record_voice_over,
                        color: theme.textTheme.bodyText1.color),
                  ),
                ),
          isWriting
              ? Container()
              : GestureDetector(
                  child: Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: theme.scaffoldBackgroundColor,
                    ),
                    child: Icon(Icons.camera_alt,
                        color: theme.textTheme.bodyText1.color),
                  ),
                  onTap: () => pickImage(source: ImageSource.camera),
                ),
          isWriting
              ? Container(
                  margin: EdgeInsets.only(left: 10),
                  decoration: BoxDecoration(
                      gradient: UniversalVariables.fabGradient,
                      shape: BoxShape.circle),
                  child: IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 15,
                    ),
                    onPressed: () => sendMessage(),
                  ))
              : Container()
        ],
      ),
    );
  }

  void pickImage({@required ImageSource source}) async {
    File selectedImage = await Utils.pickImage(source: source);
    _storageMethods.uploadImage(
        image: selectedImage,
        receiverId: widget.receiver.uid,
        senderId: _currentUserId,
        imageUploadProvider: _imageUploadProvider);
  }
}

