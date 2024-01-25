import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:nexthour/models/upi_details_model.dart';
import 'package:http/http.dart' as http;
import '../common/apipath.dart';
import '../common/global.dart';

class UpiDetailsProvider with ChangeNotifier {
  UpiDetailsModel? upiDetailsModel;

  Future<void> getData() async {
    final response = await http.get(Uri.parse(APIData.upiDetails), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });

    print("UPI Details API Status Code :-> ${response.statusCode}");

    if (response.statusCode == 200) {
      log('UPI Details API Response :-> ${response.body}');
      upiDetailsModel = UpiDetailsModel.fromJson(json.decode(response.body));
    }
  }
}
