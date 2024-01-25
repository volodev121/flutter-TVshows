//import 'package:better_player/better_player.dart';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '/common/global.dart';

class DownloadedVideoPlayer extends StatefulWidget {
  DownloadedVideoPlayer(
      {this.taskId, this.name, this.fileName, this.downloadStatus});
  final String? taskId;
  final String? name;
  final String? fileName;
  final dynamic downloadStatus;

  @override
  _DownloadedVideoPlayerState createState() => _DownloadedVideoPlayerState();
}

class _DownloadedVideoPlayerState extends State<DownloadedVideoPlayer>
    with WidgetsBindingObserver {
  ChewieController? _betterPlayerController;
  VideoPlayerController? _videoPlayerController;
  var betterPlayerConfiguration;
  var vFileName;

  @override
  void initState() {
    super.initState();
    setState(() {
      playerTitle = widget.name;
      vFileName = widget.fileName;
    });
    print('local path1: $localPath');
    print('local path2: $localPath/${widget.fileName}');

    Future.delayed(Duration.zero, () {
      initializePlayer();
    });
  }

  Future<void> initializePlayer() async {
    try {
      int _startAt = 0;
      if (await storage.containsKey(key: '$localPath/$vFileName')) {
        String? s = await storage.read(key: '$localPath/$vFileName');
        if (s != null) {
          _startAt = int.parse(s);
        } else {
          _startAt = 0;
        }
      }

      _videoPlayerController =
          VideoPlayerController.file(File('$localPath/$vFileName'));
      await _videoPlayerController!.initialize();

      _betterPlayerController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        aspectRatio: _videoPlayerController!.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white,
        ),
        placeholder: Container(
          color: Colors.black,
        ),
        autoInitialize: true,
      );

      _betterPlayerController!.play();

      _videoPlayerController!.addListener(() {
        if (currentPositionInSec == 0) setState(() {});
        currentPositionInSec = _videoPlayerController!.value.position.inSeconds;
        print('Position in Seconds : $currentPositionInSec');
      });
    } catch (e) {
      print('Chewie Player Error: $e');
    }
  }

  int currentPositionInSec = 0, durationInSec = 0;

  void saveCurrentPosition() {
    durationInSec =
        _betterPlayerController!.videoPlayerController.value.duration.inSeconds;
    print('Duration in Seconds :$durationInSec');
    if (currentPositionInSec == durationInSec) {
      storage.write(key: '$localPath/$vFileName', value: '0');
    } else {
      storage.write(
          key: '$localPath/$vFileName', value: '$currentPositionInSec');
    }
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

  @override
  void dispose() {
    saveCurrentPosition();
    _betterPlayerController!.dispose();
    _videoPlayerController!.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
      ),
      backgroundColor: Colors.black,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: _betterPlayerController != null
                ? AspectRatio(
                    aspectRatio: MediaQuery.of(context).size.aspectRatio,
                    child: Chewie(
                      controller: _betterPlayerController!,
                    ),
                  )
                : SizedBox.shrink(),
          )
        ],
      ),
    );
  }
}
