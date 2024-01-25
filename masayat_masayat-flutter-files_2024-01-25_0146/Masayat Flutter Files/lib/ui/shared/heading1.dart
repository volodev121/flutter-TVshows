import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nexthour/ui/shared/recommended_grid_view.dart';
import 'package:nexthour/ui/shared/top_grid_view.dart';
import '../../models/datum.dart';
import '/common/route_paths.dart';
// ignore: import_of_legacy_library_into_null_safe
import '/common/shimmer-effect.dart';
import '/ui/widgets/grid_movie_tv.dart';

class Heading1 extends StatefulWidget {
  final String heading;
  final String type;
  final loading;
  final List<Datum>? videoList;
  Heading1(this.heading, this.type, this.loading, {this.videoList});

  @override
  _Heading1State createState() => _Heading1State();
}

class _Heading1State extends State<Heading1> {
  final navigatorKey = GlobalKey<NavigatorState>();
  @override
  Widget build(BuildContext context) {
    return widget.loading == true
        ? Padding(
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            child: Shimmer.fromColors(
              baseColor: Colors.grey.shade400,
              highlightColor2: Colors.grey.shade500,
              highlightColor: Colors.grey.shade500,
              child: Text(
                translate("Loading_"),
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.heading,
                  style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Text(
                      translate("View_All"),
                      style: TextStyle(
                        fontFamily: 'Lato',
                        fontSize: 16.0,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    onTap: () {
                      if (widget.type == "Top") {
                        Navigator.pushNamed(
                          context,
                          RoutePaths.topVideos,
                          arguments: TopGridView(widget.videoList),
                        );
                      } else if (widget.type == "TV") {
                        Navigator.pushNamed(context, RoutePaths.gridVideos,
                            arguments: GridMovieTV("T"));
                      } else if (widget.type == "Mov") {
                        Navigator.pushNamed(context, RoutePaths.gridVideos,
                            arguments: GridMovieTV("M"));
                      } else if (widget.type == "Blog") {
                        Navigator.pushNamed(context, RoutePaths.blogList);
                      } else if (widget.type == "Actor") {
                        Navigator.pushNamed(context, RoutePaths.actorsGrid);
                      } else if (widget.type == "F") {
                        Navigator.pushNamed(context, RoutePaths.gridVideos,
                            arguments: GridMovieTV("F"));
                      } else if (widget.type == "U") {
                        Navigator.pushNamed(context, RoutePaths.gridVideos,
                            arguments: GridMovieTV("U"));
                      } else if (widget.type == "Audio") {
                        Navigator.pushNamed(context, RoutePaths.gridVideos,
                            arguments: GridMovieTV("A"));
                      } else if (widget.type == "Event") {
                        Navigator.pushNamed(context, RoutePaths.gridVideos,
                            arguments: GridMovieTV("E"));
                      } else if (widget.type == "Recommended") {
                        Navigator.pushNamed(
                          context,
                          RoutePaths.recommendedVideos,
                          arguments: RecommendedGridView(widget.videoList),
                        );
                      }
                    },
                  ),
                )
              ],
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}

class Heading2 extends StatefulWidget {
  final String heading;
  final String type;
  Heading2(this.heading, this.type);

  @override
  _Heading2State createState() => _Heading2State();
}

class _Heading2State extends State<Heading2> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "${widget.heading}",
                style: TextStyle(
                    fontFamily: 'Lato',
                    fontSize: 16.0,
                    fontWeight: FontWeight.w700,
                    color: Colors.red),
              ),
              SizedBox(
                width: 5.0,
              ),
              Icon(
                CupertinoIcons.dot_radiowaves_right,
                color: Colors.red,
                size: 20.0,
              )
            ],
          ),
          Material(
            color: Colors.transparent,
            child: InkWell(
              child: Text(
                translate("View_All"),
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 16.0,
                  fontWeight: FontWeight.w700,
                  color: Theme.of(context).primaryColor,
                ),
              ),
              onTap: () {
                if (widget.type == "Live") {
                  Navigator.pushNamed(context, RoutePaths.liveGrid);
                }
              },
            ),
          )
        ],
      ),
    );
  }
}
