import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart' as chewei;
import 'package:flutter/services.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nexthour/common/styles.dart';

import 'package:provider/provider.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_position.dart';
import 'package:subtitle_wrapper_package/data/models/style/subtitle_style.dart';
import 'package:subtitle_wrapper_package/subtitle_controller.dart';
import 'package:subtitle_wrapper_package/subtitle_wrapper.dart';
import 'package:video_player/video_player.dart';
import '../common/apipath.dart';
import '../common/google-ads.dart';
import '../models/Subtitles.dart';
import '../providers/app_config.dart';
import '../providers/user_profile_provider.dart';
import '/common/global.dart';
import 'package:flutter/material.dart';
//import 'package:wakelock/wakelock.dart';

// ignore: must_be_immutable
class MyCustomPlayer extends StatefulWidget {
  MyCustomPlayer({
    required this.title,
    required this.url,
    this.downloadStatus,
    required this.subtitles,
  });

  final String title;
  String url;
  final dynamic downloadStatus;
  final Subtitles1? subtitles;

  @override
  State<StatefulWidget> createState() {
    return _MyCustomPlayerState();
  }
}

class _MyCustomPlayerState extends State<MyCustomPlayer>
    with WidgetsBindingObserver {
  TargetPlatform? platform;
  chewei.ChewieController? _betterPlayerController;
  VideoPlayerController? _videoPlayerController;
  SubtitleController? _subtitleController;

  var betterPlayerConfiguration;
  DateTime? currentBackPressTime;
  bool _subtitleOn = false;

  dynamic selectedVideoIndex;

  //  Handle back press
  Future<bool> onWillPopS() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Navigator.pop(context);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);

      return Future.value(true);
    }
    return Future.value(true);
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        if (_betterPlayerController != null) _betterPlayerController!.pause();
        debugPrint("Inactive");
        break;
      case AppLifecycleState.resumed:
        if (_betterPlayerController != null) _betterPlayerController!.pause();
        break;
      case AppLifecycleState.paused:
        if (_betterPlayerController != null) _betterPlayerController!.pause();
        break;
      case AppLifecycleState.detached:
        break;
    }
  }

  BannerAd? _bannerAd;
  AdWidget? adWidget;

  @override
  void initState() {
    initializePlayer();
    super.initState();

    // Ad
    _bannerAd = BannerAd(
      adUnitId: Platform.isAndroid ? bannerAdIDAndroid : bannerAdIDiOS,
      request: AdRequest(),
      size: AdSize.banner,
      listener: BannerAdListener(
        onAdLoaded: (Ad ad) {
          print('$BannerAd loaded.');
        },
        onAdFailedToLoad: (Ad ad, LoadAdError error) {
          print('$BannerAd failedToLoad: $error');
        },
        onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
        onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
      ),
    );
    _bannerAd?.load();
    adWidget = AdWidget(ad: _bannerAd!);

    setState(() {
      playerTitle = widget.title;
    });

    WidgetsBinding.instance.addObserver(this);
    Future.delayed(Duration.zero, () {
      initializePlayer();
    });

    String os = Platform.operatingSystem;

    if (os == 'android') {
      setState(() {
        platform = TargetPlatform.android;
      });
    } else {
      setState(() {
        platform = TargetPlatform.iOS;
      });
    }
  }

  Future<void> initializePlayer() async {
    widget.url = widget.url.contains(' ')
        ? widget.url.replaceAll(RegExp(r' '), '%20')
        : widget.url;
    print('Video URL :-> ${widget.url}');

    if (widget.subtitles != null) {
      if ((widget.subtitles?.subtitles?.length)! > 0) {
        for (int i = 0; i < (widget.subtitles?.subtitles?.length)!; i++) {
          _subtitleController = SubtitleController(
              subtitleType: SubtitleType.srt,
              subtitleUrl:
                  '${APIData.subtitlePlayer}${widget.subtitles!.subtitles![0].subT}',
              showSubtitles: true);
        }
      }
      print('hello${_subtitleController!.subtitleUrl}');
    }

    try {
      int _startAt = 0;
      if (await storage.containsKey(key: widget.url)) {
        String? s = await storage.read(key: widget.url);
        if (s != null) {
          _startAt = int.parse(s);
        } else {
          _startAt = 0;
        }
      }

      _videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(widget.url));
      await _videoPlayerController!.initialize();

      _betterPlayerController = chewei.ChewieController(
        videoPlayerController: _videoPlayerController!,
        showControls: true,
        showControlsOnInitialize: true,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        materialProgressColors: chewei.ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white,
        ),
        placeholder: Container(
          color: Colors.black,
        ),
        autoInitialize: true,
        additionalOptions: (context) {
          List<chewei.OptionItem> options = [
            chewei.OptionItem(
                onTap: () {
                  setState(() {
                    _subtitleOn = !_subtitleOn;
                  });
                },
                iconData: Icons.subtitles,
                title: 'Subtitles'),
          ];
          var z = widget.subtitles!.subtitles;
          for (int i = 0; i < z!.length; i++) {
            options.add(chewei.OptionItem(
              onTap: () {
                print('${APIData.subtitlePlayer}${z[i].subT}');
                _subtitleController!.updateSubtitleUrl(
                    url: '${APIData.subtitlePlayer}${z[i].subT}');
              },
              iconData: Icons.sign_language,
              title: "${z[i].subLang}",
            ));
          }

          return options;
        },
        optionsBuilder: (context, defaultOptions) async {
          await showModalBottomSheet<void>(
            context: context,
            builder: (BuildContext ctx) {
              return Container(
                height: 300,
                decoration: BoxDecoration(color: kDarkBgDark),
                child: ListView.builder(
                  itemCount: defaultOptions.length,
                  itemBuilder: (_, i) => ListTile(
                    leading: Icon(defaultOptions[i].iconData),
                    title: Text(defaultOptions[i].title),
                    onTap: () {
                      Navigator.pop(context); // Close the bottom sheet
                      defaultOptions[i]
                          .onTap!(); // Execute the selected option's onTap function
                    },
                  ),
                ),
              );
            },
          );
        },
      );

      _betterPlayerController!.play();

      _betterPlayerController!.videoPlayerController.addListener(
        () {
          if (currentPositionInSec == 0) setState(() {});
          currentPositionInSec = _betterPlayerController!
              .videoPlayerController.value.position.inSeconds;
          print('Position in Seconds : $currentPositionInSec');
        },
      );
    } catch (e) {
      print('Chewei Player Error :-> $e');
    }
  }

  int currentPositionInSec = 0, durationInSec = 0;

  void saveCurrentPosition() {
    durationInSec =
        _betterPlayerController!.videoPlayerController.value.duration.inSeconds;
    print('Duration in Seconds :$durationInSec');
    if (currentPositionInSec == durationInSec) {
      storage.write(key: widget.url, value: '0');
    } else {
      storage.write(key: widget.url, value: '$currentPositionInSec');
    }
  }

  @override
  void dispose() async {
    saveCurrentPosition();
    _videoPlayerController!.dispose();
    _betterPlayerController!.dispose();

    // Ad
    _bannerAd?.dispose();
    _bannerAd = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    final appconfig = Provider.of<AppConfig>(context, listen: false).appModel;
    return WillPopScope(
      child: Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.landscape
            ? null
            : AppBar(
                backgroundColor: Colors.transparent,
              ),
        backgroundColor: Theme.of(context).primaryColorDark,
        body: Stack(
          children: [
            _betterPlayerController == null
                ? Center(child: CircularProgressIndicator())
                : Center(
                    // flex: 8,
                    child: _betterPlayerController != null
                        ? GestureDetector(
                            child: SizedBox(
                              height: MediaQuery.of(context).orientation ==
                                      Orientation.landscape
                                  ? MediaQuery.of(context).size.longestSide
                                  : 360,
                              child: Stack(children: [
                                SubtitleWrapper(
                                  videoPlayerController:
                                      _betterPlayerController!
                                          .videoPlayerController,
                                  subtitleController: _subtitleController!,
                                  subtitleStyle: SubtitleStyle(
                                    position:
                                        MediaQuery.of(context).orientation ==
                                                Orientation.portrait
                                            ? SubtitlePosition(
                                                bottom: 0,
                                                top: 150,
                                                left: 0,
                                                right: 0)
                                            : SubtitlePosition(
                                                bottom: 0,
                                                top: 300,
                                                left: 0,
                                                right: 0),
                                    textColor: Colors.white,
                                    hasBorder: true,
                                  ),
                                  videoChild: chewei.Chewie(
                                    controller: _betterPlayerController!,
                                  ),
                                ),
                                Positioned(
                                    bottom: 0,
                                    top: 247,
                                    left: MediaQuery.of(context).size.width *
                                            0.9 -
                                        24,
                                    right: 0,
                                    child: MediaQuery.of(context).orientation ==
                                            Orientation.portrait
                                        ? AnimatedOpacity(
                                            duration: Duration(seconds: 3),
                                            opacity: 0.0,
                                            child: IconButton(
                                                onPressed: () {
                                                  SystemChrome
                                                      .setPreferredOrientations([
                                                    DeviceOrientation
                                                        .landscapeLeft,
                                                    DeviceOrientation
                                                        .landscapeRight,
                                                  ]);
                                                },
                                                icon: Icon(
                                                  Icons.fullscreen,
                                                  size: 25,
                                                  color: Colors.white,
                                                )),
                                          )
                                        : SizedBox()),
                                Positioned(
                                  bottom: 0,
                                  top: 310,
                                  left: MediaQuery.of(context).size.width * 0.9,
                                  right: 0,
                                  child: MediaQuery.of(context).orientation ==
                                          Orientation.portrait
                                      ? SizedBox()
                                      : AnimatedOpacity(
                                          opacity: 0.0,
                                          duration: Duration(seconds: 3),
                                          child: IconButton(
                                            icon: Icon(
                                              Icons.fullscreen_exit,
                                              size: 25,
                                              color: Colors.white,
                                            ),
                                            onPressed: () {
                                              SystemChrome
                                                  .setPreferredOrientations([
                                                DeviceOrientation.portraitUp,
                                                DeviceOrientation.portraitDown,
                                              ]);
                                            },
                                          ),
                                        ),
                                ),
                              ]),
                            ),
                          )
                        : SizedBox.shrink(),
                  ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if ((userDetails.removeAds == "0" ||
                        userDetails.removeAds == 0) &&
                    (appconfig?.appConfig?.removeAds == 0 ||
                        appconfig?.appConfig?.removeAds == '0'))
                  Expanded(
                    flex: 1,
                    child: Align(
                      alignment: FractionalOffset.topCenter,
                      child: Padding(
                        padding: EdgeInsets.only(top: 20.0),
                        child: Container(
                          alignment: Alignment.center,
                          child: adWidget,
                          width: _bannerAd!.size.width.toDouble(),
                          height: _bannerAd!.size.height.toDouble(),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // GestureDetector(
            //   // behavior: HitTestBehavior.opaque,
            //   onTap: () {
            //     print('Hello');
            //   },
            // )
          ],
        ),
      ),
      onWillPop: onWillPopS,
    );
  }
}
