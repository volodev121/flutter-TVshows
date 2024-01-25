import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/models/episode.dart';
import '/ui/screens/video_detail_screen.dart';
import '/ui/widgets/tvseries_item.dart';

class FeaturedList extends StatefulWidget {
  final menuByCat;
  FeaturedList({this.menuByCat});
  @override
  _FeaturedListState createState() => _FeaturedListState();
}

class _FeaturedListState extends State<FeaturedList> {
  @override
  Widget build(BuildContext context) {
    print("type:1 ${widget.menuByCat}");
    return widget.menuByCat.length == 0
        ? SizedBox.shrink()
        : Container(
            height: 170,
            margin: EdgeInsets.only(top: 15.0),
            child: ListView.builder(
                shrinkWrap: true,
                physics: ClampingScrollPhysics(),
                padding: EdgeInsets.only(left: 15.0),
                scrollDirection: Axis.horizontal,
                itemCount: widget.menuByCat.length,
                itemBuilder: (BuildContext context, int index) {
                  print("type:2${widget.menuByCat[index].type}");
                  return widget.menuByCat[index].type == DatumType.T
                      ? InkWell(
                          borderRadius: BorderRadius.circular(5.0),
                          child: Container(
                            margin: EdgeInsets.only(right: 15.0),
                            child:
                                TVSeriesItem(widget.menuByCat[index], context),
                          ),
                          onTap: () {
                            Navigator.pushNamed(context, RoutePaths.videoDetail,
                                arguments:
                                    VideoDetailScreen(widget.menuByCat[index]));
                          },
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
                                child: widget.menuByCat[index].thumbnail == null
                                    ? Image.asset(
                                        "assets/placeholder_box.jpg",
                                        height: 170,
                                        width: 120.0,
                                        fit: BoxFit.cover,
                                      )
                                    : FadeInImage.assetNetwork(
                                        image: APIData.movieImageUri +
                                            "${widget.menuByCat[index].thumbnail}",
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
                            Navigator.pushNamed(context, RoutePaths.videoDetail,
                                arguments:
                                    VideoDetailScreen(widget.menuByCat[index]));
                          },
                        );
                }),
          );
  }
}
