import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/models/CountViewModel.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../common/apipath.dart';
import 'dart:io';

class CountViewProvider with ChangeNotifier {
  CountViewModel countViewModel = CountViewModel();

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
      Uri.parse(APIData.countViews),
      headers: {
        HttpHeaders.authorizationHeader: "Bearer $token",
      },
    );
    print("View Counts API Status Code :-> ${response.statusCode}");
    log("View Counts API Response :-> ${response.body}");
    if (response.statusCode == 200) {
      countViewModel = CountViewModel.fromJson(jsonDecode(response.body));
      notifyListeners();
    } else {
      print("View Counts API Status Code :-> ${response.statusCode}");
    }
  }
}
