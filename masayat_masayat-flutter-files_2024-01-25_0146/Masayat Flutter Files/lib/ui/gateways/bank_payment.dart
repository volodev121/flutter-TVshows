import 'package:flutter/material.dart';
import '/providers/app_config.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

class BankPayment extends StatefulWidget {
  @override
  _BankPaymentState createState() => _BankPaymentState();
}

class _BankPaymentState extends State<BankPayment> {
  Widget _buildCard() {
    var bankName = Provider.of<AppConfig>(context).appModel!.config!.bankName;
    var branch = Provider.of<AppConfig>(context).appModel!.config!.branch;
    var ifscCode = Provider.of<AppConfig>(context).appModel!.config!.ifscCode;
    var accountNo = Provider.of<AppConfig>(context).appModel!.config!.accountNo;
    var contactEmail = Provider.of<AppConfig>(context).appModel!.config!.wEmail;
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 15.0, 20.0, 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("Bank"),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("$bankName"),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("Branch"),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("$branch"),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("IFSC Code"),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("$ifscCode"),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("Account No."),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  child: Text("$accountNo"),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0.0),
          child: Text(
            "* You can transfer the subscription amount in this account. Your subscription will be active after confirming amount for respective subscription. "
            "For query send email at - $contactEmail",
            style: TextStyle(
              fontSize: 11.0,
              height: 1.1,
              letterSpacing: 0.4,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "Bank Details") as PreferredSizeWidget?,
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: _buildCard(),
      ),
    );
  }
}
