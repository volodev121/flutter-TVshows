import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/common/global.dart';
import '/providers/app_config.dart';
import '/providers/main_data_provider.dart';
import '/providers/menu_provider.dart';
import '/providers/slider_provider.dart';
import '/ui/shared/back_press.dart';
import '/ui/screens/video_page.dart';
import '/ui/shared/image_slider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '/common/apipath.dart';
import 'home-screen-shimmer.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late AnimationController animation;
  late Animation<double> _fadeInFadeOut;
  bool loading = true;
  AppConfig myModel = AppConfig();
  MenuProvider menuProvider = MenuProvider();

  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  ScrollController? _scrollViewController;
  FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  TargetPlatform? platform;
  bool? notificationPermission;

  Future<bool> _checkPermission() async {
    if (platform == TargetPlatform.android) {
      PermissionStatus permission = await Permission.notification.status;
      if (permission != PermissionStatus.granted) {
        Map<Permission, PermissionStatus> permissions =
            await [Permission.notification].request();
        if (permissions[Permission.notification] == PermissionStatus.granted) {
          return true;
        }
      } else {
        return true;
      }
    } else {
      return true;
    }
    return false;
  }

  getPermission() async {
    notificationPermission = await _checkPermission();
  }

  @override
  void initState() {
    super.initState();
    getPermission();

    Firebase.initializeApp();
    _firebaseMessaging.getToken().then((value) => print("Token: $value"));

    _scrollViewController = new ScrollController();
    animation = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 1500),
    );
    _fadeInFadeOut = Tween<double>(begin: 0.2, end: 0.8).animate(animation);

    animation.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        animation.reverse();
      } else if (status == AnimationStatus.dismissed) {
        animation.forward();
      }
    });
    animation.forward();
  }

  Future getMenus() async {
    menuProvider = Provider.of<MenuProvider>(context, listen: false);

    myModel = Provider.of<AppConfig>(context, listen: false);
    final sliderProvider = Provider.of<SliderProvider>(context, listen: false);

    MainProvider mainProvider =
        Provider.of<MainProvider>(context, listen: false);
    await menuProvider.getMenus(context);
    await mainProvider.getMainApiData(context);
    await sliderProvider.getSlider();

    List menusItemList = menuProvider.menuList;
    menusItemList.removeWhere(
      (item) {
        return item.name.toString().length == 0;
      },
    );
    return menusItemList;
  }

  @override
  Widget build(BuildContext context) {
    print("menudtalist: ${menuListData.length}");
    if (menuListData.length > 0) {
      return SafeArea(
        child: WillPopScope(
            child: DefaultTabController(
              length: menuListData.length,
              child: Scaffold(
                key: _scaffoldKey,
                body: _scaffoldBody(myModel, menuListData),
                backgroundColor: Theme.of(context).primaryColorDark,
              ),
            ),
            onWillPop: OnBackPress.onWillPopS),
      );
    } else {
      return FutureBuilder(
        future: getMenus(),
        builder: (context, AsyncSnapshot dataSnapshot) {
          if (dataSnapshot.connectionState == ConnectionState.waiting) {
            return safeAreaShimmer();
          } else {
            if (dataSnapshot.error != null) {
              return Center(
                child: Text(translate('An_error_occurred')),
              );
            } else {
              if (dataSnapshot.data != null) {
                menuListData.clear();
                menuListData.insertAll(0, dataSnapshot.data);
              }

              return SafeArea(
                child: WillPopScope(
                    child: DefaultTabController(
                      length: dataSnapshot.data == null
                          ? 0
                          : dataSnapshot.data.length,
                      child: Scaffold(
                        key: _scaffoldKey,
                        body: _scaffoldBody(myModel, dataSnapshot.data),
                        backgroundColor: Theme.of(context).primaryColorDark,
                      ),
                    ),
                    onWillPop: OnBackPress.onWillPopS),
              );
            }
          }
        },
      );
    }
  }

  //  When menu length is 0.
  Widget safeAreaMenuNull() {
    return SafeArea(
      child: Scaffold(body: scaffoldBodyMenuNull()),
    );
  }

  //  Scaffold body when menu length is 0.
  Widget scaffoldBodyMenuNull() {
    return Center(
      child: Text(translate("No_data_Available")),
    );
  }

  //  Sliver app bar
  Widget _sliverAppBar(innerBoxIsScrolled, myModel, menus) {
    bool type = false;
    var dWidth = MediaQuery.of(context).size.width;
    var isPortrait =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (dWidth > 900 || isPortrait) {
      print("is : $isPortrait");
      type = true;
    } else {
      type = false;
    }
    var logo =
        Provider.of<AppConfig>(context, listen: false).appModel!.config!.logo;
    return SliverAppBar(
      elevation: 0.0,
      stretch: true,
      expandedHeight:
          MediaQuery.of(context).size.height * Constants.sliderHeight,
      flexibleSpace: FlexibleSpaceBar(
          stretchModes: [
            StretchMode.zoomBackground,
            StretchMode.blurBackground,
            StretchMode.fadeTitle
          ],
          background: Container(
            child: ImageSlider(),
          )),
      title: Row(
        children: [
          Expanded(
            flex: type == true ? 1 : 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: type == true
                    ? EdgeInsets.only(left: 15.0, right: 15.0)
                    : EdgeInsets.only(left: 5.0, right: 5.0),
                child: Image.network(
                  '${APIData.logoImageUri}$logo',
                  scale: type == true ? 1.8 : 1.6,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/logo.png",
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: type == true ? 4 : 5,
            child: Align(
              alignment: Alignment.centerLeft,
              child: TabBar(
                indicatorSize: TabBarIndicatorSize.tab,
                indicatorColor: Color.fromRGBO(125, 183, 91, 1.0),
                labelStyle: TextStyle(fontWeight: FontWeight.w500),
                // ignore: deprecated_member_use
                labelColor: Theme.of(context).textSelectionTheme.selectionColor,
                unselectedLabelColor: Theme.of(context).hintColor,
                unselectedLabelStyle: TextStyle(fontWeight: FontWeight.w400),
                indicator: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: Colors.transparent,
                      width: 0,
                    ),
                  ),
                ),
                isScrollable: true,
                tabs: List.generate(
                  menus.length,
                  (int index) {
                    return Tab(
                      child: new Container(
                        child: new Text(
                          '${menus[index].name}',
                          style: TextStyle(
                            fontFamily: 'Lato',
                            fontSize: 15.0,
                            letterSpacing: 0.9,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          )
        ],
      ),
      backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.8),
      pinned: true,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      automaticallyImplyLeading: false,
    );
  }

//  Scaffold body
  Widget _scaffoldBody(myModel, menus) {
    return NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          _sliverAppBar(innerBoxIsScrolled, myModel, menus),
        ];
      },
      body: TabBarView(
        children: List<Widget>.generate(
          menus.length,
          (int index) {
            menuId = menus[index].id;
            menuSlug = menus[index].slug;
            return VideosPage(
              loading: false,
              menuId: menuId,
              menuSlug: menuSlug,
            );
          },
        ),
      ),
    );
  }

  //  When menu length is not 0
  Widget safeArea(myModel, menus) {
    return SafeArea(
      child: WillPopScope(
          child: DefaultTabController(
            length: menus == null ? 0 : menus.length,
            child: Scaffold(
              key: _scaffoldKey,
              body: _scaffoldBody(myModel, menus),
              backgroundColor: Theme.of(context).primaryColorDark,
            ),
          ),
          onWillPop: OnBackPress.onWillPopS),
    );
  }

  Widget safeAreaShimmer() {
    return SafeArea(
      child: WillPopScope(
          child: Scaffold(
            key: _scaffoldKey,
            body: _scaffoldBodyShimmer(),
            backgroundColor: Theme.of(context).primaryColorDark,
          ),
          onWillPop: OnBackPress.onWillPopS),
    );
  }

  Widget _scaffoldBodyShimmer() {
    return NestedScrollView(
      controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          _sliverAppBarShimmer(innerBoxIsScrolled),
        ];
      },
      body: HomeScreenShimmer(
        loading: true,
      ),
    );
  }

  Widget _sliverAppBarShimmer(innerBoxIsScrolled) {
    bool type = false;
    var dWidth = MediaQuery.of(context).size.width;
    var isPortrait =
        MediaQuery.of(context).orientation == Orientation.landscape;
    if (dWidth > 900 || isPortrait) {
      print("is : $isPortrait");
      type = true;
    } else {
      type = false;
    }
    return SliverAppBar(
      elevation: 0.0,
      stretch: true,
      expandedHeight:
          MediaQuery.of(context).size.height * Constants.sliderHeight,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: [
          StretchMode.zoomBackground,
          StretchMode.blurBackground,
          StretchMode.fadeTitle
        ],
        background: Container(
          child: FadeTransition(
            opacity: _fadeInFadeOut,
            child: Container(
              padding: const EdgeInsets.only(
                  top: 0.0, bottom: 0.0, left: 0.0, right: 0.0),
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(
                    "assets/placeholder_box.jpg",
                  ),
                  fit: BoxFit.cover,
                  onError: (exception, stackTrace) {
                    Image.asset(
                      "assets/placeholder_box.jpg",
                      fit: BoxFit.cover,
                    );
                  },
                ),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        color: Colors.white,
                        gradient: LinearGradient(
                          begin: FractionalOffset.topCenter,
                          end: FractionalOffset.bottomCenter,
                          colors: [
                            Theme.of(context).primaryColorDark,
                            Colors.transparent,
                            Colors.transparent,
                            Theme.of(context).primaryColorDark,
                          ],
                          stops: [0.02, 0.4, 0.6, 1.0],
                        )),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            flex: type == true ? 1 : 2,
            child: Align(
              alignment: Alignment.centerLeft,
              child: Container(
                margin: type == true
                    ? EdgeInsets.only(left: 15.0, right: 15.0)
                    : EdgeInsets.only(left: 5.0, right: 5.0),
                child: Image.asset(
                  "assets/logo.png",
                  scale: type == true ? 2.2 : 2.0,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      "assets/logo.png",
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Theme.of(context).primaryColorDark.withOpacity(0.8),
      pinned: true,
      floating: true,
      forceElevated: innerBoxIsScrolled,
      automaticallyImplyLeading: false,
    );
  }

  @override
  void dispose() {
    animation.dispose();
    super.dispose();
    _scrollViewController!.dispose();
  }
}
