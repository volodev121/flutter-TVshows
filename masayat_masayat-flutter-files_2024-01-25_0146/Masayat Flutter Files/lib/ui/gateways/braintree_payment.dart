import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/providers/app_config.dart';
import '/ui/screens/splash_screen.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/success_ticket.dart';
import 'package:provider/provider.dart';
import 'package:flutter_braintree/flutter_braintree.dart';

class BraintreePaymentScreen extends StatefulWidget {
  BraintreePaymentScreen(this.planIndex, this.payAmount);
  final int planIndex;
  final payAmount;
  @override
  _BraintreePaymentScreenState createState() => _BraintreePaymentScreenState();
}

class _BraintreePaymentScreenState extends State<BraintreePaymentScreen> {
  var nonceStatus;
  var noncePayment;
  var msgResponse;
  String createdDate = '';
  String createdTime = '';
  var paymentResponse;
  var subscriptionResponse;
  bool isShowing = false;
  bool isBack = true;
  var ind;

//  Generating client nonce from braintree to access payment services
  Future<String?> getClientNonce() async {
    setState(() {
      isBack = false;
    });
    setState(() {
      isShowing = true;
    });

    Fluttertoast.showToast(msg: "Don't press back button.");
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    try {
      final clientTokenResponse = await http.get(
          Uri.parse(APIData.clientNonceApi),
          headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
      var resBody = json.decode(clientTokenResponse.body);
      if (clientTokenResponse.statusCode == 200) {
        braintreeClientNonce = resBody['client'];
        print("ksmnkks2: $resBody");
        var request = BraintreeDropInRequest(
          tokenizationKey: braintreeClientNonce,
          collectDeviceData: true,
          googlePaymentRequest: BraintreeGooglePaymentRequest(
            totalPrice: widget.payAmount != null
                ? "${widget.payAmount}"
                : "${planDetails[widget.planIndex].amount}",
            currencyCode: "${planDetails[widget.planIndex].currency}",
            billingAddressRequired: false,
          ),
          paypalRequest: BraintreePayPalRequest(
            amount: widget.payAmount != null
                ? "${widget.payAmount}"
                : "${planDetails[widget.planIndex].amount}",
            displayName: 'App User',
          ),
          cardEnabled: true,
        );
        final result = await BraintreeDropIn.start(request);
        if (result != null) {
          payNow(result.paymentMethodNonce);
        } else {
          setState(() {
            isBack = true;
            isShowing = false;
          });
        }
      } else {
        setState(() {
          isBack = true;
          isShowing = false;
        });
      }
    } catch (e) {
      print("ksmnkks: $e");
      setState(() {
        isBack = true;
        isShowing = false;
      });
    }

    return null;
  }

  // Alert dialog to save show progress
  Widget alertUploadingDetails() {
    return WillPopScope(
        child: AlertDialog(
          backgroundColor: Colors.white,
          content: Container(
            height: 100.0,
            width: 200.0,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  "Uploading Details...",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.background,
                  ),
                ),
                SizedBox(
                  height: 15.0,
                ),
                CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                ),
              ],
            ),
          ),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(25.0))),
        ),
        onWillPop: () async => false);
  }

  goToDialog2() {
    if (isShowing == true) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) {
          return alertUploadingDetails();
        },
      );
    }
  }

  void payNow(BraintreePaymentMethodNonce nonce) {
    print("jnscjnsjcnjw: ${nonce.nonce}");
    nonceStatus = "success";
    noncePayment = nonce.nonce;
    goToDialog2();
    sendPaymentNonce();
  }

