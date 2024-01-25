import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:nexthour/services/countryProvider.dart';
import '../localization/language_model.dart';
import '../localization/language_provider.dart';
import '../models/RecommendedDataModel.dart';
import '../models/TopDataModel.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import 'package:http/http.dart' as http;
import '/models/datum.dart';
import '/models/episode.dart';
import '/models/genre_model.dart';
import '/models/menu_by_category.dart';
import '/models/seasons.dart';
import '/providers/main_data_provider.dart';
import 'package:provider/provider.dart';
import 'movie_tv_provider.dart';

class MenuDataProvider with ChangeNotifier {
  MenuByCategory menuByCategory = new MenuByCategory();
  List<Datum> menuCatMoviesList = [];
  List<Datum> menuCatTvSeriesList = [];
  List<Datum> menuDataList = [];
  List<Datum> liveDataList = [];

  Future<MenuByCategory> getMenusData(BuildContext context, menuId) async {
    var genreList = Provider.of<MainProvider>(context, listen: false).genreList;
    var actorList = Provider.of<MainProvider>(context, listen: false).actorList;
    var directorList =
        Provider.of<MainProvider>(context, listen: false).directorList;
    var audioList = Provider.of<MainProvider>(context, listen: false).audioList;
    menuDataList = [];
    menuCatMoviesList = [];
    menuCatTvSeriesList = [];
    liveDataList = [];
    final response = await http.get(
        Uri.parse(APIData.menuDataApi + "/$menuId?secret=" + APIData.secretKey),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $authToken",
        });
    print('Menu Data API Status Code ${response.statusCode}');
    log("Menu Data API Response -> ${response.body}");
    if (response.statusCode == 200) {
      menuByCategory = MenuByCategory.fromJson(json.decode(response.body));
      if (menuByCategory.data != null) {
        for (int i = 0; i < menuByCategory.data!.length; i++) {
          for (int j = 0; j < menuByCategory.data![i].length; j++) {
            var genreData = menuByCategory.data![i][j].genreId == null
                ? null
                : menuByCategory.data![i][j].genreId!.split(",").toList();
            var actors = menuByCategory.data![i][j].actorId == null
                ? null
                : menuByCategory.data![i][j].actorId!.split(",").toList();
            var audios = menuByCategory.data![i][j].aLanguage == null
                ? null
                : menuByCategory.data![i][j].aLanguage!.split(",").toList();
            var directors = menuByCategory.data![i][j].directorId == null
                ? null
                : menuByCategory.data![i][j].directorId!.split(",").toList();

            menuDataList.add(Datum(
              isKids: menuByCategory.data![i][j].isKids,
              id: menuByCategory.data![i][j].id,
              tmdbId: menuByCategory.data![i][j].tmdbId,
              title: menuByCategory.data![i][j].title,
              keyword: menuByCategory.data![i][j].keyword,
              description: menuByCategory.data![i][j].description,
              duration: menuByCategory.data![i][j].duration,
              thumbnail: menuByCategory.data![i][j].thumbnail,
              poster: menuByCategory.data![i][j].poster,
              tmdb: menuByCategory.data![i][j].tmdb,
              fetchBy: menuByCategory.data![i][j].fetchBy,
              directorId: menuByCategory.data![i][j].directorId,
              actorId: menuByCategory.data![i][j].actorId,
              genreId: menuByCategory.data![i][j].genreId,
              trailerUrl: menuByCategory.data![i][j].trailerUrl,
              detail: menuByCategory.data![i][j].detail,
              rating: menuByCategory.data![i][j].rating,
              maturityRating: menuByCategory.data![i][j].maturityRating,
              subtitle: menuByCategory.data![i][j].subtitle,
              subtitles: menuByCategory.data![i][j].subtitles,
              publishYear: menuByCategory.data![i][j].publishYear,
              released: menuByCategory.data![i][j].released,
              uploadVideo: menuByCategory.data![i][j].updatedAt,
              featured: menuByCategory.data![i][j].featured,
              series: menuByCategory.data![i][j].series,
              aLanguage: menuByCategory.data![i][j].aLanguage,
              audioFiles: menuByCategory.data![i][j].audioFiles,
              type: menuByCategory.data![i][j].type,
              live: menuByCategory.data![i][j].live,
              status: menuByCategory.data![i][j].status,
              createdBy: menuByCategory.data![i][j].createdBy,
              createdAt: menuByCategory.data![i][j].createdAt,
              isUpcoming: menuByCategory.data![i][j].isUpcoming,
              updatedAt: menuByCategory.data![i][j].updatedAt,
              userRating: menuByCategory.data![i][j].userRating,
              movieSeries: menuByCategory.data![i][j].movieSeries,
              videoLink: menuByCategory.data![i][j].videoLink,
              comments: menuByCategory.data![i][j].comments,
              episodeRuntime: menuByCategory.data![i][j].episodeRuntime,
              seasons: menuByCategory.data![i][j].seasons,
              country: menuByCategory.data![i][j].country,
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
            ));

            menuDataList.removeWhere((element) =>
                element.status == 0 ||
                element.status == "0" ||
                element.country?.contains(countryName.toUpperCase()) == true);
            if (isKidsModeEnabled) {
              menuDataList.removeWhere((element) => element.isKids == 0);
            }
          }
        }
        for (int i = 0; i < menuDataList.length; i++) {
          if (menuDataList[i].type == DatumType.M) {
            var audios = menuDataList[i].aLanguage == null ||
                    menuDataList[i].aLanguage == "null"
                ? null
                : menuDataList[i].aLanguage!.split(",").toList();

            menuCatMoviesList.add(Datum(
              isKids: menuDataList[i].isKids,
              id: menuDataList[i].id,
              actorId: menuDataList[i].actorId,
              title: menuDataList[i].title,
              trailerUrl: menuDataList[i].trailerUrl,
              status: menuDataList[i].status,
              keyword: menuDataList[i].keyword,
              description: menuDataList[i].description,
              duration: menuDataList[i].duration,
              thumbnail: menuDataList[i].thumbnail,
              poster: menuDataList[i].poster,
              directorId: menuDataList[i].directorId,
              detail: menuDataList[i].detail,
              rating: menuDataList[i].rating,
              maturityRating: menuDataList[i].maturityRating,
              subtitle: menuDataList[i].subtitle,
              subtitles: menuDataList[i].subtitles,
              publishYear: menuDataList[i].publishYear,
              released: menuDataList[i].released,
              uploadVideo: menuDataList[i].uploadVideo,
              featured: menuDataList[i].featured,
              series: menuDataList[i].series,
              aLanguage: menuDataList[i].aLanguage,
              live: menuDataList[i].live,
              createdBy: menuDataList[i].createdBy,
              createdAt: menuDataList[i].createdAt,
              updatedAt: menuDataList[i].updatedAt,
              isUpcoming: menuDataList[i].isUpcoming,
              userRating: menuDataList[i].userRating,
              movieSeries: menuDataList[i].movieSeries,
              videoLink: menuDataList[i].videoLink,
              comments: menuDataList[i].comments,
              episodeRuntime: menuDataList[i].episodeRuntime,
              genreId: menuDataList[i].genreId,
              type: menuDataList[i].type,
              tmdbId: menuDataList[i].tmdbId,
              tmdb: menuDataList[i].tmdb,
              fetchBy: menuDataList[i].fetchBy,
              genre: menuDataList[i].genre,
              genres: menuDataList[i].genres,
              actor: menuDataList[i].actor,
              actors: menuDataList[i].actors,
              directors: menuDataList[i].directors,
              country: menuDataList[i].country,
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
                  return "${audioList[actIndex].language}";
                }
                return null;
              }),
            ));

            menuCatMoviesList.removeWhere((element) =>
                element.status == 0 ||
                element.status == "0" ||
                element.country?.contains(countryName.toUpperCase()) == true);
            if (isKidsModeEnabled) {
              menuCatMoviesList.removeWhere((element) => element.isKids == 0);
            }
          } else {
            menuCatTvSeriesList.add(Datum(
              isKids: menuDataList[i].isKids,
              id: menuDataList[i].id,
              actorId: menuDataList[i].actorId,
              title: menuDataList[i].title,
              trailerUrl: menuDataList[i].trailerUrl,
              status: menuDataList[i].status,
              keyword: menuDataList[i].keyword,
              description: menuDataList[i].description,
              duration: menuDataList[i].duration,
              thumbnail: menuDataList[i].thumbnail,
              poster: menuDataList[i].poster,
              directorId: menuDataList[i].directorId,
              detail: menuDataList[i].detail,
              rating: menuDataList[i].rating,
              maturityRating: menuDataList[i].maturityRating,
              subtitle: menuDataList[i].subtitle,
              subtitles: menuDataList[i].subtitles,
              publishYear: menuDataList[i].publishYear,
              released: menuDataList[i].released,
              uploadVideo: menuDataList[i].uploadVideo,
              featured: menuDataList[i].featured,
              series: menuDataList[i].series,
              aLanguage: menuDataList[i].aLanguage,
              live: menuDataList[i].live,
              createdBy: menuDataList[i].createdBy,
              createdAt: menuDataList[i].createdAt,
              updatedAt: menuDataList[i].updatedAt,
              isUpcoming: menuDataList[i].isUpcoming,
              userRating: menuDataList[i].userRating,
              movieSeries: menuDataList[i].movieSeries,
              videoLink: menuDataList[i].videoLink,
              genre: menuDataList[i].genre,
              genres: menuDataList[i].genres,
              actor: menuDataList[i].actor,
              actors: menuDataList[i].actors,
              directors: menuDataList[i].directors,
              audios: menuDataList[i].audios,
              comments: menuDataList[i].comments,
              episodeRuntime: menuDataList[i].episodeRuntime,
              genreId: menuDataList[i].genreId,
              type: menuDataList[i].type,
              country: menuDataList[i].country,
              seasons: List.generate(
                  menuDataList[i].seasons == null
                      ? 0
                      : menuDataList[i].seasons!.length, (sIndex) {
                var actors = menuDataList[i].seasons![sIndex].actorId == "" ||
                        menuDataList[i].seasons![sIndex].actorId == null
                    ? null
                    : menuDataList[i]
                        .seasons![sIndex]
                        .actorId!
                        .split(",")
                        .toList();
                return Season(
                  id: menuDataList[i].seasons![sIndex].id,
                  thumbnail: menuDataList[i].seasons![sIndex].thumbnail,
                  poster: menuDataList[i].seasons![sIndex].poster,
                  detail: menuDataList[i].seasons![sIndex].detail,
                  seasonNo: menuDataList[i].seasons![sIndex].seasonNo,
                  strailerUrl: menuDataList[i].seasons![sIndex].strailerUrl,
                  publishYear: menuDataList[i].seasons![sIndex].publishYear,
                  episodes: List.generate(
                      menuDataList[i].seasons![sIndex].episodes == null
                          ? 0
                          : menuDataList[i].seasons![sIndex].episodes!.length,
                      (eIndex) {
                    return Episode(
                      id: menuDataList[i].seasons![sIndex].episodes![eIndex].id,
                      thumbnail: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .thumbnail,
                      title: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .title,
                      detail: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .detail,
                      duration: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .duration,
                      createdAt: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .createdAt,
                      updatedAt: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .updatedAt,
                      episodeNo: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .episodeNo,
                      aLanguage: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .aLanguage,
                      subtitle: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .subtitle,
                      subtitles: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .subtitles,
                      released: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .released,
                      seasonsId: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .seasonsId,
                      videoLink: menuDataList[i]
                          .seasons![sIndex]
                          .episodes![eIndex]
                          .videoLink,
                    );
                  }),
                  actorId: menuDataList[i].seasons![sIndex].actorId,
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
                  aLanguage: menuDataList[i].seasons![sIndex].aLanguage,
                  createdAt: menuDataList[i].seasons![sIndex].createdAt,
                  updatedAt: menuDataList[i].seasons![sIndex].updatedAt,
                  featured: menuDataList[i].seasons![sIndex].featured,
                  tmdb: menuDataList[i].seasons![sIndex].tmdb,
                  tmdbId: menuDataList[i].seasons![sIndex].tmdbId,
                  subtitle: menuDataList[i].seasons![sIndex].subtitle,
                  subtitles: menuDataList[i].seasons![sIndex].subtitles,
                );
              }),
              tmdbId: menuDataList[i].tmdbId,
              tmdb: menuDataList[i].tmdb,
              fetchBy: menuDataList[i].fetchBy,
            ));

            menuCatTvSeriesList.removeWhere((element) =>
                element.status == 0 ||
                element.status == "0" ||
                element.country?.contains(countryName.toUpperCase()) == true);
            if (isKidsModeEnabled) {
              menuCatTvSeriesList.removeWhere((element) => element.isKids == 0);
            }
          }
        }

        // Remove Duplicate Items

        List<Datum> _menuCatMoviesList = [];

        menuCatMoviesList.forEach((element) {
          if (_menuCatMoviesList.length > 0) {
            bool isAvailable = false;
            isAvailable = _menuCatMoviesList.any((_element) =>
                (element.id == _element.id && element.title == _element.title));
            if (!isAvailable) {
              _menuCatMoviesList.add(element);
            }
          } else {
            _menuCatMoviesList.add(element);
          }
        });

        menuCatMoviesList = _menuCatMoviesList;

        List<Datum> _menuCatTvSeriesList = [];

        menuCatTvSeriesList.forEach((element) {
          if (_menuCatTvSeriesList.length > 0) {
            bool isAvailable = false;
            isAvailable = _menuCatTvSeriesList.any((_element) =>
                (element.id == _element.id && element.title == _element.title));
            if (!isAvailable) {
              _menuCatTvSeriesList.add(element);
            }
          } else {
            _menuCatTvSeriesList.add(element);
          }
        });

        menuCatTvSeriesList = _menuCatTvSeriesList;

        // ---

        for (int i = 0; i < menuCatMoviesList.length; i++) {
          if (menuCatMoviesList[i].live == 1 ||
              "${menuCatMoviesList[i].live}" == "1") {
            var audios = menuCatMoviesList[i].aLanguage == null ||
                    menuCatMoviesList[i].aLanguage == "null"
                ? null
                : menuCatMoviesList[i].aLanguage!.split(",").toList();
            liveDataList.add(Datum(
              isKids: menuCatMoviesList[i].isKids,
              id: menuCatMoviesList[i].id,
              actorId: menuCatMoviesList[i].actorId,
              title: menuCatMoviesList[i].title,
              trailerUrl: menuCatMoviesList[i].trailerUrl,
              status: menuCatMoviesList[i].status,
              keyword: menuCatMoviesList[i].keyword,
              description: menuCatMoviesList[i].description,
              duration: menuCatMoviesList[i].duration,
              thumbnail: menuCatMoviesList[i].thumbnail,
              poster: menuCatMoviesList[i].poster,
              directorId: menuCatMoviesList[i].directorId,
              detail: menuCatMoviesList[i].detail,
              rating: menuCatMoviesList[i].rating,
              maturityRating: menuCatMoviesList[i].maturityRating,
              subtitle: menuCatMoviesList[i].subtitle,
              subtitles: menuCatMoviesList[i].subtitles,
              publishYear: menuCatMoviesList[i].publishYear,
              released: menuCatMoviesList[i].released,
              uploadVideo: menuCatMoviesList[i].uploadVideo,
              featured: menuCatMoviesList[i].featured,
              series: menuCatMoviesList[i].series,
              aLanguage: menuCatMoviesList[i].aLanguage,
              live: menuCatMoviesList[i].live,
              createdBy: menuCatMoviesList[i].createdBy,
              createdAt: menuCatMoviesList[i].createdAt,
              updatedAt: menuCatMoviesList[i].updatedAt,
              isUpcoming: menuCatMoviesList[i].isUpcoming,
              userRating: menuCatMoviesList[i].userRating,
              movieSeries: menuCatMoviesList[i].movieSeries,
              videoLink: menuCatMoviesList[i].videoLink,
              comments: menuCatMoviesList[i].comments,
              episodeRuntime: menuCatMoviesList[i].episodeRuntime,
              genreId: menuCatMoviesList[i].genreId,
              type: menuCatMoviesList[i].type,
              tmdbId: menuCatMoviesList[i].tmdbId,
              tmdb: menuCatMoviesList[i].tmdb,
              fetchBy: menuCatMoviesList[i].fetchBy,
              genre: menuCatMoviesList[i].genre,
              genres: menuCatMoviesList[i].genres,
              actor: menuCatMoviesList[i].actor,
              actors: menuCatMoviesList[i].actors,
              directors: menuCatMoviesList[i].directors,
              country: menuCatMoviesList[i].country,
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
                  return "${audioList[actIndex].language}";
                }
                return null;
              }),
            ));
            liveDataList.removeWhere((element) =>
                element.status == 0 ||
                element.status == "0" ||
                element.country?.contains(countryName.toUpperCase()) == true);
            if (isKidsModeEnabled) {
              liveDataList.removeWhere((element) => element.isKids == 0);
            }
          }
        }
      }
    } else {
      throw "Can't get menus data";
    }
    notifyListeners();
    return menuByCategory;
  }

  TopDataModel? topDataModel;
  List<Datum> topMovieTVSeries = [];

  Future<void> getTopData(BuildContext context, String? menuSlug) async {
    topMovieTVSeries = [];
    http.Response response = await http.get(
        Uri.parse(APIData.topData + "/$menuSlug?secret=" + APIData.secretKey),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $authToken",
        });
    print('Top Data API Status Code ${response.statusCode}');
    log("Top Data API Response -> ${response.body}");
    if (response.statusCode == 200) {
      topDataModel = topDataModelFromJson(response.body);

      topDataModel?.topData?.menuData?.forEach((_menuData) {
        if (_menuData.tvseries?.id == null) {
          Provider.of<MovieTVProvider>(context, listen: false)
              .moviesList
              .forEach((_movie) {
            if (_menuData.movie?.id.toString() == _movie.id.toString()) {
              topMovieTVSeries.add(_movie);
            }
          });
        } else {
          Provider.of<MovieTVProvider>(context, listen: false)
              .tvSeriesList
              .forEach((_tvSeries) {
            if (_menuData.tvseries?.id.toString() == _tvSeries.id.toString()) {
              topMovieTVSeries.add(_tvSeries);
            }
          });
        }
      });
    }
  }

  RecommendedDataModel? recommendedDataModel;
  List<Datum> recommendedMovieTVSeries = [];

  Future<void> getRecommendedData(
      BuildContext context, String? menuSlug) async {
    recommendedMovieTVSeries = [];
    http.Response response = await http.get(
      Uri.parse(APIData.recommendedData),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        HttpHeaders.authorizationHeader: "Bearer $authToken",
      },
    );
    print('Recommended Data API Status Code ${response.statusCode}');
    log("Recommended Data API Response -> ${response.body}");
    if (response.statusCode == 200) {
      recommendedDataModel = recommendedDataModelFromJson(response.body);

      recommendedDataModel?.recomended?.forEach((_menuData) {
        if (_menuData.type == "M") {
          Provider.of<MovieTVProvider>(context, listen: false)
              .moviesList
              .forEach((_movie) {
            if (_menuData.id.toString() == _movie.id.toString()) {
              recommendedMovieTVSeries.add(_movie);
            }
          });
        } else {
          Provider.of<MovieTVProvider>(context, listen: false)
              .tvSeriesList
              .forEach((_tvSeries) {
            if (_menuData.id.toString() == _tvSeries.id.toString()) {
              recommendedMovieTVSeries.add(_tvSeries);
            }
          });
        }
      });
    }
  }

  List<Language> videoLanguages = [];
  void getVideoLanguage(BuildContext context, List<Datum> allVideoList) {
    videoLanguages = [];
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);

    languageProvider.languageModel?.language?.forEach((language) {
      allVideoList.forEach((movieTV) {
        if (movieTV.type == DatumType.T) {
          movieTV.seasons!.forEach((seasons) {
            if (seasons.aLanguage != null) {
              if (seasons.aLanguage!
                  .split(",")
                  .toList()
                  .contains(language.id.toString())) {
                if (!videoLanguages
                    .any((element) => element.id == language.id)) {
                  videoLanguages.add(language);
                }
              }
            }
          });
        } else {
          if (movieTV.aLanguage != null) {
            if (movieTV.aLanguage!
                .split(",")
                .toList()
                .contains(language.id.toString())) {
              if (!videoLanguages.any((element) => element.id == language.id)) {
                videoLanguages.add(language);
              }
            }
          }
        }
      });
    });
  }

  List<Datum> getVideosByLanguage(int? languageId, List<Datum> allVideoList) {
    List<Datum> _videoList = [];
    allVideoList.forEach((movieTV) {
      if (movieTV.type == DatumType.T) {
        movieTV.seasons!.forEach((seasons) {
          if (seasons.aLanguage != null) {
            if (seasons.aLanguage!
                .split(",")
                .toList()
                .contains(languageId.toString())) {
              if (!_videoList.any((element) =>
                  (element.id == movieTV.id && element.type == movieTV.type))) {
                _videoList.add(movieTV);
              }
            }
          }
        });
      } else {
        if (movieTV.aLanguage != null) {
          if (movieTV.aLanguage!
              .split(",")
              .toList()
              .contains(languageId.toString())) {
            if (!_videoList.any((element) =>
                (element.id == movieTV.id && element.type == movieTV.type))) {
              _videoList.add(movieTV);
            }
          }
        }
      }
    });
    return _videoList;
  }

  @override
  void dispose() {
    super.dispose();
  }
}
