import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexthour/ui/screens/splash_screen.dart';
import 'package:provider/provider.dart';
import '../../common/route_paths.dart';
import '../../common/theme_work.dart';
import '/common/global.dart';
import '/ui/shared/appbar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsScreen extends StatefulWidget {
  @override
  _AppSettingsScreenState createState() => _AppSettingsScreenState();
}

class _AppSettingsScreenState extends State<AppSettingsScreen> {
  late Connectivity connectivity;
  // ignore: cancel_subscriptions
  StreamSubscription<ConnectivityResult>? subscription;

  void _onChanged1(bool value) {
    setState(() {
      boolValue = value;
      addBoolToSF(value);
      print(value);
    });
  }

  Widget wifiTitleText() {
    return Text(
      translate("Wi_Fi_Only"),
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 14.0,
      ),
    );
  }

  Widget leadingWifiListTile() {
    return Container(
      padding: EdgeInsets.only(right: 20.0),
      decoration: BoxDecoration(
        border: Border(
          right: new BorderSide(
            width: 1.0,
            color: Colors.white24,
          ),
        ),
      ),
      child: Icon(
        FontAwesomeIcons.signal,
        size: 20.0,
      ),
    );
  }

  Widget wifiSubtitle() {
    return Container(
      height: 40.0,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: 8.0,
          ),
          Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Text(
                  translate("Play_video_only_when_connected_to_wi_fi"),
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget wifiSwitch() {
    return Switch(
        activeColor: Theme.of(context).primaryColor,
        inactiveThumbColor: Theme.of(context).primaryColor.withOpacity(0.1),
        inactiveTrackColor: Theme.of(context).primaryColorDark,
        value: boolValue!,
        onChanged: _onChanged1);
  }

//    Widget used to create ListTile to show wi-fi status
  Widget makeListTile1() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      leading: leadingWifiListTile(),
      title: wifiTitleText(),
      subtitle: wifiSubtitle(),
      trailing: wifiSwitch(),
    );
  }

  Widget kidsMode() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 5.0,
      ),
      tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      leading: Container(
        padding: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          border: Border(
            right: new BorderSide(
              width: 1.0,
              color: Colors.white24,
            ),
          ),
        ),
        child: Icon(
          FontAwesomeIcons.children,
          size: 25.0,
        ),
      ),
      title: Text(
        translate('Kids_Mode'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
      subtitle: Text(
        translate('Shows_only_kids_contents'),
        style: TextStyle(
          fontSize: 12.0,
        ),
      ),
      trailing: Switch(
        activeColor: Theme.of(context).primaryColor,
        inactiveThumbColor: Theme.of(context).primaryColor.withOpacity(0.1),
        inactiveTrackColor: Theme.of(context).primaryColorDark,
        value: isKidsModeEnabled,
        onChanged: _setKidsModeState,
      ),
    );
  }

  Future<void> _getKidsModeState() async {
    await getKidsModeState();
    setState(() {});
  }

  void _setKidsModeState(bool newValue) {
    setState(() {
      isKidsModeEnabled = newValue;
      prefs.setBool("KidsMode", newValue);
    });
    Future.delayed(Duration(seconds: 1)).then(
      (_) {
        Navigator.pushReplacementNamed(
          context,
          RoutePaths.splashScreen,
          arguments: SplashScreen(
            token: authToken,
          ),
        );
      },
    );
  }

  ThemeProvider? themeProvider;

  Widget darkTheme() {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(
        horizontal: 20.0,
        vertical: 5.0,
      ),
      tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
      leading: Container(
        padding: EdgeInsets.only(right: 20.0),
        decoration: BoxDecoration(
          border: Border(
            right: new BorderSide(
              width: 1.0,
              color: Colors.white24,
            ),
          ),
        ),
        child: Icon(
          isLight ? FontAwesomeIcons.sun : FontAwesomeIcons.moon,
          size: 25.0,
        ),
      ),
      title: Text(
        translate('Switch_Theme'),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16.0,
        ),
      ),
      subtitle: Text(
        translate('Dark & Light'),
        style: TextStyle(
          fontSize: 12.0,
        ),
      ),
      trailing: Switch(
        activeColor: Theme.of(context).primaryColor,
        inactiveThumbColor: Theme.of(context).primaryColor.withOpacity(0.1),
        inactiveTrackColor: Theme.of(context).primaryColorDark,
        value: !isLight,
        onChanged: (state) {
          // setState(() {
          themeProvider!.isDark = state;
          // });
        },
      ),
    );
  }

  Widget scaffold() {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColorDark,
      appBar: customAppBar(context, translate("App_Settings"))
          as PreferredSizeWidget?,
      body: Container(
        margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          children: <Widget>[
            makeListTile1(),
            SizedBox(height: 5.0),
            ListTile(
              contentPadding: EdgeInsets.symmetric(
                horizontal: 20.0,
                vertical: 5.0,
              ),
              tileColor: Theme.of(context).primaryColor.withOpacity(0.1),
              leading: Container(
                padding: EdgeInsets.only(right: 20.0),
                decoration: BoxDecoration(
                  border: Border(
                    right: new BorderSide(
                      width: 1.0,
                      color: Colors.white24,
                    ),
                  ),
                ),
                child: Icon(
                  FontAwesomeIcons.language,
                  size: 25.0,
                ),
              ),
              title: Text(
                translate('Language_'),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16.0,
                ),
              ),
              subtitle: Text(
                translate('Choose_your_App_Language'),
                style: TextStyle(
                  fontSize: 12.0,
                ),
              ),
              onTap: () {
                Navigator.pushNamed(context, RoutePaths.ChooseLanguage);
              },
            ),
            SizedBox(height: 5.0),
            kidsMode(),
            SizedBox(height: 5.0),
            darkTheme(),
          ],
        ),
      ),
    );
  }

//  Used to save value to shared preference of wi-fi switch
  addBoolToSF(value) async {
    prefs = await SharedPreferences.getInstance();
    prefs.setBool('boolValue', value);
  }

//  Used to get saved value from shared preference of wi-fi switch
  getValuesSF() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      boolValue = prefs.getBool('boolValue');
    });
  }

  @override
  void initState() {
    super.initState();
    this.getValuesSF();

    _getKidsModeState();

//    Used to check connection status of use device
    connectivity = new Connectivity();
    subscription =
        connectivity.onConnectivityChanged.listen((ConnectivityResult result) {
      checkConnectionStatus = result.toString();
      if (result == ConnectivityResult.wifi) {
        setState(() {});
      } else if (result == ConnectivityResult.mobile) {
        setState(() {});
      } else if (result == ConnectivityResult.none) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context);

    if (boolValue == null) {
      boolValue = false;
    }
    return scaffold();
  }
}
