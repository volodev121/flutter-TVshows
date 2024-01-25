import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:in_app_update/in_app_update.dart';
import '../../localization/language_provider.dart';
import '../../providers/audio_provider.dart';
import '../../providers/count_view_provider.dart';
import '../../providers/live_event_provider.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/common/global.dart';
import '/providers/app_config.dart';
import '/providers/movie_tv_provider.dart';
import '/providers/user_profile_provider.dart';
import '/ui/screens/multi_screen.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class SplashScreen extends StatefulWidget {
  SplashScreen({this.token});

  final String? token;

  @override
  State<StatefulWidget> createState() {
    return SplashScreenState();
  }
}

class SplashScreenState extends State<SplashScreen> {
  // ignore: unused_field
  String _debugLabelString = "";

  // ignore: unused_field
  bool _enableConsentButton = false;

  bool _flexibleUpdateAvailable = false;
  bool _requireConsent = true;
  GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey();
  late AppUpdateInfo _updateInfo;
  TargetPlatform? platform;
  // @override
  // void initState() {
  //   super.initState();

  //   Future.delayed(Duration.zero, () async {
  //     try {
  //       print('error here');
  //       await getCountry();
  //       print('error');
  //       final result = await InternetAddress.lookup('google.com');
  //       if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
  //         print('connected');
  //         setLocalPath();

  //         checkLoginStatus();
  //       }
  //     } on SocketException catch (_) {
  //       setLocalPath();
  //       Future.delayed(Duration(seconds: 2), () {
  //         Navigator.pushNamed(context, RoutePaths.download);
  //       });
  //       Fluttertoast.showToast(msg: "You’re Offline!");
  //       print('not connected');
  //     }
  //   });
  // }

