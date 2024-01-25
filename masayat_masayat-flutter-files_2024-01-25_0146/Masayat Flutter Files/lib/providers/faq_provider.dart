import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/models/faq_model.dart';

class FAQProvider with ChangeNotifier {
  FaqModel? faqModel;

  Future<FaqModel?> fetchFAQ(BuildContext context) async {
    final response = await http.get(Uri.parse(APIData.faq), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    });
    if (response.statusCode == 200) {
      faqModel = FaqModel.fromJson(json.decode(response.body));
    } else {
      throw "Can't faq data";
    }
    notifyListeners();
    return faqModel;
  }
}
