import 'dart:async';
import 'dart:convert';
import 'dart:developer' as dev;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../providers/audio_provider.dart';
import '../../providers/count_view_provider.dart';
import '../../providers/live_event_provider.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/common/styles.dart';
import '/models/login_model.dart';
import '/providers/app_config.dart';
import '/providers/faq_provider.dart';
import '/providers/login_provider.dart';
import '/providers/movie_tv_provider.dart';
import '/providers/user_profile_provider.dart';
import '/services/firebase_auth.dart';
import '/ui/shared/logo.dart';
import '/ui/widgets/register_here.dart';
import '/ui/widgets/reset_alert_container.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_lwa/lwa.dart';
import 'package:flutter_lwa_platform_interface/flutter_lwa_platform_interface.dart';

LoginWithAmazon _loginWithAmazon = LoginWithAmazon(
  scopes: <Scope>[ProfileScope.profile(), ProfileScope.postalCode()],
);

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = new TextEditingController();
  final TextEditingController _passwordController = new TextEditingController();
  bool _isHidden = true;
  String msg = '';
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool isLoggedIn = false;
  var profileData;
  bool isShowing = false;
  late LoginModel loginModel;

  LwaUser _lwaUser = LwaUser.empty();

  @override
  void initState() {
    super.initState();
    _loginWithAmazon.onLwaAuthorizeChanged.listen((LwaAuthorizeResult auth) {
      setState(() {
        lwaAuth = auth;
      });
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _fetchUserProfile() async {
    if (lwaAuth.isLoggedIn) {
      _lwaUser = await _loginWithAmazon.fetchUserProfile();
      setState(() {
        isShowing = true;
      });
      var email = _lwaUser.userEmail;
      var password = "password";
      var code = _lwaUser.userId;
      var name = _lwaUser.userName;
      print("Amazon details: ${_lwaUser.userEmail}");
      print("Amazon details4: ${_lwaUser.userId}");
      print("Amazon details5: ${_lwaUser.userInfo}");
      print("Amazon details6: ${_lwaUser.userName}");
      print("Amazon details7: ${_lwaUser.userPostalCode}");
      print("Amazon details8: ${_lwaUser.hashCode}");
      goToDialog();
      socialLogin("amazon", email, password, code, name, "code");
    } else {
      _lwaUser = LwaUser.empty();
      print("Amazon details2: $_lwaUser");
    }
    setState(() {
      _lwaUser = _lwaUser;
    });
  }

  Future<void> _handleSignIn(BuildContext context) async {
    try {
      await _loginWithAmazon.signIn();
      _fetchUserProfile();
    } catch (error) {
      if (error is PlatformException) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('${error.message}'),
        ));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(error.toString()),
        ));
      }
    }
  }

  bool get isLoading {
    return false;
  }

  // Initialize login with facebook
  void initiateFacebookLogin() async {
    final LoginResult result = await FacebookAuth.instance.login();

    if (result.status == LoginStatus.success) {
      final AccessToken? accessToken = result.accessToken;

      var graphResponse = await http.get(Uri.parse(
          'https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email,picture.height(200)&access_token=${accessToken!.token}'));

      var profile = json.decode(graphResponse.body);
      setState(() {
        isShowing = true;
      });
      var name = profile['name'];
      var email = profile['email'];
      var code = profile['id'];
      var password = "password";

      print("++Facebook SignIn++");
      print("Name : " + name);
      print("Email : " + email);
      print("ID : " + code);

      goToDialog();
      socialLogin("facebook", email, password, code, name, "code");

      onLoginStatusChanged(true, profileData: profile);
    } else {
      print(result.status);
      print(result.message);
    }
  }

  void onLoginStatusChanged(bool isLoggedIn, {profileData}) {
    setState(() {
      this.isLoggedIn = isLoggedIn;
      this.profileData = profileData;
    });
  }

  Future<String?> socialLogin(
      provider, email, password, code, name, uid) async {
    final accessTokenResponse =
        await http.post(Uri.parse(APIData.socialLoginApi), body: {
      "email": email,
      "password": password,
      "code": code,
      "name": name,
      "provider": provider,
    });
    print(accessTokenResponse.statusCode);
    dev.log(accessTokenResponse.body);
    if (accessTokenResponse.statusCode == 200) {
      loginModel = LoginModel.fromJson(json.decode(accessTokenResponse.body));
      var refreshToken = loginModel.refreshToken!;
      var mToken = loginModel.accessToken!;
      debugPrint("storing-data-started");
      await storage.write(key: "login", value: "true");
      await storage.write(key: "authToken", value: mToken);
      await storage.write(key: "refreshToken", value: refreshToken);
      debugPrint("data-stored");
      print("data-stored");
      setState(() {
        authToken = mToken;
      });
      fetchAppData(context);
    } else {
      setState(() {
        isShowing = false;
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error in login");
    }
    return null;
  }

  Future<void> fetchAppData(ctx) async {
    UserProfileProvider userProfileProvider =
        Provider.of<UserProfileProvider>(ctx, listen: false);
    MovieTVProvider movieTVProvider =
        Provider.of<MovieTVProvider>(ctx, listen: false);
    FAQProvider faqProvider = Provider.of<FAQProvider>(ctx, listen: false);
    await userProfileProvider.getUserProfile(ctx);
    await faqProvider.fetchFAQ(ctx);
    await movieTVProvider.getMoviesTVData(ctx);
    await Provider.of<AudioProvider>(ctx, listen: false).loadData();
    await Provider.of<LiveEventProvider>(ctx, listen: false).loadData();
    await Provider.of<CountViewProvider>(ctx, listen: false).loadData();
    setState(() {
      isShowing = false;
    });
    setState(() {
      isShowing = false;
    });
    Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
  }

  Future<void> _saveForm() async {
    FocusScope.of(context).requestFocus(new FocusNode());
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final isValid = _formKey.currentState!.validate();
    if (!isValid) {
      return;
    }
    _formKey.currentState!.save();
    setState(() {
      _isLoading = true;
    });
    try {
      print("sss1:");
      await loginProvider.login(
          _emailController.text, _passwordController.text, context);
      print("sss2:");
      if (loginProvider.loginStatus == true) {
        print("sss3:");
        final userDetails =
            Provider.of<UserProfileProvider>(context, listen: false)
                .userProfileModel!;
        if (userDetails.payment == "Free") {
          Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
        } else if (userDetails.active == 1 || userDetails.active == "1") {
          Navigator.pushNamed(context, RoutePaths.multiScreen);
        } else {
          Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
        }
      } else if (loginProvider.emailVerify == false) {
        print("sss4:");
        setState(() {
          setState(() {
            _isLoading = false;
            _emailController.text = '';
            _passwordController.text = '';
          });
        });
        showAlertDialog(context, loginProvider.emailVerifyMsg);
      } else {
        print("sss5:");
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(
          msg: "The user credentials were incorrect..!",
          backgroundColor: Colors.red,
          textColor: Colors.white,
          gravity: ToastGravity.BOTTOM,
        );
      }
    } catch (error) {
      print("sss: $error");
      await showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          title: Text(
            'An error occurred!',
            style: TextStyle(
              color: Colors.black.withOpacity(0.7),
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            'Something went wrong',
            style: TextStyle(
              color: Colors.black.withOpacity(0.6),
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color?>(
                  Colors.grey,
                ),
              ),
              child: Text('OK'),
              onPressed: () {
                Navigator.pop(context);
              },
            )
          ],
        ),
      );
    }
    setState(() {
      _isLoading = false;
    });
  }

  showAlertDialog(BuildContext context, String msg) {
    var msg1 = msg.replaceAll('"', "");
    Widget okButton = TextButton(
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color?>(
          primaryBlue,
        ),
      ),
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    AlertDialog alert = AlertDialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      title: Text(
        "Verify Email!",
        textAlign: TextAlign.center,
        style: TextStyle(
            color: primaryBlue, fontSize: 22.0, fontWeight: FontWeight.bold),
      ),
      content: Text("$msg1 Verify email sent on your register email.",
          style: TextStyle(
            color: Theme.of(context).colorScheme.background,
            fontSize: 16.0,
          )),
      actions: [
        okButton,
      ],
    );
    // show the dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
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
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(primaryBlue),
                    ),
                    SizedBox(
                      width: 15.0,
                    ),
                    Text(
                      "Loading ..",
                      style: TextStyle(
                          color: Theme.of(context).colorScheme.background),
                    )
                  ],
                ),
              ),
              onWillPop: () async => false));
    } else {
      Navigator.pop(context);
    }
  }

  resetPasswordAlertBox() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            contentPadding: EdgeInsets.only(top: 10.0),
            content: ResetAlertBoxContainer(),
          );
        });
  }

