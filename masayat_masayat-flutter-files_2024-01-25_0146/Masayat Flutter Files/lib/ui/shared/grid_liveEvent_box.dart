import 'package:flutter/material.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/models/LiveEventModel.dart';

class GridLiveEventBox extends StatelessWidget {
  GridLiveEventBox(this.buildContext, this.liveEvent);
  final BuildContext buildContext;
  final LiveEvent liveEvent;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: new BorderRadius.circular(5.0),
      child: ClipRRect(
        borderRadius: new BorderRadius.circular(5.0),
        child: liveEvent.thumbnail == null
            ? Image.asset(
                "assets/placeholder_box.jpg",
                height: 200,
                width: 60.0,
                fit: BoxFit.cover,
              )
            : FadeInImage.assetNetwork(
                image: APIData.liveEventThumbnail + liveEvent.thumbnail!,
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
