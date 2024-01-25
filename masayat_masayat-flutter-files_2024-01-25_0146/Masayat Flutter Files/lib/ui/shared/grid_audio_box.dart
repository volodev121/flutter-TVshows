import 'package:flutter/material.dart';
import 'package:nexthour/common/apipath.dart';
import '../../models/AudioModel.dart';

class GridAudioBox extends StatelessWidget {
  GridAudioBox(this.buildContext, this.audio);
  final BuildContext buildContext;
  final Audio audio;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: new BorderRadius.circular(5.0),
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(5.0),
        child: audio.thumbnail == null
            ? Image.asset(
                "assets/placeholder_box.jpg",
                height: 200,
                width: 60.0,
                fit: BoxFit.cover,
              )
            : FadeInImage.assetNetwork(
                image: APIData.audioThumbnail + audio.thumbnail,
                placeholder: "assets/placeholder_box.jpg",
                height: 200,
                width: 60.0,
                imageScale: 1.0,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
