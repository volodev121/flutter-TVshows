import 'package:flutter/material.dart';
import '../../localization/language_model.dart';
import '../../models/datum.dart';
import '../shared/movie_tv_by_lang_grid_view.dart';

class MovieTVLanguageList extends StatelessWidget {
  final bool loading;
  final List<Language> movieTVLanguageList;
  final List<Datum> movieTV;
  const MovieTVLanguageList(
      {required this.loading,
      required this.movieTVLanguageList,
      required this.movieTV});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: ListView.builder(
        shrinkWrap: true,
        physics: ClampingScrollPhysics(),
        padding: EdgeInsets.only(left: 15.0),
        scrollDirection: Axis.horizontal,
        itemCount: movieTVLanguageList.length,
        itemBuilder: (_, index) {
          if (loading)
            return Container(
              width: 80.0,
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.cyanAccent,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: Center(
                child: Text(
                  "Loading...",
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            );
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => MovieTvByLanguageGridView(
                    movieTVLanguageList[index].name,
                    movieTVLanguageList[index].id,
                    movieTV,
                  ),
                ),
              );
            },
            child: Container(
              width: 80.0,
              margin: EdgeInsets.all(5.0),
              padding: EdgeInsets.symmetric(vertical: 5.0),
              decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(
                  color: Colors.cyanAccent,
                ),
                borderRadius: BorderRadius.all(
                  Radius.circular(5.0),
                ),
              ),
              child: Center(
                child: Text(
                  movieTVLanguageList[index].name!,
                  style: TextStyle(
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
