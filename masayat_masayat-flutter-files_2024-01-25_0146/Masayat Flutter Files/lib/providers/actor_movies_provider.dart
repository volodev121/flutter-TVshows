import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/countryProvider.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/actor_movies_details.dart';
import '/models/datum.dart';
import '/models/episode.dart';
import '/models/genre_model.dart';
import '/models/seasons.dart';
import '/providers/main_data_provider.dart';
import '/providers/movie_tv_provider.dart';
import 'package:provider/provider.dart';

class ActorMoviesProvider with ChangeNotifier {
  ActorMoviesDetails? actorMoviesDetails;
  List<Datum> actorMoviesTVList = [];
  List<Actormovie?> actorMovies = [];
  List<Actormovie?> actorTVSeries = [];
  bool? loading;

  Future<ActorMoviesDetails?> getActorsMovies(
      BuildContext context, String id) async {
    var movieTvList =
        Provider.of<MovieTVProvider>(context, listen: false).movieTvList;
    var genreList = Provider.of<MainProvider>(context, listen: false).genreList;
    var actorList = Provider.of<MainProvider>(context, listen: false).actorList;
    var directorList =
        Provider.of<MainProvider>(context, listen: false).directorList;
    var audioList = Provider.of<MainProvider>(context, listen: false).audioList;
    loading = true;
    actorMoviesTVList = [];
    try {
      final response = await http.get(
          Uri.parse("${APIData.actorMovies}$id?secret=" + APIData.secretKey),
          headers: {
            "Content-Type": "application/x-www-form-urlencoded",
            HttpHeaders.authorizationHeader: "Bearer $authToken"
          });
      print(response.statusCode);
      print(response);
      print(response.body);
      if (response.statusCode == 200) {
        actorMoviesDetails =
            ActorMoviesDetails.fromJson(json.decode(response.body));
        actorMovies = List<Actormovie?>.generate(
            actorMoviesDetails!.actormovies!.length, (index) {
          if ("${actorMoviesDetails!.actormovies![index].type}" == "M") {
            return Actormovie(
              id: actorMoviesDetails!.actormovies![index].id,
              tmdbId: actorMoviesDetails!.actormovies![index].tmdbId,
              title: actorMoviesDetails!.actormovies![index].title,
              keyword: actorMoviesDetails!.actormovies![index].keyword,
              description: actorMoviesDetails!.actormovies![index].description,
              duration: actorMoviesDetails!.actormovies![index].duration,
              thumbnail: actorMoviesDetails!.actormovies![index].thumbnail,
              poster: actorMoviesDetails!.actormovies![index].poster,
              type: actorMoviesDetails!.actormovies![index].type,
              live: actorMoviesDetails!.actormovies![index].live,
            );
          } else {
            return null;
          }
        });

        actorMovies.removeWhere((element) => element == null);

        actorTVSeries = List<Actormovie?>.generate(
            actorMoviesDetails!.actormovies!.length, (index) {
          if ("${actorMoviesDetails!.actormovies![index].type}" == "S") {
            return Actormovie(
              id: actorMoviesDetails!.actormovies![index].id,
              tvSeriesId: actorMoviesDetails!.actormovies![index].tvSeriesId,
              tmdbId: actorMoviesDetails!.actormovies![index].tmdbId,
              seasonNo: actorMoviesDetails!.actormovies![index].seasonNo,
              seasonSlug: actorMoviesDetails!.actormovies![index].seasonSlug,
              tmdb: actorMoviesDetails!.actormovies![index].tmdb,
              publishYear: actorMoviesDetails!.actormovies![index].publishYear,
              thumbnail: actorMoviesDetails!.actormovies![index].thumbnail,
              poster: actorMoviesDetails!.actormovies![index].poster,
              actorId: actorMoviesDetails!.actormovies![index].actorId,
              aLanguage: actorMoviesDetails!.actormovies![index].aLanguage,
              subtitle: actorMoviesDetails!.actormovies![index].subtitle,
              subtitleList:
                  actorMoviesDetails!.actormovies![index].subtitleList,
              detail: actorMoviesDetails!.actormovies![index].detail,
              featured: actorMoviesDetails!.actormovies![index].featured,
              type: actorMoviesDetails!.actormovies![index].type,
              trailerUrl: actorMoviesDetails!.actormovies![index].trailerUrl,
              isProtect: actorMoviesDetails!.actormovies![index].isProtect,
              password: actorMoviesDetails!.actormovies![index].password,
              createdAt: actorMoviesDetails!.actormovies![index].createdAt,
              updatedAt: actorMoviesDetails!.actormovies![index].updatedAt,
            );
          } else {
            return null;
          }
        });

        actorTVSeries.removeWhere((element) => element == null);

        final ids = actorTVSeries.map((e) => e!.tvSeriesId).toSet();
        actorTVSeries.retainWhere((x) => ids.remove(x!.tvSeriesId));

        for (int i = 0; i < movieTvList.length; i++) {
          if (movieTvList[i].type == DatumType.T) {
            for (int k = 0; k < actorTVSeries.length; k++) {
              if (movieTvList[i].id == actorTVSeries[k]!.tvSeriesId) {
                actorMoviesTVList.add(Datum(
                  isKids: movieTvList[i].isKids,
                  id: movieTvList[i].id,
                  tmdbId: movieTvList[i].tmdbId,
                  title: movieTvList[i].title,
                  keyword: movieTvList[i].keyword,
                  description: movieTvList[i].description,
                  duration: movieTvList[i].duration,
                  thumbnail: movieTvList[i].thumbnail,
                  poster: movieTvList[i].poster,
                  tmdb: movieTvList[i].tmdb,
                  fetchBy: movieTvList[i].fetchBy,
                  directorId: movieTvList[i].directorId,
                  actorId: movieTvList[i].actorId,
                  genreId: movieTvList[i].genreId,
                  trailerUrl: movieTvList[i].trailerUrl,
                  detail: movieTvList[i].detail,
                  rating: movieTvList[i].rating,
                  maturityRating: movieTvList[i].maturityRating,
                  subtitle: movieTvList[i].subtitle,
                  subtitles: movieTvList[i].subtitles,
                  publishYear: movieTvList[i].publishYear,
                  released: movieTvList[i].released,
                  uploadVideo: movieTvList[i].uploadVideo,
                  featured: movieTvList[i].featured,
                  series: movieTvList[i].series,
                  aLanguage: movieTvList[i].aLanguage,
                  audioFiles: movieTvList[i].audioFiles,
                  type: movieTvList[i].type,
                  live: movieTvList[i].live,
                  status: movieTvList[i].status,
                  createdBy: movieTvList[i].createdBy,
                  createdAt: movieTvList[i].createdAt,
                  updatedAt: movieTvList[i].updatedAt,
                  isUpcoming: movieTvList[i].isUpcoming,
                  userRating: movieTvList[i].userRating,
                  movieSeries: movieTvList[i].movieSeries,
                  videoLink: movieTvList[i].videoLink,
                  comments: movieTvList[i].comments,
                  episodeRuntime: movieTvList[i].episodeRuntime,
                  country: movieTvList[i].country,
                  seasons: List.generate(
                      movieTvList[i].seasons == null
                          ? 0
                          : movieTvList[i].seasons!.length, (sIndex) {
                    var seasonActors =
                        movieTvList[i].seasons![sIndex].actorId == "" ||
                                movieTvList[i].seasons![sIndex].actorId == null
                            ? null
                            : movieTvList[i]
                                .seasons![sIndex]
                                .actorId!
                                .split(",")
                                .toList();
                    var audioLang = movieTvList[i].seasons![sIndex].aLanguage ==
                                "" ||
                            movieTvList[i].seasons![sIndex].aLanguage == null
                        ? null
                        : movieTvList[i]
                            .seasons![sIndex]
                            .aLanguage
                            .split(",")
                            .toList();
                    return Season(
                      id: movieTvList[i].seasons![sIndex].id,
                      thumbnail: movieTvList[i].seasons![sIndex].thumbnail,
                      poster: movieTvList[i].seasons![sIndex].poster,
                      detail: movieTvList[i].seasons![sIndex].detail,
                      seasonNo: movieTvList[i].seasons![sIndex].seasonNo,
                      publishYear: movieTvList[i].seasons![sIndex].publishYear,
                      episodes: List.generate(
                          movieTvList[i].seasons![sIndex].episodes == null
                              ? 0
                              : movieTvList[i]
                                  .seasons![sIndex]
                                  .episodes!
                                  .length, (eIndex) {
                        return Episode(
                          id: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .id,
                          thumbnail: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .thumbnail,
                          title: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .title,
                          detail: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .detail,
                          duration: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .duration,
                          createdAt: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .createdAt,
                          updatedAt: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .updatedAt,
                          episodeNo: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .episodeNo,
                          aLanguage: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .aLanguage,
                          subtitle: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .subtitle,
                          subtitles: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .subtitles,
                          released: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .released,
                          seasonsId: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .seasonsId,
                          videoLink: movieTvList[i]
                              .seasons![sIndex]
                              .episodes![eIndex]
                              .videoLink,
                        );
                      }),
                      actorId: movieTvList[i].seasons![sIndex].actorId,
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
                        var audioIdList = List.generate(
                            audioLang == null ? 0 : audioLang.length,
                            (int idIndex) {
                          return "${audioLang[idIndex]}";
                        });
                        var isAv2 = 0;
                        for (var y in audioIdList) {
                          if (actorsId == y) {
                            isAv2 = 1;
                            break;
                          }
                        }
                        if (isAv2 == 1) {
                          return "${audioList[actIndex].language}";
                        }
                        return null;
                      }),
                      aLanguage: movieTvList[i].seasons![sIndex].aLanguage,
                      createdAt: movieTvList[i].seasons![sIndex].createdAt,
                      updatedAt: movieTvList[i].seasons![sIndex].updatedAt,
                      featured: movieTvList[i].seasons![sIndex].featured,
                      tmdb: movieTvList[i].seasons![sIndex].tmdb,
                      tmdbId: movieTvList[i].seasons![sIndex].tmdbId,
                      subtitle: movieTvList[i].seasons![sIndex].subtitle,
                      subtitles: movieTvList[i].seasons![sIndex].subtitles,
                    );
                  }),
                  genre: movieTvList[i].genre,
                  genres: movieTvList[i].genres,
                  directors: movieTvList[i].directors,
                  actors: movieTvList[i].actors,
                  audios: movieTvList[i].audios,
                  actor: movieTvList[i].actor,
                ));
              }
            }
          } else {
            for (int k = 0; k < actorMovies.length; k++) {
              if (movieTvList[i].id == actorMovies[k]!.id) {
                var genreData = movieTvList[i].genreId == null
                    ? null
                    : movieTvList[i].genreId!.split(",").toList();
                var actors = movieTvList[i].actorId == null
                    ? null
                    : movieTvList[i].actorId!.split(",").toList();
                var audios = movieTvList[i].aLanguage == null
                    ? null
                    : movieTvList[i].aLanguage!.split(",").toList();
                var directors = movieTvList[i].directorId == null
                    ? null
                    : movieTvList[i].directorId!.split(",").toList();
                actorMoviesTVList.add(Datum(
                  isKids: movieTvList[i].isKids,
                  id: movieTvList[i].id,
                  tmdbId: movieTvList[i].tmdbId,
                  title: movieTvList[i].title,
                  keyword: movieTvList[i].keyword,
                  description: movieTvList[i].description,
                  duration: movieTvList[i].duration,
                  thumbnail: movieTvList[i].thumbnail,
                  poster: movieTvList[i].poster,
                  tmdb: movieTvList[i].tmdb,
                  fetchBy: movieTvList[i].fetchBy,
                  directorId: movieTvList[i].directorId,
                  actorId: movieTvList[i].actorId,
                  genreId: movieTvList[i].genreId,
                  trailerUrl: movieTvList[i].trailerUrl,
                  detail: movieTvList[i].detail,
                  rating: movieTvList[i].rating,
                  maturityRating: movieTvList[i].maturityRating,
                  subtitle: movieTvList[i].subtitle,
                  subtitles: movieTvList[i].subtitles,
                  publishYear: movieTvList[i].publishYear,
                  released: movieTvList[i].released,
                  uploadVideo: movieTvList[i].uploadVideo,
                  featured: movieTvList[i].featured,
                  series: movieTvList[i].series,
                  aLanguage: movieTvList[i].aLanguage,
                  audioFiles: movieTvList[i].audioFiles,
                  type: movieTvList[i].type,
                  live: movieTvList[i].live,
                  status: movieTvList[i].status,
                  createdBy: movieTvList[i].createdBy,
                  createdAt: movieTvList[i].createdAt,
                  updatedAt: movieTvList[i].updatedAt,
                  isUpcoming: movieTvList[i].isUpcoming,
                  userRating: movieTvList[i].userRating,
                  movieSeries: movieTvList[i].movieSeries,
                  videoLink: movieTvList[i].videoLink,
                  comments: movieTvList[i].comments,
                  episodeRuntime: movieTvList[i].episodeRuntime,
                  seasons: movieTvList[i].seasons,
                  country: movieTvList[i].country,
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
                    var actorsIdList =
                        List.generate(directors == null ? 0 : directors.length,
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
                  audios: List.generate(
                    audioList.length,
                    (actIndex) {
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
                    },
                  ),
                ));
              }
            }
          }
        }
        actorMoviesTVList.removeWhere((element) =>
            element.status == 0 ||
            "${element.status}" == "0" ||
            element.country?.contains(countryName.toUpperCase()) == true);
        loading = false;
      } else {
        throw "Can't get actor movies data";
      }
      notifyListeners();
      return actorMoviesDetails;
    } catch (error) {
      print(error);
      throw error;
    }
  }
}
