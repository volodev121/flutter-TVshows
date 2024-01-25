import 'dart:developer';
import 'dart:io';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:nexthour/models/user_profile_model.dart';
import 'package:nexthour/providers/app_config.dart';
import '../../common/google-ads.dart';
import '../../models/CountViewModel.dart';
import '../../models/Subtitles.dart';
import '../../providers/count_view_provider.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/models/datum.dart';
import '/models/episode.dart';
import '/player/iframe_player.dart';
import '/player/m_player.dart';
import '/player/player.dart';
import '/player/playerMovieTrailer.dart';
import '/player/player_episodes.dart';
import '/providers/user_profile_provider.dart';
import '/ui/widgets/video_header_diagonal.dart';
import '/ui/widgets/video_item_box.dart';
import 'package:provider/provider.dart';

class VideoDetailHeader extends StatefulWidget {
  VideoDetailHeader(this.videoDetail, this.userProfileModel);

  final Datum? videoDetail;
  final UserProfileModel? userProfileModel;

  @override
  VideoDetailHeaderState createState() => VideoDetailHeaderState();
}

class VideoDetailHeaderState extends State<VideoDetailHeader>
    with WidgetsBindingObserver {
  var dMsg = '';
  var hdUrl;
  var sdUrl;
  var mReadyUrl,
      mIFrameUrl,
      mUrl360,
      mUrl480,
      mUrl720,
      mUrl1080,
      youtubeUrl,
      vimeoUrl,
      uploadVideo;

  bool notAdult() {
    bool canWatch = true;
    if (widget.videoDetail!.maturityRating == MaturityRating.ADULT) {
      log('Adult Content');
      if (int.parse(widget.userProfileModel!.user!.age.toString()) <= 18) {
        canWatch = false;
      }
    }
    return canWatch;
  }

  getAllScreens(mVideoUrl, type, subtitles) async {
    log("Video Details :-> ${widget.videoDetail?.toJson().toString()}");
    bool canWatch = notAdult();
    if (canWatch) {
      if (type == "CUSTOM") {
        addHistory(widget.videoDetail!.type, widget.videoDetail!.id);
        var router = new MaterialPageRoute(
          builder: (BuildContext context) => new MyCustomPlayer(
            url: mVideoUrl,
            title: widget.videoDetail!.title!,
            downloadStatus: 1,
            subtitles: subtitles,
          ),
        );
        Navigator.of(context).push(router);
      } else if (type == "EMD") {
        addHistory(widget.videoDetail!.type, widget.videoDetail!.id);
        var router = new MaterialPageRoute(
          builder: (BuildContext context) => IFramePlayerPage(url: mVideoUrl),
        );
        Navigator.of(context).push(router);
      } else if (type == "JS") {
        addHistory(widget.videoDetail!.type, widget.videoDetail!.id);
        var router = new MaterialPageRoute(
          builder: (BuildContext context) => PlayerMovie(
            id: widget.videoDetail!.id,
            type: widget.videoDetail!.type,
          ),
        );
        Navigator.of(context).push(router);
      }
    } else {
      log("You can't access this content!");
      Fluttertoast.showToast(
        msg: translate("You_cant_access_this_content_"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  var appconfig;
  @override
  void initState() {
    super.initState();
    appconfig = Provider.of<AppConfig>(context, listen: false).appModel;
  }

  Future<String?> addHistory(vType, id) async {
    var type = vType == DatumType.M ? "M" : "T";
    final response = await http.get(
        Uri.parse(
            "${APIData.addWatchHistory}/$type/$id?secret=${APIData.secretKey}"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
    log("Add to Watch History API Input :-> Type = $type, ID = $id");
    log("Add to Watch History API Status Code :-> ${response.statusCode}");
    log("Add to Watch History API Response :-> ${response.body}");
    if (response.statusCode == 200) {
    } else {
      throw "can't added to history.";
    }
    return null;
  }

  void _showMsg() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    if (userDetails.paypal!.length == 0 ||
        userDetails.user!.subscriptions == null ||
        userDetails.user!.subscriptions!.length == 0) {
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

  void _showDialog(i) {
    log("Video Details :-> ${widget.videoDetail?.toJson().toString()}");
    var videoLinks;
    var episodeUrl;
    var episodeTitle;
    episodeUrl = widget.videoDetail!.seasons![newSeasonIndex].episodes;
    episodeTitle = episodeUrl![0].title;
    videoLinks = episodeUrl![0].videoLink;

    var subtitles = Subtitles1.fromJson(episodeUrl![0].subtitles);
    log("Subtitles :-> ${subtitles.toJson()}");

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0))),
          backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
          title: Text(
            translate("Video_Quality"),
            style: TextStyle(
              color: Color.fromRGBO(72, 163, 198, 1.0),
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          content: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  translate(
                      "Select_Video_Format_in_which_you_want_to_play_video"),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(
                  height: 10.0,
                ),
                videoLinks.url360 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("360"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            print("season Url: ${videoLinks.url360}");
                            var hdUrl = videoLinks.url360;
                            var hdTitle = episodeTitle;
                            freeTrial(hdUrl, "CUSTOM", hdTitle, subtitles);
                          },
                        ),
                      ),
                videoLinks.url480 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("480"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            print("season Url: ${videoLinks.url480}");
                            var hdUrl = videoLinks.url480;
                            var hdTitle = episodeTitle;
                            freeTrial(hdUrl, "CUSTOM", hdTitle, subtitles);
                          },
                        ),
                      ),
                videoLinks.url720 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("720"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            print("season Url: ${videoLinks.url720}");
                            var hdUrl = videoLinks.url720;
                            var hdTitle = episodeTitle;
                            freeTrial(hdUrl, "CUSTOM", hdTitle, subtitles);
                          },
                        ),
                      ),
                videoLinks.url1080 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("1080"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            print("season Url: ${videoLinks.url1080}");
                            var hdUrl = videoLinks.url1080;
                            var hdTitle = episodeTitle;
                            freeTrial(hdUrl, "CUSTOM", hdTitle, subtitles);
                          },
                        ),
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  freeTrial(videoURL, type, title, subtitles) {
    bool canWatch = notAdult();
    if (canWatch) {
      if (type == "EMD") {
        print("mIFrameUrl22");
        addHistory(widget.videoDetail!.type, widget.videoDetail!.id);
        var router = new MaterialPageRoute(
          builder: (BuildContext context) => IFramePlayerPage(url: mIFrameUrl),
        );
        Navigator.of(context).push(router);
      } else if (type == "CUSTOM") {
        addHistory(widget.videoDetail!.type, widget.videoDetail!.id);
        var router1 = new MaterialPageRoute(
          builder: (BuildContext context) => MyCustomPlayer(
            url: videoURL,
            title: title,
            downloadStatus: 1,
            subtitles: subtitles,
          ),
        );
        Navigator.of(context).push(router1);
      } else {
        addHistory(widget.videoDetail!.type, widget.videoDetail!.id);
        var router = new MaterialPageRoute(
          builder: (BuildContext context) => PlayerEpisode(id: videoURL),
        );
        Navigator.of(context).push(router);
      }
    } else {
      log("You can't access this content!");
      Fluttertoast.showToast(
        msg: translate("You_cant_access_this_content_"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  void _onTapPlay() {
    if (widget.videoDetail!.type == DatumType.T) {
      var videoLinks;
      var episodeUrl;
      episodeUrl = widget.videoDetail!.seasons![newSeasonIndex].episodes;
      videoLinks = episodeUrl![0].videoLink;

      var subtitles = Subtitles1.fromJson(episodeUrl![0].subtitles);
      log("Subtitles :-> ${subtitles.toJson()}");

      log("Video Details :-> ${widget.videoDetail?.toJson().toString()}");

      mReadyUrl = videoLinks.readyUrl;
      mUrl360 = videoLinks.url360;
      mUrl480 = videoLinks.url480;
      mUrl720 = videoLinks.url720;
      mUrl1080 = videoLinks.url1080;
      mIFrameUrl = videoLinks.iframeurl;

      if (mIFrameUrl != null ||
          mReadyUrl != null ||
          mUrl360 != null ||
          mUrl480 != null ||
          mUrl720 != null ||
          mUrl1080 != null) {
        if (mIFrameUrl != null) {
          var matchIFrameUrl = mIFrameUrl.substring(0, 24);
          if (matchIFrameUrl == 'https://drive.google.com') {
            var rep = mIFrameUrl.split('/d/').last;
            rep = rep.split('/preview').first;
            var newurl =
                "https://www.googleapis.com/drive/v3/files/$rep?alt=media&key=${APIData.googleDriveApi}";
            getAllScreens(newurl, "CUSTOM", subtitles);
          } else {
            getAllScreens(mIFrameUrl, "EMD", subtitles);
          }
        } else if (mReadyUrl != null) {
          var checkMp4 = videoLinks.readyUrl.substring(mReadyUrl.length - 4);
          var checkMpd = videoLinks.readyUrl.substring(mReadyUrl.length - 4);
          var checkWebm = videoLinks.readyUrl.substring(mReadyUrl.length - 5);
          var checkMkv = videoLinks.readyUrl.substring(mReadyUrl.length - 4);
          var checkM3u8 = videoLinks.readyUrl.substring(mReadyUrl.length - 5);

          if (videoLinks.readyUrl.substring(0, 18) == "https://vimeo.com/" ||
              videoLinks.readyUrl.substring(0, 25) ==
                  "https://player.vimeo.com/") {
            getAllScreens(episodeUrl[0]['id'], "JS", subtitles);
          } else if (videoLinks.readyUrl.substring(0, 29) ==
              'https://www.youtube.com/embed') {
            getAllScreens(mReadyUrl, "EMD", subtitles);
          } else if (videoLinks.readyUrl.substring(0, 23) ==
              'https://www.youtube.com') {
            getAllScreens(episodeUrl[0]['id'], "JS", subtitles);
          } else if (checkMp4 == ".mp4" ||
              checkMpd == ".mpd" ||
              checkWebm == ".webm" ||
              checkMkv == ".mkv" ||
              checkM3u8 == ".m3u8") {
            getAllScreens(mReadyUrl, "CUSTOM", subtitles);
          } else {
            getAllScreens(episodeUrl[0]['id'], "JS", subtitles);
          }
        } else if (mUrl360 != null ||
            mUrl480 != null ||
            mUrl720 != null ||
            mUrl1080 != null) {
          _showDialog(0);
        } else {
          getAllScreens(seasonEpisodeData[0]['id'], "JS", subtitles);
        }
      } else {
        Fluttertoast.showToast(msg: translate("Video_URL_doesnt_exist"));
      }
    } else {
      var videoLink = widget.videoDetail!.videoLink!;
      var subtitles = widget.videoDetail!.subtitles;

      var vLink = videoLink.toJson();
      log("Video Link :-> $vLink");
      mIFrameUrl = videoLink.iframeurl;
      print("Iframe: $mIFrameUrl");
      mReadyUrl = videoLink.readyUrl;
      print("Ready Url: $mReadyUrl");
      mUrl360 = videoLink.url360;
      print("Url 360: $mUrl360");
      mUrl480 = videoLink.url480;
      print("Url 480: $mUrl480");
      mUrl720 = videoLink.url720;
      print("Url 720: $mUrl720");
      mUrl1080 = videoLink.url1080;
      print("Url 1080: $mUrl1080");
      String uvURL = videoLink.uploadVideo.toString();
      uploadVideo =
          uvURL.contains(' ') ? uvURL.replaceAll(RegExp(r' '), '%20') : uvURL;
      print("Upload Video: $uploadVideo");
      if (mIFrameUrl == null &&
          mReadyUrl == null &&
          mUrl360 == null &&
          mUrl480 == null &&
          mUrl720 == null &&
          mUrl1080 == null &&
          uploadVideo == null) {
        Fluttertoast.showToast(msg: translate("Video_is_not_available"));
      } else {
        if (mUrl360 != null ||
            mUrl480 != null ||
            mUrl720 != null ||
            mUrl1080 != null) {
          _showQualityDialog(mUrl360, mUrl480, mUrl720, mUrl1080, subtitles);
        } else {
          if (mIFrameUrl != null) {
            var matchIFrameUrl = mIFrameUrl.substring(0, 24);
            if (matchIFrameUrl == 'https://drive.google.com') {
              var rep = mIFrameUrl.split('/d/').last;
              rep = rep.split('/preview').first;
              var newurl =
                  "https://www.googleapis.com/drive/v3/files/$rep?alt=media&key=${APIData.googleDriveApi}";
              getAllScreens(newurl, "CUSTOM", subtitles);
            } else {
              print("mIFrameUrl $mIFrameUrl");
              getAllScreens(mIFrameUrl, "EMD", subtitles);
            }
          } else if (mReadyUrl != null) {
            var matchUrl = mReadyUrl;
            var checkMp4 = mReadyUrl.substring(mReadyUrl.length - 4);
            var checkMpd = mReadyUrl.substring(mReadyUrl.length - 4);
            var checkWebm = mReadyUrl.substring(mReadyUrl.length - 5);
            var checkMkv = mReadyUrl.substring(mReadyUrl.length - 4);
            var checkM3u8 = mReadyUrl.substring(mReadyUrl.length - 5);

            if (matchUrl.substring(0, 18) == "https://vimeo.com/" ||
                matchUrl.substring(0, 25) == "https://player.vimeo.com/") {
              var router = new MaterialPageRoute(
                builder: (BuildContext context) => PlayerMovie(
                  id: widget.videoDetail!.id,
                  type: widget.videoDetail!.type,
                ),
              );
              Navigator.of(context).push(router);
            } else if (matchUrl == 'https://www.youtube.com/embed') {
              var url = '$mReadyUrl';
              getAllScreens(url, "EMD", subtitles);
            } else if (matchUrl.substring(0, 23) == 'https://www.youtube.com') {
              getAllScreens(mReadyUrl, "JS", subtitles);
            } else if (checkMp4 == ".mp4" ||
                checkMpd == ".mpd" ||
                checkWebm == ".webm" ||
                checkMkv == ".mkv" ||
                checkM3u8 == ".m3u8") {
              getAllScreens(mReadyUrl, "CUSTOM", subtitles);
            } else {
              getAllScreens(mReadyUrl, "JS", subtitles);
            }
          } else if (uploadVideo != null) {
            getAllScreens(uploadVideo, "CUSTOM", subtitles);
          }
        }
      }
    }
  }

  void _showQualityDialog(mUrl360, mUrl480, mUrl720, mUrl1080, subtitles) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          backgroundColor: Color.fromRGBO(250, 250, 250, 1.0),
          title: Text(
            translate("Video_Quality"),
            style: TextStyle(
              color: Color.fromRGBO(72, 163, 198, 1.0),
              fontWeight: FontWeight.w600,
              fontSize: 20.0,
            ),
            textAlign: TextAlign.center,
          ),
          content: Container(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  translate(
                      "Select_Video_Format_in_which_you_want_to_play_video"),
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.7),
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(
                  height: 5.0,
                ),
                mUrl360 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("360"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            getAllScreens(mUrl360, "CUSTOM", subtitles);
                          },
                        ),
                      ),
                SizedBox(
                  height: 5.0,
                ),
                mUrl480 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("480"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            getAllScreens(mUrl480, "CUSTOM", subtitles);
                          },
                        ),
                      ),
                SizedBox(
                  height: 5.0,
                ),
                mUrl720 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("720"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            getAllScreens(mUrl720, "CUSTOM", subtitles);
                          },
                        ),
                      ),
                SizedBox(
                  height: 5.0,
                ),
                mUrl1080 == null
                    ? SizedBox.shrink()
                    : Padding(
                        padding: EdgeInsets.only(left: 50.0, right: 50.0),
                        child: ElevatedButton(
                          style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all<Color?>(
                              activeDotColor,
                            ),
                            overlayColor: MaterialStateProperty.all<Color?>(
                              Color.fromRGBO(72, 163, 198, 1.0),
                            ),
                          ),
                          child: Container(
                            alignment: Alignment.center,
                            width: 100.0,
                            height: 30.0,
                            child: Text("1080"),
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                            getAllScreens(mUrl1080, "CUSTOM", subtitles);
                          },
                        ),
                      ),
                SizedBox(
                  height: 5.0,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _onTapTrailer() {
    bool canWatch = notAdult();
    if (canWatch) {
      var trailerUrl;
      if (widget.videoDetail!.type == DatumType.T) {
        trailerUrl = widget.videoDetail!.seasons![newSeasonIndex].strailerUrl;
      } else {
        trailerUrl = widget.videoDetail!.trailerUrl;
      }
      if (trailerUrl == null) {
        Fluttertoast.showToast(msg: translate("Trailer_is_not_available"));
      } else {
        var checkMp4 = trailerUrl.substring(trailerUrl.length - 4);
        var checkMpd = trailerUrl.substring(trailerUrl.length - 4);
        var checkWebm = trailerUrl.substring(trailerUrl.length - 5);
        var checkMkv = trailerUrl.substring(trailerUrl.length - 4);
        var checkM3u8 = trailerUrl.substring(trailerUrl.length - 5);
        if (trailerUrl.substring(0, 23) == 'https://www.youtube.com') {
          var router = new MaterialPageRoute(
            builder: (BuildContext context) => new PlayerMovieTrailer(
              id: widget.videoDetail!.id,
              type: widget.videoDetail!.type,
            ),
          );
          Navigator.of(context).push(router);
        } else if (checkMp4 == ".mp4" ||
            checkMpd == ".mpd" ||
            checkWebm == ".webm" ||
            checkMkv == ".mkv" ||
            checkM3u8 == ".m3u8") {
          var router = new MaterialPageRoute(
            builder: (BuildContext context) => new MyCustomPlayer(
              url: trailerUrl,
              title: widget.videoDetail!.title!,
              downloadStatus: 1,
              subtitles: null,
            ),
          );
          Navigator.of(context).push(router);
        } else {
          var router = new MaterialPageRoute(
            builder: (BuildContext context) => new PlayerMovieTrailer(
              id: widget.videoDetail!.id,
              type: widget.videoDetail!.type,
            ),
          );
          Navigator.of(context).push(router);
        }
      }
    } else {
      log("You can't access this content!");
      Fluttertoast.showToast(
        msg: translate("You_cant_access_this_content_"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    return Stack(
      children: <Widget>[
        new Padding(
          padding: const EdgeInsets.only(bottom: 130.0),
          child: _buildDiagonalImageBackground(context),
        ),
        headerDecorationContainer(),
        new Positioned(
          top: 26.0,
          left: 4.0,
          child: new BackButton(color: Colors.white),
        ),
        new Positioned(
          top: 180.0,
          bottom: 0.0,
          left: 16.0,
          right: 16.0,
          child: headerRow(theme),
        ),
      ],
    );
  }

  Widget headerRow(theme) {
    var dW = MediaQuery.of(context).size.width;
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var ratingCaptionStyle = textTheme.bodySmall!.copyWith(
        letterSpacing: -0.2,
        color: Colors.white70,
        fontSize: 10.0,
        fontWeight: FontWeight.w700);
    dynamic tmbdRat = widget.videoDetail!.rating;
    if (tmbdRat.runtimeType == int) {
      double reciprocal(double d) => 1 / d;

      reciprocal(tmbdRat.toDouble());

      tmbdRat = widget.videoDetail!.rating == null ? 0.0 : tmbdRat / 2;
    } else if (tmbdRat.runtimeType == String) {
      tmbdRat =
          widget.videoDetail!.rating == null ? 0.0 : double.parse(tmbdRat) / 2;
    } else {
      tmbdRat = widget.videoDetail!.rating == null ? 0.0 : tmbdRat / 2;
    }

    CountViewModel countViewModel =
        Provider.of<CountViewProvider>(context, listen: false).countViewModel;
    int views = 0;
    print("Movie ID :-> ${widget.videoDetail?.id}");
    countViewModel.movies?.forEach((element) {
      if (element.id == widget.videoDetail?.id &&
          element.title == widget.videoDetail?.title) {
        // View Count
        views = element.views! + element.uniqueViewsCount!;
        // Protected Content Password
        if (element.isProtect == 1) {
          String password =
              element.password != null ? element.password.toString() : "N/A";
          if (protectedContentPwd.length > 0) {
            if (!protectedContentPwd.containsKey(
                '${widget.videoDetail?.id}_${widget.videoDetail?.id}')) {
              protectedContentPwd[
                      '${widget.videoDetail?.id}_${widget.videoDetail?.id}'] =
                  password;
            }
          } else {
            protectedContentPwd[
                    '${widget.videoDetail?.id}_${widget.videoDetail?.id}'] =
                password;
          }
        }
      }
    });

    var viewsCount = Row(
      children: <Widget>[
        Icon(
          Icons.visibility,
          size: 17,
          color: Colors.white,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 3.0,
          ),
          child: Text(
            "${valueToKMB(value: views)} ${(views == 1) ? 'view' : 'views'}",
            style: TextStyle(
              fontSize: 12.0,
            ),
          ),
        ),
      ],
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 1,
          child: new Hero(
            tag: "${widget.videoDetail!.title} ${widget.videoDetail!.id}",
            child: VideoItemBox(
              context,
              widget.videoDetail,
            ),
          ),
        ),
        Expanded(
          flex: dW > 900 ? 1 : 2,
          child: new Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: new Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                dW > 900 || widget.videoDetail!.rating == null
                    ? Text(
                        widget.videoDetail!.title!,
                        style: Theme.of(context).textTheme.titleLarge,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      )
                    : Expanded(
                        flex: 2,
                        child: Text(
                          widget.videoDetail!.title!,
                          style: Theme.of(context).textTheme.titleLarge,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                widget.videoDetail!.rating == null
                    ? SizedBox.shrink()
                    : SizedBox(
                        height: 10.0,
                      ),
                Expanded(
                  flex: dW > 900 ? 1 : 4,
                  child: widget.videoDetail!.rating == null
                      ? SizedBox.shrink()
                      : Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: EdgeInsets.only(
                                  left: 3.5, right: 3.5, top: 3.0, bottom: 3.0),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: new Text(
                                      "$tmbdRat",
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                  SizedBox(
                                    height: 1.0,
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: Padding(
                                      padding: const EdgeInsets.only(top: 0.0),
                                      child: new Text(
                                        translate('Rating_').toUpperCase(),
                                        style: ratingCaptionStyle,
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.only(left: 8.0),
                                  child: RatingBar.builder(
                                    initialRating:
                                        widget.videoDetail!.rating == null
                                            ? 0.0
                                            : tmbdRat,
                                    minRating: 1,
                                    direction: Axis.horizontal,
                                    allowHalfRating: true,
                                    itemCount: 5,
                                    itemSize: 25,
                                    itemBuilder: (context, _) => Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    onRatingUpdate: (rating) {
                                      print(rating);
                                    },
                                  ),
                                ),
                                if (widget.videoDetail?.type == DatumType.M)
                                  viewsCount,
                              ],
                            ),
                          ],
                        ),
                ),
                dW > 900
                    ? Expanded(
                        flex: 2,
                        child: header(theme),
                      )
                    : header(theme),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget headerDecorationContainer() {
    return Container(
      height: 262.0,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: FractionalOffset.topCenter,
          end: FractionalOffset.bottomCenter,
          colors: [
            Theme.of(context).primaryColorDark.withOpacity(0.1),
            Theme.of(context).primaryColorDark
          ],
          stops: [0.3, 0.8],
        ),
      ),
    );
  }

  Widget header(theme) {
    var dW = MediaQuery.of(context).size.width;
    final userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Padding(
      padding: const EdgeInsets.only(top: 6.0),
      child: dW > 900
          ? Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor),
                      overlayColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColorDark.withOpacity(0.1)),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.fromLTRB(0, 10.0, 0.0, 10.0)),
                      textStyle: MaterialStateProperty.all(
                        Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontFamily: 'Lato',
                            ),
                      ),
                    ),
                    onPressed: () {
                      // Remove this line
                      // userDetails.active = "1";
                      // -----
                      if (userDetails.active == "1" ||
                          userDetails.active == 1) {
                        if ((userDetails.removeAds == "0" ||
                                userDetails.removeAds == 0) &&
                            (appconfig.appConfig.removeAds == 0 ||
                                appconfig.appConfig.removeAds == '0')) {
                          // createInterstitialAd()
                          //     .then((value) => showInterstitialAd());
                        }
                        _onTapPlay();
                      } else {
                        _showMsg();
                      }
                    },
                    icon: Icon(Icons.play_arrow,
                        size: 30.0,
                        color: Theme.of(context).colorScheme.secondary),
                    label: Text(
                      translate('Watch_Now'),
                    ),
                  ),
                ),
                SizedBox(
                  width: 20.0,
                ),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColor.withOpacity(0.2)),
                      overlayColor: MaterialStateProperty.all(
                          Theme.of(context).primaryColorDark.withOpacity(0.1)),
                      padding: MaterialStateProperty.all(
                          const EdgeInsets.fromLTRB(0, 10.0, 0.0, 10.0)),
                      textStyle: MaterialStateProperty.all(
                        Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontFamily: 'Lato',
                            ),
                      ),
                    ),
                    onPressed: _onTapTrailer,
                    icon: Icon(Icons.play_arrow_outlined,
                        size: 30.0,
                        color: Theme.of(context).colorScheme.secondary),
                    label: Text(
                      translate('Preview_'),
                    ),
                  ),
                ),
              ],
            )
          : Column(
              children: <Widget>[
                "${widget.videoDetail?.isUpcoming}" == "1"
                    ? Container(
                        height: 40,
                        padding: EdgeInsets.all(6.0),
                        child: AnimatedTextKit(
                          repeatForever: true,
                          animatedTexts: [
                            FadeAnimatedText(
                              translate("Coming_Soon"),
                              textAlign: TextAlign.center,
                              textStyle: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      )
                    : OutlinedButton(
                        onPressed: () {
                          // Remove this line
                          // userDetails.active = "1";
                          // -----
                          if (userDetails.active == "1" ||
                              userDetails.active == 1) {
                            if ((userDetails.removeAds == "0" ||
                                    userDetails.removeAds == 0) &&
                                (appconfig.appConfig.removeAds == 0 ||
                                    appconfig.appConfig.removeAds == '0')) {
                              createInterstitialAd()
                                  .then((value) => showInterstitialAd());
                            }
                            _onTapPlay();
                          } else {
                            _showMsg();
                          }
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            Expanded(
                              flex: 0,
                              child: Icon(
                                Icons.play_arrow,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                            new Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                            ),
                            Expanded(
                              flex: 1,
                              child: new Text(
                                translate("Play_"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: 'Lato',
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.9,
                                  color:
                                      isLight ? Colors.black54 : Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.all<Color?>(
                            theme.primaryColor.withOpacity(0.1),
                          ),
                          overlayColor: MaterialStateProperty.all<Color?>(
                            theme.primaryColor,
                          ),
                          padding:
                              MaterialStateProperty.all<EdgeInsetsGeometry?>(
                            const EdgeInsets.fromLTRB(6.0, 0.0, 12.0, 0.0),
                          ),
                          shape: MaterialStateProperty.all<OutlinedBorder?>(
                            RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(10.0),
                              side: BorderSide(
                                color: Theme.of(context).primaryColor,
                                width: 2.0,
                              ),
                            ),
                          ),
                        ),
                      ),
                OutlinedButton(
                  onPressed: _onTapTrailer,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Expanded(
                        flex: 0,
                        child: new Icon(
                          Icons.play_arrow,
                        ),
                      ),
                      new Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 5.0, 0.0),
                      ),
                      Expanded(
                        flex: 1,
                        child: new Text(
                          translate("Trailer_"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 15.0,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.9,
                            color: isLight ? Colors.black54 : Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  style: ButtonStyle(
                    overlayColor: MaterialStateProperty.all<Color?>(
                      theme.primaryColorLight,
                    ),
                    padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
                      const EdgeInsets.fromLTRB(6.0, 0.0, 12.0, 0.0),
                    ),
                    shape: MaterialStateProperty.all<OutlinedBorder?>(
                      RoundedRectangleBorder(
                        borderRadius: new BorderRadius.circular(10.0),
                        side: BorderSide(color: Colors.white70, width: 2.0),
                      ),
                    ),
                  ),
                )
              ],
            ),
    );
  }

  Widget _buildDiagonalImageBackground(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return widget.videoDetail!.poster == null
        ? Image.asset(
            "assets/placeholder_cover.jpg",
            height: 225.0,
            width: screenWidth,
            fit: BoxFit.cover,
          )
        : DiagonallyCutColoredImage(
            FadeInImage.assetNetwork(
              image: widget.videoDetail!.type == DatumType.M
                  ? "${APIData.movieImageUriPosterMovie}${widget.videoDetail!.poster}"
                  : "${APIData.tvImageUriPosterTv}${widget.videoDetail!.poster}",
              placeholder: "assets/placeholder_cover.jpg",
              width: screenWidth,
              height: 225.0,
              fit: BoxFit.cover,
              imageErrorBuilder: (context, error, stackTrace) {
                return Image.asset(
                  "assets/placeholder_cover.jpg",
                  fit: BoxFit.cover,
                  width: screenWidth,
                  height: 225.0,
                );
              },
            ),
            color: const Color(0x00FFFFFF),
          );
  }
}
