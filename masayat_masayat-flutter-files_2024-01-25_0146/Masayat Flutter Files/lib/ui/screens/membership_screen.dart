import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/common/global.dart';
import '/providers/user_profile_provider.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

class MembershipScreen extends StatefulWidget {
  @override
  _MembershipScreenState createState() => _MembershipScreenState();
}

class _MembershipScreenState extends State<MembershipScreen> {
  //  Active plan status row with name
  Widget planStatusRow() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(translate("Active_Plans_"),
            style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w400)),
        Text(
          userDetails.currentSubscription == null
              ? userDetails.payment == "Free"
                  ? translate("Free_Trial")
                  : 'N/A'
              : '${userDetails.currentSubscription}',
          style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

//  Plan expiry date row
  Widget planExpiryDateRow() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    var date = userDetails.end;
    String yy = '';
    if (date == null || userDetails.active != "1") {
      yy = 'N/A';
    } else {
      yy = date.toString().substring(8, 10) +
          "/" +
          date.toString().substring(5, 7) +
          "/" +
          date.toString().substring(0, 4);
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          translate("Plan_will_expired_on_"),
          style: TextStyle(fontSize: 14.0),
        ),
        Text(
          yy,
          style: TextStyle(fontSize: 14.0, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

//  Column that contains rows and status button.
  Widget uiColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        planStatusRow(),
        Padding(padding: EdgeInsets.fromLTRB(15.0, 10.0, 16.0, 0.0)),
        planExpiryDateRow(),
        statusButton(),
      ],
    );
  }

//  Scaffold body containing overall UI of this page
  Widget scaffoldBody() {
    return Container(
      padding: EdgeInsets.fromLTRB(20.0, 150.0, 0.0, 20.0),
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          planStatusRow(),
          Padding(padding: EdgeInsets.fromLTRB(15.0, 10.0, 16.0, 0.0)),
          planExpiryDateRow(),
          statusButton(),
        ],
      ),
    );
  }

  bool loading = false;
//  Status button that handle user active status and stop or resume.
  Widget statusButton() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Padding(
      padding: EdgeInsets.fromLTRB(15.0, 50.0, 16.0, 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Material(
            child: Container(
              height: 50.0,
              width: 200.0,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomRight,
                  stops: [0.1, 0.5, 0.7, 0.9],
                  colors: [
                    Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
                    Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
                    Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
                    Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
                  ],
                ),
              ),

              // This will change the user status after tapping on button and it will also change button
              child: userDetails.active == "1"
                  ? new MaterialButton(
                      splashColor: Color.fromRGBO(72, 163, 198, 0.9),
                      child: loading
                          ? CircularProgressIndicator()
                          : Text(
                              translate("Stop_Subscription"),
                              // style: TextStyle(color: Colors.white),
                            ),
                      onPressed: () {
                        userDetails.payment!.toLowerCase() == 'free' ||
                                userDetails.payment!.toLowerCase() ==
                                    'by admin' ||
                                userDetails.payment!.toLowerCase() == 'paypal'
                            ? _onTap(
                                userPaymentType: 'paypal',
                                value: 0,
                                subscriptionId: userDetails.payid)
                            : _onTap(
                                userPaymentType: 'stripe',
                                value: 0,
                                subscriptionId: userDetails.payid,
                              );
                      },
                    )
                  : userDetails.currentSubscription != null
                      ? new MaterialButton(
                          splashColor: Color.fromRGBO(72, 163, 198, 0.9),
                          child: loading
                              ? CircularProgressIndicator()
                              : Text(
                                  translate("Resume_Subscription"),
                                  // style: TextStyle(color: Colors.white),
                                ),
                          onPressed: () {
                            userDetails.payment!.toLowerCase() == 'free' ||
                                    userDetails.payment!.toLowerCase() ==
                                        'by admin' ||
                                    userDetails.payment!.toLowerCase() ==
                                        'paypal'
                                ? _onTap(
                                    userPaymentType: 'paypal',
                                    value: 1,
                                    subscriptionId: userDetails.payid)
                                : _onTap(
                                    userPaymentType: 'stripe',
                                    value: 1,
                                    subscriptionId: userDetails.payid,
                                  );
                          },
                        )
                      : new MaterialButton(
                          splashColor: Color.fromRGBO(34, 34, 34, 1.0),
                          child: Text(
                            translate("Resume_Subscription"),
                            // style: TextStyle(color: Colors.white),
                          ),
                          onPressed: () {
                            Fluttertoast.showToast(
                                msg: translate("You_are_not_Subscribed"));
                          },
                        ),
            ),
          ),
          SizedBox(height: 8.0),
        ],
      ),
    );
  }

  void _onTap(
      {required String? userPaymentType,
      required String? subscriptionId,
      required int value}) {
    if (userPaymentType == 'stripe') {
      stripeUpdateDetails(value: value, subscriptionId: subscriptionId);
    } else if (userPaymentType == 'paypal') {
      paypalUpdateDetails(value: value, subscriptionId: subscriptionId);
    } else {
      return;
    }
  }

  Future<void> stripeUpdateDetails(
      {required String? subscriptionId, required int value}) async {
    setState(() {
      loading = true;
    });
    try {
      print(APIData.paypalUpdateApi + '$subscriptionId/$value');
      Response response = await Dio().get(
        APIData.paypalUpdateApi + '$subscriptionId/$value',
        queryParameters: {
          "secret": APIData.secretKey,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer " + authToken,
            "Accept": "application/json"
          },
        ),
      );
      if (response.statusCode == 200) {
        await Provider.of<UserProfileProvider>(context, listen: false)
            .getUserProfile(context);
        value == 0
            ? ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(translate('Subscription_Paused')),
                ),
              )
            : ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(translate('Subscription_Resumed')),
                ),
              );
      } else {
        print('Stripe Update Status Code : ${response.statusCode}');
      }
    } catch (e) {
      print('Stripe Update Error : $e');
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> paypalUpdateDetails(
      {required String? subscriptionId, required int value}) async {
    setState(() {
      loading = true;
    });
    try {
      print(APIData.paypalUpdateApi + '$subscriptionId/$value');
      Response response = await Dio().get(
        APIData.paypalUpdateApi + '$subscriptionId/$value',
        queryParameters: {
          "secret": APIData.secretKey,
        },
        options: Options(
          headers: {
            "Authorization": "Bearer " + authToken,
            "Accept": "application/json"
          },
        ),
      );
      if (response.statusCode == 200) {
        await Provider.of<UserProfileProvider>(context, listen: false)
            .getUserProfile(context);
        value == 0
            ? ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(translate('Subscription_Paused')),
                ),
              )
            : ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(translate('Subscription_Resumed')),
                ),
              );
      } else {
        print('Paypal Update Status Code : ${response.statusCode}');
      }
    } catch (e) {
      print('Paypal Update Error : $e');
    }
    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Membership_Plan"))
          as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }
}
