import 'package:flutter/material.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/models/LiveEventModel.dart' as liveEvent_;
import 'package:nexthour/ui/screens/liveEventScreen.dart';
import '../../models/menu_by_category.dart';
import '/common/route_paths.dart';

class LiveEventList extends StatefulWidget {
  final loading;
  final List<LiveEvent> liveEvents;
  LiveEventList({this.loading, required this.liveEvents});
  @override
  _LiveEventListState createState() => _LiveEventListState();
}

class _LiveEventListState extends State<LiveEventList> {
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
        : widget.liveEvents.length == 0
            ? SizedBox.shrink()
            : Container(
                height: 170,
                margin: EdgeInsets.only(top: 15.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.only(left: 15.0),
                  scrollDirection: Axis.horizontal,
                  itemCount:
                      widget.loading == true ? 4 : widget.liveEvents.length,
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
                                  child: widget.liveEvents[index].thumbnail ==
                                          null
                                      ? Image.asset(
                                          "assets/placeholder_box.jpg",
                                          height: 170,
                                          width: 120.0,
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage.assetNetwork(
                                          image: APIData.liveEventThumbnail +
                                              widget
                                                  .liveEvents[index].thumbnail!,
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
                                RoutePaths.Event,
                                arguments: LiveEventScreen(
                                  liveEvent: liveEvent_.LiveEvent.fromJson(
                                    widget.liveEvents[index].toJson(),
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
