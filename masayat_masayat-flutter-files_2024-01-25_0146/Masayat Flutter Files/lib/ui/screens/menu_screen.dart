import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:launch_review/launch_review.dart';
import 'package:nexthour/ui/screens/subscription_plans.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/providers/user_profile_provider.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '/providers/app_config.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_lwa/lwa.dart';
import 'package:flutter_lwa_platform_interface/flutter_lwa_platform_interface.dart';

LoginWithAmazon _loginWithAmazon = LoginWithAmazon(
  scopes: <Scope>[ProfileScope.profile(), ProfileScope.postalCode()],
);

class MenuScreen extends StatefulWidget {
  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String? platform;
  @override
  void initState() {
    super.initState();
    _loginWithAmazon.onLwaAuthorizeChanged.listen((LwaAuthorizeResult auth) {
      setState(() {
        lwaAuth = auth;
      });
    });
    // _getTheme();
  }

  Future<void> _handleSignOut() async {
    if (lwaAuth.isLoggedIn) {
      setState(() {
        lwaAuth = LwaAuthorizeResult.empty();
      });
      _loginWithAmazon.signOut();
    } else {}
    return;
  }

// user name
  Widget userName(activeUsername) {
    return Text(
      activeUsername,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 14.0,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // Manage Profile
  Widget manageProfile(width, context) {
    return Container(
      width: width,
      color: Theme.of(context).primaryColorLight,
      child: Padding(
        padding: EdgeInsets.only(bottom: 15.0),
        child: InkWell(
          onTap: () => Navigator.pushNamed(context, RoutePaths.manageProfile),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.edit,
                size: 15,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                translate("Manage_Profile"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget profileImage() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Column(
      children: <Widget>[
        Container(
          height: 55.0,
          width: 55.0,
          child: Image.asset(
            "assets/avatar.png",
            scale: 1.7,
            fit: BoxFit.cover,
          ),
          decoration: BoxDecoration(
            border: Border.all(
              color: isLight ? Colors.black54 : Colors.white,
              width: 2.0,
            ),
          ),
        ),
        Text(
          "${userDetails.user!.name}",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  updateScreens(screen, count, index) async {
    final updateScreensResponse =
        await http.post(Uri.parse(APIData.updateScreensApi), body: {
      "macaddress": '$ip',
      "screen": '$screen',
      "count": '$count',
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    print("screen $screen");
    print("count $count");
    print(updateScreensResponse.statusCode);
    if (updateScreensResponse.statusCode == 200) {
      storage.write(
          key: "screenName", value: "${screenList[index].screenName}");
      storage.write(key: "screenStatus", value: "YES");
      storage.write(key: "screenCount", value: "${index + 1}");
      storage.write(
          key: "activeScreen", value: "${screenList[index].screenName}");
    } else {
      Fluttertoast.showToast(msg: translate("Error_in_selecting_profile"));
      throw "Can't select profile";
    }
  }

//  Drawer Header
  Widget drawerHeader(width) {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    var userScreenCount;
    if (userDetails.screen != null) {
      if (userDetails.screen.runtimeType == int) {
        userScreenCount = userDetails.screen;
      } else {
        userScreenCount = int.parse(userDetails.screen!);
      }
    }

    return Container(
      width: width,
      child: DrawerHeader(
        margin: EdgeInsets.fromLTRB(0, 0.0, 0, 0),
        padding: EdgeInsets.all(0.0),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 11.0,
            ),
            userDetails.active == "1" || userDetails.active == 1
                ? userDetails.payment == "Free" || screenList.length == 0
                    ? profileImage()
                    : Expanded(
                        child: Container(
                        height: 100,
                        child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            shrinkWrap: true,
                            physics: ClampingScrollPhysics(),
                            itemCount: userScreenCount,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                child: "${screenList[index].id + 1}" ==
                                        '$screenCount'
                                    ? Column(
                                        children: <Widget>[
                                          Container(
                                            height: 70.0,
                                            margin:
                                                EdgeInsets.only(right: 10.0),
                                            width: 70,
                                            child: userDetails.user!.image !=
                                                    null
                                                ? Image.network(
                                                    "${APIData.profileImageUri}" +
                                                        "${userDetails.user!.image}",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    "assets/avatar.png",
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4.5,
                                                    fit: BoxFit.cover,
                                                  ),
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.white,
                                                width: 1.0,
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          Text(
                                            screenList[index].screenName!,
                                            style: TextStyle(
                                              fontSize: 12.0,
                                            ),
                                          ),
                                        ],
                                      )
                                    : Column(
                                        children: <Widget>[
                                          Container(
                                            margin:
                                                EdgeInsets.only(right: 12.0),
                                            height: 60.0,
                                            width: 60.0,
                                            child: userDetails.user!.image !=
                                                    null
                                                ? Image.network(
                                                    "${APIData.profileImageUri}" +
                                                        "${userDetails.user!.image}",
                                                    fit: BoxFit.cover,
                                                  )
                                                : Image.asset(
                                                    "assets/avatar.png",
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width /
                                                            4.5,
                                                    fit: BoxFit.cover,
                                                  ),
                                          ),
                                          SizedBox(
                                            height: 10.0,
                                          ),
                                          userName(
                                              screenList[index].screenName),
                                        ],
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
                            }),
                      ))
                : profileImage(),
            SizedBox(
              height: 15.0,
            ),
            Container(
              width: width,
              child: Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushNamed(context, RoutePaths.manageProfile);
                  },
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(
                        Icons.edit,
                        size: 15,
                      ),
                      SizedBox(
                        width: 10.0,
                      ),
                      Text(
                        translate("Manage_Profile"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).primaryColorDark,
        ),
      ),
    );
  }

//  Notification
  Widget notification() {
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, RoutePaths.notifications);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.notifications,
                size: 15,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                translate("Notifications_"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 3.0,
          ),
        ),
      ),
    );
  }

//  App settings
  Widget appSettings() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.appSettings);
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Text(
              translate("App_Settings"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  watch  history
  Widget watchHistory() {
    return Container(
      child: InkWell(
        onTap: () {
          Navigator.pushNamed(context, RoutePaths.watchHistory);
        },
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Icon(
                FontAwesomeIcons.solidCirclePlay,
                size: 15,
              ),
              SizedBox(
                width: 10.0,
              ),
              Text(
                translate("Watch_History"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).primaryColorDark,
            width: 3.0,
          ),
        ),
      ),
    );
  }

//  Account
  Widget account() {
    return InkWell(
      onTap: () {
        _onButtonPressed();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Text(
              translate("Manage_Account"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

//  Subscribe
  Widget subscribe() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SubscriptionPlan(),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).primaryColorDark,
              width: 3.0,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 20.0),
          child: Row(
            children: <Widget>[
              Text(
                translate("Manage_Subscription"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//  Help
  Widget help() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.faq);
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Text(
              translate("FAQ_"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Blog
  Widget blog() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, RoutePaths.blogList),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Text(
              translate("Blog_"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Donate
  Widget donate() {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, RoutePaths.donation),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Text(
              translate("Donate_"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Rate Us
  Widget checkForUpdate() {
    return InkWell(
      onTap: () {
        String os = Platform.operatingSystem; //in your code
        if (os == 'android') {
          if (APIData.androidAppId != '') {
            LaunchReview.launch(
              androidAppId: APIData.androidAppId,
            );
          } else {
            Fluttertoast.showToast(
                msg: translate('PlayStore_id_is_not_available'));
          }
        } else {
          if (APIData.iosAppId != '') {
            LaunchReview.launch(
                androidAppId: APIData.androidAppId, iOSAppId: APIData.iosAppId);

            LaunchReview.launch(writeReview: false, iOSAppId: APIData.iosAppId);
          } else {
            Fluttertoast.showToast(
                msg: translate('AppStore_id_is_not_available'));
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Text(
              translate("Rate_Us"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

//  Rate Us
  Widget rateUs() {
    return InkWell(
      onTap: () {
        String os = Platform.operatingSystem; //in your code
        if (os == 'android') {
          if (APIData.androidAppId != '') {
            LaunchReview.launch(
              androidAppId: APIData.androidAppId,
            );
          } else {
            Fluttertoast.showToast(
                msg: translate('PlayStore_id_is_not_available'));
          }
        } else {
          if (APIData.iosAppId != '') {
            LaunchReview.launch(
                androidAppId: APIData.androidAppId, iOSAppId: APIData.iosAppId);

            LaunchReview.launch(writeReview: false, iOSAppId: APIData.iosAppId);
          } else {
            Fluttertoast.showToast(
                msg: translate('AppStore_id_is_not_available'));
          }
        }
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Text(
              translate("Rate_Us"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }

//  Share app
  Widget shareApp() {
    return InkWell(
      onTap: () {
        String os = Platform.operatingSystem; //in your code
        if (os == 'android') {
          if (APIData.androidAppId != '') {
            Share.share(APIData.shareAndroidAppUrl);
          } else {
            Fluttertoast.showToast(
                msg: translate('PlayStore_id_is_not_available'));
          }
        } else {
          if (APIData.iosAppId != '') {
            Share.share(APIData.shareIOSAppUrl);
          } else {
            Fluttertoast.showToast(
                msg: translate('AppStore_id_is_not_available'));
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).primaryColorDark,
              width: 3.0,
            ),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
          child: Row(
            children: <Widget>[
              Text(
                translate("Share_App"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//  Sign Out
  Widget signOut() {
    return InkWell(
      onTap: () {
        _signOutDialog();
      },
      child: Padding(
        padding: EdgeInsets.fromLTRB(20.0, 12.0, 10.0, 12.0),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 8,
              child: Text(
                translate("Sign_Out"),
                textAlign: TextAlign.left,
                style: TextStyle(
                  fontSize: 14.0,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Expanded(
              flex: 1,
              child: Icon(
                Icons.settings_power,
                size: 15,
              ),
            )
          ],
        ),
      ),
    );
  }

  // Bottom Sheet after on tapping account
  Widget _buildBottomSheet() {
    return Container(
      child: Column(
        children: <Widget>[
          ListTile(
            title: Text(translate('Membership_')),
            onTap: () => Navigator.pushNamed(context, RoutePaths.membership),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15.0,
            ),
          ),
          ListTile(
            title: Text(translate('Payment_History')),
            trailing: Icon(
              Icons.arrow_forward_ios,
              size: 15.0,
            ),
            onTap: () {
              Navigator.pushNamed(context, RoutePaths.paymentHistory);
            },
          ),
        ],
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(50.0),
          topRight: const Radius.circular(50.0),
        ),
      ),
    );
  }

  Widget drawer(width, height2) {
    var appConfig = Provider.of<AppConfig>(context, listen: false).appModel!;
    return Drawer(
      elevation: 20.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          drawerHeader(width),
          Expanded(
            child: Container(
              color: Theme.of(context).primaryColorLight,
              child: ListView(
                children: [
                  notification(),
                  watchHistory(),
                  appSettings(),
                  account(),
                  subscribe(),
                  appConfig.config!.donation == 1 ||
                          "${appConfig.config!.donation}" == "1"
                      ? donate()
                      : SizedBox.shrink(),
                  appConfig.blogs!.length != 0 ? blog() : SizedBox.shrink(),
                  help(),
                  rateUs(),
                  shareApp(),
                  signOut(),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    double height = MediaQuery.of(context).size.height;
    double height2 = (height * 76.75) / 100;
    return SizedBox(
      width: width,
      child: drawer(width, height2),
    );
  }

  void _onButtonPressed() {
    showModalBottomSheet(
      context: context,
      builder: (builder) {
        return new Container(
          height: 150.0,
          color: Colors.transparent, //could change this to Color(0xFF737373),
          //so you don't have to change MaterialApp canvasColor
          child: new Container(
            decoration: new BoxDecoration(
              borderRadius: new BorderRadius.only(
                topLeft: const Radius.circular(10.0),
                topRight: const Radius.circular(10.0),
              ),
            ),
            child: _buildBottomSheet(),
          ),
        );
      },
    );
  }

  _signOutDialog() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Color.fromRGBO(34, 34, 34, 1.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(25.0),
              ),
            ),
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
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
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
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          stops: [0.1, 0.3, 0.5, 0.7, 1.0],
                          colors: [
                            Color.fromRGBO(72, 163, 198, 1.0),
                            Color.fromRGBO(30, 157, 207, 25),
                            Color.fromRGBO(27, 162, 187, 50),
                            Color.fromRGBO(32, 163, 173, 75),
                            Color.fromRGBO(37, 164, 160, 100),
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

  bool isShowing = true;

  screenLogout() async {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    setState(() {
      isShowing = false;
    });
    var screenLogOutResponse, screenCount, actScreen;
    final facebookLogin = FacebookAuth.instance;
    final GoogleSignIn googleSignIn = new GoogleSignIn();

    googleSignIn.isSignedIn().then((s) {
      googleSignIn.signOut();
    });

    facebookLogin.logOut();

    _handleSignOut();
    if (userDetails.active == "1" || userDetails.active == 1) {
      if (userDetails.payment == "Free") {
        screenLogOutResponse =
            await http.post(Uri.parse(APIData.screenLogOutApi), headers: {
          "Accept": "application/json",
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $authToken"
        });
      } else {
        screenCount = await storage.read(key: "screenCount");
        actScreen = await storage.read(key: "activeScreen");
        screenLogOutResponse =
            await http.post(Uri.parse(APIData.screenLogOutApi), body: {
          "screen": '$actScreen',
          "count": '$screenCount',
          "macaddress": '$ip',
        }, headers: {
          "Content-Type": "application/x-www-form-urlencoded",
          HttpHeaders.authorizationHeader: "Bearer $authToken"
        });
      }
    } else {
      screenLogOutResponse =
          await http.post(Uri.parse(APIData.screenLogOutApi), headers: {
        "Accept": "application/json",
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

  goToDialog() {
    if (isShowing == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
          child: AlertDialog(
            backgroundColor: Colors.white,
            title: Row(
              children: [
                CircularProgressIndicator(
                  valueColor: new AlwaysStoppedAnimation<Color>(
                    Theme.of(context).colorScheme.background,
                  ),
                ),
                SizedBox(
                  width: 15.0,
                ),
                Text(
                  translate("Loading_"),
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.background),
                )
              ],
            ),
          ),
          onWillPop: () async => false,
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }
}
