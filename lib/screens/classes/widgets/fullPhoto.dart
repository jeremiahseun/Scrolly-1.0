import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';


class FullPhoto extends StatelessWidget {
  final List images;
  final int index;

  FullPhoto({ @required this.images, @required this.index });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'FULL PHOTO',
          style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: FullPhotoScreen(index: index, images: images),
    );
  }
}

class FullPhotoScreen extends StatefulWidget {
  final int index;
  final List images;

  FullPhotoScreen({ Key key, @required this.index, @required this.images }) : super(key: key);

  @override
  State createState() => new FullPhotoScreenState();
}

class FullPhotoScreenState extends State<FullPhotoScreen> {
  int currentIndex;
  bool verticalGallery = true;
  PageController page;

  @override
  void initState() {
    page = PageController (initialPage:  widget.index);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    return Container(
    child: PhotoViewGallery.builder(
      scrollPhysics: const BouncingScrollPhysics(),
      itemCount: widget.images.length,
      scrollDirection: verticalGallery ? Axis.vertical : Axis.horizontal,
      pageController: page,
      builder: (BuildContext context, int index) {
        return PhotoViewGalleryPageOptions(
          imageProvider: NetworkImage(widget.images[index]),
          initialScale: PhotoViewComputedScale.contained * 0.8,
          heroAttributes: PhotoViewHeroAttributes(tag: widget.images[index]),
        );
      },
      loadFailedChild: Center(
        child: Container(
          width: 20.0,
          height: 20.0,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(Colors.purple),
          ),
        ),
      ),
      backgroundDecoration: const BoxDecoration(
        color: Colors.black,
      ),
    )
  );
  }
}
