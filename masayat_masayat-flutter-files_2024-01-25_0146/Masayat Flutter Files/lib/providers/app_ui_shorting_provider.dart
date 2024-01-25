import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/models/AppUiShortingModel.dart';
import '/common/apipath.dart';
import '/common/global.dart';

class AppUIShortingProvider with ChangeNotifier {
  late AppUiShortingModel appUiShortingModel;

  Future<void> loadData(BuildContext context) async {
    final response = await http.get(
      Uri.parse(APIData.appUiShorting),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $authToken",
      },
    );
    print("App UI Shorting API Status Code -> ${response.statusCode}");
    if (response.statusCode == 200) {
      String data = response.body;
      // String data1 = """
      // {"appUiShorting":[{"id":4,"name":"movies","position":1,"is_active":1},
      // {"id":1,"name":"genre","position":2,"is_active":1},
      // {"id":2,"name":"artist","position":3,"is_active":1},
      // {"id":6,"name":"coming_soon","position":4,"is_active":1},
      // {"id":3,"name":"trending","position":5,"is_active":1},
      // {"id":7,"name":"blog","position":6,"is_active":1},
      // {"id":5,"name":"tv_series","position":7,"is_active":1},
      // {"id":8,"name":"live","position":8,"is_active":1},
      // {"id":9,"name":"audio","position":9,"is_active":1}]}
      // """;
      print("App UI Shorting API Response -> $data");
      appUiShortingModel = AppUiShortingModel.fromJson(await jsonDecode(data));
    }
  }
}
