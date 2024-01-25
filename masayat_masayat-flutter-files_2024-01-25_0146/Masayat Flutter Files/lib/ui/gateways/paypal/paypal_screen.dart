import 'dart:convert';
import 'dart:io';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/ui/screens/splash_screen.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/success_ticket.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;

class PaypalScreen extends StatefulWidget {
  final String? payId;
  final String? saleId;
  final String? method;
  final String? amount;
  final planIndex;

  PaypalScreen(
      {this.payId, this.saleId, this.method, this.amount, this.planIndex});

  @override
  _PaypalScreenState createState() => _PaypalScreenState();
}

class _PaypalScreenState extends State<PaypalScreen> {
  bool isDataAvailable = true;
  bool isShowing = true;
  bool isBack = false;
  var createdDate;
  var createdTime;

  @override
  void initState() {
    super.initState();
    Future.delayed(Duration(milliseconds: 100), () {
      setState(() {
        isDataAvailable = true;
        isShowing = true;
      });
      goToDialog2();
      _sendDetails(widget.payId, widget.planIndex);
    });
  }

  goToDialog(purDate, time, msgRes) {
    setState(() {
      isDataAvailable = true;
    });
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => new GestureDetector(
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SuccessTicket(
                msgResponse: "$msgRes",
                planAmount: widget.amount,
                subDate: purDate,
                time: time,
              ),
              SizedBox(
                height: 10.0,
              ),
              FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.clear,
                ),
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.splashScreen,
                    arguments: SplashScreen(
                      token: authToken,
                    ),
                  );
                },
              )
            ],
          ),
        ),
      ),
    );
  }

//  Send payment details
  _sendDetails(transactionId, planId) async {
    try {
      final sendResponse =
          await http.post(Uri.parse(APIData.sendRazorDetails), body: {
        "reference": "$transactionId",
        "amount": "${widget.amount}",
        "plan_id": "$planId",
        "status": "1",
        "method": "PayPal",
      }, headers: {
        HttpHeaders.authorizationHeader: "Bearer $authToken",
        "Accept": "application/json"
      });
      var response = json.decode(sendResponse.body);
      if (sendResponse.statusCode == 200) {
        var msgResponse = response['message'];
        var subRes = response['subscription'];
        var date = subRes['created_at'];
        var time = subRes['created_at'];
        createdDate = DateFormat('d MMM y').format(DateTime.parse(date));
        createdTime = DateFormat('HH:mm a').format(DateTime.parse(time));
        setState(() {
          isShowing = false;
        });
        goToDialog(createdDate, createdTime, msgResponse);
      } else {
        setState(() {
          isShowing = false;
        });
        Fluttertoast.showToast(msg: "Your transaction failed.");
      }
    } catch (error) {
      print(error);
    }
  }

  goToDialog2() {
    if (isShowing == true) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => WillPopScope(
              child: AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(
                    Radius.circular(25.0),
                  ),
                ),
                backgroundColor: Colors.white,
                title: Text(
                  "Saving Payment Info",
                  style: TextStyle(color: Color(0xFF3F4654)),
                ),
                content: Container(
                  height: 70.0,
                  width: 150.0,
                  child: Center(
                    child: CircularProgressIndicator(
                      valueColor:
                          new AlwaysStoppedAnimation<Color>(Color(0xFF0284A2)),
                    ),
                  ),
                ),
              ),
              onWillPop: () async => isBack));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "PayPal Payment") as PreferredSizeWidget?,
    );
  }
}
