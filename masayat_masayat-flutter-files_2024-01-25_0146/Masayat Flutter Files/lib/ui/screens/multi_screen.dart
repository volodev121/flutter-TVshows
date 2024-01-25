import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:dart_ipify/dart_ipify.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/providers/app_config.dart';
import '/providers/user_profile_provider.dart';
import '/ui/screens/bottom_navigations_bar.dart';
import '/ui/shared/appbar.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class MultiScreen extends StatefulWidget {
  @override
  _MultiScreenState createState() => _MultiScreenState();
}

class _MultiScreenState extends State<MultiScreen> {
  Widget appBar() {
    var appConfig = Provider.of<AppConfig>(context, listen: false).appModel!;
    return AppBar(
      title: Image.network(
        '${APIData.logoImageUri}${appConfig.config!.logo}',
        scale: 1.7,
      ),
      actions: <Widget>[
        IconButton(
          icon: Icon(
            Icons.edit,
            size: 30,
            color: Colors.white,
          ),
          padding: EdgeInsets.only(right: 15.0),
          onPressed: () => Navigator.pushNamed(
            context,
            RoutePaths.createScreen,
          ),
        ),
      ],
      automaticallyImplyLeading: false,
      centerTitle: true,
      backgroundColor: Color.fromRGBO(34, 34, 34, 1.0).withOpacity(0.98),
    );
  }

  Future<void> initPlatformState() async {
    String ipAddress;
    try {
      ipAddress = await Ipify.ipv4();
    } on PlatformException {
      ipAddress = 'Failed to get IP Address.';
    }
    if (!mounted) return;
    setState(() {
      ip = ipAddress;
    });
  }

  updateScreens(screen, count, index) async {
    final updateScreensResponse =
        await http.post(Uri.parse(APIData.updateScreensApi), body: {
      "macaddress": '$ip',
      "screen": '$screen',
      "count": '$count',
    }, headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    if (updateScreensResponse.statusCode == 200) {
      storage.write(
          key: "screenName", value: "${screenList[index].screenName}");
      storage.write(key: "screenStatus", value: "YES");
      storage.write(key: "screenCount", value: "${screenList[index].id + 1}");
      storage.write(
          key: "activeScreen", value: "${screenList[index].screenName}");
      Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
    } else {
      Fluttertoast.showToast(msg: translate("Error_in_selecting_profile"));
      throw "Can't select profile";
    }
  }

  Future<String?> getAllScreens() async {
    final getAllScreensResponse =
        await http.get(Uri.parse(APIData.showScreensApi), headers: {
      'Content-Type': 'application/x-www-form-urlencoded',
      HttpHeaders.authorizationHeader: "Bearer $authToken",
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
      print(getAllScreensResponse.statusCode);
      throw "Can't get screens data";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    this.getAllScreens();
    if (!kIsWeb) {
      initPlatformState();
    }
  }

  bool isShowing = true;
  screenLogout() async {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    setState(() {
      isShowing = false;
    });
    var screenLogOutResponse;

    if (userDetails.active == "1" || userDetails.active == 1) {
      if (userDetails.payment == "Free") {
        print("userDetails1: ${userDetails.active}' '${userDetails.payment}");
        screenLogOutResponse =
            await http.post(Uri.parse(APIData.screenLogOutApi), headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $authToken"
        });
      } else {
        screenLogOutResponse =
            await http.post(Uri.parse(APIData.screenLogOutApi), body: {
          "macaddress": '$ip',
        }, headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $authToken"
        });
      }
    } else {
      print("userDetails3: ${userDetails.active}' '${userDetails.payment}");
      screenLogOutResponse =
          await http.post(Uri.parse(APIData.screenLogOutApi), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        HttpHeaders.authorizationHeader: "Bearer $authToken"
      });
    }

    print('screenLogOutResponse: ${screenLogOutResponse.body}');
    if (screenLogOutResponse.statusCode == 200) {
      setState(() {
        isShowing = true;
      });
      await storage.deleteAll();
      Navigator.pushNamed(context, RoutePaths.loginHome);
    } else {
      setState(() {
        isShowing = true;
      });
      Fluttertoast.showToast(msg: translate("Something_went_wrong_"));
    }
  }