//  Saving payment details to your server so that user details can be updated either user is subscribed or not subscribed.
  Future<String?> sendPaymentNonce() async {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    try {
      final sendNonceResponse =
          await http.post(Uri.parse(APIData.sendPaymentNonceApi), body: {
        "amount": widget.payAmount != null
            ? "${widget.payAmount}"
            : "${planDetails[widget.planIndex].amount}",
        "nonce": noncePayment,
        "plan_id": "${planDetails[widget.planIndex].id}",
      }, headers: {
        HttpHeaders.authorizationHeader: "Bearer $authToken"
      });

      paymentResponse = json.decode(sendNonceResponse.body);
      print('mesgRespon: $paymentResponse');

      if (paymentResponse == 'Currency Not Supported') {
        setState(() {
          isBack = true;
          isShowing = false;
        });
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Your transaction failed due to Currency Not Supported");
      } else {
        msgResponse = paymentResponse['message'];
        subscriptionResponse = paymentResponse['subscription'];
        var date = subscriptionResponse['created_at'];
        var time = subscriptionResponse['created_at'];
        createdDate = DateFormat('d MMM y').format(DateTime.parse(date));
        createdTime = DateFormat('HH:mm a').format(DateTime.parse(time));
        if (sendNonceResponse.statusCode == 200) {
          setState(() {
            isShowing = false;
          });
          goToDialog(
              createdDate,
              createdTime,
              widget.payAmount != null
                  ? "${widget.payAmount}"
                  : planDetails[widget.planIndex].amount);
        } else {
          setState(() {
            isShowing = false;
          });
          Fluttertoast.showToast(msg: "Your transaction failed");
        }
      }
    } catch (e) {
      setState(() {
        isBack = true;
        isShowing = false;
      });
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Your transaction failed");
      throw '$e';
    }
    return null;
  }

  /*
  After creating successful payment and saving details to server successfully.
  Create a successful dialog
*/

  Widget closeFloatingButton() => FloatingActionButton(
        backgroundColor: Colors.black,
        child: Icon(
          Icons.clear,
        ),
        onPressed: () => Navigator.pushNamed(
          context,
          RoutePaths.splashScreen,
          arguments: SplashScreen(
            token: authToken,
          ),
        ),
      );

  Widget? goToDialog(subDate, time, planAmount) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (context) => WillPopScope(
            child: GestureDetector(
              child: Container(
                color: Theme.of(context).primaryColorLight.withOpacity(0.2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SuccessTicket(
                      msgResponse: msgResponse,
                      subDate: subDate,
                      time: time,
                      planAmount: "$planAmount",
                    ),
                    SizedBox(
                      height: 10.0,
                    ),
                    closeFloatingButton(),
                  ],
                ),
              ),
            ),
            onWillPop: () async => false));
    return null;
  }

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
        Text("Amount: " +
            '\n' +
            (widget.payAmount != null
                ? "${widget.payAmount} "
                : '${planDetails[widget.planIndex].amount} ') +
            '${planDetails[widget.planIndex].currency}'),
      ]),
    );
  }

  Widget braintreeLogoContainer() {
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
              "assets/braintree_logo.png",
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
            color: Theme.of(context).primaryColorLight.withOpacity(0.9),
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
            child: braintreeLogoContainer(),
          ),
          SizedBox(
            height: 30.0,
          ),
          paymentDetailsCard(),
          SizedBox(
            height: 20.0,
          ),
          isShowing == true
              ? CircularProgressIndicator()
              : Padding(
                  padding: EdgeInsets.only(left: 15.0, right: 15.0),
                  child: payButtonRow(),
                )
        ],
      ),
    );
  }

  Widget payButtonRow() {
    return Row(
      children: <Widget>[
        Expanded(
          flex: 1,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0),
              ),
              backgroundColor: Color.fromRGBO(72, 163, 198, 1.0),
            ),
            onPressed: getClientNonce,
            child: Text(
              "Continue Pay",
              // style: TextStyle(color: Colors.white),
            ),
          ),
        )
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isBack = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar:
            customAppBar(context, "Braintree Payment") as PreferredSizeWidget?,
        body: _body(),
      ),
      onWillPop: () async => isBack,
    );
  }
}
