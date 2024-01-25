import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/common/route_paths.dart';
import '/ui/shared/appbar.dart';

class PaymentHistoryScreen extends StatefulWidget {
  @override
  _PaymentHistoryScreenState createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  //  Text on container to select stripe history
  Widget stripeText() {
    return Expanded(
      flex: 4,
      child: Text(translate("Stripe_Payment_History")),
    );
  }

//  Container to select stripe payment history
  Widget goToStripeHistory() {
    return InkWell(
      child: Container(
        height: 80.0,
        child: Card(
            child: Padding(
          padding: EdgeInsets.fromLTRB(35.0, 0.0, 10.0, 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 4,
                child: Text(translate("Stripe_Payment_History")),
              ),
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15.0,
                ),
              )
            ],
          ),
        )),
      ),

//   This onTap take you to the next screen that contains stripe payment history.
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.stripeHistory);
      },
    );
  }

//  Container to choose other payment history
  Widget goToOtherHistory() {
    return InkWell(
      child: Container(
        height: 80.0,
        child: Card(
            child: Padding(
          padding: EdgeInsets.fromLTRB(35.0, 0.0, 10.0, 0.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Expanded(
                flex: 3,
                child: Text(translate("Other_Payment_History")),
              ),
              Expanded(
                flex: 1,
                child: Icon(
                  Icons.arrow_forward_ios,
                  size: 15.0,
                ),
              )
            ],
          ),
        )),
      ),

      // This onTap take you to the next screen that contains payment history except stripe.
      onTap: () {
        Navigator.pushNamed(context, RoutePaths.otherHistory);
      },
    );
  }

//  Scaffold body contains overall UI of this page
  Widget scaffoldBody() {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          goToStripeHistory(),
          Container(
            height: 2.0,
          ),
          goToOtherHistory(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Payment_History"))
          as PreferredSizeWidget?,
      body: scaffoldBody(),
    );
  }
}
