import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cashfree_pg/cashfree_pg.dart';
import 'package:flutter/material.dart';
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
import 'package:http/http.dart' as http;

class CashfreePayment extends StatefulWidget {
  final int planIndex;
  final payAmount;

  const CashfreePayment({required this.planIndex, this.payAmount});

  @override
  _CashfreePaymentState createState() => _CashfreePaymentState();
}

class _CashfreePaymentState extends State<CashfreePayment> {
  Future<void> loadData() async {
    var planDetails = Provider.of<AppConfig>(context).planList;
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    setState(() {
      name = userDetails!.user!.name;
      email = userDetails.user!.email;
      phone = userDetails.user!.mobile;
      address = '${userDetails.user!.name!}, ${userDetails.user!.mobile}';
      cashfreeAppID = Provider.of<PaymentKeyProvider>(context, listen: false)
          .paymentKeyModel!
          .cashfreeAppID;
      cashfreeSecretKey =
          Provider.of<PaymentKeyProvider>(context, listen: false)
              .paymentKeyModel!
              .cashfreeSecrectID;
      cashfreeApiEndUrl =
          Provider.of<PaymentKeyProvider>(context, listen: false)
              .paymentKeyModel!
              .cashfreeApiEndUrl;

      customerName = "$name";
      customerPhone = "$phone";
      customerEmail = "$email";
      appId = "$cashfreeAppID";
      orderCurrency = "${planDetails[widget.planIndex].currency}";
      orderAmount = widget.payAmount != null
          ? '${widget.payAmount}'
          : '${planDetails[widget.planIndex].amount}';
      orderId = 'CASHFREE-${DateTime.now().microsecondsSinceEpoch}';

      isBack = true;
    });
    generateToken();
  }

  var name, email, phone, address;
  var paymentResponse, createdDate, createdTime;
  var cashfreeAppID, cashfreeSecretKey, cashfreeApiEndUrl;
  bool isShowing = true;
  bool isLoading = true;
  bool isBack = false;
  String? selectedUrl;
  double progress = 0;
  bool generatingToken = false;

  Future<void> generateToken() async {
    print(
        'CashFree App ID :-> $cashfreeAppID, \nCashFree Secret Key :-> $cashfreeSecretKey');

    var response = await http.post(
      Uri.parse(
          "$cashfreeApiEndUrl/api/v2/cftoken/order"), // User api.cashfree.com for production
      headers: {
        "x-client-id": "$cashfreeAppID",
        "x-client-secret": "$cashfreeSecretKey"
      },
      body: jsonEncode({
        "orderId": "$orderId",
        "orderAmount": "$orderAmount",
        "orderCurrency": "$orderCurrency"
      }),
    );
    print('Cashfree Status Code : ${response.statusCode}');
    print('Cashfree Response : ${response.body}');
    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      print('Cashfree Response : $jsonResponse');
      if (jsonResponse['status'] == 'OK') {
        tokenData = jsonResponse['cftoken'];
        setState(() {
          generatingToken = false;
        });
      } else {
        print("CASHFREE STATUS FAILED");
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    loadData();
  }

  var scaffoldKey = GlobalKey<ScaffoldState>();

  //Replace with actual values
  String? orderId;
  String stage = "PROD"; // TEST or PROD
  String? orderAmount;
  String tokenData = "TOKEN_DATA"; // Generated Token.
  String? customerName;
  String orderNote =
      "Order_Note"; // A help text to make customers know more about the order.
  String? orderCurrency;
  String? appId;
  String? customerPhone;
  String? customerEmail;
  String notifyUrl = "https://test.gocashfree.com/notify";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Cashfree Payment") as PreferredSizeWidget,
      body: generatingToken
          ? Center(
              child: CircularProgressIndicator(),
            )
          : _body(),
    );
  }

  Widget logoContainer() {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).primaryColorLight.withOpacity(0.9),
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
              "assets/cashfreelogo.png",
              scale: 1.0,
              width: 150.0,
            ),
          )
        ],
      ),
    );
  }

  Widget makeListTile() {
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
          '${planDetails[widget.planIndex].name}',
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
                        '${planDetails[widget.planIndex].intervalCount}' +
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
                '${planDetails[widget.planIndex].amount} ' +
                '${planDetails[widget.planIndex].currency}')
            : Text("Amount: " +
                '\n' +
                '${widget.payAmount} ' +
                '${planDetails[widget.planIndex].currency}'),
      ]),
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
          children: <Widget>[makeListTile()],
        ),
      ),
    );
  }

  Widget payButtonRow() {
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
                if ((cashfreeAppID == null || cashfreeAppID == '') ||
                    (cashfreeSecretKey == null || cashfreeSecretKey == '')) {
                  Fluttertoast.showToast(
                      msg: "Cashfree App ID or Secret Key is not available.");
                  return;
                } else {
                  makePayment();
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
            child: logoContainer(),
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

  void getUPIApps() {}

  // WEB Intent -
  makePayment() {
    Map<String, dynamic> inputParams = {
      "orderId": orderId,
      "orderAmount": orderAmount,
      "customerName": customerName,
      "orderNote": orderNote,
      "orderCurrency": orderCurrency,
      "appId": appId,
      "customerPhone": customerPhone,
      "customerEmail": customerEmail,
      "stage": stage,
      "tokenData": tokenData,
      "notifyUrl": notifyUrl
    };

    CashfreePGSDK.doPayment(inputParams).then(
      (value) => value?.forEach(
        (key, value) {
          print("$key : $value");
          //Do something with the result
          if ('$key' == 'txStatus') {
            if ('$value' == 'SUCCESS') {
              sendPaymentDetails(orderId, "Cashfree");
            } else {
              Fluttertoast.showToast(
                  msg: "Your transaction ${value.toString().toLowerCase()}.");
            }
          }
        },
      ),
    );
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
              style: TextStyle(
                color: Color(0xFF3F4654),
              ),
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

  goToDialog(subDate, time, message) {
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
                msgResponse: "$message",
                subDate: subDate,
                time: time,
                planAmount: widget.payAmount,
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

  sendPaymentDetails(transactionId, paymentMethod) async {
    try {
      goToDialog2();
      var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
      var amount = planDetails[widget.planIndex].amount;
      var planId = planDetails[widget.planIndex].id;

      var sendResponse = await http.post(
        Uri.parse(
          APIData.sendRazorDetails, // Pending
        ),
        body: {
          "reference": "$transactionId",
          "amount": "$amount",
          "plan_id": "$planId",
          "status": "1",
          "method": "$paymentMethod",
        },
        headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"},
      );

      paymentResponse = json.decode(sendResponse.body);

      var msgResponse = paymentResponse['message'];
      var subscriptionResponse = paymentResponse['subscription'];
      var date = subscriptionResponse['created_at'];
      var time = subscriptionResponse['created_at'];
      createdDate = DateFormat('d MMM y').format(DateTime.parse(date));
      createdTime = DateFormat('HH:mm a').format(DateTime.parse(time));

      if (sendResponse.statusCode == 200) {
        setState(() {
          isShowing = false;
        });
        goToDialog(createdDate, createdTime, msgResponse);
      } else {
        Fluttertoast.showToast(msg: "Your transaction failed!");
        setState(() {
          isShowing = false;
        });
      }
    } catch (error) {}
  }
}
