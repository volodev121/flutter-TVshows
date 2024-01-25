import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/providers/app_config.dart';
import '/providers/payment_key_provider.dart';
import '/providers/user_profile_provider.dart';
import '/ui/screens/splash_screen.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/success_ticket.dart';
import 'package:provider/provider.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class RazorPayment extends StatefulWidget {
  RazorPayment(this.index, this.payAmount);
  final index;
  final payAmount;

  @override
  _RazorPaymentState createState() => _RazorPaymentState();
}

class _RazorPaymentState extends State<RazorPayment> {
  late Razorpay _razorpay;
  bool isBack = false;
  bool isShowing = false;
  var razorResponse;
  var msgResponse;
  var razorSubscriptionResponse;
  String createdDatePaystack = '';
  String createdTimePaystack = '';
  var ind;
  dynamic price;

  Widget makeListTile1() {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      leading: Container(
        padding: EdgeInsets.only(right: 20.0),
        decoration: new BoxDecoration(
          border: new Border(
            right: new BorderSide(
              width: 1.0,
              color: Colors.white24,
            ),
          ),
        ),
        child: Icon(
          FontAwesomeIcons.arrowDownShortWide,
          size: 20.0,
        ),
      ),
      title: Padding(
        padding: EdgeInsets.only(top: 10.0),
        child: Text(
          '${planDetails[widget.index].name}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14.0,
          ),
        ),
      ),
      subtitle: Container(
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
                    'Min duration ' +
                        '${planDetails[widget.index].intervalCount}' +
                        ' days',
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      trailing: Column(children: <Widget>[
        widget.payAmount == null
            ? Text("Amount: " +
                '\n' +
                '${planDetails[widget.index].amount} ' +
                '${planDetails[widget.index].currency}')
            : Text("Amount: " +
                '\n' +
                '${widget.payAmount} ' +
                '${planDetails[widget.index].currency}'),
      ]),
    );
  }

  Widget razorLogoContainer() {
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
              "assets/razorlogo.png",
              scale: 1.0,
              width: 150.0,
            ),
          )
        ],
      ),
    );
  }

  Widget paymentDetailsCard() {
    return Card(
      elevation: 0.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
            color: Theme.of(context).primaryColorLight,
            borderRadius: BorderRadius.circular(10.0)),
        child: ListView(
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          physics: ClampingScrollPhysics(),
          children: <Widget>[makeListTile1()],
        ),
      ),
    );
  }

  Widget _body() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            height: 20.0,
          ),
          Card(
            elevation: 8.0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            margin: new EdgeInsets.symmetric(horizontal: 10.0, vertical: 6.0),
            child: razorLogoContainer(),
          ),
          SizedBox(
            height: 30.0,
          ),
          paymentDetailsCard(),
          SizedBox(
            height: 20.0,
          ),
          Padding(
            padding: EdgeInsets.only(left: 15.0, right: 15.0),
            child: payButtonRow(),
          )
        ],
      ),
    );
  }

  Widget payButtonRow() {
    var razorPayKey =
        Provider.of<PaymentKeyProvider>(context).paymentKeyModel!.razorkey;
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: ButtonTheme(
            height: 45,
            child: ElevatedButton(
              style: ButtonStyle(
                shape: MaterialStateProperty.all<OutlinedBorder?>(
                  RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20.0),
                  ),
                ),
                backgroundColor: MaterialStateProperty.all<Color?>(
                  Color.fromRGBO(72, 163, 198, 1.0),
                ),
              ),
              onPressed: () {
                if (razorPayKey == null) {
                  Fluttertoast.showToast(msg: "Razorpay key not entered.");
                  return;
                } else {
                  openCheckout();
                }
              },
              child: Text(
                "Continue Pay",
                // style: TextStyle(color: Colors.white),
              ),
            ),
          ),
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    ind = widget.index;
    return Scaffold(
      appBar: customAppBar(context, "RazorPay Payment") as PreferredSizeWidget?,
      body: _body(),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isBack = true;
    });
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    super.dispose();
    // _razorpay.clear();
  }

  void openCheckout() async {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    var razorPayKey = Provider.of<PaymentKeyProvider>(context, listen: false)
        .paymentKeyModel!
        .razorkey;
    double cost;
    dynamic amountdata = widget.payAmount == null
        ? planDetails[widget.index].amount
        : widget.payAmount;
    switch (amountdata.runtimeType) {
      case int:
        {
          setState(() {
            price = amountdata;
          });
        }
        break;
      case String:
        {
          setState(() {
            cost = amountdata == null ? 0 : double.parse(amountdata);
            price = cost.round();
          });
        }
        break;
      case double:
        {
          setState(() {
            cost = amountdata == null ? 0 : amountdata;
            price = cost.round();
          });
        }
    }
    var options = {
      'key': razorPayKey,
      'amount': '${price! * 100}',
      'name': APIData.appName,
      'description': planDetails[widget.index].name,
      'external': {
        'wallets': ['paytm']
      },
      'prefill': {'email': '${userDetails!.user!.email}'}
    };

    try {
      // _razorpay.open(options);
    } catch (e) {
      debugPrint("$e");
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
              style: TextStyle(color: Theme.of(context).colorScheme.background),
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
    } else {
      Navigator.pop(context);
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    Fluttertoast.showToast(msg: "SUCCESS: " + response.paymentId!);
    setState(() {
      isShowing = true;
      isBack = false;
    });
    sendRazorDetails(response.paymentId);
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Fluttertoast.showToast(
      msg: "ERROR: " + response.code.toString() + " - " + response.message!,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Fluttertoast.showToast(msg: "EXTERNAL_WALLET: " + response.walletName!);
  }

  goToDialog(subdate, time) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => new GestureDetector(
        child: Container(
          color: Colors.white.withOpacity(0.05),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              SuccessTicket(
                msgResponse: "$msgResponse",
                subDate: "$subdate",
                time: "$time",
                planAmount: "$price",
              ),
              SizedBox(
                height: 10.0,
              ),
              FloatingActionButton(
                backgroundColor: Colors.white,
                child: Icon(
                  Icons.clear,
                  color: Colors.black,
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

  Future<String?> sendRazorDetails(payId) async {
    goToDialog2();
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    var am = planDetails[widget.index].amount;
    var plan1 = planDetails[widget.index].id;

    final sendResponse =
        await http.post(Uri.parse(APIData.sendRazorDetails), body: {
      "reference": "$payId",
      "amount": "$am",
      "plan_id": "$plan1",
      "status": "1",
      "method": "RazorPay",
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken"
    });
    print(sendResponse.statusCode);
    print(sendResponse.body);
    razorResponse = json.decode(sendResponse.body);
    msgResponse = razorResponse['message'];
    razorSubscriptionResponse = razorResponse['subscription'];
    var date = razorSubscriptionResponse['created_at'];
    var time = razorSubscriptionResponse['created_at'];
    createdDatePaystack = DateFormat('d MMM y').format(DateTime.parse(date));
    createdTimePaystack = DateFormat('HH:mm a').format(DateTime.parse(time));

    if (sendResponse.statusCode == 200) {
      setState(() {
        isShowing = false;
      });
      goToDialog(createdDatePaystack, createdTimePaystack);
    } else {
      Fluttertoast.showToast(msg: "Your transaction failed contact to Admin.");
      setState(() {
        isShowing = false;
      });
    }
    return null;
  }
}
