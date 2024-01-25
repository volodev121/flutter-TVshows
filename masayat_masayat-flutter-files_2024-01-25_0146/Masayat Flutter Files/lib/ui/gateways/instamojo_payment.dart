import 'dart:convert';
import 'dart:io';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/common/route_paths.dart';
import 'package:nexthour/providers/app_config.dart';
import 'package:nexthour/providers/payment_key_provider.dart';
import 'package:nexthour/providers/user_profile_provider.dart';
import 'package:nexthour/ui/screens/splash_screen.dart';
import 'package:nexthour/ui/shared/appbar.dart';
import 'package:nexthour/ui/shared/success_ticket.dart';
import 'package:provider/provider.dart';

bool isLoading = true;

class InstamojoPayment extends StatefulWidget {
  final int planIndex;
  final payAmount;
  const InstamojoPayment(this.planIndex, this.payAmount);

  @override
  _InstamojoPaymentState createState() => _InstamojoPaymentState();
}

class _InstamojoPaymentState extends State<InstamojoPayment> {
  String? selectedUrl;
  double progress = 0;
  bool isDataAvailable = true;
  bool isShowing = true;
  bool isBack = false;
  var createdDate;
  var createdTime;

  @override
  void initState() {
    super.initState();
    createRequest(widget.payAmount);
  }

  _sendDetails(transactionId, planId) async {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    var amount = widget.payAmount != null
        ? widget.payAmount
        : planDetails[widget.planIndex].amount;
    print('send details');
    print('transaction id $transactionId');
    try {
      final sendResponse = await http.post(
        Uri.parse(APIData.sendRazorDetails),
        body: {
          "reference": "$transactionId",
          "amount": "$amount",
          "plan_id": "$planId",
          "status": "1",
          "method": "instamojo",
        },
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $authToken",
          "Accept": "application/json"
        },
      );
      print('amount $amount');
      print('send response ${sendResponse.statusCode}');
      var response = json.decode(sendResponse.body);
      print('response body  ${sendResponse.body}');
      print('response ${response.cast<String, dynamic>()}');
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
      print('send details error $error');
    }
  }

  goToDialog(purDate, time, msgRes) {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    var amount = widget.payAmount != null
        ? widget.payAmount
        : planDetails[widget.planIndex].amount;
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
                planAmount: amount,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          customAppBar(context, "InstaMojo Payment") as PreferredSizeWidget?,
      body: Container(
        child: Center(
          child: isLoading
              ? //check loading status
              CircularProgressIndicator() //if true
              : InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: Uri.tryParse(selectedUrl!),
                  ),
                  onWebViewCreated: (InAppWebViewController controller) {},
                  onProgressChanged:
                      (InAppWebViewController controller, int progress) {
                    setState(() {
                      this.progress = progress / 100;
                    });
                  },
                  onUpdateVisitedHistory: (_, Uri? uri, __) {
                    print(uri);
                    // uri contains newly loaded url
                    if (mounted) {
                      String? paymentRequestId =
                          uri!.queryParameters['payment_id'];
                      print("value is: " + paymentRequestId!);
                      //calling this method to check payment status
                      _checkPaymentStatus(paymentRequestId);
                    }
                  },
                ),
        ),
      ),
    );
  }

  _checkPaymentStatus(String id) async {
    var instamojoKey = Provider.of<PaymentKeyProvider>(context, listen: false)
        .paymentKeyModel!;
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    var response = await http
        .get(Uri.parse("${instamojoKey.imurl}payments/$id/"), headers: {
      "Accept": "application/json",
      "Content-Type": "application/x-www-form-urlencoded",
      "X-Api-Key": "${instamojoKey.imapikey}",
      "X-Auth-Token": "${instamojoKey.imauthtoken}"
    });
    var realResponse = json.decode(response.body);
    print(' real response $realResponse');
    if (realResponse['success'] == true) {
      if (realResponse["payment"]['status'] == 'Credit') {
        print('sucesssssssssssful');
        print('transaction id $id');
        print('${planDetails[widget.planIndex].planId}');
        _sendDetails(id, planDetails[widget.planIndex].id);
        // Payment is successful.
      } else {
        print('failed');
        // Payment failed or pending.
      }
    } else {
      print("PAYMENT STATUS FAILED");
    }
  }

  Future createRequest(payAmount) async {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    var instamojoKey = Provider.of<PaymentKeyProvider>(context, listen: false)
        .paymentKeyModel!;
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    Map<String, String> body = {
      "amount": widget.payAmount != null
          ? "${widget.payAmount}"
          : "${planDetails[widget.planIndex].amount}", //amount to be paid
      "purpose": "${planDetails[widget.planIndex].name}",
      "buyer_name": '${userDetails!.user!.name}',
      "email": '${userDetails.user!.email}',
      "phone": '${userDetails.user!.mobile}',
      "allow_repeated_payments": "true",
      "send_email": "true",
      "send_sms": "true",
      "redirect_url": "${APIData.domainLink}payment-successfully",
      //Where to redirect after a successful payment.
      "webhook": "${APIData.domainLink}payment-successfully",
    };
//First we have to create a Payment_Request.
//then we'll take the response of our request.
    print("Instamojo URL :-> ${instamojoKey.imurl}payment-requests/");
    var resp =
        await http.post(Uri.parse("${instamojoKey.imurl}payment-requests/"),
            headers: {
              "Accept": "application/json",
              "Content-Type": "application/x-www-form-urlencoded",
              "X-Api-Key": "${instamojoKey.imapikey}",
              "X-Auth-Token": "${instamojoKey.imauthtoken}"
            },
            body: body);
    print('card ${resp.statusCode}');
    if (json.decode(resp.body)['success'] == true) {
//If request is successful take the longurl.
      setState(() {
        isLoading = false; //setting state to false after data loaded

        selectedUrl =
            json.decode(resp.body)["payment_request"]['longurl'].toString() +
                "?embed=form";
      });
      print('Message :- ${json.decode(resp.body)['message'].toString()}');

//If something is wrong with the data we provided to
//create the Payment_Request. For Example, the email is in incorrect format, the payment_Request creation will fail.
    }
  }
}
