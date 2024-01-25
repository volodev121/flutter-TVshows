import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/countryProvider.dart';
import '/common/route_paths.dart';
import '/models/genre_model.dart';
import '/providers/main_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/apipath.dart';
import 'package:http/http.dart' as http;
import '../common/global.dart';
import '../models/comment.dart';
import '../models/datum.dart';
import '../models/episode.dart';
import '../models/movie_tv.dart';
import '../models/seasons.dart';

class MovieTVProvider with ChangeNotifier {
  MovieTv? movieTv;
  List<Datum> movieTvList = [];
  List<Datum> tvSeriesList = [];
  List<Datum> moviesList = [];
  List<Datum> topVideoList = [];

  Future<MovieTv?> getMoviesTVData(BuildContext context) async {
    var genreList = Provider.of<MainProvider>(context, listen: false).genreList;
    var actorList = Provider.of<MainProvider>(context, listen: false).actorList;
    var directorList =
        Provider.of<MainProvider>(context, listen: false).directorList;
    var audioList = Provider.of<MainProvider>(context, listen: false).audioList;
    try {
      var token;
      if (kIsWeb) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        token = prefs.getString('token');
      } else {
        token = await storage.read(key: "authToken");
      }
      final response = await http.get(Uri.parse(APIData.movieTvApi), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        HttpHeaders.authorizationHeader: "Bearer $token",
      });
      if (response.statusCode == 200) {
        log('Movies :-> ${response.body}');
        log("Bearer Token :-> $token");
        movieTv = MovieTv.fromJson(json.decode(response.body));
        movieTv?.data?.removeWhere((element) =>
            element.country?.contains(countryName.toUpperCase()) == true);

        fetchMovieTVSeriesList(
            movieTv, genreList, actorList, directorList, audioList);
        fetchTVSeriesList(
            movieTvList, genreList, actorList, directorList, audioList);

        var topMVList = movieTv!.topMoviesTv;
        for (int i = 0; i < moviesList.length; i++) {
          for (int j = 0; j < topMVList!.length; j++) {
            if (topMVList[j].tvSeriesId == null) {
              if (moviesList[i].id == topMVList[j].movieId) {
                var genreData = moviesList[i].genreId == null
                    ? null
                    : moviesList[i].genreId!.split(",").toList();
                var actors = moviesList[i].actorId == null
                    ? null
                    : moviesList[i].actorId!.split(",").toList();
                var audios = moviesList[i].aLanguage == null
                    ? null
                    : moviesList[i].aLanguage!.split(",").toList();
                var directors = moviesList[i].directorId == null
                    ? null
                    : moviesList[i].directorId!.split(",").toList();

                if (topVideoList.length > 0) {
                  bool isAvailable = false;
                  isAvailable = topVideoList.any((element) =>
                      (element.id == moviesList[i].id &&
                          element.title == moviesList[i].title));
                  if (!isAvailable) {
                    topVideoList.add(Datum(
                      isKids: moviesList[i].isKids,
                      id: moviesList[i].id,
                      tmdbId: moviesList[i].tmdbId,
                      title: moviesList[i].title,
                      keyword: moviesList[i].keyword,
                      description: moviesList[i].description,
                      duration: moviesList[i].duration,
                      thumbnail: moviesList[i].thumbnail,
                      poster: moviesList[i].poster,
                      tmdb: moviesList[i].tmdb,
                      fetchBy: moviesList[i].fetchBy,
                      directorId: moviesList[i].directorId,
                      actorId: moviesList[i].actorId,
                      genreId: moviesList[i].genreId,
                      trailerUrl: moviesList[i].trailerUrl,
                      detail: moviesList[i].detail,
                      rating: moviesList[i].rating,
                      maturityRating: moviesList[i].maturityRating,
                      subtitle: moviesList[i].subtitle,
                      subtitles: movieTvList[i].subtitles,
                      publishYear: moviesList[i].publishYear,
                      released: moviesList[i].released,
                      uploadVideo: moviesList[i].updatedAt,
                      featured: moviesList[i].featured,
                      series: moviesList[i].series,
                      aLanguage: moviesList[i].aLanguage,
                      audioFiles: moviesList[i].audioFiles,
                      type: moviesList[i].type,
                      live: moviesList[i].live,
                      status: moviesList[i].status,
                      createdBy: moviesList[i].createdBy,
                      createdAt: moviesList[i].createdAt,
                      updatedAt: moviesList[i].updatedAt,
                      isUpcoming: moviesList[i].isUpcoming,
                      userRating: moviesList[i].userRating,
                      movieSeries: moviesList[i].movieSeries,
                      videoLink: moviesList[i].videoLink,
                      comments: moviesList[i].comments,
                      episodeRuntime: moviesList[i].episodeRuntime,
                      seasons: moviesList[i].seasons,
                      country: moviesList[i].country,
                      genre: List.generate(
                          genreData == null ? 0 : genreData.length,
                          (int genreIndex) {
                        return "${genreData![genreIndex]}";
                      }),
                      genres: List.generate(genreList.length, (int gIndex) {
                        var genreId2 = genreList[gIndex].id.toString();
                        var genreNameList = List.generate(
                            genreData == null ? 0 : genreData.length,
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
                            directors == null ? 0 : directors.length,
                            (int idIndex) {
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
                    ));
                  }
                } else {
                  topVideoList.add(Datum(
                    isKids: moviesList[i].isKids,
                    id: moviesList[i].id,
                    tmdbId: moviesList[i].tmdbId,
                    title: moviesList[i].title,
                    keyword: moviesList[i].keyword,
                    description: moviesList[i].description,
                    duration: moviesList[i].duration,
                    thumbnail: moviesList[i].thumbnail,
                    poster: moviesList[i].poster,
                    tmdb: moviesList[i].tmdb,
                    fetchBy: moviesList[i].fetchBy,
                    directorId: moviesList[i].directorId,
                    actorId: moviesList[i].actorId,
                    genreId: moviesList[i].genreId,
                    trailerUrl: moviesList[i].trailerUrl,
                    detail: moviesList[i].detail,
                    rating: moviesList[i].rating,
                    maturityRating: moviesList[i].maturityRating,
                    subtitle: moviesList[i].subtitle,
                    subtitles: movieTvList[i].subtitles,
                    publishYear: moviesList[i].publishYear,
                    released: moviesList[i].released,
                    uploadVideo: moviesList[i].updatedAt,
                    featured: moviesList[i].featured,
                    series: moviesList[i].series,
                    aLanguage: moviesList[i].aLanguage,
                    audioFiles: moviesList[i].audioFiles,
                    type: moviesList[i].type,
                    live: moviesList[i].live,
                    status: moviesList[i].status,
                    createdBy: moviesList[i].createdBy,
                    createdAt: moviesList[i].createdAt,
                    updatedAt: moviesList[i].updatedAt,
                    isUpcoming: moviesList[i].isUpcoming,
                    userRating: moviesList[i].userRating,
                    movieSeries: moviesList[i].movieSeries,
                    videoLink: moviesList[i].videoLink,
                    comments: moviesList[i].comments,
                    episodeRuntime: moviesList[i].episodeRuntime,
                    seasons: moviesList[i].seasons,
                    country: moviesList[i].country,
                    genre:
                        List.generate(genreData == null ? 0 : genreData.length,
                            (int genreIndex) {
                      return "${genreData![genreIndex]}";
                    }),
                    genres: List.generate(genreList.length, (int gIndex) {
                      var genreId2 = genreList[gIndex].id.toString();
                      var genreNameList = List.generate(
                          genreData == null ? 0 : genreData.length,
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
                          directors == null ? 0 : directors.length,
                          (int idIndex) {
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
                  ));
                }
              }
            }
          }
        }

        for (int i = 0; i < tvSeriesList.length; i++) {
          for (int j = 0; j < topMVList!.length; j++) {
            if (topMVList[j].movieId == null) {
              if (tvSeriesList[i].id == topMVList[j].tvSeriesId) {
                var genreData = tvSeriesList[i].genreId == null
                    ? null
                    : tvSeriesList[i].genreId!.split(",").toList();
                var actors = tvSeriesList[i].actorId == null
                    ? null
                    : tvSeriesList[i].actorId!.split(",").toList();
                var audios = tvSeriesList[i].aLanguage == null
                    ? null
                    : tvSeriesList[i].aLanguage!.split(",").toList();
                var directors = tvSeriesList[i].directorId == null
                    ? null
                    : tvSeriesList[i].directorId!.split(",").toList();

                if (topVideoList.length > 0) {
                  bool isAvailable = false;
                  isAvailable = topVideoList.any((element) =>
                      (element.id == tvSeriesList[i].id &&
                          element.title == tvSeriesList[i].title));
                  if (!isAvailable) {
                    topVideoList.add(Datum(
                      isKids: tvSeriesList[i].isKids,
                      id: tvSeriesList[i].id,
                      tmdbId: tvSeriesList[i].tmdbId,
                      title: tvSeriesList[i].title,
                      keyword: tvSeriesList[i].keyword,
                      description: tvSeriesList[i].description,
                      duration: tvSeriesList[i].duration,
                      thumbnail: tvSeriesList[i].thumbnail,
                      poster: tvSeriesList[i].poster,
                      tmdb: tvSeriesList[i].tmdb,
                      fetchBy: tvSeriesList[i].fetchBy,
                      directorId: tvSeriesList[i].directorId,
                      actorId: tvSeriesList[i].actorId,
                      genreId: tvSeriesList[i].genreId,
                      trailerUrl: tvSeriesList[i].trailerUrl,
                      detail: tvSeriesList[i].detail,
                      rating: tvSeriesList[i].rating,
                      maturityRating: tvSeriesList[i].maturityRating,
                      subtitle: tvSeriesList[i].subtitle,
                      subtitles: tvSeriesList[i].subtitles,
                      publishYear: tvSeriesList[i].publishYear,
                      released: tvSeriesList[i].released,
                      uploadVideo: tvSeriesList[i].updatedAt,
                      featured: tvSeriesList[i].featured,
                      series: tvSeriesList[i].series,
                      aLanguage: tvSeriesList[i].aLanguage,
                      audioFiles: tvSeriesList[i].audioFiles,
                      type: tvSeriesList[i].type,
                      live: tvSeriesList[i].live,
                      status: tvSeriesList[i].status,
                      createdBy: tvSeriesList[i].createdBy,
                      createdAt: tvSeriesList[i].createdAt,
                      updatedAt: tvSeriesList[i].updatedAt,
                      isUpcoming: tvSeriesList[i].isUpcoming,
                      userRating: tvSeriesList[i].userRating,
                      movieSeries: tvSeriesList[i].movieSeries,
                      videoLink: tvSeriesList[i].videoLink,
                      comments: tvSeriesList[i].comments,
                      episodeRuntime: tvSeriesList[i].episodeRuntime,
                      country: tvSeriesList[i].country,
                      seasons: List.generate(
                          tvSeriesList[i].seasons == null
                              ? 0
                              : tvSeriesList[i].seasons!.length, (sIndex) {
                        var seasonActors =
                            tvSeriesList[i].seasons![sIndex].actorId == null ||
                                    tvSeriesList[i].seasons![sIndex].actorId ==
                                        ""
                                ? null
                                : tvSeriesList[i].seasons![sIndex].actorId;
                        var audios =
                            tvSeriesList[i].seasons![sIndex].aLanguage == null
                                ? null
                                : tvSeriesList[i].seasons![sIndex].aLanguage;
                        return Season(
                          id: tvSeriesList[i].seasons![sIndex].id,
                          detail: tvSeriesList[i].seasons![sIndex].detail,
                          tvSeriesId:
                              tvSeriesList[i].seasons![sIndex].tvSeriesId,
                          thumbnail: tvSeriesList[i].seasons![sIndex].thumbnail,
                          seasonNo: tvSeriesList[i].seasons![sIndex].seasonNo,
                          poster: tvSeriesList[i].seasons![sIndex].poster,
                          publishYear:
                              tvSeriesList[i].seasons![sIndex].publishYear,
                          strailerUrl:
                              tvSeriesList[i].seasons![sIndex].strailerUrl,
                          episodes: List.generate(
                              tvSeriesList[i].seasons![sIndex].episodes == null
                                  ? 0
                                  : tvSeriesList[i]
                                      .seasons![sIndex]
                                      .episodes!
                                      .length, (eIndex) {
                            return Episode(
                              id: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .id,
                              thumbnail: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .thumbnail,
                              title: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .title,
                              detail: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .detail,
                              duration: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .duration,
                              createdAt: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .createdAt,
                              updatedAt: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .updatedAt,
                              episodeNo: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .episodeNo,
                              aLanguage: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .aLanguage,
                              subtitle: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .subtitle,
                              subtitles: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .subtitles,
                              released: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .released,
                              seasonsId: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .seasonsId,
                              videoLink: tvSeriesList[i]
                                  .seasons![sIndex]
                                  .episodes![eIndex]
                                  .videoLink,
                            );
                          }),
                          actorId: tvSeriesList[i].seasons![sIndex].actorId,
                          aLanguage: tvSeriesList[i].seasons![sIndex].aLanguage,
                          actorList:
                              List.generate(actorList.length, (actIndex) {
                            var actorsId = actorList[actIndex].id.toString();
                            var actorsIdList = List.generate(
                                seasonActors == null ? 0 : seasonActors.length,
                                (int idIndex) {
                              return "${seasonActors![idIndex]}";
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
                                  placeOfBirth:
                                      actorList[actIndex].placeOfBirth,
                                  dob: actorList[actIndex].dob,
                                  createdAt: actorList[actIndex].createdAt,
                                  updatedAt: actorList[actIndex].updatedAt,
                                );
                              }
                            }
                            return null;
                          }),
                          audiosList:
                              List.generate(audioList.length, (actIndex) {
                            var actorsId = audioList[actIndex].id.toString();
                            var audioIdList = List.generate(
                                audios == null ? 0 : audios.length,
                                (int idIndex) {
                              return "${audios[idIndex]}";
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
                          createdAt: tvSeriesList[i].seasons![sIndex].createdAt,
                          updatedAt: tvSeriesList[i].seasons![sIndex].updatedAt,
                          featured: tvSeriesList[i].seasons![sIndex].featured,
                          tmdb: tvSeriesList[i].seasons![sIndex].tmdb,
                          tmdbId: tvSeriesList[i].seasons![sIndex].tmdbId,
                          subtitle: tvSeriesList[i].seasons![sIndex].subtitle,
                          subtitles: tvSeriesList[i].seasons![sIndex].subtitles,
                        );
                      }),
                      genre: List.generate(
                          genreData == null ? 0 : genreData.length,
                          (int genreIndex) {
                        return "${genreData![genreIndex]}";
                      }),
                      genres: List.generate(genreList.length, (int gIndex) {
                        var genreId2 = genreList[gIndex].id.toString();
                        var genreNameList = List.generate(
                            genreData == null ? 0 : genreData.length,
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
                            directors == null ? 0 : directors.length,
                            (int idIndex) {
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
                    ));
                  }
                } else {
                  topVideoList.add(Datum(
                    isKids: tvSeriesList[i].isKids,
                    id: tvSeriesList[i].id,
                    tmdbId: tvSeriesList[i].tmdbId,
                    title: tvSeriesList[i].title,
                    keyword: tvSeriesList[i].keyword,
                    description: tvSeriesList[i].description,
                    duration: tvSeriesList[i].duration,
                    thumbnail: tvSeriesList[i].thumbnail,
                    poster: tvSeriesList[i].poster,
                    tmdb: tvSeriesList[i].tmdb,
                    fetchBy: tvSeriesList[i].fetchBy,
                    directorId: tvSeriesList[i].directorId,
                    actorId: tvSeriesList[i].actorId,
                    genreId: tvSeriesList[i].genreId,
                    trailerUrl: tvSeriesList[i].trailerUrl,
                    detail: tvSeriesList[i].detail,
                    rating: tvSeriesList[i].rating,
                    maturityRating: tvSeriesList[i].maturityRating,
                    subtitle: tvSeriesList[i].subtitle,
                    subtitles: tvSeriesList[i].subtitles,
                    publishYear: tvSeriesList[i].publishYear,
                    released: tvSeriesList[i].released,
                    uploadVideo: tvSeriesList[i].updatedAt,
                    featured: tvSeriesList[i].featured,
                    series: tvSeriesList[i].series,
                    aLanguage: tvSeriesList[i].aLanguage,
                    audioFiles: tvSeriesList[i].audioFiles,
                    type: tvSeriesList[i].type,
                    live: tvSeriesList[i].live,
                    status: tvSeriesList[i].status,
                    createdBy: tvSeriesList[i].createdBy,
                    createdAt: tvSeriesList[i].createdAt,
                    updatedAt: tvSeriesList[i].updatedAt,
                    isUpcoming: tvSeriesList[i].isUpcoming,
                    userRating: tvSeriesList[i].userRating,
                    movieSeries: tvSeriesList[i].movieSeries,
                    videoLink: tvSeriesList[i].videoLink,
                    comments: tvSeriesList[i].comments,
                    episodeRuntime: tvSeriesList[i].episodeRuntime,
                    country: tvSeriesList[i].country,
                    seasons: List.generate(
                        tvSeriesList[i].seasons == null
                            ? 0
                            : tvSeriesList[i].seasons!.length, (sIndex) {
                      var seasonActors =
                          tvSeriesList[i].seasons![sIndex].actorId == null ||
                                  tvSeriesList[i].seasons![sIndex].actorId == ""
                              ? null
                              : tvSeriesList[i].seasons![sIndex].actorId;
                      var audios =
                          tvSeriesList[i].seasons![sIndex].aLanguage == null
                              ? null
                              : tvSeriesList[i].seasons![sIndex].aLanguage;
                      return Season(
                        id: tvSeriesList[i].seasons![sIndex].id,
                        detail: tvSeriesList[i].seasons![sIndex].detail,
                        tvSeriesId: tvSeriesList[i].seasons![sIndex].tvSeriesId,
                        thumbnail: tvSeriesList[i].seasons![sIndex].thumbnail,
                        seasonNo: tvSeriesList[i].seasons![sIndex].seasonNo,
                        poster: tvSeriesList[i].seasons![sIndex].poster,
                        publishYear:
                            tvSeriesList[i].seasons![sIndex].publishYear,
                        strailerUrl:
                            tvSeriesList[i].seasons![sIndex].strailerUrl,
                        episodes: List.generate(
                            tvSeriesList[i].seasons![sIndex].episodes == null
                                ? 0
                                : tvSeriesList[i]
                                    .seasons![sIndex]
                                    .episodes!
                                    .length, (eIndex) {
                          return Episode(
                            id: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .id,
                            thumbnail: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .thumbnail,
                            title: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .title,
                            detail: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .detail,
                            duration: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .duration,
                            createdAt: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .createdAt,
                            updatedAt: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .updatedAt,
                            episodeNo: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .episodeNo,
                            aLanguage: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .aLanguage,
                            subtitle: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .subtitle,
                            subtitles: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .subtitles,
                            released: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .released,
                            seasonsId: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .seasonsId,
                            videoLink: tvSeriesList[i]
                                .seasons![sIndex]
                                .episodes![eIndex]
                                .videoLink,
                          );
                        }),
                        actorId: tvSeriesList[i].seasons![sIndex].actorId,
                        aLanguage: tvSeriesList[i].seasons![sIndex].aLanguage,
                        actorList: List.generate(actorList.length, (actIndex) {
                          var actorsId = actorList[actIndex].id.toString();
                          var actorsIdList = List.generate(
                              seasonActors == null ? 0 : seasonActors.length,
                              (int idIndex) {
                            return "${seasonActors![idIndex]}";
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
                        audiosList: List.generate(audioList.length, (actIndex) {
                          var actorsId = audioList[actIndex].id.toString();
                          var audioIdList =
                              List.generate(audios == null ? 0 : audios.length,
                                  (int idIndex) {
                            return "${audios[idIndex]}";
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
                        createdAt: tvSeriesList[i].seasons![sIndex].createdAt,
                        updatedAt: tvSeriesList[i].seasons![sIndex].updatedAt,
                        featured: tvSeriesList[i].seasons![sIndex].featured,
                        tmdb: tvSeriesList[i].seasons![sIndex].tmdb,
                        tmdbId: tvSeriesList[i].seasons![sIndex].tmdbId,
                        subtitle: tvSeriesList[i].seasons![sIndex].subtitle,
                        subtitles: tvSeriesList[i].seasons![sIndex].subtitles,
                      );
                    }),
                    genre:
                        List.generate(genreData == null ? 0 : genreData.length,
                            (int genreIndex) {
                      return "${genreData![genreIndex]}";
                    }),
                    genres: List.generate(genreList.length, (int gIndex) {
                      var genreId2 = genreList[gIndex].id.toString();
                      var genreNameList = List.generate(
                          genreData == null ? 0 : genreData.length,
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
                          directors == null ? 0 : directors.length,
                          (int idIndex) {
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
                  ));
                }
              }
            }
          }
        }
        topVideoList.removeWhere((element) =>
            element.status == 0 ||
            "${element.status}" == "0" ||
            element.country?.contains(countryName.toUpperCase()) == true);
        if (isKidsModeEnabled) {
          topVideoList.removeWhere((element) => element.isKids == 0);
        }
      } else {
        await storage.deleteAll();
        Navigator.pushNamed(context, RoutePaths.login);
        throw "Can't get movies and tv series";
      }
      notifyListeners();
    } catch (error) {
      print("Error :-> $error");
      await storage.deleteAll();
      Navigator.pushNamed(context, RoutePaths.login);
      throw error;
    }
    return movieTv;
  }

  fetchMovieTVSeriesList(
      movieTv, genreList, actorList, directorList, audioList) {
    movieTvList = List.generate(movieTv.data.length, (index) {
      var genreData = movieTv.data[index].genreId == null
          ? null
          : movieTv.data[index].genreId.split(",").toList();
      var actors = movieTv.data[index].actorId == null
          ? null
          : movieTv.data[index].actorId.split(",").toList();
      var directors = movieTv.data[index].directorId == null
          ? null
          : movieTv.data[index].directorId.split(",").toList();
      var audios = movieTv.data[index].aLanguage == null
          ? null
          : movieTv.data[index].aLanguage.split(",").toList();
      var subtitles = movieTv.data[index].subtitles == null
          ? null
          : movieTv.data[index].subtitles;
      return Datum(
        isKids: movieTv.data[index].isKids,
        id: movieTv.data[index].id,
        actorId: movieTv.data[index].actorId,
        title: movieTv.data[index].title,
        trailerUrl: movieTv.data[index].trailerUrl,
        status: movieTv.data[index].status,
        keyword: movieTv.data[index].keyword,
        description: movieTv.data[index].description,
        duration: movieTv.data[index].duration,
        thumbnail: movieTv.data[index].thumbnail,
        poster: movieTv.data[index].poster,
        directorId: movieTv.data[index].directorId,
        detail: movieTv.data[index].detail,
        rating: movieTv.data[index].rating,
        maturityRating: movieTv.data[index].maturityRating,
        subtitle: movieTv.data[index].subtitle,
        subtitles: subtitles,
        publishYear: movieTv.data[index].publishYear,
        released: movieTv.data[index].released,
        uploadVideo: movieTv.data[index].uploadVideo,
        featured: movieTv.data[index].featured,
        series: movieTv.data[index].series,
        aLanguage: movieTv.data[index].aLanguage,
        live: movieTv.data[index].live,
        createdBy: movieTv.data[index].createdBy,
        createdAt: movieTv.data[index].createdAt,
        updatedAt: movieTv.data[index].updatedAt,
        isUpcoming: movieTv.data[index].isUpcoming,
        userRating: movieTv.data[index].userRating,
        movieSeries: movieTv.data[index].movieSeries,
        videoLink: movieTv.data[index].videoLink,
        country: movieTv.data[index].country,
        genre: List.generate(genreData == null ? 0 : genreData.length,
            (int genreIndex) {
          return "${genreData[genreIndex]}";
        }),
        genres: List.generate(genreList.length, (int gIndex) {
          var genreId2 = genreList[gIndex].id.toString();
          var genreNameList = List.generate(
              genreData == null ? 0 : genreData.length, (int nameIndex) {
            return "${genreData[nameIndex]}";
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
        actor: List.generate(actors == null ? 0 : actors.length, (int aIndex) {
          return "${actors[aIndex]}";
        }),
        actors: List.generate(actorList.length, (actIndex) {
          var actorsId = actorList[actIndex].id.toString();
          var actorsIdList =
              List.generate(actors == null ? 0 : actors.length, (int idIndex) {
            return "${actors[idIndex]}";
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
            return "${directors[idIndex]}";
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
          var audioIdList =
              List.generate(audios == null ? 0 : audios.length, (int idIndex) {
            return "${audios[idIndex]}";
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
            movieTv.data[index].comments == null
                ? 0
                : movieTv.data[index].comments.length, (cIndex) {
          return Comment(
            id: movieTv.data[index].comments[cIndex].id,
            name: movieTv.data[index].comments[cIndex].name,
            email: movieTv.data[index].comments[cIndex].email,
            movieId: movieTv.data[index].comments[cIndex].movieId,
            tvSeriesId: movieTv.data[index].comments[cIndex].tvSeriesId,
            comment: movieTv.data[index].comments[cIndex].comment,
            createdAt: movieTv.data[index].comments[cIndex].createdAt,
            updatedAt: movieTv.data[index].comments[cIndex].updatedAt,
          );
        }),
        episodeRuntime: movieTv.data[index].episodeRuntime,
        genreId: movieTv.data[index].genreId,
        type: movieTv.data[index].type,
        seasons: List.generate(
            movieTv.data[index].seasons == null
                ? 0
                : movieTv.data[index].seasons.length, (sIndex) {
          var seasonActors = movieTv.data[index].seasons[sIndex].actorId ==
                      "" ||
                  movieTv.data[index].seasons[sIndex].actorId == null
              ? null
              : movieTv.data[index].seasons[sIndex].actorId.split(",").toList();
          var seasonAudio =
              movieTv.data[index].seasons[sIndex].aLanguage == "" ||
                      movieTv.data[index].seasons[sIndex].aLanguage == null
                  ? null
                  : movieTv.data[index].seasons[sIndex].aLanguage
                      .split(",")
                      .toList();
          return Season(
            id: movieTv.data[index].seasons[sIndex].id,
            thumbnail: movieTv.data[index].seasons[sIndex].thumbnail,
            poster: movieTv.data[index].seasons[sIndex].poster,
            detail: movieTv.data[index].seasons[sIndex].detail,
            seasonNo: movieTv.data[index].seasons[sIndex].seasonNo,
            publishYear: movieTv.data[index].seasons[sIndex].publishYear,
            episodes: List.generate(
                movieTv.data[index].seasons[sIndex].episodes == null
                    ? 0
                    : movieTv.data[index].seasons[sIndex].episodes.length,
                (eIndex) {
              return Episode(
                id: movieTv.data[index].seasons[sIndex].episodes[eIndex].id,
                thumbnail: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].thumbnail,
                title:
                    movieTv.data[index].seasons[sIndex].episodes[eIndex].title,
                detail:
                    movieTv.data[index].seasons[sIndex].episodes[eIndex].detail,
                duration: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].duration,
                createdAt: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].createdAt,
                updatedAt: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].updatedAt,
                episodeNo: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].episodeNo,
                aLanguage: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].aLanguage,
                subtitle: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].subtitle,
                subtitles: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].subtitles,
                released: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].released,
                seasonsId: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].seasonsId,
                videoLink: movieTv
                    .data[index].seasons[sIndex].episodes[eIndex].videoLink,
              );
            }),
            actorId: movieTv.data[index].seasons[sIndex].actorId,
            actorList: List.generate(actorList.length, (actIndex) {
              var actorsId = actorList[actIndex].id.toString();
              var actorsIdList =
                  List.generate(seasonActors == null ? 0 : seasonActors.length,
                      (int idIndex) {
                return "${seasonActors[idIndex]}";
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
            audiosList: List.generate(audioList.length, (actIndex) {
              var actorsId = audioList[actIndex].id.toString();
              var audioIdList = List.generate(
                  seasonAudio == null ? 0 : seasonAudio.length, (int idIndex) {
                return "${seasonAudio[idIndex]}";
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
            aLanguage: movieTv.data[index].seasons[sIndex].aLanguage,
            createdAt: movieTv.data[index].seasons[sIndex].createdAt,
            updatedAt: movieTv.data[index].seasons[sIndex].updatedAt,
            featured: movieTv.data[index].seasons[sIndex].featured,
            tmdb: movieTv.data[index].seasons[sIndex].tmdb,
            tmdbId: movieTv.data[index].seasons[sIndex].tmdbId,
            subtitle: movieTv.data[index].seasons[sIndex].subtitle,
            subtitles: movieTv.data[index].seasons[sIndex].subtitles,
            strailerUrl: movieTv.data[index].seasons[sIndex].strailerUrl,
          );
        }),
      );
    });
    movieTvList.removeWhere((element) =>
        element.status == 0 ||
        "${element.status}" == "0" ||
        element.country?.contains(countryName.toUpperCase()) == true);
    if (isKidsModeEnabled) {
      movieTvList.removeWhere((element) => element.isKids == 0);
    }
  }

  fetchTVSeriesList(
      movieTvList, genreList, actorList, directorList, audioList) {
    for (int i = 0; i < movieTvList.length; i++) {
      var genreData = movieTvList[i].genreId == null
          ? null
          : movieTvList[i].genreId.split(",").toList();
      var actors = movieTvList[i].actorId == null
          ? null
          : movieTvList[i].actorId.split(",").toList();
      var subtitles =
          movieTvList[i].subtitles == null ? null : movieTvList[i].subtitles;
      if (movieTvList[i].type == DatumType.T) {
        tvSeriesList.add(Datum(
          isKids: movieTvList[i].isKids,
          id: movieTvList[i].id,
          actorId: movieTvList[i].actorId,
          title: movieTvList[i].title,
          trailerUrl: movieTvList[i].trailerUrl,
          status: movieTvList[i].status,
          keyword: movieTvList[i].keyword,
          description: movieTvList[i].description,
          duration: movieTvList[i].duration,
          thumbnail: movieTvList[i].thumbnail,
          poster: movieTvList[i].poster,
          directorId: movieTvList[i].directorId,
          detail: movieTvList[i].detail,
          rating: movieTvList[i].rating,
          maturityRating: movieTvList[i].maturityRating,
          subtitle: movieTvList[i].subtitle,
          subtitles: subtitles,
          publishYear: movieTvList[i].publishYear,
          released: movieTvList[i].released,
          uploadVideo: movieTvList[i].uploadVideo,
          featured: movieTvList[i].featured,
          series: movieTvList[i].series,
          aLanguage: movieTvList[i].aLanguage,
          live: movieTvList[i].live,
          createdBy: movieTvList[i].createdBy,
          createdAt: movieTvList[i].createdAt,
          updatedAt: movieTvList[i].updatedAt,
          isUpcoming: movieTvList[i].isUpcoming,
          userRating: movieTvList[i].userRating,
          movieSeries: movieTvList[i].movieSeries,
          videoLink: movieTvList[i].videoLink,
          country: movieTvList[i].country,
          genre: List.generate(genreData == null ? 0 : genreData.length,
              (int genreIndex) {
            return "${genreData[genreIndex]}";
          }),
          genres: List.generate(genreList.length, (int gIndex) {
            var genreId2 = genreList[gIndex].id.toString();
            var genreNameList = List.generate(
                genreData == null ? 0 : genreData.length, (int nameIndex) {
              return "${genreData[nameIndex]}";
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
          actor:
              List.generate(actors == null ? 0 : actors.length, (int aIndex) {
            return "${actors[aIndex]}";
          }),
          actors: List.generate(actorList.length, (actIndex) {
            var actorsId = actorList[actIndex].id.toString();
            var actorsIdList = List.generate(actors == null ? 0 : actors.length,
                (int idIndex) {
              return "${actors[idIndex]}";
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
          comments: List.generate(
              movieTvList[i].comments == null
                  ? 0
                  : movieTvList[i].comments.length, (cIndex) {
            return Comment(
              id: movieTvList[i].comments[cIndex].id,
              name: movieTvList[i].comments[cIndex].name,
              email: movieTvList[i].comments[cIndex].email,
              movieId: movieTvList[i].comments[cIndex].movieId,
              tvSeriesId: movieTvList[i].comments[cIndex].tvSeriesId,
              comment: movieTvList[i].comments[cIndex].comment,
              createdAt: movieTvList[i].comments[cIndex].createdAt,
              updatedAt: movieTvList[i].comments[cIndex].updatedAt,
            );
          }),
          episodeRuntime: movieTvList[i].episodeRuntime,
          genreId: movieTvList[i].genreId,
          type: movieTvList[i].type,
          seasons: List.generate(
              movieTvList[i].seasons == null
                  ? 0
                  : movieTvList[i].seasons.length, (sIndex) {
            return Season(
              id: movieTvList[i].seasons[sIndex].id,
              thumbnail: movieTvList[i].seasons[sIndex].thumbnail,
              poster: movieTvList[i].seasons[sIndex].poster,
              publishYear: movieTvList[i].seasons[sIndex].publishYear,
              episodes: List.generate(
                  movieTvList[i].seasons[sIndex].episodes == null
                      ? 0
                      : movieTvList[i].seasons[sIndex].episodes.length,
                  (eIndex) {
                return Episode(
                  id: movieTvList[i].seasons[sIndex].episodes[eIndex].id,
                  thumbnail:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].thumbnail,
                  title: movieTvList[i].seasons[sIndex].episodes[eIndex].title,
                  detail:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].detail,
                  duration:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].duration,
                  createdAt:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].createdAt,
                  updatedAt:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].updatedAt,
                  episodeNo:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].episodeNo,
                  aLanguage:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].aLanguage,
                  subtitle:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].subtitle,
                  subtitles:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].subtitles,
                  released:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].released,
                  seasonsId:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].seasonsId,
                  videoLink:
                      movieTvList[i].seasons[sIndex].episodes[eIndex].videoLink,
                );
              }),
              seasonNo: movieTvList[i].seasons[sIndex].seasonNo,
              actorId: movieTvList[i].seasons[sIndex].actorId,
              aLanguage: movieTvList[i].seasons[sIndex].aLanguage,
              createdAt: movieTvList[i].seasons[sIndex].createdAt,
              updatedAt: movieTvList[i].seasons[sIndex].updatedAt,
              featured: movieTvList[i].seasons[sIndex].featured,
              tmdb: movieTvList[i].seasons[sIndex].tmdb,
              tmdbId: movieTvList[i].seasons[sIndex].tmdbId,
              subtitle: movieTvList[i].seasons[sIndex].subtitle,
              subtitles: movieTvList[i].seasons[sIndex].subtitles,
              strailerUrl: movieTvList[i].seasons![sIndex].strailerUrl,
            );
          }),
        ));
        tvSeriesList.removeWhere((element) =>
            element.status == 0 ||
            "${element.status}" == "0" ||
            element.country?.contains(countryName.toUpperCase()) == true);
        if (isKidsModeEnabled) {
          tvSeriesList.removeWhere((element) => element.isKids == 0);
        }
      } else {
        moviesList.add(Datum(
          isKids: movieTvList[i].isKids,
          id: movieTvList[i].id,
          actorId: movieTvList[i].actorId,
          title: movieTvList[i].title,
          trailerUrl: movieTvList[i].trailerUrl,
          status: movieTvList[i].status,
          keyword: movieTvList[i].keyword,
          description: movieTvList[i].description,
          duration: movieTvList[i].duration,
          thumbnail: movieTvList[i].thumbnail,
          poster: movieTvList[i].poster,
          directorId: movieTvList[i].directorId,
          detail: movieTvList[i].detail,
          rating: movieTvList[i].rating,
          maturityRating: movieTvList[i].maturityRating,
          subtitle: movieTvList[i].subtitle,
          subtitles: subtitles,
          publishYear: movieTvList[i].publishYear,
          released: movieTvList[i].released,
          uploadVideo: movieTvList[i].uploadVideo,
          featured: movieTvList[i].featured,
          series: movieTvList[i].series,
          aLanguage: movieTvList[i].aLanguage,
          live: movieTvList[i].live,
          createdBy: movieTvList[i].createdBy,
          createdAt: movieTvList[i].createdAt,
          updatedAt: movieTvList[i].updatedAt,
          isUpcoming: movieTvList[i].isUpcoming,
          userRating: movieTvList[i].userRating,
          movieSeries: movieTvList[i].movieSeries,
          videoLink: movieTvList[i].videoLink,
          country: movieTvList[i].country,
          genre: List.generate(genreData == null ? 0 : genreData.length,
              (int genreIndex) {
            return "${genreData[genreIndex]}";
          }),
          genres: List.generate(genreList.length, (int gIndex) {
            var genreId2 = genreList[gIndex].id.toString();
            var genreNameList = List.generate(
                genreData == null ? 0 : genreData.length, (int nameIndex) {
              return "${genreData[nameIndex]}";
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
          actor:
              List.generate(actors == null ? 0 : actors.length, (int aIndex) {
            return "${actors[aIndex]}";
          }),
          actors: List.generate(actorList.length, (actIndex) {
            var actorsId = actorList[actIndex].id.toString();
            var actorsIdList = List.generate(actors == null ? 0 : actors.length,
                (int idIndex) {
              return "${actors[idIndex]}";
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
          comments: List.generate(
              movieTvList[i].comments == null
                  ? 0
                  : movieTvList[i].comments.length, (cIndex) {
            return Comment(
              id: movieTvList[i].comments[cIndex].id,
              name: movieTvList[i].comments[cIndex].name,
              email: movieTvList[i].comments[cIndex].email,
              movieId: movieTvList[i].comments[cIndex].movieId,
              tvSeriesId: movieTvList[i].comments[cIndex].tvSeriesId,
              comment: movieTvList[i].comments[cIndex].comment,
              createdAt: movieTvList[i].comments[cIndex].createdAt,
              updatedAt: movieTvList[i].comments[cIndex].updatedAt,
            );
          }),
          episodeRuntime: movieTvList[i].episodeRuntime,
          genreId: movieTvList[i].genreId,
          type: movieTvList[i].type,
        ));
        moviesList.removeWhere((element) =>
            element.status == 0 ||
            "${element.status}" == "0" ||
            element.country?.contains(countryName.toUpperCase()) == true);
        if (isKidsModeEnabled) {
          moviesList.removeWhere((element) => element.isKids == 0);
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
