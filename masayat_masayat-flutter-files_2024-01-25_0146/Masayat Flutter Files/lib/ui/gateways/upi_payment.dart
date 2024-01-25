import 'dart:convert';
import 'dart:io';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/common/route_paths.dart';
import 'package:nexthour/providers/app_config.dart';
import 'package:nexthour/ui/screens/splash_screen.dart';
import 'package:nexthour/ui/shared/appbar.dart';
import 'package:nexthour/ui/shared/success_ticket.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:upi_india/upi_india.dart';
import '../../providers/upi_details_provider.dart';

class UPIPayment extends StatefulWidget {
  final int planIndex;
  final payAmount;

  UPIPayment({required this.planIndex, this.payAmount});

  @override
  _UPIPaymentState createState() => _UPIPaymentState();
}

class _UPIPaymentState extends State<UPIPayment> {
  void loadData() {
    var planDetails = Provider.of<AppConfig>(context).planList;
    setState(() {
      UpiDetailsProvider upiDetailsProvider =
          Provider.of<UpiDetailsProvider>(context, listen: false);

      receiverName = upiDetailsProvider.upiDetailsModel!.upi!.name;
      receiverUpiId = upiDetailsProvider.upiDetailsModel!.upi!.upiid;

      amount = double.tryParse(widget.payAmount != null
          ? '${widget.payAmount}'
          : '${planDetails[widget.planIndex].amount}');
      orderId = 'UPIPayment-${DateTime.now().microsecondsSinceEpoch}';
      isBack = true;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _upiIndia.getAllUpiApps(mandatoryTransactionId: false).then(
      (value) {
        setState(
          () {
            apps = value;
          },
        );
      },
    ).catchError(
      (e) {
        apps = [];
      },
    );
    loadData();
  }

  var paymentResponse, createdDate, createdTime;
  bool isShowing = true;
  bool isBack = false;

  var scaffoldKey = GlobalKey<ScaffoldState>();

  double? amount;
  String? orderId;
  String? receiverUpiId;
  String? receiverName;

  UpiIndia _upiIndia = UpiIndia();
  late List<UpiApp> apps;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      appBar: customAppBar(context, "UPI Payment") as PreferredSizeWidget,
      body: Center(
        child: !isBack ? CircularProgressIndicator() : _body(),
      ),
    );
  }

  Widget logoContainer() {
    return Container(
      decoration: BoxDecoration(
          color: Theme.of(context).primaryColorLight,
          borderRadius: BorderRadius.circular(10.0)),
      child: ListView(
        shrinkWrap: true,
        scrollDirection: Axis.vertical,
        physics: ClampingScrollPhysics(),
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(50.0),
            child: Image.asset(
              "assets/upilogo.png",
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
          borderRadius: BorderRadius.circular(10.0),
        ),
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
                if ((receiverUpiId == null || receiverUpiId == '') ||
                    (receiverName == null || receiverName == '')) {
                  Fluttertoast.showToast(
                      msg: "Receiver's UPI ID and Name are not available.");
                  return;
                } else {
                  startPayment();
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

  Future<UpiResponse> initiateTransaction(UpiApp app) async {
    return _upiIndia.startTransaction(
      app: app,
      receiverUpiId: "$receiverUpiId",
      receiverName: '$receiverName',
      transactionRefId: '$orderId',
      transactionNote: 'Subscription Purchase',
      amount: double.parse(amount.toString()),
    );
  }

  void startPayment() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(25.0),
          ),
        ),
        backgroundColor: Colors.white,
        title: Text(
          "Select UPI App",
          style: TextStyle(color: Color(0xFF3F4654)),
        ),
        content: Container(
          height: 150.0,
          width: 150.0,
          child: apps.isEmpty
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(
                  child: ListView.builder(
                    itemBuilder: (BuildContext context, int index) {
                      return GestureDetector(
                        onTap: () async {
                          UpiResponse upiResponse =
                              await initiateTransaction(apps[index]);
                          if (upiResponse.status == UpiPaymentStatus.SUCCESS) {
                            print('-> ${upiResponse.status}');
                            sendPaymentDetails(orderId, "UPI");
                          } else
                            print('${upiResponse.status}');
                        },
                        child: Card(
                          elevation: 5.0,
                          child: ListTile(
                            leading: Image.memory(apps[index].icon),
                            title: Text(
                              apps[index].name,
                              style: TextStyle(
                                fontSize: 22.0,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                    itemCount: apps.length,
                  ),
                ),
        ),
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
              style: TextStyle(color: Color(0xFF3F4654)),
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
          APIData.sendRazorDetails,
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
