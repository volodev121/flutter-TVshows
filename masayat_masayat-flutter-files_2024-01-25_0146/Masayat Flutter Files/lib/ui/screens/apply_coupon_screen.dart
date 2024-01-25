import 'dart:convert';
import 'dart:io';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/ui/screens/select_payment_screen.dart';
import '/ui/shared/appbar.dart';
import '/providers/coupon_provider.dart';
import 'package:provider/provider.dart';
import '/models/coupon_model.dart';

class ApplyCouponScreen extends StatefulWidget {
  ApplyCouponScreen(this.amount, this.func);
  final amount;
  final func;
  @override
  _ApplyCouponScreenState createState() => _ApplyCouponScreenState();
}

class _ApplyCouponScreenState extends State<ApplyCouponScreen> {
  final _formKey = new GlobalKey<FormState>();
  final TextEditingController _couponController = new TextEditingController();
  bool _validate = false;
  bool isDataAvailable = false;
  bool _visible = false;

  Future<String?> _applyCoupon() async {
    final applyCouponResponse = await http.post(
        Uri.parse(
            "https://api.stripe.com/v1/coupons/${_couponController.text}"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $authToken"});
    var applyCouponDetails = json.decode(applyCouponResponse.body);
    if (applyCouponResponse.statusCode == 200) {
      validCoupon = applyCouponDetails['valid'];
      percentOFF = applyCouponDetails['percent_off'];
      amountOFF = applyCouponDetails['amount_off'];

      Future.delayed(Duration(seconds: 1)).then((_) => Navigator.pop(context));

      if (validCoupon == true) {
        mFlag = 1;
        setState(() {
          couponMSG = translate('Coupon_Applied');
          isCouponApplied = false;
          isDataAvailable = false;
          isStripeCoupon = true;
          widget.func();
        });
      } else {
        setState(() {
          couponMSG = translate('Coupon_has_been_expired');
          isCouponApplied = false;
          isDataAvailable = false;
          widget.func();
        });
      }
    } else {
      validCoupon = false;
      setState(() {
        couponMSG = translate('Invalid_Coupon_Code');
        isCouponApplied = false;
        isDataAvailable = false;
      });
      Future.delayed(Duration(seconds: 1)).then((_) => Navigator.pop(context));
      setState(() {
        isDataAvailable = false;
        widget.func();
      });
    }
    return null;
  }

  Future<void> _verifyCoupon(couponCode) async {
    var couponProvider =
        Provider.of<CouponProvider>(context, listen: false).couponModel;
    final applyCouponResponse =
        await http.post(Uri.parse(APIData.applyGeneralCoupon), headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken",
      "Content-Type": "application/x-www-form-urlencoded",
    }, body: {
      "coupon_code": couponCode,
    });
    print("applyCouponResponse: ${applyCouponResponse.body}");
    print("applyCouponResponse: ${applyCouponResponse.statusCode}");
    var applyCouponDetails = json.decode(applyCouponResponse.body);
    print("applyCouponResponse2: ${applyCouponDetails['message']}");
    if (applyCouponResponse.statusCode == 200) {
      for (int i = 0; i < couponProvider!.coupon!.length; i++) {
        print("applyCouponResponse22: ${couponProvider.coupon![i].amountOff}");
        if (couponProvider.coupon![i].couponCode == couponCode) {
          if (couponProvider.coupon![i].inStripe == "1" ||
              couponProvider.coupon![i].inStripe == 1) {
            _applyCoupon();
          } else {
            validCoupon = true;
            percentOFF = couponProvider.coupon![i].percentOff;
            amountOFF = couponProvider.coupon![i].amountOff;
            Future.delayed(Duration(seconds: 1))
                .then((_) => Navigator.pop(context));
            mFlag = 1;
            setState(() {
              couponMSG = translate('Coupon_Applied');
              isCouponApplied = false;
              isDataAvailable = false;
              widget.func();
            });
          }
        }
      }
    } else if (applyCouponResponse.statusCode == 401) {
      validCoupon = false;
      setState(() {
        couponMSG = translate('Coupon_has_been_expired');
        isCouponApplied = false;
        isDataAvailable = false;
      });
      Future.delayed(Duration(seconds: 1)).then((_) => Navigator.pop(context));
      setState(() {
        isDataAvailable = false;
        widget.func();
      });
    } else {
      validCoupon = false;
      setState(() {
        couponMSG = '${applyCouponDetails['message']}';
        isCouponApplied = false;
        isDataAvailable = false;
      });
      Future.delayed(Duration(seconds: 1)).then((_) => Navigator.pop(context));
      setState(() {
        isDataAvailable = false;
        widget.func();
      });
    }
  }

  Widget getCouponList(List<Coupon> cList) {
    List<Widget> list = [];
    for (int i = 0; i < cList.length; i++) {
      list.add(Container(
        height: 50,
        alignment: Alignment.topLeft,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            cList[i].percentOff == null
                ? Text(
                    "${cList[i].couponCode} ${cList[i].amountOff}"
                    "${cList[i].currency} ${translate('off_')}",
                    style: TextStyle(fontSize: 18.0),
                  )
                : Text(
                    "${cList[i].couponCode} ${cList[i].percentOff}"
                    " ${cList[i].currency} % ${translate('off_')}",
                    style: TextStyle(fontSize: 18.0),
                  )
          ],
        ),
      ));
    }
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: list,
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      CouponProvider couponProvider =
          Provider.of<CouponProvider>(context, listen: false);
      await couponProvider.getCoupons(context);
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var couponList = Provider.of<CouponProvider>(context).couponModel;
    return Scaffold(
      appBar: customAppBar(context, translate("Available_Coupons"))
          as PreferredSizeWidget?,
      body: _visible == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  children: [
                    Container(
                      height: 100.0,
                      child: Form(
                        key: _formKey,
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Container(
                                height: 60.0,
                                padding: EdgeInsets.all(8.0),
                                child: TextFormField(
                                  controller: _couponController,
                                  decoration: InputDecoration(
                                    hintText: translate("Enter_Coupon_Code"),
                                    errorText: _validate
                                        ? translate("Enter_Coupon")
                                        : null,
                                  ),
                                  validator: (val) {
                                    if (val!.length == 0) {
                                      return translate(
                                          'Please_Enter_Coupon_Code');
                                    } else {
                                      return null;
                                    }
                                  },
                                  onSaved: (val) =>
                                      _couponController.text = val!,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 1,
                              child: Container(
                                height: 60.0,
                                padding: const EdgeInsets.all(8.0),
                                child: isDataAvailable
                                    ? Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all<Color?>(
                                            activeDotColor,
                                          ),
                                        ),
                                        child: Text(translate("Apply_")),
                                        onPressed: () {
                                          final form = _formKey.currentState!;
                                          form.save();
                                          if (form.validate() == true) {
                                            FocusScope.of(context)
                                                .requestFocus(FocusNode());
                                            setState(() {
                                              couponCode =
                                                  _couponController.text;
                                            });
                                            _verifyCoupon(couponCode);
                                            isDataAvailable = true;
                                          }
                                        },
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),
                    getCouponList(couponList!.coupon!),
                  ],
                ),
              ),
            ),
    );
  }
}
