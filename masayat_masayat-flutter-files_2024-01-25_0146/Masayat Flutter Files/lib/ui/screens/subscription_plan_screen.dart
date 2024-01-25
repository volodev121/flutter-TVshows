import 'dart:io';
import 'dart:math';
// ignore: import_of_legacy_library_into_null_safe
//import 'package:currencies/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/models/plans_model.dart';
import '/providers/app_config.dart';
import '/providers/user_profile_provider.dart';
import '/ui/screens/select_payment_screen.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class SubPlanScreen extends StatefulWidget {
  @override
  _SubPlanScreenState createState() => _SubPlanScreenState();
}

class _SubPlanScreenState extends State<SubPlanScreen> {
//  List used to show all the plans using home API

  @override
  void initState() {
    super.initState();
    getUSerData();
  }

  Future getUSerData() async {
    var userDetailsProvider =
        Provider.of<UserProfileProvider>(context, listen: false);
    await userDetailsProvider.getUserProfile(context);
  }

  List<Widget> _buildCards(int count, List<Plan> planDetails) {
    bool check = false;
    planDetails.sort((a, b) => a.amount!.compareTo(b.amount!));
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;

    List<Widget> cards = List.generate(count, (int index) {
      var buttonName;
      if (userDetails.active == "1" || userDetails.active == 1) {
        final difference =
            userDetails.end!.difference(userDetails.currentDate!).inDays;

        print(' : ${planDetails[index].id}');
        if (userDetails.currentSubscription != null && difference >= 0) {
          if (userDetails.currentSubscription == planDetails[index].name) {
            buttonName = translate("Already_Subscribed");
            check = true;
          } else {
            if (check == true) {
              buttonName = translate("Upgrade_");
            } else {
              buttonName = translate("Downgrade_");
            }
          }
        } else {
          buttonName = translate("Subscribe_");
        }
      } else {
        buttonName = translate("Subscribe_");
      }

      dynamic planAm = planDetails[index].amount;

      switch (planAm.runtimeType) {
        case int:
          {
            dailyAmount =
                planDetails[index].amount / planDetails[index].intervalCount;
            dailyAmountAp = dailyAmount.toStringAsFixed(2);
          }
          break;
        case String:
          {
            dailyAmount = double.parse(planDetails[index].amount.toString()) /
                double.parse(planDetails[index].intervalCount.toString());
            dailyAmountAp = dailyAmount.toStringAsFixed(2);
          }
          break;
        case double:
          {
            dailyAmount = double.parse(planDetails[index].amount.toString()) /
                double.parse(planDetails[index].intervalCount.toString());
            dailyAmountAp = dailyAmount.toStringAsFixed(2);
          }
          break;
      }

//      Used to check soft delete status so that only active plan can be showed
      dynamic mPlanStatus = planDetails[index].status;

      if (mPlanStatus.runtimeType == int) {
        print("index number$index: $mPlanStatus");
        if (planDetails[index].status == 1) {
          return planDetails[index].deleteStatus == 0
              ? SizedBox.shrink()
              : Container(
                  margin: EdgeInsets.only(top: 10.0),
                  child: subscriptionCards(index, dailyAmountAp, buttonName),
                );
        } else {
          return SizedBox.shrink();
        }
      } else {
        if ("${planDetails[index].status}" == "active") {
          return "${planDetails[index].deleteStatus}" == "0"
              ? SizedBox.shrink()
              : subscriptionCards(index, dailyAmountAp, buttonName);
        } else {
          return SizedBox.shrink();
        }
      }
    });
    return cards;
  }

  String generateRandomString(int len) {
    var r = Random();
    const _chars =
        'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
    var randomString;
    randomString =
        List.generate(len, (index) => _chars[r.nextInt(_chars.length)]).join();
    print(randomString);
    return randomString;
  }

