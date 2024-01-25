import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/models/datum.dart';
import '/models/episode.dart';

class VideoItemBox extends StatelessWidget {
  static const IMAGE_RATIO = 1.50;

  VideoItemBox(this.buildContext, this.videoDetail, {this.height = 120.0});
  final BuildContext buildContext;
  final Datum? videoDetail;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(8.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: videoDetail!.thumbnail == null
            ? Image.asset(
                "assets/placeholder_box.jpg",
                height: 180.0,
                width: 110.0,
                fit: BoxFit.cover,
              )
            : FadeInImage.assetNetwork(
                image: videoDetail!.type == DatumType.M
                    ? "${APIData.movieImageUri}${videoDetail!.thumbnail}"
                    : "${APIData.tvImageUriTv}${videoDetail!.thumbnail}",
                placeholder: "assets/placeholder_box.jpg",
                imageErrorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    "assets/placeholder_box.jpg",
                    fit: BoxFit.cover,
                    height: 180.0,
                    width: 110.0,
                  );
                },
                height: 180.0,
                width: 110.0,
                fit: BoxFit.cover,
              ),
      ),
    );
  }
}
