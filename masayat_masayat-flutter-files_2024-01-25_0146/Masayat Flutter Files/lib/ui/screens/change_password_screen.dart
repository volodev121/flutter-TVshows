import 'dart:convert';
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/ui/shared/appbar.dart';

class ChangePasswordScreen extends StatefulWidget {
  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController _currentPasswordController =
      new TextEditingController();
  TextEditingController _editNewPasswordController =
      new TextEditingController();
  TextEditingController _editNewConfirmPasswordController =
      new TextEditingController();
  final formKey = new GlobalKey<FormState>();
  bool _isCurrentHidden = true;
  bool _isNewHidden = true;
  bool _isConfirmNewHidden = true;
  bool isShowIndicator = false;

  //  Visibility toggle for current password
  void _toggleVisibility1() {
    setState(() {
      _isCurrentHidden = !_isCurrentHidden;
    });
  }

//  Visibility toggle for new password
  void _toggleVisibility2() {
    setState(() {
      _isNewHidden = !_isNewHidden;
    });
  }

//  Visibility toggle for confirm password
  void _toggleVisibility3() {
    setState(() {
      _isConfirmNewHidden = !_isConfirmNewHidden;
    });
  }

  //  TextField for current password
  Widget buildCurrentPasswordTextField(String hintText) {
    return TextFormField(
      controller: _currentPasswordController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.all(5.0),
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: hintText == translate("Current_Password")
            ? IconButton(
                onPressed: _toggleVisibility1,
                icon: _isCurrentHidden
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
              )
            : null,
      ),
      obscureText:
          hintText == translate("Current_Password") ? _isCurrentHidden : false,
      validator: (val) {
        if (val!.length < 6) {
          if (val.length == 0) {
            return translate("Enter_Current_Password");
          } else {
            return translate("Password_too_short");
          }
        } else {
          return null;
        }
      },
      onSaved: (val) => _currentPasswordController.text = val!,
    );
  }

//  TextField for new password
  Widget buildNewPasswordTextField(String hintText) {
    return TextFormField(
      controller: _editNewPasswordController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.all(5.0),
        prefixIcon: Icon(Icons.lock_outline),
        suffixIcon: hintText == translate("New_Password")
            ? IconButton(
                onPressed: _toggleVisibility2,
                icon: _isNewHidden
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
              )
            : null,
      ),
      obscureText: hintText == translate("New_Password") ? _isNewHidden : false,
      validator: (val) {
        if (val!.length < 6) {
          if (val.length == 0) {
            return translate("Enter_Password");
          } else {
            return translate("Password_too_short");
          }
        } else {
          return null;
        }
      },
      onSaved: (val) => _editNewPasswordController.text = val!,
    );
  }

//  Confirmation of new password field
  Widget buildNewConfirmPasswordTextField(String hintText) {
    return TextFormField(
      controller: _editNewConfirmPasswordController,
      keyboardType: TextInputType.text,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.grey,
          fontSize: 14.0,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.0),
        ),
        contentPadding: EdgeInsets.all(5.0),
        prefixIcon: Icon(Icons.lock),
        suffixIcon: hintText == translate("Confirm_New_Password")
            ? IconButton(
                onPressed: _toggleVisibility3,
                icon: _isConfirmNewHidden
                    ? Icon(Icons.visibility_off)
                    : Icon(Icons.visibility),
              )
            : null,
      ),
      obscureText: hintText == translate("Confirm_New_Password")
          ? _isConfirmNewHidden
          : false,

//      Validation for password
      validator: (val) {
        if (val!.length < 6) {
          if (val.length == 0) {
            return translate('Enter_Password');
          } else {
            return translate('New_Password_too_short');
          }
        } else {
          if (_editNewPasswordController.text == val) {
            return null;
          } else {
            return translate(
                'New_Password_&_Confirm_new_password_does_not_match');
          }
        }
      },
      onSaved: (val) => _editNewConfirmPasswordController.text = val!,
    );
  }

//  Form that containing text fields to update profile
  Widget form() {
    return Container(
      padding:
          EdgeInsets.only(top: 10.0, right: 20.0, left: 20.0, bottom: 20.0),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            buildCurrentPasswordTextField(translate("Current_Password")),
            SizedBox(
              height: 20.0,
            ),
            buildNewPasswordTextField(translate("New_Password")),
            SizedBox(
              height: 20.0,
            ),
            buildNewConfirmPasswordTextField(translate("Confirm_New_Password")),
            SizedBox(
              height: 30.0,
            ),
            updateButtonContainer(),
            SizedBox(
              height: 10.0,
            ),
          ],
        ),
      ),
    );
  }

  //  Update button container
  Widget updateButtonContainer() {
    return InkWell(
      child: Container(
        height: 50.0,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          borderRadius: new BorderRadius.circular(5.0),
          // Box decoration takes a gradient
          gradient: LinearGradient(
            // Where the linear gradient begins and ends
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            // Add one stop for each color. Stops should increase from 0 to 1
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              // Colors are easy thanks to Flutter's Colors class.
              Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
              Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
              Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
              Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
            ],
          ),
          boxShadow: <BoxShadow>[
            new BoxShadow(
              color: Colors.black.withOpacity(0.20),
              blurRadius: 10.0,
              offset: new Offset(1.0, 10.0),
            ),
          ],
        ),
        child: Center(
          child: isShowIndicator == true
              ? CircularProgressIndicator(
                  backgroundColor: Colors.white,
                )
              : Text(
                  translate("Change_Password"),
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14.0,
                  ),
                ),
        ),
      ),
      onTap: () {
        if ((formKey.currentState?.validate())!) {
          formKey.currentState?.save();
          // To remove keypad on tapping button
          FocusScope.of(context).requestFocus(FocusNode());
          setState(() {
            isShowIndicator = true;
          });
          updatePass();
        }
      },
    );
  }

//  Show a dialog after updating password
  Future<void> _profileUpdated(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return WillPopScope(
          child: AlertDialog(
            backgroundColor: Colors.white,
            contentPadding: const EdgeInsets.all(5.0),
            content: Container(
              height: 100.0,
              child: Column(
                children: <Widget>[
                  SizedBox(
                    height: 15.0,
                  ),
                  Text(
                    translate('Your_password_updated'),
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.background),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: <Widget>[
                      TextButton(
                        child: Text(
                          translate('Ok_'),
                          style:
                              TextStyle(fontSize: 16.0, color: activeDotColor),
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          onWillPop: () async => false,
        );
      },
    );
  }

  Future<void> updatePass() async {
    final updateResponse =
        await http.post(Uri.parse(APIData.userProfileUpdate), body: {
      "current_password": _currentPasswordController.text,
      "new_password": _editNewConfirmPasswordController.text,
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    setState(() {
      isShowIndicator = false;
    });
    if (updateResponse.statusCode == 200) {
      _currentPasswordController.text = '';
      _editNewPasswordController.text = '';
      _editNewConfirmPasswordController.text = '';
      _profileUpdated(context);
    } else {
      Fluttertoast.showToast(msg: translate("Password_updating_failed"));
      setState(() {
        isShowIndicator = false;
      });
    }
  }

  void writeToFile(String key, String value) {
    Map<String, String> content = {key: value};
    Map<dynamic, dynamic> jsonFileContent =
        json.decode(jsonFile.readAsStringSync());
    jsonFileContent.addAll(content);
    jsonFile.writeAsStringSync(json.encode(jsonFileContent));

    this.setState(() => fileContent = json.decode(jsonFile.readAsStringSync()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Change_Password"))
          as PreferredSizeWidget?,
      body: form(),
    );
  }
}
