import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import '../../common/global.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/providers/app_config.dart';
import '/ui/shared/logo.dart';
import 'package:provider/provider.dart';
import 'bottom_navigations_bar.dart';

DateTime? currentBackPressTime;

class LoginHome extends StatefulWidget {
  @override
  _LoginHomeState createState() => _LoginHomeState();
}

class _LoginHomeState extends State<LoginHome> {
  bool _visible = false;
  bool isLoggedIn = false;
  var profileData;

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  Widget welcomeTitle() {
    return Consumer<AppConfig>(builder: (context, myModel, child) {
      return myModel.title != null
          ? Text(
              translate("Welcome_to") +
                  ' ' +
                  "${myModel.appModel!.config!.title}",
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.w600,
                  fontFamily: "AvenirNext",
                  color: Theme.of(context).primaryColor),
            )
          : Text("");
    });
  }

//  Register button
  Widget registerButton() {
    return ListTile(
      title: MaterialButton(
        height: 50.0,
        color: Colors.white,
        textColor: Colors.black,
        child: new Text(translate("Register_")),
        onPressed: () => Navigator.pushNamed(context, RoutePaths.register),
      ),
    );
  }

//  Setting background design of login button
  Widget loginButton() {
    return MaterialButton(
      height: 50.0,
      textColor: Colors.white,
      child: new Text(translate("Login_")),
      onPressed: () => Navigator.pushNamed(context, RoutePaths.login),
    );
  }

  Widget loginListTile() {
    return ListTile(
        title: Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          // Where the linear gradient begins and ends
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          // Add one stop for each color. Stops should increase from 0 to 1
          stops: [0.1, 0.3, 0.5, 0.7, 1.0],
          colors: [
            // Colors are easy thanks to Flutter's Colors class.
            Color.fromRGBO(198, 72, 72, 1.0),
            Color.fromRGBO(30, 157, 207, 25),
            Color.fromRGBO(27, 162, 187, 50),
            Color.fromRGBO(32, 163, 173, 75),
            Color.fromRGBO(37, 164, 160, 100),
          ],
        ),
      ),
      child: loginButton(),
    ));
  }

// If you get HTML tag in copy right text
  Widget html() {
    return Consumer<AppConfig>(builder: (context, myModel, child) {
      print("${myModel.appModel!.config!.copyright}");
      return HtmlWidget("${myModel.appModel!.config!.copyright}",
          customStylesBuilder: (element) {
        return {'text-align': 'center'};
      });
    });
  }

// Copyright text
  Widget copyRightTextContainer(myModel) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: new Align(
        alignment: FractionalOffset.bottomCenter,
        heightFactor: 100,
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  //    For setting copyright text on the login page
                  myModel == null
                      ? SizedBox.shrink()
                      :
                      // If you get HTML tag in copy right text
                      html(),
                  SizedBox(
                    height: 10.0,
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }

// Background image filter
  Widget imageBackDropFilter() {
    return BackdropFilter(
      filter: new ImageFilter.blur(sigmaX: 3.0, sigmaY: 3.0),
      child: new Container(
        decoration: new BoxDecoration(color: Colors.black.withOpacity(0.0)),
      ),
    );
  }

// ListView contains buttons and logo
  Widget listView(myModel) {
    return ListView(
      children: <Widget>[
        SizedBox(
          height: 100.0,
        ),
        AnimatedOpacity(
/*
  If the widget is visible, animate to 0.0 (invisible).
  If the widget is hidden, animate to 1.0 (fully visible).
*/
          opacity: _visible == true ? 1.0 : 0.0,
          duration: Duration(milliseconds: 500),

/*
For setting logo image that is accessed from the server using API.
You can change logo by server
*/
          child: logoImage(context, myModel, 0.9, 100.0, 250.0),
        ),
        SizedBox(
          height: 20.0,
        ),
/*
  For setting title on the Login or registration page that is accessed from the server using API.
  You can change this title by server
*/
        welcomeTitle(),
        SizedBox(
          height: 5.0,
        ),
        Text(
          translate("Sign_in_to_continue"),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isLight ? Colors.white : Colors.grey,
          ),
        ),
        SizedBox(
          height: 50.0,
        ),
        loginListTile(),
        SizedBox(
          height: 5.0,
        ),
        registerButton(),
      ],
    );
  }

//Overall this page in Stack
  Widget stack(myModel) {
    final logo = Provider.of<AppConfig>(context, listen: false).appModel!;
    return Stack(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
//   For setting background color of loading screen.

            color: Theme.of(context).primaryColorLight,
            image: new DecorationImage(
              fit: BoxFit.cover,
              colorFilter: new ColorFilter.mode(
                Colors.black.withOpacity(0.4),
                BlendMode.dstATop,
              ),
/*
  For setting logo image that is accessed from the server using API.
  You can change logo by server
*/
              image: NetworkImage(
                '${APIData.loginImageUri}${logo.loginImg!.image}',
              ),
            ),
          ),
          child: imageBackDropFilter(),
        ),
        listView(myModel),
        copyRightTextContainer(myModel),
      ],
    );
  }

// WillPopScope to handle app exit
  Widget willPopScope(myModel) {
    return WillPopScope(
      child: Container(
          child: Center(
        child: stack(myModel),
      )),
      onWillPop: onWillPopS,
    );
  }

  void initState() {
    super.initState();
    Timer(Duration(seconds: 2), () {
      setState(() {
        _visible = true;
      });
    });
  }

// build method
  @override
  Widget build(BuildContext context) {
    final myModel = Provider.of<AppConfig>(context).appModel;
    return Scaffold(
      body: myModel == null
          ? Center(
              child: CircularProgressIndicator(),
            )
          : willPopScope(myModel),
    );
  }
}