// Toggle for visibility
  void _toggleVisibility() {
    setState(() {
      _isHidden = !_isHidden;
    });
  }

  Widget msgTitle() {
    return Padding(
      padding: const EdgeInsets.only(
          top: 5.0, bottom: 15.0, left: 25.0, right: 25.0),
      child: Text(
        "Login to watch latest movies TV series, comedy shows and entertainment videos",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget emailField() {
    return Padding(
      padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
      child: TextFormField(
        controller: _emailController,
        validator: (value) {
          if (value!.length == 0) {
            return 'Email can not be empty';
          } else {
            if (!value.contains('@')) {
              return 'Invalid Email';
            } else {
              return null;
            }
          }
        },
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).primaryColor.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          labelText: 'Email',
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding:
          EdgeInsets.only(left: 15.0, right: 15.0, bottom: 10.0, top: 20.0),
      child: TextFormField(
        controller: _passwordController,
        validator: (value) {
          if (value!.length < 6) {
            if (value.length == 0) {
              return 'Password can not be empty';
            } else {
              return 'Password too short';
            }
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.text,
        obscureText: _isHidden == true ? true : false,
        decoration: InputDecoration(
          filled: true,
          fillColor: Theme.of(context).primaryColor.withOpacity(0.05),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10.0),
          ),
          suffixIcon: IconButton(
            onPressed: _toggleVisibility,
            icon: _isHidden
                ? Text(
                    "Show",
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  )
                : Text(
                    "Hide",
                    style: TextStyle(
                      fontSize: 10.0,
                    ),
                  ),
          ),
          labelText: 'Password',
          labelStyle: TextStyle(color: Theme.of(context).primaryColor),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    debugPaintSizeEnabled = false;
    var myModel = Provider.of<AppConfig>(context).appModel == null
        ? null
        : Provider.of<AppConfig>(context).appModel;

    var type = MediaQuery.of(context).size.width;
    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.select): ActivateIntent(),
      },
      child: type > 900
          ? Scaffold(
              body: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        registerHereText(context),
                        logoImage(context, myModel, 0.9, 63.0, 200.0),
                        msgTitle(),
                      ],
                    ),
                  ),
                  Expanded(
                      flex: 1,
                      child: Padding(
                        padding: EdgeInsets.only(right: 20.0),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Form(
                              key: _formKey,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: emailField(),
                                  ),
                                  Expanded(
                                    flex: 1,
                                    child: passwordField(),
                                  )
                                ],
                              ),
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: resetPasswordAlertBox,
                                    child: Text(
                                      'Forgot Password ?',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 20,
                            ),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15.0),
                              child: Row(
                                children: [
                                  Expanded(
                                    flex: 1,
                                    child: ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        backgroundColor: primaryBlue,
                                        padding: EdgeInsets.symmetric(
                                          vertical: 15.0,
                                        ),
                                      ),
                                      child: _isLoading == true
                                          ? SizedBox(
                                              height: 20.0,
                                              width: 20.0,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.0,
                                                valueColor:
                                                    AlwaysStoppedAnimation(
                                                  primaryBlue,
                                                ),
                                              ),
                                            )
                                          : Text(
                                              'SIGN IN',
                                              style: TextStyle(
                                                fontSize: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                      onPressed:
                                          _isLoading == true ? null : _saveForm,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(
                              height: 65.0,
                            ),
                            myModel != null
                                ? myModel.config!.amazonLogin == 1 ||
                                        "${myModel.config!.amazonLogin}" == "1"
                                    ? Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: 15.0,
                                        ),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: <Color>[
                                              Color.fromRGBO(
                                                  255, 232, 170, 1.0),
                                              Color.fromRGBO(246, 200, 74, 1.0)
                                            ],
                                          ),
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(8.0)),
                                          border: Border.all(
                                            color: Color.fromRGBO(
                                                179, 139, 34, 1.0),
                                            width: 2,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: LwaButtonCustom(
                                                onPressed: () =>
                                                    _handleSignIn(context),
                                              ),
                                            )
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink()
                                : SizedBox.shrink(),
                            SizedBox(
                              height: 15.0,
                            ),
                            myModel == null
                                ? SizedBox.shrink()
                                : myModel.config!.googleLogin == 1 ||
                                        "${myModel.config!.googleLogin}" == "1"
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: ButtonTheme(
                                                height: 50.0,
                                                child: ElevatedButton.icon(
                                                  icon: Image.asset(
                                                    "assets/google_logo.png",
                                                    height: 30,
                                                    width: 30,
                                                  ),
                                                  label: Text(
                                                    "Google Sign In",
                                                    style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .background,
                                                        fontSize: 16.0),
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color?>(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    signInWithGoogle().then(
                                                      (result) {
                                                        if (result != null) {
                                                          setState(() {
                                                            isShowing = true;
                                                          });
                                                          var email =
                                                              result.email;
                                                          var password =
                                                              "password";
                                                          var code = result.uid;
                                                          var name = result
                                                              .displayName;
                                                          goToDialog();
                                                          socialLogin(
                                                            "google",
                                                            email,
                                                            password,
                                                            code,
                                                            name,
                                                            "uid",
                                                          );
                                                        }
                                                      },
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink(),
                            SizedBox(
                              height: 15.0,
                            ),
                            myModel == null
                                ? SizedBox.shrink()
                                : myModel.config!.fbLogin == 1 ||
                                        "${myModel.config!.fbLogin}" == "1"
                                    ? Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: Row(
                                          children: [
                                            Expanded(
                                              flex: 1,
                                              child: ButtonTheme(
                                                height: 50.0,
                                                child: ElevatedButton.icon(
                                                  icon: Icon(
                                                    FontAwesomeIcons.facebook,
                                                    color: Colors.white,
                                                    size: 28,
                                                  ),
                                                  label: Text(
                                                    "Facebook Sign In",
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 16.0,
                                                    ),
                                                  ),
                                                  style: ButtonStyle(
                                                    backgroundColor:
                                                        MaterialStateProperty
                                                            .all<Color?>(
                                                      Color.fromRGBO(
                                                          60, 90, 153, 1.0),
                                                    ),
                                                  ),
                                                  onPressed: () {
                                                    initiateFacebookLogin();
                                                  },
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    : SizedBox.shrink(),
                          ],
                        ),
                      ))
                ],
              ),
            )
          : Scaffold(
              backgroundColor: Theme.of(context).primaryColorDark,
              appBar: AppBar(
                leading: BackButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, RoutePaths.loginHome),
                ),
                title: Text(
                  "Login",
                  style: TextStyle(
                    fontSize: 16.0,
                    letterSpacing: 0.9,
                  ),
                ),
                centerTitle: true,
                backgroundColor: Theme.of(context).primaryColorDark,
              ),
              body: Column(
                children: [
                  Flexible(
                    flex: 1,
                    child: Column(
                      children: [
                        Flexible(
                          flex: 1,
                          child: logoImage(context, myModel, 0.9, 63.0, 200.0),
                        ),
                        Flexible(
                          flex: 1,
                          child: msgTitle(),
                        ),
                      ],
                    ),
                  ),
                  Flexible(
                    flex: 4,
                    child: Container(
                      padding: EdgeInsets.only(top: 20.0),
                      decoration: BoxDecoration(
                        color: Theme.of(context).primaryColorLight,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(20.0),
                          topRight: Radius.circular(20.0),
                        ),
                      ),
                      child: ListView(
                        children: [
                          Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                emailField(),
                                passwordField(),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: resetPasswordAlertBox,
                                        child: Text(
                                          'Forgot Password ?',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 20,
                                ),
                                Padding(
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 15.0),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 1,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(5.0)),
                                            backgroundColor:
                                                Theme.of(context).primaryColor,
                                            padding: EdgeInsets.symmetric(
                                                vertical: 15.0),
                                          ),
                                          child: _isLoading == true
                                              ? SizedBox(
                                                  height: 20.0,
                                                  width: 20.0,
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                            primaryBlue),
                                                  ),
                                                )
                                              : Text(
                                                  'SIGN IN',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          onPressed: _isLoading == true
                                              ? null
                                              : _saveForm,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 40.0,
                                ),
                                myModel != null
                                    ? myModel.appConfig!.amazonlogin == 1 ||
                                            "${myModel.appConfig!.amazonlogin}" ==
                                                "1"
                                        ? Container(
                                            margin: EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                            ),
                                            decoration: BoxDecoration(
                                                gradient: LinearGradient(
                                                  begin: Alignment.topCenter,
                                                  end: Alignment.bottomCenter,
                                                  colors: <Color>[
                                                    Color.fromRGBO(
                                                        255, 232, 170, 1.0),
                                                    Color.fromRGBO(
                                                        246, 200, 74, 1.0)
                                                  ],
                                                ),
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                                border: Border.all(
                                                  color: Color.fromRGBO(
                                                      179, 139, 34, 1.0),
                                                  width: 2,
                                                )),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: LwaButtonCustom(
                                                      onPressed: () =>
                                                          _handleSignIn(
                                                              context)),
                                                )
                                              ],
                                            ))
                                        : SizedBox.shrink()
                                    : SizedBox.shrink(),
                                SizedBox(
                                  height: 15.0,
                                ),
                                myModel != null
                                    ? myModel.appConfig!.googleLogin == 1 ||
                                            "${myModel.appConfig!.googleLogin}" ==
                                                "1"
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 15.0),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: ButtonTheme(
                                                    height: 50.0,
                                                    child: ElevatedButton.icon(
                                                      icon: Image.asset(
                                                        "assets/google_logo.png",
                                                        height: 30,
                                                        width: 30,
                                                      ),
                                                      label: Text(
                                                        "Google Sign In",
                                                        style: TextStyle(
                                                            color: Theme.of(
                                                                    context)
                                                                .colorScheme
                                                                .background,
                                                            fontSize: 16.0),
                                                      ),
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color?>(
                                                          Colors.white,
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        if (!_isLoading)
                                                          signInWithGoogle()
                                                              .then(
                                                            (result) {
                                                              if (result !=
                                                                  null) {
                                                                setState(() {
                                                                  isShowing =
                                                                      true;
                                                                });
                                                                var email =
                                                                    result
                                                                        .email;
                                                                var password =
                                                                    "password";
                                                                var code =
                                                                    result.uid;
                                                                var name = result
                                                                    .displayName;
                                                                goToDialog();
                                                                socialLogin(
                                                                    "google",
                                                                    email,
                                                                    password,
                                                                    code,
                                                                    name,
                                                                    "uid");
                                                              }
                                                            },
                                                          );
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink()
                                    : SizedBox.shrink(),
                                SizedBox(
                                  height: 15.0,
                                ),
                                myModel != null
                                    ? myModel.config!.fbLogin == 1 ||
                                            "${myModel.config!.fbLogin}" == "1"
                                        ? Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: 15.0,
                                            ),
                                            child: Row(
                                              children: [
                                                Expanded(
                                                  flex: 1,
                                                  child: ButtonTheme(
                                                    height: 50.0,
                                                    child: ElevatedButton.icon(
                                                      icon: Icon(
                                                        FontAwesomeIcons
                                                            .facebook,
                                                        color: Colors.white,
                                                        size: 28,
                                                      ),
                                                      label: Text(
                                                        "Facebook Sign In",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontSize: 16.0,
                                                        ),
                                                      ),
                                                      style: ButtonStyle(
                                                        backgroundColor:
                                                            MaterialStateProperty
                                                                .all<Color?>(
                                                          Color.fromRGBO(
                                                            60,
                                                            90,
                                                            153,
                                                            1.0,
                                                          ),
                                                        ),
                                                      ),
                                                      onPressed: () {
                                                        if (!_isLoading)
                                                          initiateFacebookLogin();
                                                      },
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox.shrink()
                                    : SizedBox.shrink()
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          registerHereText(context),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

class LwaButtonCustom extends StatefulWidget {
  final VoidCallback onPressed;

  const LwaButtonCustom({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  _LwaButtonCustomState createState() => _LwaButtonCustomState();
}

class _LwaButtonCustomState extends State<LwaButtonCustom> {
  static const String btnImageUnpressed =
      'assets/btnlwa_gold_loginwithamazon.png';
  static const String btnImagePressed =
      'assets/btnlwa_gold_loginwithamazon_pressed.png';
  String _btnImage = btnImageUnpressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (tap) {
        setState(() {
          setState(() {
            _btnImage = btnImagePressed;
          });
        });
      },
      onTapUp: (tap) {
        setState(() {
          setState(() {
            _btnImage = btnImageUnpressed;
          });
        });
      },
      child: Container(
        child: IconButton(
          icon: Image(image: AssetImage(_btnImage)),
          iconSize: 40,
          onPressed: widget.onPressed,
        ),
      ),
    );
  }
}
