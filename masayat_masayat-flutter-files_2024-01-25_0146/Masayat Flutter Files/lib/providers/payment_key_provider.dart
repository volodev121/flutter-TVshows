import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/payment_key_model.dart';
import 'package:http/http.dart' as http;

class PaymentKeyProvider with ChangeNotifier {
  PaymentKeyModel? paymentKeyModel;

  Future<PaymentKeyModel?> fetchPaymentKeys() async {
    try {
      final response =
          await http.get(Uri.parse(APIData.stripeDetailApi), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        HttpHeaders.authorizationHeader: "Bearer $authToken"
      });
      print('Payment Keys API :-> ${APIData.stripeDetailApi}');
      log('Payment Keys :-> ${response.body}');
      print(response.statusCode);
      if (response.statusCode == 200) {
        paymentKeyModel = PaymentKeyModel.fromJson(json.decode(response.body));
      } else {
        throw "Can't get payment keys";
      }
      notifyListeners();
      return paymentKeyModel;
    } catch (error) {
      throw error;
    }
  }
}
