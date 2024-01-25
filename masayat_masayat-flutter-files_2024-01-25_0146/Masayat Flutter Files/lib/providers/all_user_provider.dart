import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '../models/AllUsers.dart';
import '/common/apipath.dart';

class AllUsersProvider with ChangeNotifier {
  AllUsers allUsers = AllUsers();

  Future<void> loadData(BuildContext context) async {
    final response = await http.get(
      Uri.parse(APIData.allUsers),
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
    );

    print("All Users Status Code : ${response.statusCode}");
    log("All Users Response : ${response.body}");

    if (response.statusCode == 200) {
      allUsers = AllUsers.fromJson(json.decode(response.body));
    } else {
      throw "Can't get All Users.";
    }
  }
}
