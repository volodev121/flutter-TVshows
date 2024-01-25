import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/models/datum.dart';
import '/models/task_info.dart';
import '/models/todo.dart';
import '/ui/screens/multi_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter_lwa_platform_interface/flutter_lwa_platform_interface.dart';

bool isKidsModeEnabled = false;

Future<void> getKidsModeState() async {
  prefs = await SharedPreferences.getInstance();
  if (prefs.containsKey("KidsMode")) {
    isKidsModeEnabled = prefs.getBool("KidsMode")!;
  } else {
    isKidsModeEnabled = false;
  }
}

String valueToKMB({dynamic value}) {
  if (value > 999 && value < 99999) {
    return "${(value / 1000).toStringAsFixed(1)}K";
  } else if (value >= 99999 && value < 999999) {
    return "${(value / 1000).toStringAsFixed(0)}K";
  } else if (value >= 999999 && value < 999999999) {
    return "${(value / 1000000).toStringAsFixed(1)}M";
  } else if (value >= 999999999) {
    return "${(value / 1000000000).toStringAsFixed(1)}B";
  } else {
    return value.toString();
  }
}

Map<String, String> protectedContentPwd = {};

var authToken;
LwaAuthorizeResult lwaAuth = LwaAuthorizeResult.empty();
List<Datum> tvWishList = [];
List<Datum> moviesWishList = [];
DateTime? currentBackPressTime;
Future<SharedPreferences> prefsTheme = SharedPreferences.getInstance();
final storage = FlutterSecureStorage();
var menuId, menuSlug;
List<Todo> todos = [];
List<ScreenProfile> screenList = [];
Database? database;
List<TaskInfo>? dTasks;
List<ItemHolder>? dItems;
late bool isLoading;
late bool permissionReady;
String? dLocalPath;
late File jsonFile;
late Directory dir;
String fileName = "userJSON.json";
bool fileExists = false;
Map<dynamic, dynamic>? fileContent;
var dCount;
var download;
late SharedPreferences prefs;
var downFileName;
bool? boolValue;
var checkConnectionStatus;
String? dailyAmountAp;
var dailyAmount;
var seasonEpisodeData;
var episodesCount;
var seasonId;
var ser;
var myActiveScreen;
var screenCount;
var screenStatus;
var screenName;
String ip = 'Unknown';
String? localPath;
var activeScreen;
var playerTitle;
var braintreeClientNonce;
var screenUsed1;
var screenUsed2;
var screenUsed3;
var screenUsed4;
var screen1, screen2, screen3, screen4;
late var newSeasonIndex;

List menuListData = [];

bool isLight = false;

Color activeDotColor = const Color.fromRGBO(125, 183, 91, 1.0);

class Constants {
  static const double sliderHeight = 0.50;
  static const double genreListHeight = 60.0;
  static const double genreItemHeight = 60.0;
  static const double genreItemWidth = 150.0;
  static const double genreItemRightMargin = 10.0;
  static const double genreItemLeftMargin = 15.0;
  static const List<Color> gradientRed = [Color(0xFF7EA6F6), Color(0xFF85C3EF)];
  static const List<Color> gradientBlue = [
    Color(0xFFC6428D),
    Color(0xFFD189E2)
  ];
  static const List<Color> gradientGreen = [
    Color(0xFFF09E59),
    Color(0xFFF4AF64)
  ];
  static const List<Color> gradientYellow = [
    Color(0xFF9A80F6),
    Color(0xFFCA7CF2)
  ];
  static const List<Color> gradientPurple = [
    Color(0xFF304C89),
    Color(0xFF648DE5)
  ];
  static const List<Color> gradientPink = [
    Color(0xFF923C01),
    Color(0xFFEF8B47)
  ];
  static const List<Color> gradientOrange = [
    Color(0xFF6202E2),
    Color(0xFFA76AFF)
  ];
  static const List<Color> gradientAmber = [
    Color(0xFF64E2C2),
    Color(0xFF68E8CC)
  ];
  static const List gradientColors = [
    gradientRed,
    gradientBlue,
    gradientGreen,
    gradientYellow,
    gradientPurple,
    gradientPink,
    gradientOrange,
    gradientAmber
  ];

  static final String blogHomeTitle = translate("Our_Blog_Posts");
}
