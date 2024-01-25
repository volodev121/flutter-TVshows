import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/models/manual_payment_model.dart';

class ManualPaymentProvider extends ChangeNotifier {
  ManualPaymentModel? manualPaymentModel;
  Future<void> fetchData() async {
    String url = APIData.manualPayments;
    http.Response response = await http.get(
      Uri.parse(url),
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $authToken',
      },
    );
    try {
      if (response.statusCode == 200) {
        String data = response.body;
        print("Manual Payment Response :-> $data");
        manualPaymentModel =
            ManualPaymentModel.fromJson(await jsonDecode(data));
      } else {
        print("Manual Payment Response Code :-> ${response.statusCode}");
      }
    } catch (e) {
      print("Manual Payment Exception :-> $e");
    }
  }
}
