import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:nexthour/providers/all_user_provider.dart';
import 'package:nexthour/providers/app_config.dart';
import 'package:nexthour/providers/user_profile_provider.dart';
import 'package:nexthour/common/facebook_ads.dart';
import '/common/global.dart';
import '/common/google-ads.dart';
import 'package:provider/provider.dart';
import 'Downloaded_videos.dart';
import 'menu_screen.dart';
import 'search_screen.dart';
import 'wishlist_screen.dart';
import 'home_screen.dart';

class MyBottomNavigationBar extends StatefulWidget {
  MyBottomNavigationBar({this.pageInd});
  final pageInd;

  @override
  _MyBottomNavigationBarState createState() => _MyBottomNavigationBarState();
}

class _MyBottomNavigationBarState extends State<MyBottomNavigationBar> {
  BannerAd? _bannerAd;
  BannerAd? _anchoredBanner;
  bool _loadingAnchoredBanner = false;

  dynamic _selectedIndex;
  static List<Widget> _widgetOptions = <Widget>[
    HomeScreen(),
    SearchScreen(),
    WishListScreen(),
    DownloadedVideos(),
    MenuScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _createAnchoredBanner(BuildContext context) async {
    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getAnchoredAdaptiveBannerAdSize(
      Orientation.portrait,
      MediaQuery.of(context).size.width.truncate() - 10,
    );

    if (size == null) {
      print('Unable to get height of anchored banner.');
      return;
    }

    if (isGoogleAdEnabled) {
      _bannerAd = BannerAd(
        size: size,
        request: request,
        adUnitId: Platform.isAndroid ? bannerAdIDAndroid : bannerAdIDiOS,
        listener: BannerAdListener(
          onAdLoaded: (Ad ad) {
            print('$BannerAd loaded.');
            setState(() {
              _anchoredBanner = ad as BannerAd?;
            });
          },
          onAdFailedToLoad: (Ad ad, LoadAdError error) {
            print('$BannerAd failedToLoad: $error');
            ad.dispose();
          },
          onAdOpened: (Ad ad) => print('$BannerAd onAdOpened.'),
          onAdClosed: (Ad ad) => print('$BannerAd onAdClosed.'),
        ),
      );
      return _bannerAd!.load();
    }
  }

  var userDetails;
  var appconfig;
  @override
  void initState() {
    super.initState();

    Provider.of<AllUsersProvider>(context, listen: false).loadData(context);

    userDetails = Provider.of<UserProfileProvider>(context, listen: false);
    appconfig = Provider.of<AppConfig>(context, listen: false).appModel;
    print("adv status= ${appconfig.appConfig.removeAds}");
    if ((userDetails.userProfileModel!.removeAds == "0" ||
            userDetails.userProfileModel!.removeAds == 0) &&
        (appconfig.appConfig.removeAds == 0 ||
            appconfig.appConfig.removeAds == '0')) {}
    _selectedIndex = widget.pageInd != null ? widget.pageInd : 0;

    initializeFBAd();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if ((userDetails.userProfileModel!.removeAds == "0" ||
            userDetails.userProfileModel!.removeAds == 0) &&
        (appconfig.appConfig.removeAds == 0 ||
            appconfig.appConfig.removeAds == '0')) {
      if (!_loadingAnchoredBanner) {
        _loadingAnchoredBanner = true;
        _createAnchoredBanner(context);
      }
    }

    return WillPopScope(
      child: (userDetails.userProfileModel!.removeAds == "0" ||
                  userDetails.userProfileModel!.removeAds == 0) &&
              (appconfig.appConfig.removeAds == 0 ||
                  appconfig.appConfig.removeAds == '0')
          ? Scaffold(
              backgroundColor: Theme.of(context).primaryColorDark,
              persistentFooterButtons: <Widget>[
                _anchoredBanner != null && isGoogleAdEnabled
                    ? Center(
                        child: Container(
                          alignment: Alignment.center,
                          width: _anchoredBanner!.size.width.toDouble(),
                          height: _anchoredBanner!.size.height.toDouble(),
                          child: AdWidget(ad: _anchoredBanner!),
                        ),
                      )
                    : SizedBox.shrink(),
              ],
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).primaryColorLight,
                selectedIconTheme: Theme.of(context).primaryIconTheme,
                unselectedIconTheme: Theme.of(context).iconTheme,
                selectedItemColor:
                    Theme.of(context).textSelectionTheme.selectionColor,
                unselectedItemColor: Theme.of(context).hintColor,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      label: translate("Home_"), icon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      label: translate("Search_"), icon: Icon(Icons.search)),
                  BottomNavigationBarItem(
                      label: translate("Wishlist_"),
                      icon: Icon(Icons.favorite_border)),
                  BottomNavigationBarItem(
                      label: translate("Download_"),
                      icon: Icon(Icons.file_download)),
                  BottomNavigationBarItem(
                      label: translate("Menu_"), icon: Icon(Icons.menu)),
                ],
                currentIndex: _selectedIndex!,
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
                onTap: _onItemTapped,
              ),
              body: Center(
                child: _widgetOptions.elementAt(_selectedIndex!),
              ))
          : Scaffold(
              backgroundColor: Theme.of(context).primaryColorDark,
              bottomNavigationBar: BottomNavigationBar(
                type: BottomNavigationBarType.fixed,
                backgroundColor: Theme.of(context).primaryColorLight,
                selectedIconTheme: Theme.of(context).primaryIconTheme,
                unselectedIconTheme: Theme.of(context).iconTheme,
                selectedItemColor:
                    Theme.of(context).textSelectionTheme.selectionColor,
                unselectedItemColor: Theme.of(context).hintColor,
                items: <BottomNavigationBarItem>[
                  BottomNavigationBarItem(
                      label: translate("Home_"), icon: Icon(Icons.home)),
                  BottomNavigationBarItem(
                      label: translate("Search_"), icon: Icon(Icons.search)),
                  BottomNavigationBarItem(
                      label: translate("Wishlist_"),
                      icon: Icon(Icons.favorite_border)),
                  BottomNavigationBarItem(
                      label: translate("Download_"),
                      icon: Icon(Icons.file_download)),
                  BottomNavigationBarItem(
                      label: translate("Menu_"), icon: Icon(Icons.menu)),
                ],
                currentIndex: _selectedIndex!,
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.w500),
                onTap: _onItemTapped,
              ),
              body: Center(
                child: _widgetOptions.elementAt(_selectedIndex!),
              ),
            ),
      onWillPop: onWillPopS,
    );
  }
}

// Handle back press to exit
Future<bool> onWillPopS() {
  DateTime now = DateTime.now();
  if (currentBackPressTime == null ||
      now.difference(currentBackPressTime!) > Duration(seconds: 2)) {
    currentBackPressTime = now;
    Fluttertoast.showToast(msg: translate("Press_again_to_exit"));
    return Future.value(false);
  }

  if (Platform.isAndroid) {
    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
    return Future.value(true);
  } else if (Platform.isIOS) {
    return exit(0);
  }
  return exit(0);
}
//}
