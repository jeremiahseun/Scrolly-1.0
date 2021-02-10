import 'dart:async';
import 'package:scrolly/screens/classes/widgets/fullPhoto.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';

class MessageItem extends StatefulWidget {
  MessageItem({
    @required this.index,
    @required this.document,
    @required this.listMessage,
    @required this.currentUserId,
    @required this.flutterSound,
  });

  final String currentUserId;
  final document;
  final FlutterSound flutterSound;
  final int index;
  final List listMessage;

  @override
  _MessageItemState createState() => _MessageItemState();
}

class _MessageItemState extends State<MessageItem> {

  double maxDuration = 1.0;
  String playerTxt = '00:00:00';
  double sliderCurrentPosition = 0.0;

  StreamSubscription _playerSubscription;

  bool isLastMessageLeft(int index) {
    if ((index > 0 &&
            widget.listMessage != null &&
            widget.listMessage[index - 1]['idFrom'] !=
                widget.listMessage[index]['idFrom']) ||
        index == 0) {
      return true;
    } else {
      return false;
    }
  }

  bool _islastIndex(int index) {
    if (index > 0 &&
        (widget.listMessage[index - 1]['idFrom'] !=
            widget.listMessage[index]['idFrom'])) {
      return true;
    }
    return false;
  }


  @override
  Widget build(BuildContext context) {
    return Container(
       margin: EdgeInsets.only(bottom: _islastIndex(widget.index) ? 25.0 : 15.0),
      child: _buildItem(),
    );
  }

  _buildItem() {
    if (widget.document['idFrom'] == widget.currentUserId) {
      // Right (my message)
      return Row(
        children: <Widget>[
          // Text
          widget.document['type'] == 0
              ? _textWidget(color: Colors.blue)
              : widget.document['type'] == 1
                  // Image
                  ? _imagesWidget()
                  // Sticker
                  : widget.document['type'] != 3
                      ? _stickerWidget() : null,
        ],
        mainAxisAlignment: MainAxisAlignment.end,
      );
    } else {
      // Left (peer message)
      return Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              isLastMessageLeft(widget.index)
                  ? _userPhoto()
                  : Container(width: 43.0), // 35 width of photo + 8 of margin

              //  show text or image
              _showFriendContent(),
            ],
          ),
          // Time
          isLastMessageLeft(widget.index)
              ? Container(
                  margin: EdgeInsets.only(left: 43, top: 3),
                  child: Row(
                    children: <Widget>[
                      Text(
                        '${widget.document['nameFrom']}',
                        style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12.0,
                            fontStyle: FontStyle.italic),
                      ),
                      SizedBox(
                        width: 15.0,
                      ),
                      Text(
                        DateFormat('dd MMM kk:mm').format(
                            DateTime.fromMillisecondsSinceEpoch(
                                int.parse(widget.document['timestamp']))),
                        style: TextStyle(
                          color: Colors.blue,
                          fontSize: 12.0,
                          fontStyle: FontStyle.italic
                        ),
                      ),
                    ],
                  ))
              : Container()
        ],
        crossAxisAlignment: CrossAxisAlignment.start,
      );
    }
  }

  _textWidget({Color color}) {
    return Flexible(
      child: Container(
        width: widget.document['content'].length > 40
            ? MediaQuery.of(context).size.width * 0.7
            : null,
        padding: EdgeInsets.fromLTRB(15.0, 10.0, 15.0, 10.0),
        // margin: edg,
        child: Text(
          '${widget.document['content']}',
          style: TextStyle(color: Colors.white),
        ),
        decoration: BoxDecoration(
            color: color ?? Colors.purple,
            borderRadius: BorderRadius.circular(8.0)),
      ),
    );
  }

  _userPhoto() {
    return Container(
      margin: EdgeInsets.only(right: 8.0),
      child: Material(
        child: CachedNetworkImage(
          placeholder: (context, url) => Container(
            child: CircularProgressIndicator(
              strokeWidth: 1.0,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            ),
            // width: 35.0,
            // height: 35.0,
          ),
          imageUrl: widget.document['photoFrom'],
          width: 35.0,
          height: 35.0,
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(18.0),
        ),
        clipBehavior: Clip.hardEdge,
      ),
    );
  }

  _imagesWidget() {
    double _containerSize = 100.0;
    List images = widget.document['images'];
    double _imgSize = _containerSize * 0.9;

    return Container(
      color: Colors.grey.shade300,
      width: 200.0,
      height: images.length == 2 ? 100 : 200,
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: images.length == 1 ? 1 : 2,
        ),
        itemCount: images.length > 4 ? 4 : images.length,
        itemBuilder: (BuildContext context, int index) {
          if (images.length > 4 && index == 3) {
            return InkWell(
              onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => FullPhoto(images: images, index: index)
              )),
              child: Container(
                height: _imgSize,
                width: _imgSize,
                margin: EdgeInsets.all(5.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade600,
                  borderRadius: BorderRadius.circular(5.0)
                ),
                child: Center(
                  child: Text(
                    '+${images.length - 3}',
                    style: TextStyle(color: Colors.white, fontSize: 25.0),
                  ),
                ),
              ),
            );
          } else if (images.length > 4 && index > 3) {
            return SizedBox();
          } 
          return _buildImgItem(index: index, images: images, size: _imgSize );
        },
      ),
    );
  }

  _buildImgItem({ double size, List images, int index }) {
    return InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) =>
                    FullPhoto(images: images, index: index))
          );
        },
        child: Container(
        height: size,
        width: size,
        padding: EdgeInsets.all(5.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(5.0),
          border: Border.all(color: Colors.grey.shade300, width: 3)
        ),
        child: CachedNetworkImage(
          imageUrl: images[index],
          fit: BoxFit.fill,
          placeholder: (_, _url) => Container(
            child: Center(
                child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.purple),
            )),
          ),
          errorWidget: (_, url, error) => Container(
            child: Image.asset(
              'images/img_not_available.jpeg',
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
      ),
    );
  }

  _showFriendContent() {
    // id to
    if (widget.document['type'] == 0) {
      // txt
      return _textWidget(color: Colors.purple);
    } else if (widget.document['type'] == 1) {
      //img
      return _imagesWidget();
    } else if (widget.document['type'] == 2) {
      // stickers
      return _stickerWidget();
    } else if (widget.document['type'] == 3) {
      // record
      // return _voiceContainer(widget.document['content'], widget.document['recorderTime']);
    }
    return Container();
  }

  _stickerWidget() {
    return Container(
      child: Image.asset(
        'images/${widget.document['content']}.gif',
        width: 100.0,
        height: 100.0,
        fit: BoxFit.cover,
      ),
    );
  }
  }

