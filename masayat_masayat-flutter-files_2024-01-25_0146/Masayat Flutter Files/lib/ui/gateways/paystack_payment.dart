// ignore_for_file: unused_field

import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_paystack/flutter_paystack.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/providers/app_config.dart';
import '/providers/payment_key_provider.dart';
import '/providers/user_profile_provider.dart';
import '/ui/screens/splash_screen.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/paystack_paynow_button.dart';
import '/ui/shared/success_ticket.dart';
import '/ui/widgets/credit_card_widget.dart';
import 'package:provider/provider.dart';

// To get started quickly, change this to your heroku deployment of
// https://github.com/PaystackHQ/sample-charge-card-backend
// Step 1. Visit https://github.com/PaystackHQ/sample-charge-card-backend
// Step 2. Click "Deploy to heroku"
// Step 3. Login with your heroku credentials or create a free heroku account
// Step 4. Provide your secret key and an email with which to start all test transactions
// Step 5. Copy the url generated by heroku (format https://some-url.herokuapp.com) into the space below

String backendUrl = 'https://wilbur-paystack.herokuapp.com';

class PaystackPayment extends StatefulWidget {
  PaystackPayment(this.index, this.payAmount);
  final int index;
  final payAmount;
  @override
  _PaystackPaymentState createState() => _PaystackPaymentState();
}

class _PaystackPaymentState extends State<PaystackPayment> {
  final _scaffoldKey = new GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  final _verticalSizeBox = const SizedBox(height: 20.0);
  final _horizontalSizeBox = const SizedBox(width: 10.0);
  final plugin = PaystackPlugin();
  final MaskedTextController _cardNumberController =
      MaskedTextController(mask: '0000 0000 0000 0000');

  int _radioValue = 0;
  bool _inProgress = false;
  String? _cardNumber;
  String? _cvv;
  dynamic _expiryMonth = 0;
  dynamic _expiryYear = 0;
  var amountInNGN;
  var amountInUSD;
  var ref;
  var paystackPaymentResponse;
  var paystackSubscriptionResponse;
  var msgResponse;
  String createdDatePaystack = '';
  String createdTimePaystack = '';
  bool isBack = true;
  bool isShowing = false;
  var ind;

//  Saving payment details to your server so that user details can be updated either user is subscribed or not subscribed.

  Future<String?> sendPaystackDetailsToServer(am, plan1) async {
    final sendResponse =
        await http.post(Uri.parse(APIData.sendPaystackDetails), body: {
      "reference": "$ref",
      "amount": "$am",
      "plan_id": "$plan1",
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    print(sendResponse.statusCode);
    paystackPaymentResponse = json.decode(sendResponse.body);
    msgResponse = paystackPaymentResponse['message'];
    paystackSubscriptionResponse = paystackPaymentResponse['subscription'];
    var date = paystackSubscriptionResponse['created_at'];
    var time = paystackSubscriptionResponse['created_at'];
    createdDatePaystack = DateFormat('d MMM y').format(DateTime.parse(date));
    createdTimePaystack = DateFormat('HH:mm a').format(DateTime.parse(time));

    if (sendResponse.statusCode == 200) {
      setState(() {
        isShowing = false;
      });
      goToDialog(createdDatePaystack, createdTimePaystack, am);
    } else {
      Fluttertoast.showToast(msg: "Your transaction failed.");
    }
    return null;
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
              style: TextStyle(color: Colors.black87),
            ),
            content: Container(
              height: 70.0,
              width: 150.0,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          onWillPop: () async => isBack,
        ),
      );
    }
  }

/*
  After creating successful payment and saving details to server successfully.
  Create a successful dialog
*/
  goToDialog(subdate, time, amount) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => new GestureDetector(
        child: Container(
          color: Colors.black.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SuccessTicket(
                msgResponse: "$msgResponse",
                subDate: "$subdate",
                time: "$time",
                planAmount: "$amount",
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var paymentKey = Provider.of<PaymentKeyProvider>(context, listen: false)
          .paymentKeyModel!;
      if (paymentKey.paystack == "null" ||
          paymentKey.paystack == null ||
          paymentKey.paystack == "") {
        Fluttertoast.showToast(msg: "Key not entered.");
      } else {
        //    plugin.initialize(publicKey: paymentKey.paystack!);
      }
    });
    setState(() {
      isBack = true;
    });
    setState(() {
      isShowing = false;
    });
  }

  Widget paystackLogoContainer() {
    return Container(
      decoration: BoxDecoration(
        color: isLight
            ? Colors.black87
            : Theme.of(context).primaryColorLight.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(50.0),
            child: Image.asset(
              "assets/paystacklogo.png",
              scale: 1.0,
              width: 150.0,
            ),
          )
        ],
      ),
    );
  }

