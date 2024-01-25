import 'dart:io';
import 'dart:math';
// ignore: import_of_legacy_library_into_null_safe
//import 'package:currencies/currencies.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:horizontal_data_table/horizontal_data_table.dart';
import 'package:intl/intl.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/common/styles.dart';
import '/models/plans_model.dart';
import '/providers/app_config.dart';
import '/providers/user_profile_provider.dart';
import '/ui/grouped-button/group_button.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'select_payment_screen.dart';

class SubscriptionPlan extends StatefulWidget {
  @override
  _SubscriptionPlanState createState() => _SubscriptionPlanState();
}

class _SubscriptionPlanState extends State<SubscriptionPlan> {
  var bText = "First Trax";

  var buttonName;
  var buttonIndex;
  bool check = false;
  var selectedIndex = 0;
  var planDetails = [];
  var tableHeader = [];
  var plansFeatureDetails = [];
  var userDetails;
  var difference = 0;
  var strlen;
  bool _isLoading = false;
  bool pageLoading = true;
  HDTRefreshController _hdtRefreshController = HDTRefreshController();

  static const int sortName = 0;
  bool isAscending = true;
  int sortType = sortName;
  var activePlanIndex;
  @override
  void initState() {
    super.initState();
    print("button : $buttonIndex");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      plansData();
    });
  }

  Future plansData() async {
    var appConfigData = Provider.of<AppConfig>(context, listen: false);
    planDetails = appConfigData.planList;
    planDetails
        .removeWhere((element) => element.status == 0 || element.status == "0");
    planDetails.sort((a, b) => a.amount!.compareTo(b.amount!));
    tableHeader = List.from(planDetails);
    tableHeader.insert(0, Plan(name: ""));
    plansFeatureDetails = appConfigData.plansFeatures;

    print("plan features: ${plansFeatureDetails.length}");

    userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    setState(() {
      pageLoading = false;
    });
    if (userDetails.active == "1" || userDetails.active == 1) {
      print("Current Subscription : ${userDetails.currentSubscription}");
      difference = userDetails.end!.difference(userDetails.currentDate!).inDays;
      for (int index = 0; index < planDetails.length; index++) {
        print("Subscription ${index + 1} : ${planDetails[index].name}");
        if (userDetails.currentSubscription == planDetails[index].name) {
          setState(() {
            selectedIndex = index;
            buttonName = translate("Already_Subscribed_with") +
                " ${planDetails[index].name}".toUpperCase();
            activePlanIndex = index;
          });
          break;
        } else {
          setState(() {
            selectedIndex = 0;
          });
        }
      }
    }
  }

  Widget _getBodyWidget() {
    return Container(
      margin: EdgeInsets.only(right: 10.0, left: 10.0),
      child: HorizontalDataTable(
        leftHandSideColumnWidth: 200,
        rightHandSideColumnWidth: planDetails.length * 60.0,
        isFixedHeader: true,
        headerWidgets: _getTitleWidget(),
        leftSideItemBuilder: _generateFirstColumnRow,
        rightSideItemBuilder: _generateRightHandSideColumnRow,
        itemCount: plansFeatureDetails.length,
        rowSeparatorWidget: const Divider(
          color: Colors.white60,
          height: 1.0,
          thickness: 0.0,
        ),
        leftHandSideColBackgroundColor: Theme.of(context).primaryColorLight,
        rightHandSideColBackgroundColor: Theme.of(context).primaryColorLight,
        htdRefreshController: _hdtRefreshController,
      ),
      height: 65.0 + (40.0 * plansFeatureDetails.length),
    );
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
    try {
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
      print('reference  $reference');
      if (freeSubscription.statusCode == 200) {
        print('Free Subscription Status Code : ${freeSubscription.statusCode}');
        Fluttertoast.showToast(msg: translate("Subscribed_Successfully"));
        Navigator.pushNamed(context, RoutePaths.splashScreen);
      } else {
        print('Free Subscription Status Code : ${freeSubscription.statusCode}');
        setState(() {
          _isLoading = false;
        });
        Fluttertoast.showToast(msg: translate("Error_in_subscription"));
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
    return null;
  }

  List<Widget> _getTitleWidget() {
    return tableHeader
        .map(
          (e) => _getTitleItemWidget(e.name, 60),
        )
        .toList();
  }

  Widget _getTitleItemWidget(String label, double width) {
    final beforeCapitalLetter = RegExp(r"(?=[A-Z])");
    var columName2 = label.replaceAll(beforeCapitalLetter, "\n");
    return Container(
      child: Text(columName2,
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold)),
      width: width,
      height: 56,
      alignment: Alignment.center,
    );
  }

  Widget _generateFirstColumnRow(BuildContext context, int index) {
    print(
      plansFeatureDetails[index].name,
    );
    return Container(
      child: Text(
        plansFeatureDetails[index].name,
      ),
      height: 40,
      padding: EdgeInsets.fromLTRB(5, 0, 0, 0),
      alignment: Alignment.centerLeft,
    );
  }

  Widget _generateRightHandSideColumnRow(BuildContext context, int index) {
    return Row(
      children: planDetails.map((plan) {
        if (plan.feature.contains("${plansFeatureDetails[index].id}") ||
            plan.feature.contains(plansFeatureDetails[index].id)) {
          return Container(
            width: 60,
            height: 40,
            child: Icon(
              Icons.check,
              size: 18.0,
            ),
          );
        } else {
          return Container(
            width: 60,
            height: 40,
            child: Icon(
              Icons.close,
              size: 18.0,
            ),
          );
        }
      }).toList(),
    );
  }

  String currency(code) {
    //   Locale locale = Localizations.localeOf(context);
    var format = NumberFormat.simpleCurrency(name: code);
    var s = format.currencySymbol;
    return s;
  }

  String currency2(code) {
    code = "$code".toLowerCase();
    code = 'Iso4217Code.$code'.toString();
    var symbol;
    // currencies.forEach((key, value) {
    //   if (code == "$key" && symbol == null) {
    //     symbol = value.symbol;
    //   }
    // });
    if (symbol) {
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
  }

  @override
  Widget build(BuildContext context) {
    var dW = MediaQuery.of(context).size.width;
    List.generate(plansFeatureDetails.length, (index) {
      print("str$index: ${plansFeatureDetails[index].name.length}");
      if (strlen == null || strlen < plansFeatureDetails[index].name.length) {
        setState(() {
          strlen = plansFeatureDetails[index].name.length;
        });
      }
    });
    print("strleng: $strlen");
    print("selected inde $selectedIndex");
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: Text(
          translate('Purchase_Memberships'),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).primaryColor,
            fontSize: 22.0,
          ),
        ),
      ),
      backgroundColor: Theme.of(context).primaryColorLight,
      body: pageLoading == true
          ? Center(
              child: CircularProgressIndicator(
              strokeWidth: 2.0,
              valueColor: AlwaysStoppedAnimation(primaryBlue),
            ))
          : ListView(
              padding: EdgeInsets.only(top: 5.0),
              physics: ClampingScrollPhysics(),
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ListTile(
                      title: Text(
                        translate(
                            "Purchase_any_of_the_membership_package_from_below"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.0,
                        ),
                      ),
                    ),
                  ],
                ),
                plansFeatureDetails.length == 0
                    ? SizedBox.shrink()
                    : pageLoading == true
                        ? Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.0,
                              valueColor: AlwaysStoppedAnimation(primaryBlue),
                            ),
                          )
                        : _getBodyWidget(),
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Center(
                    child: GroupButton(
                      spacing: 10,
                      direction: Axis.horizontal,
                      selectedColor:
                          Theme.of(context).primaryColor.withOpacity(0.5),
                      unselectedColor: Colors.transparent,
                      selectedBorderColor: Theme.of(context).primaryColor,
                      unselectedBorderColor: Theme.of(context).hintColor,
                      borderRadius: BorderRadius.circular(5.0),
                      buttonWidth: dW * 0.3,
                      buttonHeight: 70,
                      unselectedTextStyle: TextStyle(color: Colors.white),
                      onSelected: (index, isSelected) {
                        if (planDetails[index].status == 'upcoming') {
                          setState(() {
                            buttonName =
                                translate("Coming_Soon_").toUpperCase();
                            selectedIndex = index;
                            buttonIndex = index;
                          });
                        } else {
                          if (userDetails.active == "1" ||
                              userDetails.active == 1) {
                            print(' : ${planDetails[index].id}');
                            if (userDetails.currentSubscription != null &&
                                difference >= 0) {
                              if (userDetails.currentSubscription ==
                                  planDetails[index].name) {
                                setState(() {
                                  buttonName =
                                      translate("Already_Subscribed_with") +
                                          " ${planDetails[index].name}"
                                              .toUpperCase();
                                  check = true;
                                  buttonIndex = index;
                                  selectedIndex = index;
                                });
                              } else {
                                if (activePlanIndex < index) {
                                  setState(() {
                                    buttonName = translate("Upgrade_to") +
                                        " ${planDetails[index].name}"
                                            .toUpperCase();
                                    check = false;
                                    buttonIndex = index;
                                    selectedIndex = index;
                                  });
                                } else {
                                  setState(() {
                                    buttonName = translate("Downgrade_to") +
                                        " ${planDetails[index].name}"
                                            .toUpperCase();
                                    check = true;
                                    buttonIndex = index;
                                    selectedIndex = index;
                                  });
                                }
                              }
                            } else {
                              setState(() {
                                buttonName = translate("Subscribe_to") +
                                    " ${planDetails[index].name}".toUpperCase();
                                buttonIndex = index;
                                selectedIndex = index;
                              });
                            }
                          } else {
                            setState(() {
                              buttonName = translate("Subscribe_to") +
                                  " ${planDetails[index].name}".toUpperCase();
                              buttonIndex = index;
                              selectedIndex = index;
                            });
                          }
                        }

                        print('$index button is selected');
                        print('$isSelected button is selected');
                      },
                      buttons: planDetails.length == 0
                          ? [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[SizedBox.shrink()],
                              )
                            ]
                          : planDetails.map((plan) {
                              if (plan.status == 'active') {
                                if (plan.amount == 0 ||
                                    plan.amount == "0.00" ||
                                    plan.amount == "0") {
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 5.0,
                                            right: 5.0,
                                            top: 2.0,
                                            bottom: 2.0),
                                        decoration: BoxDecoration(
                                          color: Colors.yellow.withOpacity(0.9),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                          "${plan.name}".toUpperCase(),
                                          style: TextStyle(
                                            color: Colors.black87,
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      Container(
                                        child: Text(
                                          translate("Free_"),
                                          style: TextStyle(fontSize: 25.0),
                                        ),
                                      ),
                                    ],
                                  );
                                } else {
                                  var planAmountValue;
                                  if (plan.amount.runtimeType == String) {
                                    planAmountValue =
                                        double.tryParse(plan.amount);
                                  } else if (plan.amount.runtimeType == int) {
                                    planAmountValue =
                                        double.tryParse(plan.amount);
                                  } else {
                                    planAmountValue = plan.amount;
                                  }
                                  return Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(
                                            left: 5.0,
                                            right: 5.0,
                                            top: 2.0,
                                            bottom: 2.0),
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            stops: [0.1, 0.3, 0.5, 0.7, 1.0],
                                            colors: [
                                              Color.fromRGBO(80, 194, 224, 100),
                                              Color.fromRGBO(30, 157, 207, 25),
                                              Color.fromRGBO(27, 162, 187, 50),
                                              Color.fromRGBO(32, 163, 173, 75),
                                              Color.fromRGBO(37, 164, 160, 100),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                        child: Text(
                                          "${plan.name}".toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 12,
                                          ),
                                        ),
                                      ),
                                      SizedBox(
                                        height: 5.0,
                                      ),
                                      RichText(
                                        text: TextSpan(children: [
                                          WidgetSpan(
                                            child: Transform.translate(
                                              offset: const Offset(-2, -10),
                                              child: Text(
                                                currency(plan.currency),
                                                //superscript is usually smaller in size
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          ),
                                          TextSpan(
                                            text: plan.amount.runtimeType == int
                                                ? planAmountValue > 99
                                                    ? '${(planAmountValue * 1.00).toStringAsFixed(1)}'
                                                    : '${(planAmountValue * 1.00).toStringAsFixed(2)}'
                                                : planAmountValue > 99.99
                                                    ? '${(planAmountValue).toStringAsFixed(0)}'
                                                    : '${planAmountValue.toStringAsFixed(2)}',
                                            style: TextStyle(
                                                fontSize: 25.0,
                                                fontWeight: FontWeight.bold),
                                          ),
                                          WidgetSpan(
                                            child: Transform.translate(
                                              offset: const Offset(0, 0),
                                              child: Text(
                                                "/${plan.interval}",
                                                //superscript is usually smaller in size
                                                textScaleFactor: 0.9,
                                              ),
                                            ),
                                          )
                                        ]),
                                      ),
                                    ],
                                  );
                                }
                              } else if (plan.status == 'upcoming') {
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      padding: EdgeInsets.only(
                                          left: 5.0,
                                          right: 5.0,
                                          top: 2.0,
                                          bottom: 2.0),
                                      decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            stops: [0.1, 0.3, 0.5, 0.7, 1.0],
                                            colors: [
                                              Color.fromRGBO(80, 194, 224, 100),
                                              Color.fromRGBO(30, 157, 207, 25),
                                              Color.fromRGBO(27, 162, 187, 50),
                                              Color.fromRGBO(32, 163, 173, 75),
                                              Color.fromRGBO(37, 164, 160, 100),
                                            ],
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(5.0)),
                                      child: Text(
                                        "${plan.name}".toUpperCase(),
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    RichText(
                                      text: TextSpan(children: [
                                        TextSpan(
                                          text: translate("Coming_Soon_")
                                              .toUpperCase(),
                                          style: TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ]),
                                    ),
                                  ],
                                );
                              } else {
                                return SizedBox.shrink();
                              }
                            }).toList(),
                      selectedButton: selectedIndex,
                    ),
                  ),
                ),
                Container(
                  height: 60.0,
                  margin: EdgeInsets.symmetric(horizontal: 10.0, vertical: 5.0),
                  decoration: BoxDecoration(
                    borderRadius: new BorderRadius.circular(5.0),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      stops: [0.1, 0.3, 0.5, 0.7, 1.0],
                      colors: [
                        _isLoading == true
                            ? Color.fromRGBO(100, 100, 100, 1.0)
                            : Color.fromRGBO(80, 194, 224, 100),
                        _isLoading == true
                            ? Color.fromRGBO(100, 100, 100, 1.0)
                            : Color.fromRGBO(30, 157, 207, 25),
                        _isLoading == true
                            ? Color.fromRGBO(100, 100, 100, 1.0)
                            : Color.fromRGBO(27, 162, 187, 50),
                        _isLoading == true
                            ? Color.fromRGBO(100, 100, 100, 1.0)
                            : Color.fromRGBO(32, 163, 173, 75),
                        _isLoading == true
                            ? Color.fromRGBO(100, 100, 100, 1.0)
                            : Color.fromRGBO(37, 164, 160, 100),
                      ],
                    ),
                  ),
                  child: new MaterialButton(
                    splashColor: _isLoading == true
                        ? Color.fromRGBO(100, 100, 100, 1.0)
                        : Color.fromRGBO(72, 163, 198, 0.9),
                    child: pageLoading == true
                        ? CircularProgressIndicator(
                            strokeWidth: 2.0,
                            valueColor: AlwaysStoppedAnimation(primaryBlue),
                          )
                        : Text(
                            userDetails.active == "1" || userDetails.active == 1
                                ? buttonName == null
                                    ? translate("Subscribe_to") +
                                        " ${planDetails[selectedIndex].name}"
                                            .toUpperCase()
                                    : "$buttonName".toUpperCase()
                                : buttonName == null
                                    ? translate("Subscribe_to") +
                                        " ${planDetails[selectedIndex].name}"
                                            .toUpperCase()
                                    : "$buttonName".toUpperCase(),
                            style: TextStyle(color: Colors.white),
                          ),
                    onPressed: _isLoading == true
                        ? null
                        : () {
                            var status;
                            if (buttonIndex == null) {
                              status = planDetails[selectedIndex].status;
                            } else {
                              status = planDetails[buttonIndex].status;
                            }
                            if (status == 'active' && _isLoading == false) {
                              if (planDetails[selectedIndex].free == 1 ||
                                  planDetails[selectedIndex].free == "1") {
                                setState(() {
                                  _isLoading = true;
                                });
                                print(
                                    "Plan ID ${planDetails[selectedIndex].id}");
                                print(
                                    "Amount ${planDetails[selectedIndex].amount}");
                                print(
                                    "free subscription status ${planDetails[selectedIndex].status}");
                                print(
                                    "free subscription ${planDetails[selectedIndex].free}");

                                freeSub(planDetails[selectedIndex].id, 0.00,
                                    generateRandomString(8), 1, 'Free');
                              } else {
                                var router = new MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        new SelectPaymentScreen(
                                            buttonIndex == null
                                                ? selectedIndex
                                                : buttonIndex));
                                Navigator.of(context).push(router);
                              }
                            } else if (_isLoading == true) {
                            } else {
                              Fluttertoast.showToast(
                                msg: translate("This_package_is_coming_soon_"),
                              );
                            }
                          },
                  ),
                )
              ],
            ),
    );
  }
}
