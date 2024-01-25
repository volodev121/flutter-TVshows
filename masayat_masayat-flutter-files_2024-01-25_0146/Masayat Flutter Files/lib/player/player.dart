import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/episode.dart';
import '/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
//import 'package:wakelock/wakelock.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PlayerMovie extends StatefulWidget {
  PlayerMovie({this.id, this.type});

  final dynamic id;
  final type;

  @override
  _PlayerMovieState createState() => _PlayerMovieState();
}

class _PlayerMovieState extends State<PlayerMovie> with WidgetsBindingObserver {
  WebViewController? _controller1;
  late var playerResponse;
  var status;
  GlobalKey sc = new GlobalKey<ScaffoldState>();
  DateTime? currentBackPressTime;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    super.initState();
    this.loadLocal();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight
    ]);
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.inactive:
        _controller1?.reload();
        break;
      case AppLifecycleState.resumed:
        _controller1?.reload();
        break;
      case AppLifecycleState.paused:
        _controller1?.reload();
        break;
      case AppLifecycleState.detached:
        print("Detached");
        break;
    }
  }

  // void stopScreenLock() async {
  //   Wakelock.enable();
  // }

  //  Handle back press
  Future<bool> onWillPopS() {
    DateTime now = DateTime.now();
    if (currentBackPressTime == null ||
        now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
      currentBackPressTime = now;
      Navigator.pop(context);
      return Future.value(true);
    }
    return Future.value(true);
  }

  Future<String?> loadLocal() async {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    playerResponse = await http.get(widget.type == DatumType.T
        ? Uri.parse(APIData.tvSeriesPlayer +
            '${userDetails!.user!.id}/${userDetails.code}/$ser')
        : Uri.parse(APIData.moviePlayer +
            '${userDetails!.user!.id}/${userDetails.code}/${widget.id}'));
    setState(() {
      status = playerResponse.statusCode;
    });
    var responseUrl = playerResponse.body;
    return responseUrl;
  }

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    print(widget.type == DatumType.T
        ? APIData.tvSeriesPlayer +
            '${userDetails!.user!.id}/${userDetails.code}/$ser'
        : APIData.moviePlayer +
            '${userDetails!.user!.id}/${userDetails.code}/${widget.id}');
    SystemChrome.setPreferredOrientations(
        [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
    double width;
    double height;
    width = MediaQuery.of(context).size.width;
    height = MediaQuery.of(context).size.height;
    JavascriptChannel _toasterJavascriptChannel(BuildContext context) {
      return JavascriptChannel(
          name: 'Toaster',
          onMessageReceived: (JavascriptMessage message) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(message.message)),
            );
          });
    }

    return WillPopScope(
        child: Scaffold(
          key: sc,
          body: Stack(
            children: <Widget>[
              Container(
                width: width,
                height: height,
                child: WebView(
                  initialUrl: widget.type == DatumType.T
                      ? APIData.tvSeriesPlayer +
                          '${userDetails.user!.id}/${userDetails.code}/$ser'
                      : APIData.moviePlayer +
                          '${userDetails.user!.id}/${userDetails.code}/${widget.id}',
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _controller1 = webViewController;
                  },
                  javascriptChannels: <JavascriptChannel>[
                    _toasterJavascriptChannel(context),
                  ].toSet(),
                ),
              ),
              Positioned(
                top: 26.0,
                left: 4.0,
                child: IconButton(
                    icon: Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      _controller1?.reload();
                      Navigator.pop(context);
                    }),
              ),
            ],
          ),
        ),
        onWillPop: onWillPopS);
  }
}
