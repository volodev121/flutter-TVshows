import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/models/episode.dart';
import '/ui/screens/video_detail_screen.dart';

class MoviesList extends StatefulWidget {
  final DatumType? type;
  final loading;
  final data;
  MoviesList({this.type, this.loading, this.data});
  @override
  _MoviesListState createState() => _MoviesListState();
}

class _MoviesListState extends State<MoviesList> {
  @override
  Widget build(BuildContext context) {
    print("type:1 ${widget.type}");
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
        : widget.data.length == 0
            ? SizedBox.shrink()
            : Container(
                height: 170,
                margin: EdgeInsets.only(top: 15.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: ClampingScrollPhysics(),
                  padding: EdgeInsets.only(left: 15.0),
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.loading == true ? 4 : widget.data.length,
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
                                  child: widget.data[index].thumbnail == null
                                      ? Image.asset(
                                          "assets/placeholder_box.jpg",
                                          height: 170,
                                          width: 120.0,
                                          fit: BoxFit.cover,
                                        )
                                      : FadeInImage.assetNetwork(
                                          image: APIData.movieImageUri +
                                              "${widget.data[index].thumbnail}",
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
