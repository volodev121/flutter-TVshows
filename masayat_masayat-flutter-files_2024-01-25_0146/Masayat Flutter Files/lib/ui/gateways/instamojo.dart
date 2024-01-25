import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:nexthour/providers/app_config.dart';
import 'package:nexthour/providers/payment_key_provider.dart';
import 'package:nexthour/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

import 'instamojo_payment.dart';

bool isLoading = true;

class InstamojoPaymentPage extends StatefulWidget {
  final int planIndex;
  final payAmount;
  const InstamojoPaymentPage(this.planIndex, this.payAmount);

  @override
  _InstamojoPaymentPageState createState() => _InstamojoPaymentPageState();
}

class _InstamojoPaymentPageState extends State<InstamojoPaymentPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Instamojo Payment") as PreferredSizeWidget,
      body: Center(
        child: _body(),
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
              "assets/instamojo.png",
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
                var instamojoKey =
                    Provider.of<PaymentKeyProvider>(context, listen: false)
                        .paymentKeyModel!;
                if ((instamojoKey.imapikey == null ||
                        instamojoKey.imapikey == '') ||
                    (instamojoKey.imauthtoken == null ||
                        instamojoKey.imauthtoken == '') ||
                    (instamojoKey.imurl == null || instamojoKey.imurl == '')) {
                  Fluttertoast.showToast(
                      msg:
                          "Instamojo API Key or Auth Token or URL is not available.");
                  return;
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InstamojoPayment(
                        widget.planIndex,
                        widget.payAmount,
                      ),
                    ),
                  );
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
}
