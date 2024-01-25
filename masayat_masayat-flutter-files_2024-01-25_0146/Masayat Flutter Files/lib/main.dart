import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'common/global.dart';
import 'my_app.dart';
import '/services/repository/database_creator.dart';
import 'package:flutter_translate/flutter_translate.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  await Firebase.initializeApp();
  FlutterDownloader.initialize();
  await DatabaseCreator().initDatabase();

  var delegate = await LocalizationDelegate.create(
      fallbackLocale: 'en', supportedLocales: ['en', 'ar', 'es', 'hi', 'fa']);

  HttpOverrides.global = new MyHttpOverrides();

  authToken = await storage.read(key: "token");
  await getKidsModeState();
  runApp(LocalizedApp(delegate, MyApp(token: authToken)));
}

// Solutions For : HandshakeException: Handshake error in client (CERTIFICATE_VERIFY_FAILED: certificate has expired)
class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) {
        return host == "https://masayat.com" ? true : false;
      };
  }
}