  Future freeSub(dynamic id, double amount, String reference, dynamic status,
      String free) async {
    final freeSubscription =
        await http.post(Uri.parse(APIData.freeSubscription), headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken",
      "Accept": "application/json",
    }, body: {
      "plan_id": '$id',
      "amount": '$amount',
      "reference": '$reference',
      "status": '$status',
      "method": '$free',
    });
    print('refrence  $reference');
    if (freeSubscription.statusCode == 200) {
      print('Free Subscription Status Code : ${freeSubscription.statusCode}');
      Fluttertoast.showToast(
        msg: translate("Subscribed_Successfully"),
      );
      Navigator.pushNamed(context, RoutePaths.splashScreen);
    } else {
      print('Free Subscription Status Code : ${freeSubscription.statusCode}');
      Fluttertoast.showToast(
        msg: translate("Error_in_subscription"),
      );
    }
    return null;
  }

  Widget subscribeButton(index, buttonName) {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    return Padding(
      padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            borderRadius: BorderRadius.circular(25.0),
            child: Container(
              height: 40.0,
              width: 150.0,
              decoration: BoxDecoration(
                borderRadius: new BorderRadius.circular(20.0),
                gradient: LinearGradient(
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                  stops: [0.1, 0.3, 0.5, 0.7, 1.0],
                  colors: [
                    buttonName == translate("Already_Subscribed")
                        ? activeDotColor
                        : Theme.of(context).primaryColor,
                    buttonName == translate("Already_Subscribed")
                        ? activeDotColor
                        : Color.fromRGBO(30, 157, 207, 25),
                    buttonName == translate("Already_Subscribed")
                        ? activeDotColor
                        : Color.fromRGBO(27, 162, 187, 50),
                    buttonName == translate("Already_Subscribed")
                        ? activeDotColor
                        : Color.fromRGBO(32, 163, 173, 75),
                    buttonName == translate("Already_Subscribed")
                        ? activeDotColor
                        : Color.fromRGBO(37, 164, 160, 100),
                  ],
                ),
              ),
              child: new MaterialButton(
                height: 50.0,
                splashColor: Color.fromRGBO(72, 163, 198, 0.9),
                child: Text(
                  buttonName,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
                onPressed: () {
                  print("free  ${planDetails[index].free}");
                  // Working after clicking on subscribe button
                  // if free subscription
                  if (planDetails[index].free == 1 ||
                      planDetails[index].free == "1") {
                    print("Plan ID ${planDetails[index].id}");
                    print("Amount ${planDetails[index].amount}");
                    print(
                        "free subscription status ${planDetails[index].status}");
                    print("free subscription ${planDetails[index].free}");

                    freeSub(planDetails[index].id, 0.00,
                        generateRandomString(8), 1, 'Free');
                  } else {
                    var router = new MaterialPageRoute(
                        builder: (BuildContext context) =>
                            new SelectPaymentScreen(index));
                    Navigator.of(context).push(router);
                  }
                },
              ),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

/*  String currency(code) {
    code = "$code".toLowerCase();
    code = 'Iso4217Code.$code'.toString();
    var symbol;
    currencies.forEach((key, value) {
      if (code == "$key" && symbol == null) {
        symbol = value.symbol;
      }
    });
    if (symbol == null) {
      code = code.replaceAll("Iso4217Code.", "");
      code = code.toUpperCase();
      var format = NumberFormat.simpleCurrency(
        name: code, //currencyCode
      );

      print("Code: $code");
      print("CURRENCY SYMBOL ${format.currencySymbol}"); // $
      print("CURRENCY NAME ${format.currencyName}"); // USD
      return "${format.currencySymbol}";
    } else {
      return "$symbol";
    }
  }*/

//  Amount with currency
  Widget amountCurrencyText(index) {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(
                "${planDetails[index].amount}",
                style: TextStyle(
                  fontSize: 25.0,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                width: 3.0,
              ),
              //   Text('${currency(planDetails[index].currency)}'),
            ],
          ),
        ),
      ],
    );
  }

//  Daily amount
  Widget dailyAmountIntervalText(dailyAmountAp, index) {
    var dailyAmount = Provider.of<AppConfig>(context, listen: false).planList;
    return Row(
      children: <Widget>[
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: 100.0),
            child: Text(
              "$dailyAmountAp / ${dailyAmount[index].interval}",
              style: TextStyle(
                fontSize: 8.0,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

//  Plan Name
  Widget planNameText(index) {
    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;
    return Container(
      height: 35.0,
      color: Colors.cyan.shade400,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            child: Text(
              '${planDetails[index].name}',
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

//  Subscription cards
  Widget subscriptionCards(index, dailyAmountAp, buttonName) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AspectRatio(
            aspectRatio: 18.0 / 5.0,
            child: Column(
              children: <Widget>[
                planNameText(index),
                Padding(
                  padding: EdgeInsets.only(top: 10.0),
                ),
                amountCurrencyText(index),
                dailyAmountIntervalText(dailyAmountAp, index),
              ],
            ),
          ),
          subscribeButton(index, buttonName),
        ],
      ),
    );
  }

// Scaffold body
  Widget scaffoldBody() {
    var planDetails = Provider.of<AppConfig>(context).planList;

    return planDetails.length == 0
        ? noPlanColumn()
        : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                children: _buildCards(planDetails.length, planDetails),
              ),
            ),
          );
  }

  //  Empty watchlist container message
  Widget noPlanContainer() {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Text(
        translate("No_subscription_plans_available"),
        style: TextStyle(
          height: 1.5,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

//  Empty watchlist icon
  Widget noPlanIcon() {
    return Image.asset(
      "assets/no_plan.png",
      height: 140,
      width: 160,
    );
  }

//  Empty plan column
  Widget noPlanColumn() {
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          noPlanIcon(),
          SizedBox(
            height: 25.0,
          ),
          noPlanContainer(),
        ],
      ),
    );
  }

//  Build Method
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(context, translate("Subscription_Plans"))
            as PreferredSizeWidget?,
        body: FutureBuilder(
          future: getUSerData(),
          builder: (context, AsyncSnapshot dataSnapshot) {
            if (dataSnapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else {
              if (dataSnapshot.error != null) {
                return Center(
                  child: Text(translate('An_error_occurred_')),
                );
              } else {
                return scaffoldBody();
              }
            }
          },
        ),
      ),
    );
  }
}
