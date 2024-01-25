import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nexthour/models/datum.dart';
import '../../providers/menu_data_provider.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/models/episode.dart';
import '/ui/screens/video_detail_screen.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

class MovieTvByLanguageGridView extends StatefulWidget {
  final String? language;
  final int? languageId;
  final List<Datum> movieTV;

  MovieTvByLanguageGridView(this.language, this.languageId, this.movieTV);

  @override
  _MovieTvByLanguageGridViewState createState() =>
      _MovieTvByLanguageGridViewState();
}

class _MovieTvByLanguageGridViewState extends State<MovieTvByLanguageGridView> {
  late List<Widget> videoList;
  List<Datum> byLanguageVideoList = [];

  @override
  Widget build(BuildContext context) {
    byLanguageVideoList = Provider.of<MenuDataProvider>(context, listen: false)
        .getVideosByLanguage(widget.languageId, widget.movieTV);
    videoList = List.generate(
      byLanguageVideoList.length,
      (index) {
        return Container(
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(50.0)),
          child: Material(
            borderRadius: new BorderRadius.circular(5.0),
            child: InkWell(
              borderRadius: new BorderRadius.circular(5.0),
              child: ClipRRect(
                borderRadius: new BorderRadius.circular(5.0),
                child: byLanguageVideoList[index].thumbnail == null
                    ? Image.asset(
                        "assets/placeholder_box.jpg",
                        fit: BoxFit.cover,
                      )
                    : FadeInImage.assetNetwork(
                        image: byLanguageVideoList[index].type == DatumType.T
                            ? "${APIData.tvImageUriTv}${byLanguageVideoList[index].thumbnail}"
                            : "${APIData.movieImageUri}${byLanguageVideoList[index].thumbnail}",
                        placeholder: "assets/placeholder_box.jpg",
                        imageScale: 1.0,
                        fit: BoxFit.fitHeight,
                        placeholderFit: BoxFit.fitHeight,
                      ),
              ),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  RoutePaths.videoDetail,
                  arguments: VideoDetailScreen(byLanguageVideoList[index]),
                );
              },
            ),
          ),
        );
      },
    );

    return Scaffold(
      appBar: customAppBar(context, translate("${widget.language}"))
          as PreferredSizeWidget?,
      body: GridView.count(
        padding: EdgeInsets.only(
          left: 15.0,
          right: 15.0,
          top: 15.0,
          bottom: 15.0,
        ),
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        crossAxisCount: 3,
        childAspectRatio: 18 / 28,
        crossAxisSpacing: 10.0,
        mainAxisSpacing: 8.0,
        children: videoList,
      ),
    );
  }
}
