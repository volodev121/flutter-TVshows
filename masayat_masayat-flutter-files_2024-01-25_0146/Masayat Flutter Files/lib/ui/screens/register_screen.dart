import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/common/route_paths.dart';
import '/common/styles.dart';
import '/providers/app_config.dart';
import '/providers/login_provider.dart';
import '/providers/user_profile_provider.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/logo.dart';
import '/ui/widgets/register_here.dart';
import 'package:provider/provider.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _nameController = new TextEditingController();
  TextEditingController _emailController = new TextEditingController();
  TextEditingController _passController = new TextEditingController();
  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = new GlobalKey<FormState>();
  bool _showPassword = false;
  bool _isLoading = false;

// Sign up button

  void _signUp() async {
    setState(() {
      _isLoading = true;
    });
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final form = _formKey.currentState!;
    form.save();
    if (form.validate() == true) {
      try {
        await loginProvider.register(_nameController.text,
            _emailController.text, _passController.text, context);
        if (loginProvider.loginStatus == true) {
          final userDetails =
              Provider.of<UserProfileProvider>(context, listen: false)
                  .userProfileModel!;
          if (userDetails.active == 1 || userDetails.active == "1") {
            if (userDetails.payment == "Free") {
              Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
            } else {
              Navigator.pushNamed(context, RoutePaths.multiScreen);
            }
          } else {
            Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
          }
        } else if (loginProvider.emailVerify == false) {
          setState(() {
            _isLoading = false;
            _nameController.text = '';
            _emailController.text = '';
            _passController.text = '';
          });
          showAlertDialog(context, loginProvider.emailVerifyMsg);
        } else {
          setState(() {
            _isLoading = false;
          });
          print("registratiopn test: ${loginProvider.emailVerifyMsg}");
          Fluttertoast.showToast(
            msg: "${loginProvider.emailVerifyMsg}",
            backgroundColor: Colors.red,
            textColor: Colors.white,
            gravity: ToastGravity.BOTTOM,
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
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
                    Colors.blueAccent,
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
        "Sign Up Successful!",
        textAlign: TextAlign.center,
        style: TextStyle(
          color: primaryBlue,
          fontSize: 22.0,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        "$msg1 Verify your email to continue.",
        style: TextStyle(
          color: Theme.of(context).colorScheme.background,
          fontSize: 16.0,
        ),
      ),
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

  Widget msgTitle() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Text(
        "Register to watch latest movies TV series, comedy shows and entertainment videos",
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget emailField() {
    return Padding(
      padding: EdgeInsets.all(15.0),
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
        keyboardType: TextInputType.emailAddress,
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
          labelStyle: TextStyle(color: Colors.grey[600]!.withOpacity(0.9)),
        ),
      ),
    );
  }

  Widget nameField() {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: TextFormField(
        controller: _nameController,
        validator: (value) {
          if (value!.length < 5) {
            if (value.length == 0) {
              return 'Enter name';
            } else {
              return 'Enter minimum 5 characters';
            }
          } else {
            return null;
          }
        },
        keyboardType: TextInputType.name,
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
          labelText: 'Name',
          labelStyle: TextStyle(color: Colors.grey[600]!.withOpacity(0.9)),
        ),
      ),
    );
  }

  Widget passwordField() {
    return Padding(
      padding: EdgeInsets.all(15.0),
      child: TextFormField(
        controller: _passController,
        obscureText: !this._showPassword,
        validator: (value) {
          if (value!.isEmpty) {
            return 'Please enter your password';
          } else if (value.length < 6) {
            return 'Enter minimum 6 digits';
          } else {
            return null;
          }
        },
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
            icon: Icon(
              Icons.remove_red_eye,
              color: this._showPassword ? primaryBlue : Colors.grey,
            ),
            onPressed: () {
              setState(() => this._showPassword = !this._showPassword);
            },
          ),
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.grey[600]!.withOpacity(0.9)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myModel = Provider.of<AppConfig>(context, listen: false);
    return SafeArea(
        child: Scaffold(
            backgroundColor: Theme.of(context).primaryColorDark,
            appBar: customAppBar(context, "Sign Up") as PreferredSizeWidget?,
            key: scaffoldKey,
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
                                nameField(),
                                emailField(),
                                passwordField(),
                                SizedBox(
                                  height: 30,
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
                                                  child:
                                                      CircularProgressIndicator(
                                                    strokeWidth: 2.0,
                                                    valueColor:
                                                        AlwaysStoppedAnimation(
                                                      Colors.white,
                                                    ),
                                                  ),
                                                )
                                              : Text(
                                                  'SIGN UP',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                          onPressed: () {
                                            FocusScope.of(context)
                                                .requestFocus(new FocusNode());
                                            _signUp();
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 130,
                          ),
                          loginHereText(context),
                          SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    )),
              ],
            )));
  }
}
