import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/common/global.dart';

class OnBackPress {
  //  Handle back press
  static Future<bool> onWillPopS() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Fluttertoast.showToast(msg: translate("Press_again_to_exit"));
      return Future.value(false);
    }
    return SystemNavigator.pop() as Future<bool>;
  }
}
