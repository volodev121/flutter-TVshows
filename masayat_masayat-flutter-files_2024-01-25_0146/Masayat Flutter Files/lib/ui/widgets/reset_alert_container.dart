import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import 'package:http/http.dart' as http;
import '/ui/screens/forgot_password_screen.dart';

class ResetAlertBoxContainer extends StatefulWidget {
  @override
  _ResetAlertBoxContainerState createState() => _ResetAlertBoxContainerState();
}

class _ResetAlertBoxContainerState extends State<ResetAlertBoxContainer> {
  final formKey1 = new GlobalKey<FormState>();
  final TextEditingController _resetEmailController =
      new TextEditingController();
  final TextEditingController _otpController = new TextEditingController();
  bool hiddenOTP = true;
  bool hiddenEmail = false;

  Widget emailField() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        controller: _resetEmailController,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.only(
            top: 12.0,
            bottom: 5.0,
            left: 2.0,
            right: 2.0,
          ),
          hintText: translate("Enter_Email"),
          hintStyle: TextStyle(fontSize: 12.0),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        validator: (val) {
          if (val!.length == 0) {
            return translate('Email_cannot_be_empty');
          } else {
            if (!val.contains('@')) {
              return translate('Invalid_Email');
            } else {
              return null;
            }
          }
        },
        onSaved: (val) => _resetEmailController.text = val!,
      ),
    );
  }

  Widget otpField() {
    return Padding(
      padding: EdgeInsets.only(left: 30.0, right: 30.0),
      child: TextFormField(
        controller: _otpController,
        decoration: InputDecoration(
          contentPadding:
              EdgeInsets.only(top: 14.0, bottom: 0.0, left: 2.0, right: 2.0),
          hintText: translate("Enter_OTP"),
          suffixIcon: IconButton(
            splashColor: Color.fromRGBO(72, 163, 198, 1.0),
            padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
            icon: Text(
              translate("Resend_"),
              style: TextStyle(color: activeDotColor, fontSize: 10),
            ),
            onPressed: () {
              _emailVisibility();
              sendOtp();
              Fluttertoast.showToast(msg: translate("OTP_Sent"));
            },
          ),
          hintStyle: TextStyle(fontSize: 12.0),
        ),
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    );
  }

// Verify OTP code
  Future<String?> verifyOtp() async {
    final sendOtpResponse = await http.post(APIData.verifyOTPApi, body: {
      "email": _resetEmailController.text,
      "code": _otpController.text,
    });
    print("OTP res: ${sendOtpResponse.statusCode}");
    if (sendOtpResponse.statusCode == 200) {
      Navigator.pushNamed(
        context,
        RoutePaths.forgotPassword,
        arguments: ForgotPassword(
          (_resetEmailController.text),
        ),
      );
    } else {
      Fluttertoast.showToast(msg: translate("Invalid_OTP"));
    }
    return null;
  }

// Send OTP code
  Future<String?> sendOtp() async {
    final sendOtpResponse = await http.post(APIData.forgotPasswordApi, body: {
      "email": _resetEmailController.text,
    });
    print(sendOtpResponse.statusCode);
    print("otp: ${sendOtpResponse.body}");
    if (sendOtpResponse.statusCode == 200) {
      _otpVisibility();
    } else if (sendOtpResponse.statusCode == 401) {
      _emailVisibility();
      Fluttertoast.showToast(msg: translate("Email_address_doesnt_exist"));
    } else {
      Fluttertoast.showToast(msg: translate("Error_in_sending_OTP"));
      _emailVisibility();
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      hiddenOTP = true;
      hiddenEmail = false;
    });
  }

// Toggle for visibility
  void _otpVisibility() {
    setState(() {
      hiddenOTP = !hiddenOTP;
    });
  }

  void _emailVisibility() {
    setState(() {
      hiddenEmail = !hiddenEmail;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300.0,
      child: Form(
        key: formKey1,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  translate("Reset_Password"),
                  style: TextStyle(fontSize: 24.0),
                ),
              ],
            ),
            SizedBox(
              height: 10.0,
            ),
            Divider(
              color: Colors.grey,
              height: 4.0,
            ),
            hiddenEmail ? SizedBox.shrink() : emailField(),
            hiddenOTP ? SizedBox.shrink() : otpField(),
            SizedBox(
              height: 5.0,
            ),
            InkWell(
              child: Container(
                padding: EdgeInsets.only(top: 15.0, bottom: 15.0),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      // Colors are easy thanks to Flutter's Colors class.
                      Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
                      Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
                      Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
                      Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20.0),
                      bottomRight: Radius.circular(20.0)),
                ),
                child: Text(
                  hiddenOTP == true
                      ? translate("Send_OTP")
                      : translate("Reset_Password"),
                  style: TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
              onTap: () {
                if (hiddenOTP == true) {
                  final form = formKey1.currentState!;
                  form.save();
                  if (form.validate() == true) {
                    sendOtp();
                    _emailVisibility();
                  }
                } else {
                  verifyOtp();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
