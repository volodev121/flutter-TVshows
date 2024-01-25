import 'package:flutter/material.dart';
import '../../common/route_paths.dart';
import '../../models/AudioModel.dart';
import '../screens/audioScreen.dart';
import 'grid_audio_box.dart';

class GridAudioContainer extends StatelessWidget {
  GridAudioContainer(this.buildContext, this.audio);
  final BuildContext buildContext;
  final Audio audio;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: new BorderRadius.circular(5.0),
      onTap: () => _goDetailsPage(context, audio),
      child: audioColumn(context),
    );
  }

  void _goDetailsPage(BuildContext context, Audio audio) {
    Navigator.pushNamed(
      context,
      RoutePaths.Audio,
      arguments: AudioScreen(
        audio: audio,
      ),
    );
  }

  Widget audioColumn(context) {
    return Hero(
      tag: Text("Hero"),
      child: new GridAudioBox(context, audio),
    );
  }
}
