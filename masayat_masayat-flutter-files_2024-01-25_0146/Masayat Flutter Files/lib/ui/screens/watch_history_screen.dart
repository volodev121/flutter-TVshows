import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/models/comment.dart';
import '/models/datum.dart';
import '/models/episode.dart';
import '/models/genre_model.dart';
import '/models/seasons.dart';
import '/providers/main_data_provider.dart';
import '/providers/movie_tv_provider.dart';
import '/ui/screens/video_detail_screen.dart';
import '/ui/shared/appbar.dart';
import '/ui/widgets/blank_watch_history.dart';
import 'package:provider/provider.dart';
import '/providers/watch_history_provider.dart';

class WatchHistoryScreen extends StatefulWidget {
  @override
  _WatchHistoryScreenState createState() => _WatchHistoryScreenState();
}

class _WatchHistoryScreenState extends State<WatchHistoryScreen> {
  List<Datum> watchHistoryList = [];
  bool _visible = false;

//  Pop menu button to remove from history
  Widget _selectPopup(videoDetail) {
    return PopupMenuButton<int>(
      color: Theme.of(context).cardColor,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text(translate("Remove_from_history")),
        ),
      ],
      onCanceled: () {
        print("You have canceled the menu.");
      },
      onSelected: (value) {
        if (value == 1) {
          removeHistory(videoDetail.type, videoDetail.id);
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
    );
  }

//  Pop menu button to remove from history
  Widget _selectPopup1() {
    return PopupMenuButton<int>(
      color: Theme.of(context).cardColor,
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 1,
          child: Text(translate("Clear_all_history")),
        ),
      ],
      onCanceled: () {
        print("You have canceled the menu.");
      },
      onSelected: (value) {
        if (value == 1) {
          removeAllHistory();
        }
      },
      icon: Icon(
        Icons.more_vert,
      ),
    );
  }

  Future<String?> removeHistory(vType, id) async {
    var type = vType == DatumType.M ? "M" : "T";
    final response = await http.get(
        Uri.parse("${APIData.deleteWatchHistory}$type/$id?secret=" +
            APIData.secretKey),
        headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
    if (response.statusCode == 200) {
      watchHistoryList
          .removeWhere((element) => element.type == vType && element.id == id);
      setState(() {});
    }
    return null;
  }

  Future<String?> removeAllHistory() async {
    final response = await http.get(
        Uri.parse("${APIData.deleteAllWatchHistory}"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
    if (response.statusCode == 200) {
      watchHistoryList.clear();
      setState(() {});
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _visible = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      getWatchHistory();
    });
  }

  getWatchHistory() async {
    final watchList = Provider.of<WatchHistoryProvider>(context, listen: false);
    await watchList.getWatchHistory(context);
    final watchHistory =
        Provider.of<WatchHistoryProvider>(context, listen: false)
            .watchHistoryModel!
            .watchHistory;
    final moviesTvList =
        Provider.of<MovieTVProvider>(context, listen: false).movieTvList;
    final genreList =
        Provider.of<MainProvider>(context, listen: false).genreList;
    final actorList =
        Provider.of<MainProvider>(context, listen: false).actorList;
    final directorList =
        Provider.of<MainProvider>(context, listen: false).directorList;
    final audioList =
        Provider.of<MainProvider>(context, listen: false).audioList;
    for (int i = 0; i < moviesTvList.length; i++) {
      for (int j = 0; j < watchHistory!.length; j++) {
        if (moviesTvList[i].type == DatumType.T) {
          if (moviesTvList[i].id == watchHistory[j].tvId) {
            var genreData = moviesTvList[i].genreId == null
                ? null
                : moviesTvList[i].genreId!.split(",").toList();
            watchHistoryList.add(Datum(
              isKids: moviesTvList[i].isKids,
              id: moviesTvList[i].id,
              actorId: moviesTvList[i].actorId,
              title: moviesTvList[i].title,
              trailerUrl: moviesTvList[i].trailerUrl,
              status: moviesTvList[i].status,
              keyword: moviesTvList[i].keyword,
              description: moviesTvList[i].description,
              duration: moviesTvList[i].duration,
              thumbnail: moviesTvList[i].thumbnail,
              poster: moviesTvList[i].poster,
              directorId: moviesTvList[i].directorId,
              detail: moviesTvList[i].detail,
              rating: moviesTvList[i].rating,
              maturityRating: moviesTvList[i].maturityRating,
              subtitle: moviesTvList[i].subtitle,
              subtitles: moviesTvList[i].subtitles,
              publishYear: moviesTvList[i].publishYear,
              released: moviesTvList[i].released,
              uploadVideo: moviesTvList[i].uploadVideo,
              featured: moviesTvList[i].featured,
              series: moviesTvList[i].series,
              aLanguage: moviesTvList[i].aLanguage,
              live: moviesTvList[i].live,
              createdBy: moviesTvList[i].createdBy,
              createdAt: moviesTvList[i].createdAt,
              updatedAt: moviesTvList[i].updatedAt,
              isUpcoming: moviesTvList[i].isUpcoming,
              userRating: moviesTvList[i].userRating,
              movieSeries: moviesTvList[i].movieSeries,
              videoLink: moviesTvList[i].videoLink,
              country: moviesTvList[i].country,
              genre: List.generate(genreData == null ? 0 : genreData.length,
                  (int genreIndex) {
                return "${genreData![genreIndex]}";
              }),
              genres: List.generate(genreList.length, (int gIndex) {
                var genreId2 = genreList[gIndex].id.toString();
                var genreNameList = List.generate(
                    genreData == null ? 0 : genreData.length, (int nameIndex) {
                  return "${genreData![nameIndex]}";
                });
                var isAv2 = 0;
                for (var y in genreNameList) {
                  if (genreId2 == y) {
                    isAv2 = 1;
                    break;
                  }
                }
                if (isAv2 == 1) {
                  if (genreList[gIndex].name == null) {
                    return null;
                  } else {
                    return "${genreList[gIndex].name}";
                  }
                }
                return null;
              }),
              comments: List.generate(
                  moviesTvList[i].comments!.isEmpty
                      ? 0
                      : moviesTvList[i].comments!.length, (cIndex) {
                return Comment(
                  id: moviesTvList[i].comments![cIndex].id,
                  name: moviesTvList[i].comments![cIndex].name,
                  email: moviesTvList[i].comments![cIndex].email,
                  movieId: moviesTvList[i].comments![cIndex].movieId,
                  tvSeriesId: moviesTvList[i].comments![cIndex].tvSeriesId,
                  comment: moviesTvList[i].comments![cIndex].comment,
                  subcomments: moviesTvList[i].comments![cIndex].subcomments,
                  createdAt: moviesTvList[i].comments![cIndex].createdAt,
                  updatedAt: moviesTvList[i].comments![cIndex].updatedAt,
                );
              }),
              episodeRuntime: moviesTvList[i].episodeRuntime,
              genreId: moviesTvList[i].genreId,
              type: moviesTvList[i].type,
              seasons: List.generate(
                  moviesTvList[i].seasons == null
                      ? 0
                      : moviesTvList[i].seasons!.length, (sIndex) {
                var actors = moviesTvList[i].seasons![sIndex].actorId == "" ||
                        moviesTvList[i].seasons![sIndex].actorId == null
                    ? null
                    : moviesTvList[i]
                        .seasons![sIndex]
                        .actorId!
                        .split(",")
                        .toList();
                return Season(
                  id: moviesTvList[i].seasons![sIndex].id,
                  thumbnail: moviesTvList[i].seasons![sIndex].thumbnail,
                  poster: moviesTvList[i].seasons![sIndex].poster,
                  detail: moviesTvList[i].seasons![sIndex].detail,
                  seasonNo: moviesTvList[i].seasons![sIndex].seasonNo,
                  publishYear: moviesTvList[i].seasons![sIndex].publishYear,
                  episodes: List.generate(
                      moviesTvList[i].seasons![sIndex].episodes == null
                          ? 0
                          : moviesTvList[i].seasons![sIndex].episodes!.length,
                      (eIndex) {
                    return Episode(
                      id: moviesTvList[i].seasons![sIndex].episodes![eIndex].id,
                      thumbnail: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .thumbnail,
                      title: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .title,
                      detail: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .detail,
                      duration: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .duration,
                      createdAt: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .createdAt,
                      updatedAt: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .updatedAt,
                      episodeNo: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .episodeNo,
                      aLanguage: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .aLanguage,
                      subtitle: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .subtitle,
                      subtitles: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .subtitles,
                      released: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .released,
                      seasonsId: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .seasonsId,
                      videoLink: moviesTvList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .videoLink,
                    );
                  }),
                  actorId: moviesTvList[i].seasons![sIndex].actorId,
                  actorList: List.generate(actorList.length, (actIndex) {
                    var actorsId = actorList[actIndex].id.toString();
                    var actorsIdList = List.generate(
                        actors == null ? 0 : actors.length, (int idIndex) {
                      return "${actors![idIndex]}";
                    });
                    var isAv2 = 0;
                    for (var y in actorsIdList) {
                      if (actorsId == y) {
                        isAv2 = 1;
                        break;
                      }
                    }
                    if (isAv2 == 1) {
                      if (actorList[actIndex].name == null) {
                        return null;
                      } else {
                        return Actor(
                          id: actorList[actIndex].id,
                          name: actorList[actIndex].name,
                          image: actorList[actIndex].image,
                          biography: actorList[actIndex].biography,
                          placeOfBirth: actorList[actIndex].placeOfBirth,
                          dob: actorList[actIndex].dob,
                          createdAt: actorList[actIndex].createdAt,
                          updatedAt: actorList[actIndex].updatedAt,
                        );
                      }
                    }
                    return null;
                  }),
                  aLanguage: moviesTvList[i].seasons![sIndex].aLanguage,
                  createdAt: moviesTvList[i].seasons![sIndex].createdAt,
                  updatedAt: moviesTvList[i].seasons![sIndex].updatedAt,
                  featured: moviesTvList[i].seasons![sIndex].featured,
                  tmdb: moviesTvList[i].seasons![sIndex].tmdb,
                  tmdbId: moviesTvList[i].seasons![sIndex].tmdbId,
                  subtitle: moviesTvList[i].seasons![sIndex].subtitle,
                  subtitles: moviesTvList[i].seasons![sIndex].subtitles,
                );
              }),
              tmdbId: moviesTvList[i].tmdbId,
              tmdb: moviesTvList[i].tmdb,
              fetchBy: moviesTvList[i].fetchBy,
            ));
          }
        } else {
          if (moviesTvList[i].id == watchHistory[j].movieId) {
            var genreData = moviesTvList[i].genreId == null
                ? null
                : moviesTvList[i].genreId!.split(",").toList();
            var actors = moviesTvList[i].actorId == null
                ? null
                : moviesTvList[i].actorId!.split(",").toList();
            var directors = moviesTvList[i].directorId == null
                ? null
                : moviesTvList[i].directorId!.split(",").toList();
            var audios = moviesTvList[i].aLanguage == null
                ? null
                : moviesTvList[i].aLanguage!.split(",").toList();
            watchHistoryList.add(
              Datum(
                isKids: moviesTvList[i].isKids,
                id: moviesTvList[i].id,
                title: moviesTvList[i].title,
                trailerUrl: moviesTvList[i].trailerUrl,
                status: moviesTvList[i].status,
                keyword: moviesTvList[i].keyword,
                description: moviesTvList[i].description,
                duration: moviesTvList[i].duration,
                thumbnail: moviesTvList[i].thumbnail,
                poster: moviesTvList[i].poster,
                directorId: moviesTvList[i].directorId,
                detail: moviesTvList[i].detail,
                rating: moviesTvList[i].rating,
                maturityRating: moviesTvList[i].maturityRating,
                subtitle: moviesTvList[i].subtitle,
                subtitles: moviesTvList[i].subtitles,
                publishYear: moviesTvList[i].publishYear,
                released: moviesTvList[i].released,
                uploadVideo: moviesTvList[i].uploadVideo,
                featured: moviesTvList[i].featured,
                series: moviesTvList[i].series,
                aLanguage: moviesTvList[i].aLanguage,
                live: moviesTvList[i].live,
                createdBy: moviesTvList[i].createdBy,
                createdAt: moviesTvList[i].createdAt,
                updatedAt: moviesTvList[i].updatedAt,
                isUpcoming: moviesTvList[i].isUpcoming,
                userRating: moviesTvList[i].userRating,
                movieSeries: moviesTvList[i].movieSeries,
                videoLink: moviesTvList[i].videoLink,
                country: moviesTvList[i].country,
                genre: List.generate(genreData == null ? 0 : genreData.length,
                    (int genreIndex) {
                  return "${genreData![genreIndex]}";
                }),
                genres: List.generate(genreList.length, (int gIndex) {
                  var genreId2 = genreList[gIndex].id.toString();
                  var genreNameList =
                      List.generate(genreData == null ? 0 : genreData.length,
                          (int nameIndex) {
                    return "${genreData![nameIndex]}";
                  });
                  var isAv2 = 0;
                  for (var y in genreNameList) {
                    if (genreId2 == y) {
                      isAv2 = 1;
                      break;
                    }
                  }
                  if (isAv2 == 1) {
                    if (genreList[gIndex].name == null) {
                      return null;
                    } else {
                      return "${genreList[gIndex].name}";
                    }
                  }
                  return null;
                }),
                actorId: moviesTvList[i].actorId,
                actor: List.generate(actors == null ? 0 : actors.length,
                    (int aIndex) {
                  return "${actors![aIndex]}";
                }),
                actors: List.generate(actorList.length, (actIndex) {
                  var actorsId = actorList[actIndex].id.toString();
                  var actorsIdList = List.generate(
                      actors == null ? 0 : actors.length, (int idIndex) {
                    return "${actors![idIndex]}";
                  });
                  var isAv2 = 0;
                  for (var y in actorsIdList) {
                    if (actorsId == y) {
                      isAv2 = 1;
                      break;
                    }
                  }
                  if (isAv2 == 1) {
                    if (actorList[actIndex].name == null) {
                      return null;
                    } else {
                      return Actor(
                        id: actorList[actIndex].id,
                        name: actorList[actIndex].name,
                        image: actorList[actIndex].image,
                        biography: actorList[actIndex].biography,
                        placeOfBirth: actorList[actIndex].placeOfBirth,
                        dob: actorList[actIndex].dob,
                        createdAt: actorList[actIndex].createdAt,
                        updatedAt: actorList[actIndex].updatedAt,
                      );
                    }
                  }
                  return null;
                }),
                directors: List.generate(directorList.length, (actIndex) {
                  var directorsId = directorList[actIndex].id.toString();
                  var actorsIdList = List.generate(
                      directors == null ? 0 : directors.length, (int idIndex) {
                    return "${directors![idIndex]}";
                  });
                  var isAv2 = 0;
                  for (var y in actorsIdList) {
                    if (directorsId == y) {
                      isAv2 = 1;
                      break;
                    }
                  }
                  if (isAv2 == 1) {
                    if (directorList[actIndex].name == null) {
                      return null;
                    } else {
                      return Director(
                        id: directorList[actIndex].id,
                        name: directorList[actIndex].name,
                        image: directorList[actIndex].image,
                        biography: directorList[actIndex].biography,
                        placeOfBirth: directorList[actIndex].placeOfBirth,
                        dob: directorList[actIndex].dob,
                        createdAt: directorList[actIndex].createdAt,
                        updatedAt: directorList[actIndex].updatedAt,
                      );
                    }
                  }
                  return null;
                }),
                audios: List.generate(audioList.length, (actIndex) {
                  var actorsId = audioList[actIndex].id.toString();
                  var audioIdList = List.generate(
                      audios == null ? 0 : audios.length, (int idIndex) {
                    return "${audios![idIndex]}";
                  });
                  var isAv2 = 0;
                  for (var y in audioIdList) {
                    if (actorsId == y) {
                      isAv2 = 1;
                      break;
                    }
                  }
                  if (isAv2 == 1) {
                    if (audioList[actIndex].language == null) {
                      return null;
                    } else {
                      return "${audioList[actIndex].language}";
                    }
                  }
                  return null;
                }),
                comments: List.generate(
                    moviesTvList[i].comments!.isEmpty
                        ? 0
                        : moviesTvList[i].comments!.length, (cIndex) {
                  return Comment(
                    id: moviesTvList[i].comments![cIndex].id,
                    name: moviesTvList[i].comments![cIndex].name,
                    email: moviesTvList[i].comments![cIndex].email,
                    movieId: moviesTvList[i].comments![cIndex].movieId,
                    tvSeriesId: moviesTvList[i].comments![cIndex].tvSeriesId,
                    comment: moviesTvList[i].comments![cIndex].comment,
                    subcomments: moviesTvList[i].comments![cIndex].subcomments,
                    createdAt: moviesTvList[i].comments![cIndex].createdAt,
                    updatedAt: moviesTvList[i].comments![cIndex].updatedAt,
                  );
                }),
                episodeRuntime: moviesTvList[i].episodeRuntime,
                genreId: moviesTvList[i].genreId,
                type: moviesTvList[i].type,
                tmdbId: moviesTvList[i].tmdbId,
                tmdb: moviesTvList[i].tmdb,
                fetchBy: moviesTvList[i].fetchBy,
              ),
            );
          }
        }
      }
    }
    setState(() {
      _visible = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          customAppBar2(context, translate("Watch_History"), _selectPopup1())
              as PreferredSizeWidget?,
      body: _visible == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : watchHistoryList.length == 0
              ? BlankWatchHistory()
              : ListView.builder(
                  itemCount: watchHistoryList.length,
                  padding: EdgeInsets.only(
                      left: 15.0, right: 15.0, top: 5.0, bottom: 10.0),
                  itemBuilder: (context, index) {
                    watchHistoryList[index]
                        .genres!
                        .removeWhere((element) => element == null);
                    String s =
                        "${watchHistoryList[index].genres}".replaceAll("[", "");
                    String genresName = "$s".replaceAll("]", "");
                    return Column(
                      children: [
                        Container(
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.all(Radius.circular(5.0)),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                highlightColor: Colors.grey[800],
                                child: Container(
                                  height: 130,
                                  color: Theme.of(context).primaryColorLight,
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.only(
                                            topLeft: Radius.circular(5.0),
                                            bottomLeft: Radius.circular(5.0)),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              "assets/placeholder_box.jpg",
                                          image: watchHistoryList[index].type ==
                                                  DatumType.M
                                              ? '${APIData.movieImageUri}${watchHistoryList[index].thumbnail}'
                                              : '${APIData.tvImageUriTv}${watchHistoryList[index].thumbnail}',
                                          fit: BoxFit.cover,
                                          width: 100,
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          padding: EdgeInsets.only(left: 10.0),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 12,
                                              ),
                                              Text(
                                                '${watchHistoryList[index].title}',
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 15.0,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                '$genresName',
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  color: Colors.blue,
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              watchHistoryList[index]
                                                          .duration ==
                                                      null
                                                  ? SizedBox.shrink()
                                                  : Text(
                                                      translate("Duration_") +
                                                          ' : ${watchHistoryList[index].duration} ' +
                                                          translate("min_"),
                                                      textAlign:
                                                          TextAlign.start,
                                                      style: TextStyle(
                                                        fontSize: 14.0,
                                                      ),
                                                    ),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  RatingBar.builder(
                                                    initialRating:
                                                        watchHistoryList[index]
                                                                    .rating ==
                                                                null
                                                            ? 0.0
                                                            : double.parse(
                                                                "${watchHistoryList[index].rating / 2}"),
                                                    minRating: 1,
                                                    direction: Axis.horizontal,
                                                    allowHalfRating: true,
                                                    itemCount: 5,
                                                    itemSize: 20,
                                                    itemBuilder: (context, _) =>
                                                        Icon(
                                                      Icons.star,
                                                      color: Colors.amber,
                                                    ),
                                                    onRatingUpdate: (rating) {
                                                      print(rating);
                                                    },
                                                  ),
                                                  SizedBox(
                                                    width: 70.0,
                                                  ),
                                                  _selectPopup(
                                                    watchHistoryList[index],
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutePaths.videoDetail,
                                    arguments: VideoDetailScreen(
                                        watchHistoryList[index]),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 10),
                      ],
                    );
                  },
                ),
    );
  }
}
