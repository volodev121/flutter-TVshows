import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:intl/intl.dart';
import '/models/user_profile_model.dart';
import '/providers/user_profile_provider.dart';
import '/ui/shared/appbar.dart';
import '/ui/shared/blank_history.dart';
import '/ui/shared/seperator2.dart';
import 'package:provider/provider.dart';

class StripeHistoryScreen extends StatefulWidget {
  @override
  _StripeHistoryScreenState createState() => _StripeHistoryScreenState();
}

class _StripeHistoryScreenState extends State<StripeHistoryScreen> {
  List<Subscription> _stripeHistoryList() {
    var stripePayment = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!
        .user!
        .subscriptions;
    return List<Subscription>.generate(
        stripePayment == null ? 0 : stripePayment.length, (int index) {
      return Subscription(
        id: stripePayment![index].id,
        userId: stripePayment[index].userId,
        name: stripePayment[index].name,
        stripeId: stripePayment[index].stripeId,
        stripePlan: stripePayment[index].stripePlan,
        subscriptionFrom: stripePayment[index].subscriptionFrom,
        subscriptionTo: stripePayment[index].subscriptionTo,
        createdAt: stripePayment[index].createdAt,
        amount: stripePayment[index].amount,
      );
    });
  }

  List<Card>? _buildCards(int count) {
    var stripePayment = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!
        .user!
        .subscriptions!;
    for (var j = 0; j < stripePayment.length;) {
      List<Card> cards = List.generate(
        count,
        (j) => Card(
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AspectRatio(
                aspectRatio: 16.0 / 6.0,
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                    ),
                    stripePlanName(stripePayment[j].name),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.fromLTRB(20.0, 5.0, 0.0, 0.0),
                          child: Separator2(),
                        ),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Padding(
                            padding: EdgeInsets.only(left: 20.0),
                          ),
                          subsCreatedDate(stripePayment[j].createdAt),
                          Expanded(
                            flex: 2,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  child: Text(
                                    stripePayment[j].amount.toString() + ' ',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 14.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                ),
                                SizedBox(
                                  height: 3.0,
                                ),
                                subscriptionFromTo(
                                    DateFormat("d-m-y HH:MM").format(
                                        stripePayment[j].subscriptionFrom),
                                    DateFormat("d-m-y HH:MM").format(
                                        stripePayment[j].subscriptionTo)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    stripeId(stripePayment[j].stripeId),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
      return cards;
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _stripeHistoryList();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Widget stripeId(stripePaymentId) {
    return Padding(
      padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(left: 20.0),
          ),
          Expanded(
            child: stripePaymentId != null
                ? Text(
                    translate('Transaction_ID_') + '\n' + stripePaymentId,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      height: 1.3,
                    ),
                  )
                : Text(
                    translate('Transaction_ID_') + '\n' + 'N/A',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12.0,
                      height: 1.3,
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget subscriptionFromTo(subFrom, subTo) {
    return Container(
      child: subFrom != null && subTo != null
          ? Text(
              translate('From_') +
                  ' ' +
                  subFrom +
                  '\n' +
                  translate('To_') +
                  ' ' +
                  subTo,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  letterSpacing: 0.8,
                  height: 1.3,
                  fontWeight: FontWeight.w500),
            )
          : Text(
              translate('From_') +
                  ' ' +
                  'N/A' +
                  '\n' +
                  translate('To_') +
                  ' ' +
                  'N/A',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 10.0,
                  letterSpacing: 0.8,
                  height: 1.3,
                  fontWeight: FontWeight.w500),
            ),
    );
  }

  Widget subsCreatedDate(subscriptionCreatedDate) {
    return Expanded(
      flex: 2,
      child: subscriptionCreatedDate != null
          ? Text(
              subscriptionCreatedDate + ' via ' + '\n' + 'Stripe',
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            )
          : Text(
              'N/A' + ' via ' + '\n' + 'Stripe',
              style: TextStyle(color: Colors.white, fontSize: 12.0),
            ),
    );
  }

  Widget stripePlanName(stripePlan) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20.0),
        ),
        Expanded(
          child: stripePlan != null
              ? Text(
                  stripePlan.toString(),
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                )
              : Text(
                  'N/A',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600),
                ),
        ),
      ],
    );
  }

  Widget scaffoldBody() {
    var stripePayment = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!
        .user!
        .subscriptions!;
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: SingleChildScrollView(
        child: Column(
          children: _buildCards(stripePayment.length)!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var stripePayment = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!
        .user!
        .subscriptions;
    return SafeArea(
      child: stripePayment != null
          ? Scaffold(
              appBar: customAppBar(context, translate("Stripe_Payment_History"))
                  as PreferredSizeWidget?,
              backgroundColor: Color.fromRGBO(34, 34, 34, 0.0),
              body: scaffoldBody(),
            )
          : BlankHistoryContainer(),
    );
  }
}
