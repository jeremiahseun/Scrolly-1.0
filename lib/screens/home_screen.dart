import 'dart:ui';

import 'package:animations/animations.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:scrolly/constants/strings.dart';
import 'package:scrolly/models/user.dart';
import 'package:scrolly/screens/posts/post_helper.dart';
import 'package:scrolly/screens/posts/post_image.dart';
import 'package:intl/intl.dart';
import 'package:scrolly/screens/posts/upload_post.dart';
import 'package:scrolly/screens/widgets/scrolly_appbar.dart';
import 'posts/post_details.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class HomeScreen extends StatefulWidget {
  final UserModel meUser;

  const HomeScreen({Key key, this.meUser}) : super(key: key);
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoading = false;
  FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  RefreshController _refreshController =
      RefreshController(initialRefresh: false);

  FirebaseAuth auth = FirebaseAuth.instance;

  List<DocumentSnapshot> posts, postComment;
  bool isLiked = false;

  @override
  void initState() {
    _fetchPosts();
    super.initState();
  }

  _fetchPosts() async {
    try {
      QuerySnapshot snapshot = await _db
          .collection(POSTS_COLLECTION)
          .orderBy('time', descending: true)
          .get();

      setState(() {
        posts = snapshot.docs;
        _isLoading = false;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    String name = auth.currentUser.displayName;
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: scrollyAppBar(
        context,
        theme,
        meUser: widget.meUser,
        actions: Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              name,
              style: GoogleFonts.averiaLibre(
                  color: theme.textTheme.bodyText1.color),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add_a_photo_outlined),
        onPressed: () {
          Provider.of<UploadPost>(context, listen: false)
              .selectPostImageType(context, theme);
        },
        elevation: 30,
      ),
      body: _isLoading
          ? Container(
              child: LinearProgressIndicator(),
            )
          : SmartRefresher(
              controller: _refreshController,
              header: WaterDropMaterialHeader(),
              onRefresh: () async {
                _fetchPosts();
                await Future.delayed(Duration(milliseconds: 2000));
                _refreshController.refreshCompleted();
                return null;
              },
              child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('posts')
                      .orderBy('time', descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      // _fetchPosts();
                      return ListView(
                        children: snapshot.data.docs
                            .map((DocumentSnapshot documentSnapshot) {
                          // var format = DateFormat("EEE, MMM d 'at' h:mm a");
                          // // DateFormat("${'MMMd '}at${' HH:mm vvvv'}");

                          // var currentTime = format.format(
                          //   DateTime.parse(
                          //     documentSnapshot.data()['time'],
                          //   ),
                          // );
                          final String text =
                              '${documentSnapshot.data()['caption']}';
                          final String picture =
                              "${documentSnapshot.data()['picture_post']}";
                          return Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: theme.cardColor,
                              boxShadow: [
                                BoxShadow(
                                  offset: Offset(0, 1),
                                  blurRadius: 4,
                                  color: Colors.blueGrey,
                                ),
                              ],
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: 0, vertical: 5),
                            margin: EdgeInsets.symmetric(
                                horizontal: 10, vertical: 7),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  margin: EdgeInsets.only(
                                      left: 10, right: 5, top: 10, bottom: 5),
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 17,
                                        backgroundImage: NetworkImage(
                                            "${documentSnapshot.data()['profile_photo']}"),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${documentSnapshot.data()['name']}",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold),
                                          ),
                                          Text(
                                            'currentTime',
                                            style: TextStyle(
                                                color: theme
                                                    .textTheme.headline1.color,
                                                fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      // Spacer(),
                                      // IconButton(
                                      //   icon: Icon(Icons.menu_rounded),
                                      //   onPressed: () {},
                                      // ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                OpenContainer(
                                  closedBuilder: (context, openWidget) {
                                    return Container(
                                      alignment: Alignment.center,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            // alignment: Alignment.center,
                                            margin: EdgeInsets.symmetric(
                                              vertical: 5,
                                              horizontal: 10,
                                            ),
                                            child: AutoSizeText(
                                              text,
                                              minFontSize: 14,
                                              style: TextStyle(fontSize: 18),
                                              // maxLines: 4,
                                              overflow: TextOverflow.ellipsis,
                                            ),

                                            //  textScaleFactor: 1,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Container(
                                            child: CachedNetworkImage(
                                              imageUrl: picture,
                                              height: 300,
                                              width: double.infinity,
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                              placeholder: (context, url) => Center(
                                                  child:
                                                      CircularProgressIndicator()),
                                              errorWidget:
                                                  (context, url, error) =>
                                                      Icon(Icons.error),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                  openBuilder: (context, closedWidget) {
                                    return PostDetails(
                                      theme: theme,
                                      text: text,
                                      documentSnapshot: documentSnapshot,
                                      postComment: postComment,
                                    );
                                  },
                                  openColor: theme.cardColor,
                                  closedColor: theme.cardColor,
                                  transitionType: ContainerTransitionType.fade,
                                  transitionDuration:
                                      Duration(milliseconds: 400),
                                ),
                                SizedBox(
                                  height: 5,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.only(left: 10.0, right: 5),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.max,
                                        children: [
                                          Container(
                                            // alignment: Alignment.centerLeft,
                                            child: Column(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Provider.of<PostHelper>(
                                                            context,
                                                            listen: false)
                                                        .addLike(
                                                            context,
                                                            documentSnapshot.id,
                                                            auth.currentUser
                                                                .uid);
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      SvgPicture.asset(
                                                        'assets/icons/like.svg',
                                                        color: Colors.grey,
                                                        height: 22,
                                                        width: 22,
                                                        fit: BoxFit.contain,
                                                      ),
                                                      SizedBox(
                                                        width: 5,
                                                      ),
                                                      StreamBuilder<
                                                          QuerySnapshot>(
                                                        stream: FirebaseFirestore
                                                            .instance
                                                            .collection(
                                                                POSTS_COLLECTION)
                                                            .doc(
                                                                "${documentSnapshot.id}")
                                                            .collection('likes')
                                                            .snapshots(),
                                                        builder: (context,
                                                            snapshot) {
                                                          if (snapshot
                                                              .hasData) {
                                                            return Text(
                                                              snapshot.data.docs
                                                                  .length
                                                                  .toString(),
                                                              style: TextStyle(
                                                                fontSize: 11,
                                                                color: theme
                                                                    .textTheme
                                                                    .bodyText1
                                                                    .color,
                                                              ),
                                                            );
                                                          }
                                                          return SizedBox();
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          // SizedBox(width: 5),
                                          // Text(
                                          //   'Hubert, Emily and 1902 others',
                                          //   style: TextStyle(
                                          //     fontSize: 10,
                                          //     color: theme.textTheme.bodyText1.color,
                                          //   ),
                                          // ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Image.asset(
                                            'assets/icons/comments.png',
                                            height: 25,
                                            width: 25,
                                          ),
                                          StreamBuilder<QuerySnapshot>(
                                            stream: FirebaseFirestore.instance
                                                .collection(POSTS_COLLECTION)
                                                .doc("${documentSnapshot.id}")
                                                .collection(
                                                    POSTS_COMMENT_COLLECTION)
                                                .snapshots(),
                                            builder: (context, snapshot) {
                                              if (snapshot.hasData) {
                                                return Text(
                                                  snapshot.data.docs.length
                                                      .toString(),
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    color: theme.textTheme
                                                        .bodyText1.color,
                                                  ),
                                                );
                                              }
                                              return SizedBox();
                                            },
                                          ),
                                        ],
                                      ),
                                      RichText(
                                        text: TextSpan(
                                          style: TextStyle(
                                            color:
                                                theme.textTheme.bodyText1.color,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          children: [
                                            TextSpan(
                                                text:
                                                    "${documentSnapshot.data()['location']},"),
                                            TextSpan(
                                                text: '\nUniversity of Lagos'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    } else if (snapshot.hasError) {
                      showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            content: Text(
                                'Sorry, there seems to be no connection now... 😥'),
                            title: Text('Alert!'),
                          );
                        },
                      );
                    }
                    return Container();
                  }),
            ),
    );
  }
}
