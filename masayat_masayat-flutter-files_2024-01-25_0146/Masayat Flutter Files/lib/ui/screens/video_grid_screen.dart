import 'package:flutter/material.dart';
import 'package:nexthour/common/unity_ads.dart';
import '/models/datum.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/grid_video_container.dart';

// ignore: must_be_immutable
class VideoGridScreen extends StatelessWidget {
  final dynamic id;
  final String? title;
  final List<Datum> genreDataList;

  VideoGridScreen(this.id, this.title, this.genreDataList);

  late List<Widget> videoList;

  @override
  Widget build(BuildContext context) {
    showRewardedVideoAds();
    videoList = List.generate(genreDataList.isEmpty ? 0 : genreDataList.length,
        (index) {
      return GridVideoContainer(context, genreDataList[index]);
    });
    videoList.removeWhere((value) => value != value);

    return Scaffold(
      appBar: customAppBar(context, title) as PreferredSizeWidget?,
      body: GridView.count(
          padding: EdgeInsets.only(
            left: 15.0,
            right: 15.0,
            top: 15.0,
            bottom: 15.0,
          ),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          crossAxisCount: 3,
          childAspectRatio: 18 / 28,
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 8.0,
          children: videoList),
    );
  }
}