  _signOutDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(25.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: Container(
              width: 300.0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Text(
                        translate("Sign_Out_"),
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Divider(
                    color: Colors.grey,
                    height: 4.0,
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                        left: 30.0, right: 30.0, top: 15.0, bottom: 15.0),
                    child: Text(
                      translate("Are_you_sure_that_you_want_to_logout_"),
                      style:
                          TextStyle(color: Color.fromRGBO(155, 155, 155, 1.0)),
                    ),
                  ),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      color: Colors.white70,
                      padding: EdgeInsets.only(top: 10.0, bottom: 10.0),
                      child: Text(
                        translate("Cancel_"),
                        style:
                            TextStyle(color: Color.fromRGBO(34, 34, 34, 1.0)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      screenLogout();
                    },
                    child: Container(
                      padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25.0),
                            bottomRight: Radius.circular(25.0)),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomRight,
                          stops: [0.1, 0.5, 0.7, 0.9],
                          colors: [
                            Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
                            Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
                            Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
                            Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
                          ],
                        ),
                      ),
                      child: Text(
                        translate("Confirm_"),
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }

  Widget signOut() {
    return InkWell(
        onTap: () {
          _signOutDialog();
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                translate("Sign_Out"),
                textAlign: TextAlign.left,
                style: TextStyle(
                    color: Colors.white70,
                    fontSize: 14.0,
                    fontWeight: FontWeight.w400),
              ),
              SizedBox(
                width: 5.0,
              ),
              Icon(Icons.settings_power, size: 18, color: Colors.white70),
            ],
          ),
        ));
  }

  @override
  Widget build(BuildContext context) {
    var userProfile = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    var userScreenCount;
    if (userProfile!.screen != null) {
      if (userProfile.screen.runtimeType == int) {
        userScreenCount = userProfile.screen;
      } else {
        userScreenCount = int.parse(userProfile.screen);
      }
    }

    return WillPopScope(
      child: Scaffold(
        appBar: customAppBar(context, translate("Select_Profile"))
            as PreferredSizeWidget?,
        body: screenList.length == 0
            ? Center(
                child: CircularProgressIndicator(),
              )
            : Container(
                child: CustomScrollView(
                  slivers: <Widget>[
                    SliverList(
                      delegate: SliverChildListDelegate(
                        [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                margin:
                                    EdgeInsets.only(top: 30.0, bottom: 30.0),
                                child: Text(
                                  translate("Who_s_Watching_"),
                                  style: TextStyle(fontSize: 16.0),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: 40.0),
                      sliver: SliverGrid(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2),
                        delegate: SliverChildBuilderDelegate(
                          (BuildContext context, int index) {
                            return InkWell(
                              child: Container(
                                width: 110.0,
                                height: 110.0,
                                child: Column(
                                  children: <Widget>[
                                    Image.asset(
                                      'assets/avatar.png',
                                      width: 100.0,
                                      height: 80.0,
                                      fit: BoxFit.cover,
                                    ),
                                    SizedBox(
                                      height: 10.0,
                                    ),
                                    Text(
                                      "${screenList[index].screenName}",
                                      style: TextStyle(
                                          fontSize: 12.0,
                                          color: Colors.white.withOpacity(0.7)),
                                    ),
                                  ],
                                ),
                              ),
                              onTap: () {
                                if ("${screenList[index].screenStatus}" ==
                                    "YES") {
                                  Fluttertoast.showToast(
                                    msg: translate("Profile_already_in_use_"),
                                  );
                                } else {
                                  setState(() {
                                    myActiveScreen =
                                        screenList[index].screenName;
                                    screenCount = index + 1;
                                  });
                                  updateScreens(
                                      myActiveScreen, screenCount, index);
                                }
                              },
                            );
                          },
                          childCount: userScreenCount,
                        ),
                      ),
                    ),
                    SliverToBoxAdapter(
                      child: signOut(),
                    )
                  ],
                ),
              ),
      ),
      onWillPop: onWillPopS,
    );
  }
}

class ScreenProfile {
  int id;
  String? screenName;
  String? screenStatus;

  ScreenProfile(this.id, this.screenName, this.screenStatus);
}
