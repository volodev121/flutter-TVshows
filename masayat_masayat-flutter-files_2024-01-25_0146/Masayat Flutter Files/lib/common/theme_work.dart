import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/common/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyThemePreferences {
  static const THEME_KEY = "theme";

  setTheme(bool value) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    sharedPreferences.setBool(THEME_KEY, value);
  }

  getTheme() async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();
    return sharedPreferences.getBool(THEME_KEY) ?? true;
  }
}

class ThemeProvider extends ChangeNotifier {
  late bool _isDark;
  late MyThemePreferences _preferences;
  bool get isDark => _isDark;

  ThemeProvider() {
    _isDark = true;
    _preferences = MyThemePreferences();
    getPreferences();
  }
  //Switching the themes
  set isDark(bool value) {
    _isDark = value;
    isLight = !_isDark;
    _preferences.setTheme(value);
    _update();
    notifyListeners();
  }

  getPreferences() async {
    _isDark = await _preferences.getTheme();
    isLight = !_isDark;
    _update();
    notifyListeners();
  }

  _update() {
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarBrightness: isLight ? Brightness.light : Brightness.dark,
        systemNavigationBarColor: isLight
            ? buildLightTheme().primaryColorLight
            : buildDarkTheme().primaryColorLight,
        systemNavigationBarIconBrightness:
            isLight ? Brightness.dark : Brightness.light,
        statusBarColor: isLight
            ? buildLightTheme().primaryColorDark
            : buildDarkTheme().primaryColorDark,
        statusBarIconBrightness: isLight ? Brightness.dark : Brightness.light,
      ),
    );
  }
}
