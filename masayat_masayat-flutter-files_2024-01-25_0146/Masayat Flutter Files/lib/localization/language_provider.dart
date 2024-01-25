import 'dart:convert';

import 'package:http/http.dart' as http;

import '../common/apipath.dart';
import '../localization/language_screen.dart';
import '../localization/language_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  LanguageModel? languageModel;
  Future<void> loadData(BuildContext context, {bool loadScreen = true}) async {
    String url = APIData.language;
    print('Language List Response :-> $url');
    Map<String, String> headers = {
      'Content-Type': 'application/json', // Set the desired content type
    };
    http.Response response = await http.get(Uri.parse(url), headers: headers);

    if (response.statusCode == 200) {
      var responseData = response.body;

      print('Language List Response :-> $responseData');
      languageModel = LanguageModel.fromJson(await jsonDecode(responseData));
      // Load Language Code
      SharedPreferences sharedPreferences =
          await SharedPreferences.getInstance();
      languageCode = sharedPreferences.getString('languageCode');
      languageCode = languageCode == null ? 'en' : languageCode;

      if (loadScreen)
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => LanguageScreen()));
    } else {
      print('Language Response Code :-> ${response.statusCode}');
    }
  }

  String? languageCode;

  Future<void> changeLanguageCode(
      {String? language, BuildContext? context}) async {
    for (Language? _language in (languageModel?.language)!) {
      if (_language?.name == language) {
        languageCode = _language?.local;
        break;
      }
    }
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setString('languageCode', languageCode!);
    await changeLocale(context!, languageCode);
    await Fluttertoast.showToast(
        msg: translate("Language_Changed_Successfully"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.CENTER,
        backgroundColor: Colors.blue,
        textColor: Colors.white,
        fontSize: 16.0);
    notifyListeners();
  }
}
