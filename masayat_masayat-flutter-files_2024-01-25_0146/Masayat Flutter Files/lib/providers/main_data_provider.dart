import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/models/genre_model.dart';

class MainProvider with ChangeNotifier {
  GenreModel? genreModel;
  List<Genre> genreList = [];
  List<Actor> actorList = [];
  List<Director> directorList = [];
  List<Audio> audioList = [];

  Future<GenreModel?> getMainApiData(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(APIData.allDataApi), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        HttpHeaders.authorizationHeader: "Bearer $authToken",
      });
      print("Main API Status Code : ${response.statusCode}");
      log("Main API Response : ${response.body}");
      if (response.statusCode == 200) {
        genreModel = GenreModel.fromJson(json.decode(response.body));
        genreList = List.generate(genreModel!.genre!.length, (index) {
          return Genre(
            id: genreModel!.genre![index].id,
            name: genreModel!.genre![index].name,
            createdAt: genreModel!.genre![index].createdAt,
            updatedAt: genreModel!.genre![index].updatedAt,
          );
        });
        actorList = List.generate(genreModel!.actor!.length, (index) {
          return Actor(
            id: genreModel!.actor![index].id,
            name: genreModel!.actor![index].name,
            placeOfBirth: genreModel!.actor![index].placeOfBirth,
            biography: genreModel!.actor![index].biography,
            dob: genreModel!.actor![index].dob,
            image: genreModel!.actor![index].image,
            createdAt: genreModel!.actor![index].createdAt,
            updatedAt: genreModel!.actor![index].updatedAt,
          );
        });

        List<Actor> _actorList = [];

        actorList.forEach((element) {
          if (_actorList.length > 0) {
            bool isAvailable = false;
            isAvailable = _actorList.any((_element) =>
                (element.id == _element.id && element.name == _element.name));
            if (!isAvailable) {
              _actorList.add(element);
            }
          } else {
            _actorList.add(element);
          }
        });

        actorList = _actorList;

        directorList = List.generate(genreModel!.director!.length, (index) {
          return Director(
            id: genreModel!.director![index].id,
            name: genreModel!.director![index].name,
            placeOfBirth: genreModel!.director![index].placeOfBirth,
            biography: genreModel!.director![index].biography,
            dob: genreModel!.director![index].dob,
            image: genreModel!.director![index].image,
            createdAt: genreModel!.director![index].createdAt,
            updatedAt: genreModel!.director![index].updatedAt,
          );
        });
        audioList = List.generate(
            genreModel!.audio!.length,
            (index) => Audio(
                  id: genreModel!.audio![index].id,
                  language: genreModel!.audio![index].language,
                  createdAt: genreModel!.audio![index].createdAt,
                  updatedAt: genreModel!.audio![index].updatedAt,
                  name: genreModel!.audio![index].name,
                ));
      } else {
        await storage.deleteAll();
        Navigator.pushNamed(context, RoutePaths.login);
        throw "Can't get main API data";
      }
      notifyListeners();
      return genreModel;
    } catch (error) {
      print(error);
      await storage.deleteAll();
      Navigator.pushNamed(context, RoutePaths.login);
      throw error;
    }
  }
}
