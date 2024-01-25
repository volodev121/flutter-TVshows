import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/providers/menu_data_provider.dart';
import '/ui/screens/video_detail_screen.dart';
import 'package:provider/provider.dart';

class LiveVideoList extends StatefulWidget {
  @override
  _LiveVideoListState createState() => _LiveVideoListState();
}

class _LiveVideoListState extends State<LiveVideoList> {
  @override
  Widget build(BuildContext context) {
    var menuByCat =
        Provider.of<MenuDataProvider>(context, listen: false).liveDataList;
    return menuByCat.length == 0
        ? SizedBox.shrink()
        : Container(
            height: 170,
            margin: EdgeInsets.only(top: 15.0),
            child: ListView.builder(
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
              padding: EdgeInsets.only(left: 15.0),
              scrollDirection: Axis.horizontal,
              itemCount: menuByCat.length,
              itemBuilder: (BuildContext context, int index) {
                return InkWell(
                  borderRadius: new BorderRadius.circular(5.0),
                  child: Container(
                    margin: EdgeInsets.only(right: 15.0),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: new BorderRadius.circular(5.0),
                      child: ClipRRect(
                        borderRadius: new BorderRadius.circular(5.0),
                        child: menuByCat[index].thumbnail == null
                            ? Image.asset(
                                "assets/placeholder_box.jpg",
                                height: 170,
                                width: 120.0,
                                fit: BoxFit.cover,
                              )
                            : FadeInImage.assetNetwork(
                                image: APIData.movieImageUri +
                                    "${menuByCat[index].thumbnail}",
                                placeholder: "assets/placeholder_box.jpg",
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
                      arguments: VideoDetailScreen(menuByCat[index]),
                    );
                  },
                );
              },
            ),
          );
  }
}
