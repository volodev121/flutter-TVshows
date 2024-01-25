import 'package:flutter/material.dart';
import '../../models/datum.dart';
import '../../providers/menu_data_provider.dart';
import '../../ui/shared/grid_video_container.dart';
import 'package:provider/provider.dart';
import '../../models/episode.dart';

class GenreWiseMoviesList extends StatefulWidget {
  final dynamic id;
  final String? title;
  final List<Datum> genreDataList;
  final DatumType type;

  GenreWiseMoviesList(this.id, this.title, this.genreDataList, this.type);

  @override
  _GenreWiseMoviesListState createState() => _GenreWiseMoviesListState();
}

class _GenreWiseMoviesListState extends State<GenreWiseMoviesList> {
  late List<Widget> videoList;

  @override
  Widget build(BuildContext context) {
    videoList = List.generate(widget.genreDataList.length, (index) {
      print("type: ${widget.genreDataList[index].type}");
      if (widget.type == widget.genreDataList[index].type) {
        return GridVideoContainer(context, widget.genreDataList[index]);
      } else {
        return SizedBox.shrink();
      }
    });
    videoList.removeWhere((value) => value == value);
    var menuByCat =
        Provider.of<MenuDataProvider>(context, listen: false).menuCatMoviesList;
    return menuByCat.length == 0
        ? SizedBox.shrink()
        : GridView.count(
            padding: EdgeInsets.only(
                left: 15.0, right: 15.0, top: 15.0, bottom: 15.0),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            physics: ClampingScrollPhysics(),
            crossAxisCount: 3,
            childAspectRatio: 18 / 28,
            crossAxisSpacing: 10.0,
            mainAxisSpacing: 8.0,
            children: videoList);
  }
}
