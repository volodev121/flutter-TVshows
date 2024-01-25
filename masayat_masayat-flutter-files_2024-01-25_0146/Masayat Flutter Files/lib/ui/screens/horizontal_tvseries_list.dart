import 'package:flutter/material.dart';
import '/common/route_paths.dart';
import '/models/episode.dart';
import '/ui/screens/video_detail_screen.dart';
import '/ui/widgets/tvseries_item.dart';

class TvSeriesList extends StatefulWidget {
  final DatumType? type;
  final loading;
  final data;
  TvSeriesList({this.type, this.loading, this.data});
  @override
  _TvSeriesListState createState() => _TvSeriesListState();
}

class _TvSeriesListState extends State<TvSeriesList> {
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
        : Container(
            height: 170,
            margin: EdgeInsets.only(top: 15.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(left: 15.0),
              scrollDirection: Axis.horizontal,
              itemCount: widget.data.length == 0 ? 4 : widget.data.length,
              itemBuilder: (BuildContext context, int index) {
                return widget.data.length == 0
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
                              errorBuilder: (context, error, stackTrace) {
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
                      )
                    : InkWell(
                        borderRadius: BorderRadius.circular(5.0),
                        child: Container(
                          margin: EdgeInsets.only(right: 15.0),
                          child: TVSeriesItem(widget.data[index], context),
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            RoutePaths.videoDetail,
                            arguments: VideoDetailScreen(
                              widget.data[index],
                            ),
                          );
                        },
                      );
              },
            ),
          );
  }
}