  @override
  initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      try {
        print('error her');
        // await getCountry();
        print('erroe');
        final result = await InternetAddress.lookup('google.com');
        if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
          print('connected');
          setLocalPath();

          checkLoginStatus();
        }
      } on SocketException catch (_) {
        setLocalPath();
        Future.delayed(Duration(seconds: 2), () {
          Navigator.pushNamed(context, RoutePaths.download);
        });
        Fluttertoast.showToast(msg: "You’re Offline!");
        print('not connected');
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<Null> setLocalPath() async {
    print('sms');
    var deviceLocalPath =
        (await _findLocalPath()) + Platform.pathSeparator + 'Download';
    print('local path: $deviceLocalPath');
    setState(() {
      localPath = deviceLocalPath;
      dLocalPath = deviceLocalPath;
    });
  }

  Future<String> _findLocalPath() async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<void> checkForUpdate() async {
    InAppUpdate.checkForUpdate().then((info) {
      setState(() {
        _updateInfo = info;
      });
    }).catchError((e) => _showError(e));
    if (_updateInfo.updateAvailability == UpdateAvailability.updateAvailable) {
      InAppUpdate.startFlexibleUpdate().then((_) {
        setState(() {
          _flexibleUpdateAvailable = true;
        });
      }).catchError((e) => _showError(e));
    }
    if (!_flexibleUpdateAvailable) {
      InAppUpdate.completeFlexibleUpdate().then((_) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Success!')));
      }).catchError((e) => _showError(e));
    }
  }

  _showError(dynamic exception) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(exception.toString())));
  }

  // For One Signal notification
  Future<void> initPlatformState() async {
    if (!mounted) return;

    OneSignal.shared.setLogLevel(OSLogLevel.verbose, OSLogLevel.none);

    OneSignal.shared.setRequiresUserPrivacyConsent(_requireConsent);

    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      print('NOTIFICATION OPENED HANDLER CALLED WITH: $result');
      this.setState(() {
        _debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });
    OneSignal.shared
        .setNotificationOpenedHandler((OSNotificationOpenedResult result) {
      this.setState(() {
        _debugLabelString =
            "Opened notification: \n${result.notification.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setInAppMessageClickedHandler((OSInAppMessageAction action) {
      this.setState(() {
        _debugLabelString =
            "In App Message Clicked: \n${action.jsonRepresentation().replaceAll("\\n", "\n")}";
      });
    });

    OneSignal.shared
        .setSubscriptionObserver((OSSubscriptionStateChanges changes) {});

    OneSignal.shared
        .setPermissionObserver((OSPermissionStateChanges changes) {});

    OneSignal.shared.setEmailSubscriptionObserver(
        (OSEmailSubscriptionStateChanges changes) {});

    OneSignal.shared.setAppId(APIData.onSignalAppId);

    bool requiresConsent = await OneSignal.shared.requiresUserPrivacyConsent();

    this.setState(() {
      _enableConsentButton = requiresConsent;
    });
    oneSignalInAppMessagingTriggerExamples();
  }

  oneSignalInAppMessagingTriggerExamples() async {
    OneSignal.shared.addTrigger("trigger_1", "one");

    Map<String, Object> triggers = new Map<String, Object>();
    triggers["trigger_2"] = "two";
    triggers["trigger_3"] = "three";
    OneSignal.shared.addTriggers(triggers);

    OneSignal.shared.removeTriggerForKey("trigger_2");

    // ignore: unused_local_variable
    Object triggerValue =
        (await OneSignal.shared.getTriggerValueForKey("trigger_3"))!;
    List<String> keys = [];
    keys.add("trigger_1");
    keys.add("trigger_3");
    OneSignal.shared.removeTriggersForKeys(keys);

    OneSignal.shared.pauseInAppMessages(false);
  }

  // For One Signal permission
  void _handleConsent() {
    OneSignal.shared.consentGranted(true);
    this.setState(() {
      _enableConsentButton = false;
    });
  }

  Widget logoImage(myModel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          child: Image.asset(
            'assets/logo.png',
            fit: BoxFit.cover,
          ),
        )
      ],
    );
  }

  Future checkLoginStatus() async {
    // Loading Languages
    LanguageProvider languageProvider =
        Provider.of<LanguageProvider>(context, listen: false);
    await languageProvider.loadData(context, loadScreen: false);
    changeLocale(context, languageProvider.languageCode);

    print('here-1');
    final appConfig = Provider.of<AppConfig>(context, listen: false);
    await appConfig.getHomeData(context);
    var all;
    if (kIsWeb) {
      all = false;
    } else {
      all = await storage.read(key: "login");
    }

    if (all == "true") {
      _handleConsent();
      initPlatformState();
      var token = await storage.read(key: "authToken");
      setState(() {
        authToken = token;
      });
      final movieTVProvider =
          Provider.of<MovieTVProvider>(context, listen: false);
      await movieTVProvider.getMoviesTVData(context);
      await Provider.of<AudioProvider>(context, listen: false).loadData();
      await Provider.of<LiveEventProvider>(context, listen: false).loadData();
      await Provider.of<CountViewProvider>(context, listen: false).loadData();
      final userProfileProvider =
          Provider.of<UserProfileProvider>(context, listen: false);
      await userProfileProvider.getUserProfile(context);

      var userDetails =
          Provider.of<UserProfileProvider>(context, listen: false);

      if (userDetails.userProfileModel!.active == "1" ||
          userDetails.userProfileModel!.active == 1) {
        if (userDetails.userProfileModel!.payment == "Free") {
          Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
        } else {
          var activeScreen = await storage.read(key: "activeScreen");
          var actScreenCount = await storage.read(key: "screenCount");
          if (activeScreen == null) {
            Navigator.pushNamed(context, RoutePaths.multiScreen);
          } else {
            setState(() {
              myActiveScreen = activeScreen;
              screenCount = actScreenCount;
            });
            getAllScreens();
            Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
          }
        }
      } else {
        Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
      }
    } else {
      if (appConfig.slides.length == 0) {
        Navigator.pushNamed(context, RoutePaths.loginHome);
      } else {
        Navigator.pushNamed(context, RoutePaths.introSlider);
      }
    }
  }

  Future<String?> getAllScreens() async {
    final getAllScreensResponse =
        await http.get(Uri.parse(APIData.showScreensApi), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    if (getAllScreensResponse.statusCode == 200) {
      var screensRes = json.decode(getAllScreensResponse.body);
      setState(() {
        screen1 = screensRes['screen']['screen1'] == null
            ? "Screen1"
            : screensRes['screen']['screen1'];
        screen2 = screensRes['screen']['screen2'] == null
            ? "Screen2"
            : screensRes['screen']['screen2'];
        screen3 = screensRes['screen']['screen3'] == null
            ? "Screen3"
            : screensRes['screen']['screen3'];
        screen4 = screensRes['screen']['screen4'] == null
            ? "Screen4"
            : screensRes['screen']['screen4'];

        activeScreen = screensRes['screen']['activescreen'];
        screenUsed1 = screensRes['screen']['screen_1_used'];
        screenUsed2 = screensRes['screen']['screen_2_used'];
        screenUsed3 = screensRes['screen']['screen_3_used'];
        screenUsed4 = screensRes['screen']['screen_4_used'];
        screenList = [
          ScreenProfile(0, screen1, screenUsed1),
          ScreenProfile(1, screen2, screenUsed2),
          ScreenProfile(2, screen3, screenUsed3),
          ScreenProfile(3, screen4, screenUsed4),
        ];
      });
    } else if (getAllScreensResponse.statusCode == 401) {
      storage.deleteAll();
      Navigator.pushNamed(context, RoutePaths.login);
    } else {
      throw "Can't get screens data";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/splash.png",
            fit: BoxFit.fill,
            height: double.infinity,
            width: double.infinity,
          ),
          Align(
            alignment: FractionalOffset.bottomCenter,
            heightFactor: 10,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  "assets/logo.png",
                  fit: BoxFit.cover,
                ),
                SizedBox(
                  height: 70,
                ),
                CircularProgressIndicator(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
