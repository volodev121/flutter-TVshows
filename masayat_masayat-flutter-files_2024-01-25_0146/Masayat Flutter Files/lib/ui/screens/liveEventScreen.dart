import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import 'package:nexthour/models/LiveEventModel.dart';
import 'package:nexthour/ui/shared/appbar.dart';
import 'package:provider/provider.dart';
import '../../common/apipath.dart';
import '../../common/global.dart';
import '../../common/route_paths.dart';
import '../../models/user_profile_model.dart';
import '../../player/iframe_player.dart';
import '../../player/m_player.dart';
import '../../providers/user_profile_provider.dart';
import '../widgets/expandable_text.dart';
import '../widgets/video_header_diagonal.dart';

class LiveEventScreen extends StatefulWidget {
  const LiveEventScreen({required this.liveEvent});

  final LiveEvent liveEvent;

  @override
  State<LiveEventScreen> createState() => _LiveEventScreenState();
}

class _LiveEventScreenState extends State<LiveEventScreen> {
  UserProfileModel? userProfileModel;

  @override
  void initState() {
    userProfileModel = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    super.initState();
  }

  var screenWidth;

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    DateTime start = DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse("${widget.liveEvent.startTime}");
    DateTime end =
        DateFormat("yyyy-MM-dd hh:mm:ss").parse("${widget.liveEvent.endTime}");
    return Scaffold(
      appBar:
          customAppBar(context, translate("Live_Event")) as PreferredSizeWidget,
      body: Container(
        child: Column(
          children: [
            Expanded(
              flex: 2,
              child: Stack(
                children: [
                  _diagonalImageBackground(context),
                  Positioned(
                    bottom: 0,
                    left: -4,
                    child: Card(
                      color: Colors.transparent,
                      elevation: 5.0,
                      child: Container(
                        height: 170,
                        width: screenWidth,
                        child: ClipRRect(
                          child: BackdropFilter(
                            filter: ImageFilter.blur(
                              sigmaX: 20,
                              sigmaY: 20,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Container(
                                  child: widget.liveEvent.thumbnail == null
                                      ? Image.asset(
                                          "assets/placeholder_box.jpg",
                                          height: 170,
                                          width: 120,
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage.assetNetwork(
                                          image: APIData.liveEventThumbnail +
                                              widget.liveEvent.thumbnail!,
                                          placeholder:
                                              "assets/placeholder_box.jpg",
                                          height: 170,
                                          width: 120.0,
                                          imageScale: 1.0,
                                          fit: BoxFit.cover,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) {
                                            return Image.asset(
                                              "assets/placeholder_box.jpg",
                                              height: 170,
                                              width: 120.0,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                ),
                                Container(
                                  padding: EdgeInsets.all(8),
                                  width: screenWidth - 125,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      FittedBox(
                                        child: Text(
                                          "${widget.liveEvent.title}",
                                          style: TextStyle(
                                            fontSize: 22.0,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      Container(
                                        padding: EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.green,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                        child: FittedBox(
                                          child: Text(
                                            "Starts at : ${DateFormat("dd MMM yyyy hh:mm a").format(start)}",
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      Container(
                                        padding: EdgeInsets.all(6.0),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.red,
                                            width: 1.0,
                                          ),
                                          borderRadius: BorderRadius.all(
                                            Radius.circular(5.0),
                                          ),
                                        ),
                                        child: FittedBox(
                                          child: Text(
                                            "Ends at   : ${DateFormat("dd MMM yyyy hh:mm a").format(end)}",
                                            style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.w300,
                                            ),
                                          ),
                                        ),
                                      ),
                                      Divider(),
                                      FittedBox(
                                        child: Text(
                                          "Organised by - ${widget.liveEvent.organizedBy}",
                                          style: TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.w400,
                                            fontStyle: FontStyle.italic,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    SizedBox(height: 15),
                    CircleAvatar(
                      radius: 38,
                      backgroundColor: Colors.blue,
                      child: CircleAvatar(
                        radius: 35,
                        child: Center(
                          child: IconButton(
                            icon: Icon(
                              Icons.play_arrow,
                              size: 30.0,
                            ),
                            onPressed: () async {
                              if ('${userProfileModel?.active}' == '1') {
                                if (widget.liveEvent.iframeurl != null) {
                                  playVideo(widget.liveEvent.iframeurl);
                                } else if (widget.liveEvent.readyUrl != null) {
                                  playVideo(widget.liveEvent.readyUrl!);
                                }
                              } else {
                                _showMsg();
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 5),
                    if (widget.liveEvent.description != null)
                      SizedBox(height: 5),
                    if (widget.liveEvent.description != null)
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: ExpandableText(
                          isLight ? Colors.black : Colors.white,
                          "${widget.liveEvent.description}",
                          3,
                        ),
                      ),
                    SizedBox(height: 10),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void playVideo(String url) {
    print("Live Event URL -> $url");
    if (url.substring(0, 18) == "https://vimeo.com/" ||
        url.substring(0, 25) == "https://player.vimeo.com/") {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => IFramePlayerPage(
            url: url,
          ),
        ),
      );
    } else if (url.substring(0, 23) == 'https://www.youtube.com' ||
        url.startsWith('https://youtu.be')) {
      if (url.length >= 30 &&
          url.substring(0, 30) == 'https://www.youtube.com/embed/') {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => IFramePlayerPage(
              url: url,
            ),
          ),
        );
      }
      if (url.startsWith('https://youtu.be')) {
        var pos = url.lastIndexOf('/');
        String result = (pos != -1) ? url.substring(0, pos) : url;
        String id = url.replaceAll('$result/', '');
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => IFramePlayerPage(
              url: 'https://www.youtube.com/embed/$id',
            ),
          ),
        );
      } else {
        String id = url.split("v=").last;
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (BuildContext context) => IFramePlayerPage(
              url: 'https://www.youtube.com/embed/$id',
            ),
          ),
        );
      }
    } else if (url.endsWith(".mp4") == true ||
        url.endsWith(".mpd") == true ||
        url.endsWith(".webm") == true ||
        url.endsWith(".mkv") == true ||
        url.endsWith(".m3u8") == true) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => new MyCustomPlayer(
            url: url,
            title: widget.liveEvent.title!,
            downloadStatus: 1,
            subtitles: null,
          ),
        ),
      );
    } else {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => IFramePlayerPage(
            url: url,
          ),
        ),
      );
    }
  }

  Widget _diagonalImageBackground(BuildContext context) {
    return widget.liveEvent.poster == null
        ? Image.asset(
            "assets/live.png",
            width: screenWidth,
            fit: BoxFit.cover,
          )
        : DiagonallyCutColoredImage(
            FadeInImage.assetNetwork(
              image: "${APIData.liveEventPoster}${widget.liveEvent.poster}",
              placeholder: "assets/live.png",
              width: screenWidth,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/live.png",
                  fit: BoxFit.cover,
                  width: screenWidth,
                );
              },
            ),
            color: Colors.black45,
          );
  }

  void _showMsg() {
    var dMsg = '';
    if (userProfileModel?.paypal!.length == 0 ||
        userProfileModel?.user!.subscriptions == null ||
        userProfileModel?.user!.subscriptions!.length == 0) {
      dMsg = translate(
              "Watch_unlimited_movies__TV_shows_and_videos_in_HD_or_SD_quality") +
          " " +
          translate("You_dont_have_subscribe");
    } else {
      dMsg = translate(
              "Watch_unlimited_movies__TV_shows_and_videos_in_HD_or_SD_quality") +
          " " +
          translate("You_dont_have_any_active_subscription_plan");
    }
    // set up the button
    Widget cancelButton = TextButton(
      child: Text(
        translate("Cancel_"),
        style: TextStyle(color: activeDotColor, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    Widget subscribeButton = TextButton(
      child: Text(
        translate("Subscribe_"),
        style: TextStyle(color: activeDotColor, fontSize: 16.0),
      ),
      onPressed: () {
        Navigator.pop(context);
        Navigator.pushNamed(context, RoutePaths.subscriptionPlans);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      contentPadding:
          EdgeInsets.only(top: 10.0, left: 16.0, right: 16.0, bottom: 0.0),
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            translate("Subscription_Plans"),
            style: TextStyle(color: Colors.black),
          ),
        ],
      ),
      content: Row(
        children: <Widget>[
          Flexible(
            flex: 1,
            fit: FlexFit.loose,
            child: Text(
              "$dMsg",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
          )
        ],
      ),
      actions: [
        subscribeButton,
        cancelButton,
      ],
    );

    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }
}
