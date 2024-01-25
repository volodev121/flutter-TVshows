import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
//import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:http/http.dart' as http;

var x;

class PlayerEpisode extends StatefulWidget {
  PlayerEpisode({this.id});
  final dynamic id;

  @override
  _PlayerEpisodeState createState() => _PlayerEpisodeState();
}

class _PlayerEpisodeState extends State<PlayerEpisode>
    with WidgetsBindingObserver {
  WebViewController? _controller1;
  DateTime? currentBackPressTime;

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        print("1000");
        _controller1?.reload();
        screenLogout();
        break;
      case AppLifecycleState.paused:
        print("1001");
        _controller1?.reload();
        screenLogout();
        break;
      case AppLifecycleState.resumed:
        updateScreens(myActiveScreen, fileContent!["screenCount"]);
        print("1003");
        break;
      case AppLifecycleState.detached:
        screenLogout();
        break;
    }
  }

  updateScreens(screen, count) async {
    final updateScreensResponse =
        await http.post(Uri.parse(APIData.updateScreensApi), body: {
      "macaddress": '$ip',
      "screen": '$screen',
      "count": '$count',
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    print(updateScreensResponse.statusCode);
    print(updateScreensResponse.body);
    if (updateScreensResponse.statusCode == 200) {
      print(updateScreensResponse.body);
    }
  }

  //  Handle back press
  Future<bool> onWillPopS() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    print("Back Pressed");
    if (userDetails.payment != "Free") {
      screenLogout();
    }
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Navigator.pop(context);
      return Future.value(true);
    }
    return Future.value(true);
  }

  screenLogout() async {
    //  Wakelock.disable();
    final screenLogOutResponse =
        await http.post(Uri.parse(APIData.screenLogOutApi), body: {
      "screen": '$myActiveScreen',
      "count": '${fileContent!['screenCount']}',
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    print(screenLogOutResponse.statusCode);
    print(screenLogOutResponse.body);

    final accessToken = await http.post(Uri.parse(APIData.loginApi), body: {
      "email": fileContent!['user'],
      "password": fileContent!['pass'],
    });

    if (accessToken.statusCode == 200) {
      var user = json.decode(accessToken.body);
      setState(() {
        authToken = "${user['access_token']}";
      });
    }
  }

  @override
  void initState() {
    super.initState();
    //  stopScreenLock();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    //  Wakelock.disable();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    print(
        "Episode URL: ${APIData.episodePlayer + '${userDetails.user!.id}/${userDetails.code}/${widget.id}'}");
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;

    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    print("player episodes");
    return WillPopScope(
      child: Scaffold(
          body: Stack(
        children: <Widget>[
          Container(
            width: width,
            height: height,
            child: WebView(
              initialUrl: APIData.episodePlayer +
                  '${userDetails.user!.id}/${userDetails.code}/${widget.id}',
              javascriptMode: JavascriptMode.unrestricted,
              onWebViewCreated: (WebViewController webViewController) {
                _controller1 = webViewController;
              },
            ),
          ),
          Positioned(
            top: 26.0,
            left: 4.0,
            child: IconButton(
                icon: Icon(Icons.arrow_back_ios),
                onPressed: () {
                  Navigator.pop(context);
                }),
          ),
        ],
      )),
      onWillPop: onWillPopS,
    );
  }
}

class LocalLoader {
  Future<String> loadLocal(BuildContext context) async {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return await rootBundle.loadString(
        APIData.moviePlayer + '${userDetails.user!.id}/${userDetails.code}/$x');
  }
}
