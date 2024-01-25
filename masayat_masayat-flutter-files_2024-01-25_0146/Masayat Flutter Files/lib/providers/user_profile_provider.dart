import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import '/models/login_model.dart';
import '/models/user_profile_model.dart';

class UserProfileProvider with ChangeNotifier {
  UserProfileModel? userProfileModel;
  LoginModel? loginModel;

  Future<UserProfileModel?> getUserProfile(BuildContext context) async {
    try {
      final response = await http.get(
        Uri.parse(APIData.userProfileApi),
        headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $authToken",
        },
      );
      log("Bearer Token :-> $authToken");
      print("User Profile :-> ${response.statusCode}");
      log("User Profile :-> ${response.body}");
      if (response.statusCode == 200) {
        userProfileModel =
            UserProfileModel.fromJson(json.decode(response.body));
      } else {
        await storage.deleteAll();
        Navigator.pushNamed(context, RoutePaths.loginHome);
        throw "Can't get user profile";
      }
    } catch (error) {
      await storage.deleteAll();
      print("user_profile_provider: $error");
      return Navigator.pushNamed(context, RoutePaths.loginHome);
    }
    notifyListeners();
    return null;
  }
}
