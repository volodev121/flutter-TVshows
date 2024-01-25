import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/models/LiveEventModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/apipath.dart';
import 'dart:io';

class LiveEventProvider with ChangeNotifier {
  LiveEventModel liveEventModel = LiveEventModel();

  Future<void> loadData() async {
    var token;
    if (kIsWeb) {
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      token = sharedPreferences.getString('token');
    } else {
      token = await storage.read(key: "authToken");
    }
    final response = await http.get(
      Uri.parse(APIData.liveEvents),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
      },
    );
    print("Live Events API Status Code :-> ${response.statusCode}");
    log("Live Events API Response :-> ${response.body}");
    if (response.statusCode == 200) {
      liveEventModel = LiveEventModel.fromJson(jsonDecode(response.body));
      notifyListeners();
    } else {
      print("Live Events API Status Code :-> ${response.statusCode}");
    }
  }
}
