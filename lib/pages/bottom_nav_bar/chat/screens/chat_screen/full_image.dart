import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullImagePageRoute extends StatelessWidget {
  final String imageDownloadUrl;

  FullImagePageRoute(this.imageDownloadUrl);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(),
      body: Container(
          child: PhotoView(
        imageProvider: CachedNetworkImageProvider(imageDownloadUrl),
      )),
    );
  }
}
