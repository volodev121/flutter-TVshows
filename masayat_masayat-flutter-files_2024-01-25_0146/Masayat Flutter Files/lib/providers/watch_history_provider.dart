import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/datum.dart';
import '/models/watch_history_model.dart';
import 'package:http/http.dart' as http;

class WatchHistoryProvider with ChangeNotifier {
  List<Datum> tvWishList = [];
  WatchHistoryModel? watchHistoryModel;

  Future<WatchHistoryModel?> getWatchHistory(BuildContext context) async {
    var token = await storage.read(key: "authToken");
    final response = await http.get(Uri.parse(APIData.watchHistory), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $token",
    });
    if (response.statusCode == 200) {
      watchHistoryModel =
          WatchHistoryModel.fromJson(json.decode(response.body));
    } else {
      throw "Can't get watch history data";
    }
    notifyListeners();
    return watchHistoryModel;
  }
}
