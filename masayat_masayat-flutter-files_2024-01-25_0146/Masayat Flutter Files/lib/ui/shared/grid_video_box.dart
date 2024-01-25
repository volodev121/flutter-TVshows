import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/models/datum.dart';
import '/models/episode.dart';

class GridVideoBox extends StatelessWidget {
  GridVideoBox(this.buildContext, this.videoWatch);
  final BuildContext buildContext;
  final Datum videoWatch;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: new BorderRadius.circular(5.0),
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(5.0),
        child: videoWatch.thumbnail == null
            ? Image.asset(
                "assets/placeholder_box.jpg",
                height: 200,
                width: 60.0,
                fit: BoxFit.cover,
              )
            : FadeInImage.assetNetwork(
                image: videoWatch.type == DatumType.M
                    ? "${APIData.movieImageUri}${videoWatch.thumbnail}"
                    : "${APIData.tvImageUriTv}${videoWatch.thumbnail}",
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