//  Scaffold body contains form to fill card details
  Widget cardDetailsForm() {
    var planDetails = Provider.of<AppConfig>(context).planList;
    var userDetails =
        Provider.of<UserProfileProvider>(context).userProfileModel;
    return Container(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Card(
                  elevation: 8.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  margin:
                      new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
                  child: paystackLogoContainer(),
                ),

                //        UI design for entering card details
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: new TextFormField(
                    keyboardType: TextInputType.number,
                    controller: _cardNumberController,
                    decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Card Number',
                    ),
                    onSaved: (String? value) => _cardNumber = value,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'CVV',
                    ),
                    onSaved: (String? value) => _cvv = value,
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Expiry Month',
                    ),
                    onSaved: (String? value) =>
                        _expiryMonth = int.tryParse(value!),
                  ),
                ),

                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                  child: TextFormField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      border: const OutlineInputBorder(),
                      labelText: 'Expiry Year',
                    ),
                    onSaved: (String? value) =>
                        _expiryYear = int.tryParse(value!),
                  ),
                ),

                _verticalSizeBox,
                _inProgress
                    ? new Container(
                        alignment: Alignment.center,
                        height: 50.0,
                        child: Platform.isIOS
                            ? new CupertinoActivityIndicator()
                            : new CircularProgressIndicator(),
                      )
                    : new Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: <Widget>[
                              _horizontalSizeBox,
                              Flexible(
                                flex: 2,
                                child: Container(
                                    width: double.infinity,
                                    child: PayStackPlatformButton(
                                      'Pay Now',
                                      () {
                                        if (planDetails[widget.index]
                                                .currency !=
                                            "NGN") {
                                          Fluttertoast.showToast(
                                              msg:
                                                  "Paystack supports only NGN currency");
                                        } else {
                                          _handleCheckout(
                                            widget.payAmount == null
                                                ? planDetails[widget.index]
                                                    .amount
                                                : widget.payAmount,
                                            userDetails!.user!.email,
                                            planDetails[widget.index].id,
                                          );
                                        }
                                      },
                                    )),
                              ),
                            ],
                          )
                        ],
                      )
              ],
            ),
          ),
        ));
  }

//  Build method
  @override
  Widget build(BuildContext context) {
    ind = widget.index;
    return WillPopScope(
      child: Scaffold(
        appBar:
            customAppBar(context, "Paystack Payment") as PreferredSizeWidget?,
        key: _scaffoldKey,
        body: cardDetailsForm(),
      ),
      onWillPop: () async => isBack,
    );
  }

//   This will handle all checkout process after tapping on Pay Now button
  _handleCheckout(amount, email, planId) async {
    setState(() {
      isBack = false;
    });
    setState(() => _inProgress = true);
    _formKey.currentState!.save();
    Charge charge = Charge()
      ..amount = (double.parse(amount) ~/ 1)
      ..email = email
      ..card = _getCardFromUI();

    if (!_isLocal()) {
      var accessCode = await _fetchAccessCodeFrmServer(_getReference());
      charge.accessCode = accessCode;
    } else {
      charge.reference = _getReference();
    }

    CheckoutResponse response = await plugin.checkout(context,
        method: CheckoutMethod.card, charge: charge, fullscreen: false);
    ref = response.reference;
    if (response.message == 'Success') {
      setState(() {
        isShowing = true;
      });
      goToDialog2();
      sendPaystackDetailsToServer(amount, planId);
    } else {
      setState(() {
        isBack = true;
        _inProgress = false;
      });
    }
    _updateStatus(response.reference, '$response');
  }

// ignore: unused_element
  String _getReference() {
    String platform;
    if (Platform.isIOS) {
      platform = 'iOS';
    } else {
      platform = 'Android';
    }
    return 'ChargedFrom${platform}_${DateTime.now().millisecondsSinceEpoch}';
  }

  PaymentCard _getCardFromUI() {
    // Using just the must-required parameters.
    return PaymentCard(
      number: _cardNumber,
      cvc: _cvv,
      expiryMonth: _expiryMonth,
      expiryYear: _expiryYear,
    );
  }

// ignore: unused_element
  Future<String?> _fetchAccessCodeFrmServer(String reference) async {
    String url = '$backendUrl/new-access-code';
    String? accessCode;
    try {
      http.Response response = await http.get(Uri.parse(url));
      accessCode = response.body;
    } catch (e) {
      //   setState(() => _inProgress = false);
      _updateStatus(
          reference,
          'There was a problem getting a new access code form'
          ' the backend: $e');
    }

    return accessCode;
  }

  _updateStatus(String? reference, String message) {
    _showMessage('Reference: $reference \n\ Response123: $message',
        const Duration(seconds: 7));
  }

  _showMessage(String message,
      [Duration duration = const Duration(seconds: 4)]) {}

  bool _isLocal() {
    return _radioValue == 0;
  }
}
