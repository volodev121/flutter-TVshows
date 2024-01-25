import 'package:flutter/material.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/models/AudioModel.dart' as audio_;
import 'package:nexthour/ui/screens/audioScreen.dart';
import '../../models/menu_by_category.dart';
import '/common/route_paths.dart';

class AudioList extends StatefulWidget {
  final loading;
  final List<Audio> audios;
  AudioList({this.loading, required this.audios});
  @override
  _AudioListState createState() => _AudioListState();
}

class _AudioListState extends State<AudioList> {
  @override
  Widget build(BuildContext context) {
    return widget.loading == true
        ? Container(
            height: 170,
            margin: EdgeInsets.only(top: 15.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(left: 15.0),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (BuildContext context, int index) {
                return Container(
                  margin: EdgeInsets.only(right: 15.0),
                  child: Material(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(5.0),
                    child: ClipRRect(
                      borderRadius: new BorderRadius.circular(5.0),
                      child: Image.asset(
                        "assets/placeholder_box.jpg",
                        height: 170,
                        width: 120.0,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                );
              },
            ),
          )
        : widget.audios.length == 0
            ? SizedBox.shrink()
            : Container(
                height: 170,
                margin: EdgeInsets.only(top: 15.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.only(left: 15.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.loading == true ? 4 : widget.audios.length,
                  itemBuilder: (BuildContext context, int index) {
                    return widget.loading == true
                        ? Container(
                            margin: EdgeInsets.only(right: 15.0),
                            child: Material(
                              color: Colors.transparent,
                              borderRadius: BorderRadius.circular(5.0),
                              child: ClipRRect(
                                borderRadius: new BorderRadius.circular(5.0),
                                child: Image.asset(
                                  "assets/placeholder_box.jpg",
                                  height: 170,
                                  width: 120.0,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                          )
                        : InkWell(
                            borderRadius: new BorderRadius.circular(5.0),
                            child: Container(
                              margin: EdgeInsets.only(right: 15.0),
                              child: Material(
                                color: Colors.transparent,
                                borderRadius: new BorderRadius.circular(5.0),
                                child: ClipRRect(
                                  borderRadius: new BorderRadius.circular(5.0),
                                  child: widget.audios[index].thumbnail == null
                                      ? Image.asset(
                                          "assets/placeholder_box.jpg",
                                          height: 170,
                                          width: 120.0,
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage.assetNetwork(
                                          image: APIData.audioThumbnail +
                                              widget.audios[index].thumbnail!,
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
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(
                                context,
                                RoutePaths.Audio,
                                arguments: AudioScreen(
                                  audio: audio_.Audio.fromJson(
                                    widget.audios[index].toJson(),
                                  ),
                                ),
                              );
                            },
                          );
                  },
                ),
              );
  }
}
