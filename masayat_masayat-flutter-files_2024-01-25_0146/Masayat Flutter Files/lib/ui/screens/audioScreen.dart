import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/models/AudioModel.dart';
import 'package:nexthour/models/user_profile_model.dart';
import 'package:provider/provider.dart';
import '../../common/global.dart';
import '../../common/route_paths.dart';
import '../../providers/user_profile_provider.dart';
import '../shared/appbar.dart';
import '../widgets/expandable_text.dart';
import '../widgets/video_header_diagonal.dart';
import 'package:audioplayers/audioplayers.dart';

class AudioScreen extends StatefulWidget {
  const AudioScreen({required this.audio});

  final Audio audio;

  @override
  State<AudioScreen> createState() => _AudioScreenState();
}

class _AudioScreenState extends State<AudioScreen> {
  AudioPlayer audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    initialization();
    super.initState();
  }

  Future<void> initialization() async {
    userProfileModel = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;

    if (widget.audio.uploadAudio != null) {
      await audioPlayer
          .setSourceUrl('${APIData.audioFile}${widget.audio.uploadAudio}');
      print('Audio :-> ${APIData.audioFile}${widget.audio.uploadAudio}');
    } else if (widget.audio.audiourl != null) {
      await audioPlayer.setSourceUrl('${widget.audio.audiourl}');
    }

    audioPlayer.onPlayerStateChanged.listen((state) {
      setState(() {
        isPlaying = state == PlayerState.playing;
      });
    });

    audioPlayer.onDurationChanged.listen((cDuration) {
      setState(() {
        duration = cDuration;
      });
    });

    audioPlayer.onPositionChanged.listen((cPosition) {
      setState(() {
        position = cPosition;
      });
    });

    audioPlayer.onPlayerComplete.listen((_) {
      setState(() {
        position = Duration.zero;
        isPlaying = false;
      });
    });
  }

  @override
  void dispose() {
    audioPlayer.dispose();
    super.dispose();
  }

  UserProfileModel? userProfileModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Audio_")) as PreferredSizeWidget,
      body: Container(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  _diagonalImageBackground(context),
                  widget.audio.thumbnail == null
                      ? Center(
                          child: CircleAvatar(
                            backgroundImage:
                                AssetImage("assets/placeholder_cover.jpg"),
                            radius: 125.0,
                          ),
                        )
                      : Center(
                          child: CircleAvatar(
                            backgroundImage: NetworkImage(
                                "${APIData.audioThumbnail}${widget.audio.thumbnail}"),
                            radius: 125.0,
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
                    Text(
                      "${widget.audio.title}",
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (widget.audio.detail != null) SizedBox(height: 5),
                    if (widget.audio.detail != null)
                      Container(
                        padding: EdgeInsets.all(10.0),
                        child: ExpandableText(
                          Colors.white,
                          "${widget.audio.detail}",
                          3,
                        ),
                      ),
                    SizedBox(height: 10),
                    Slider(
                      min: 0,
                      max: duration.inSeconds.toDouble(),
                      value: position.inSeconds.toDouble(),
                      onChanged: (newValue) async {
                        final position = Duration(seconds: newValue.toInt());
                        await audioPlayer.seek(position);
                        await audioPlayer.resume();
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 30.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(formatTime(position)),
                          Text(formatTime(duration)),
                        ],
                      ),
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: MediaQuery.of(context).size.width - 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          CircleAvatar(
                            radius: 25,
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.replay_10,
                                  size: 28.0,
                                ),
                                onPressed: () async {
                                  if ('${userProfileModel?.active}' == '1') {
                                    if ((position.inSeconds - 10) >= 0) {
                                      await audioPlayer.seek(Duration(
                                          seconds: position.inSeconds - 10));
                                      await audioPlayer.resume();
                                    } else {
                                      await audioPlayer
                                          .seek(Duration(seconds: 0));
                                      await audioPlayer.resume();
                                    }
                                  } else {
                                    _showMsg();
                                  }
                                },
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 35,
                            child: Center(
                              child: IconButton(
                                icon: isPlaying
                                    ? Icon(
                                        Icons.pause,
                                        size: 30.0,
                                      )
                                    : Icon(
                                        Icons.play_arrow,
                                        size: 30.0,
                                      ),
                                onPressed: () async {
                                  if ('${userProfileModel?.active}' == '1') {
                                    if (isPlaying) {
                                      await audioPlayer.pause();
                                    } else {
                                      if (widget.audio.uploadAudio != null) {
                                        await audioPlayer.play(
                                          UrlSource(
                                              '${APIData.audioFile}${widget.audio.uploadAudio}'),
                                        );
                                      } else if (widget.audio.audiourl !=
                                          null) {
                                        await audioPlayer.play(
                                          UrlSource('${widget.audio.audiourl}'),
                                        );
                                      }
                                    }
                                  } else {
                                    _showMsg();
                                  }
                                },
                              ),
                            ),
                          ),
                          CircleAvatar(
                            radius: 25,
                            child: Center(
                              child: IconButton(
                                icon: Icon(
                                  Icons.forward_10,
                                  size: 28.0,
                                ),
                                onPressed: () async {
                                  if ('${userProfileModel?.active}' == '1') {
                                    if ((position.inSeconds + 10) <=
                                        duration.inSeconds) {
                                      await audioPlayer.seek(Duration(
                                          seconds: position.inSeconds + 10));
                                      await audioPlayer.resume();
                                    } else {
                                      await audioPlayer.seek(Duration(
                                          seconds: duration.inSeconds));
                                      await audioPlayer.resume();
                                    }
                                  } else {
                                    _showMsg();
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
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

  Widget _diagonalImageBackground(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    print("Audio Poster : ${APIData.audioPoster}${widget.audio.poster}");
    return widget.audio.poster == null
        ? Image.asset(
            "assets/music.png",
            width: screenWidth,
            fit: BoxFit.cover,
          )
        : DiagonallyCutColoredImage(
            FadeInImage.assetNetwork(
              image: "${APIData.audioPoster}${widget.audio.poster}",
              placeholder: "assets/music.png",
              width: screenWidth,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/music.png",
                  fit: BoxFit.cover,
                  width: screenWidth,
                );
              },
            ),
            color: Colors.black45,
          );
  }

  String formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, "0");

    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return [if (duration.inHours > 0) hours, minutes, seconds].join(":");
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
