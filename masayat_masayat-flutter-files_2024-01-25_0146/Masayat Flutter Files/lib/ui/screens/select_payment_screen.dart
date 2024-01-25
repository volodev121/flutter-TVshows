import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:nexthour/providers/manual_payment_provider.dart';
import 'package:nexthour/ui/gateways/cashfree_payment.dart';
import 'package:nexthour/ui/gateways/instamojo.dart';
import 'package:nexthour/ui/gateways/manual_payment_list.dart';
import 'package:nexthour/ui/gateways/payhere_payment.dart';
import 'package:nexthour/ui/gateways/payumoney_payment.dart';
import 'package:nexthour/ui/gateways/rave_payment.dart';
import '../../providers/upi_details_provider.dart';
import '../gateways/upi_payment.dart';
import '/ui/gateways/braintree_payment.dart';
import '/common/apipath.dart';
import 'dart:async';
import '/common/global.dart';
import '/common/route_paths.dart';
import '/providers/app_config.dart';
import '/providers/payment_key_provider.dart';
import '/providers/user_profile_provider.dart';
import '/ui/gateways/bank_payment.dart';
import '../gateways/in_app_payment.dart';
import '/ui/gateways/paypal/PaypalPayment.dart';
import '/ui/gateways/paystack_payment.dart';
import '/ui/gateways/paytm_payment.dart';
import '/ui/gateways/razor_payment.dart';
import '/ui/gateways/stripe_payment.dart';
import '/ui/screens/apply_coupon_screen.dart';
import 'package:provider/provider.dart';

List listPaymentGateways = [];
String couponMSG = '';
var validCoupon, percentOFF, amountOFF;
bool isCouponApplied = true;
var mFlag = 0;
String couponCode = '';
var genCoupon; // Useless

var afterDiscountAmount;
bool isStripeCoupon = false;

class SelectPaymentScreen extends StatefulWidget {
  SelectPaymentScreen(this.planIndex);

  final planIndex;

  @override
  _SelectPaymentScreenState createState() => _SelectPaymentScreenState();
}

class _SelectPaymentScreenState extends State<SelectPaymentScreen>
    with TickerProviderStateMixin, RouteAware {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  ScrollController? _scrollViewController;

  TabController? _paymentTabController;
  bool isDataAvailable = false;
  var refreshKey = GlobalKey<RefreshIndicatorState>();

  bool loading = true;

  PageController hPagerController = PageController(keepPage: true);
  PageController vPagerController = PageController(keepPage: true);
  double mWidth = 100.0;
  double mHeight = 100.0;

  ManualPaymentProvider manualPaymentProvider = ManualPaymentProvider();

  @override
  void initState() {
    super.initState();

    setState(() {
      loading = true;
    });
    isCouponApplied = true;
    mFlag = 0;
    validCoupon = false;
    couponCode = '';
    isStripeCoupon = false;
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      PaymentKeyProvider paymentKeyProvider =
          Provider.of<PaymentKeyProvider>(context, listen: false);
      await paymentKeyProvider.fetchPaymentKeys();

      UpiDetailsProvider upiDetailsProvider =
          Provider.of<UpiDetailsProvider>(context, listen: false);
      await upiDetailsProvider.getData();

      manualPaymentProvider =
          Provider.of<ManualPaymentProvider>(context, listen: false);
      await manualPaymentProvider.fetchData();

      var manualPayment =
          manualPaymentProvider.manualPaymentModel!.manualPayment!.isNotEmpty
              ? "1"
              : "0";

      listPaymentGateways = [];
      var stripePayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .stripePayment;
      var inappPayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .inappPayment;
      var btreePayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .brainetreePayment;
      var paystackPayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .paystackPayment;
      var bankPayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .bankdetails;
      var instamojoPayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .instamojoPayment;
      var razorPayPaymentStatus = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .razorpayPayment;
      var paytmPaymentStatus = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .paytmPayment;
      var payPal = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .appConfig!
          .paypalPayment;
      var cashfreePayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .config!
          .cashfreePayment;
      var rave = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .config!
          .flutterravePayment;
      var payherePayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .config!
          .payherePayment;

      var upiPayment = upiDetailsProvider.upiDetailsModel != null
          ? upiDetailsProvider.upiDetailsModel!.upi!.status
          : 0;

      var payuPayment = Provider.of<AppConfig>(context, listen: false)
          .appModel!
          .config!
          .payherePayment; // Update it.

      if (instamojoPayment == 1 || "$instamojoPayment" == "1") {
        listPaymentGateways.add(PaymentGateInfo(title: 'InstaMojo', status: 1));
      }
      if (stripePayment == 1 || "$stripePayment" == "1") {
        listPaymentGateways.add(PaymentGateInfo(title: 'stripe', status: 1));
      }
      if (inappPayment == 1 || "$inappPayment" == "1") {
        if (Platform.isAndroid) {
          listPaymentGateways.add(PaymentGateInfo(title: 'inapp', status: 1));
        }
      }
      if (btreePayment == 1 || "$btreePayment" == "1") {
        listPaymentGateways.add(PaymentGateInfo(title: 'btree', status: 1));
      }
      if (paystackPayment == 1 || "$paystackPayment" == "1") {
        listPaymentGateways.add(PaymentGateInfo(title: 'paystack', status: 1));
      }
      if (bankPayment == 1 || "$bankPayment" == "1") {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'bankPayment', status: 1));
      }
      if (razorPayPaymentStatus == 1 || "$razorPayPaymentStatus" == "1") {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'razorPayment', status: 1));
      }
      if (paytmPaymentStatus == 1 || "$paytmPaymentStatus" == "1") {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'paytmPayment', status: 1));
      }
      if (payPal == 1 || "$payPal" == "1") {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'paypalPayment', status: 1));
      }
      // Manual payment
      if (manualPayment == '1' || '$manualPayment' == '1') {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'manualPayment', status: 1));
      }
      // Cashfree payment
      if (cashfreePayment == 1 || '$cashfreePayment' == '1') {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'cashfreePayment', status: 1));
      }
      // Rave payment
      if (rave == 1 || '$rave' == '1') {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'ravePayment', status: 1));
      }
      // Payhere payment
      if (payherePayment == 1 || '$payherePayment' == '1') {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'payherePayment', status: 1));
      }
      // UPI payment
      if (upiPayment == 1 || '$upiPayment' == '1') {
        listPaymentGateways
            .add(PaymentGateInfo(title: 'upiPayment', status: 1));
      }
      // PayU payment
      if (payuPayment == 1 || '$payuPayment' == '1') {
        listPaymentGateways.add(PaymentGateInfo(title: 'PayU', status: 1));
      }
      setState(() {
        loading = false;
      });
      _paymentTabController = TabController(
          vsync: this,
          length:
              listPaymentGateways.isNotEmpty ? listPaymentGateways.length : 0,
          initialIndex: 0);
    });
  }

  Future<Null> refreshList() async {
    refreshKey.currentState?.show();
    await Future.delayed(Duration(seconds: 2));
  }

//  Apply coupon forward icon
  Widget applyCouponIcon() {
    return Expanded(
      flex: 1,
      child: Padding(
        padding: EdgeInsets.only(left: 0.0),
        child: Icon(
          Icons.keyboard_arrow_right,
        ),
      ),
    );
  }

//  Gift icon
  Widget giftIcon() {
    return Padding(
      padding: EdgeInsets.only(left: 10.0),
      child: Icon(
        Icons.card_giftcard,
        color: Color.fromRGBO(125, 183, 91, 1.0),
      ),
    );
  }

//  Payment method tas
  Widget paymentMethodTabs() {
    return PreferredSize(
      child: SliverAppBar(
        title: TabBar(
          indicatorSize: TabBarIndicatorSize.tab,
          controller: _paymentTabController,
          indicatorColor: activeDotColor,
          isScrollable: true,
          tabs: List<Tab>.generate(
            listPaymentGateways.isEmpty ? 0 : listPaymentGateways.length,
            (int index) {
              if (listPaymentGateways[index].title == 'stripe') {
                return Tab(
                  child: tabLabelText('Stripe'),
                );
              }
              if (listPaymentGateways[index].title == 'btree') {
                return Tab(
                  child: tabLabelText('Braintree'),
                );
              }

              if (listPaymentGateways[index].title == 'paystack') {
                return Tab(
                  child: tabLabelText('Paystack'),
                );
              }
              if (listPaymentGateways[index].title == 'bankPayment') {
                return Tab(
                  child: tabLabelText('Bank Payment'),
                );
              }
              if (listPaymentGateways[index].title == 'PayU') {
                return Tab(
                  child: tabLabelText('PayU'),
                );
              }
              if (listPaymentGateways[index].title == 'InstaMojo') {
                return Tab(
                  child: tabLabelText('InstaMojo'),
                );
              }
              if (listPaymentGateways[index].title == 'razorPayment') {
                return Tab(
                  child: tabLabelText('RazorPay'),
                );
              }
              if (listPaymentGateways[index].title == 'paytmPayment') {
                return Tab(
                  child: tabLabelText('Paytm'),
                );
              }
              if (listPaymentGateways[index].title == 'paypalPayment') {
                return Tab(
                  child: tabLabelText('PayPal'),
                );
              }
              if (listPaymentGateways[index].title == 'inapp') {
                return Tab(
                  child: tabLabelText('In App'),
                );
              }
              if (listPaymentGateways[index].title == 'manualPayment') {
                return Tab(
                  child: tabLabelText('Manual'),
                );
              }
              if (listPaymentGateways[index].title == 'cashfreePayment') {
                return Tab(
                  child: tabLabelText('Cashfree'),
                );
              }
              if (listPaymentGateways[index].title == 'ravePayment') {
                return Tab(
                  child: tabLabelText('Rave'),
                );
              }
              if (listPaymentGateways[index].title == 'payherePayment') {
                return Tab(
                  child: tabLabelText('Payhere'),
                );
              }
              if (listPaymentGateways[index].title == 'upiPayment') {
                return Tab(
                  child: tabLabelText('UPI'),
                );
              }
              return Tab(
                child: tabLabelText('Default'),
              );
            },
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).primaryColorLight,
        pinned: true,
        floating: true,
      ),
      preferredSize: Size.fromHeight(0.0),
    );
  }

//  App bar material design
  Widget appbarMaterialDesign() {
    return Material(
      child: Container(
        height: 80.0,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            stops: [0.1, 0.3, 0.5, 0.7, 1.0],
            colors: [
              Color.fromRGBO(72, 163, 198, 1.0),
              Color.fromRGBO(30, 157, 207, 25),
              Color.fromRGBO(27, 162, 187, 50),
              Color.fromRGBO(32, 163, 173, 75),
              Color.fromRGBO(37, 164, 160, 100),
            ],
          ),
        ),
      ),
    );
  }

//  Select payment text
  Widget selectPaymentText() {
    var logo =
        Provider.of<AppConfig>(context, listen: false).appModel!.config!.logo;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(left: 20.0, top: 40.0),
        ),
        Expanded(
          flex: 1,
          child: Text(
            translate('Select_Payment'),
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        Expanded(
          flex: 1,
          child: Container(
            padding: EdgeInsets.only(left: 40.0, right: 20.0),
            child: Image.network('${APIData.logoImageUri}$logo'),
          ),
        )
      ],
    );
  }

//  Plan name and user name
  Widget planAndUserName(indexPer) {
    var planDetails = Provider.of<AppConfig>(context).planList;
    var name =
        Provider.of<UserProfileProvider>(context).userProfileModel!.user!.name!;
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
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Text(
                  "${planDetails[widget.planIndex].name}",
                  style: TextStyle(
                      color: Color.fromRGBO(72, 163, 198, 1.0),
                      fontSize: 14.0,
                      fontWeight: FontWeight.w600),
                ),
                Padding(
                  padding: EdgeInsets.only(top: 15.0),
                ),
                Text(
                  name,
                  style: TextStyle(
                    fontSize: 12.0,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

//  Minimum duration
  Widget minDuration(indexPer) {
    var planDetails = Provider.of<AppConfig>(context).planList;
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            translate('Min_duration') +
                ' ${planDetails[indexPer].intervalCount} ' +
                translate('days_'),
            style: TextStyle(
              fontSize: 12.0,
              height: 1.3,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 10.0),
          ),
          Text(
            new DateFormat.yMMMd().format(new DateTime.now()),
            style: TextStyle(
              fontSize: 12.0,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

//  After applying coupon
  Widget couponProcessing(afterDiscountAmount, indexPer) {
    var planDetails = Provider.of<AppConfig>(context).planList;
    return Container(
      margin: EdgeInsets.fromLTRB(20.0, 10.0, 20, 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Row(
            children: <Widget>[
              discountText(),
              Expanded(
                flex: 1,
                child: validCoupon == true && percentOFF != null
                    ? Text(
                        percentOFF.toString() + " %",
                        style: TextStyle(
                          fontSize: 12.0,
                          height: 1.3,
                        ),
                      )
                    : amountOFF != null
                        ? Text(
                            amountOFF.toString() +
                                " ${planDetails[widget.planIndex].currency}",
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.3,
                            ),
                          )
                        : Text(
                            "0 %",
                            style: TextStyle(
                              fontSize: 12.0,
                              height: 1.3,
                            ),
                          ),
              ),
            ],
          ),
          SizedBox(
            height: 10.0,
          ),
          Row(
            children: <Widget>[
              afterDiscountText(),
              Expanded(
                flex: 1,
                child: validCoupon == true
                    ? Text(
                        afterDiscountAmount.toString() +
                            " ${planDetails[widget.planIndex].currency}",
                        style: TextStyle(
                          fontSize: 12.0,
                          height: 1.3,
                        ),
                      )
                    : amountText(indexPer),
              ),
            ],
          )
        ],
      ),
    );
  }

//  Plan amount
  Widget planAmountText(indexPer, dailyAmountAp) {
    var planDetails = Provider.of<AppConfig>(context).planList;
    return Expanded(
      flex: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Container(
            child: Text(
              "${planDetails[widget.planIndex].amount}" +
                  " ${currency(planDetails[indexPer].currency)}".toUpperCase(),
              style: TextStyle(
                fontSize: 22.0,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Container(
            child: Text(
              '( $dailyAmountAp' +
                  ' ${currency(planDetails[widget.planIndex].currency)} / ${planDetails[widget.planIndex].interval} )',
              style: TextStyle(
                fontSize: 10.0,
                letterSpacing: 0.8,
                height: 1.3,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

//  Logo row
  Widget logoRow() {
    var logo =
        Provider.of<AppConfig>(context, listen: false).appModel!.config!.logo;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.end,
      children: <Widget>[
        Container(
          margin: EdgeInsets.only(top: 12.0, right: 12.0),
          alignment: Alignment.center,
          child: Image.network(
            '${APIData.logoImageUri}$logo',
            scale: 1.9,
          ),
        ),
      ],
    );
  }

//  Discount percent
  Widget discountText() {
    return Expanded(
      flex: 5,
      child: Text(
        translate("Discount_"),
        style: TextStyle(
          fontSize: 12.0,
          height: 1.3,
        ),
      ),
    );
  }

//  Amount after discount
  Widget afterDiscountText() {
    return Expanded(
      flex: 5,
      child: Text(
        translate("After_Discount_Amount_"),
        style: TextStyle(
          fontSize: 12.0,
          height: 1.3,
        ),
      ),
    );
  }

  String currency(code) {
    var format = NumberFormat.simpleCurrency(
      name: code, //currencyCode
    );
    print("CURRENCY SYMBOL ${format.currencySymbol}"); // $
    print("CURRENCY NAME ${format.currencyName}"); // USD
    return "${format.currencySymbol}";
  }

//  Amount
  Widget amountText(indexPer) {
    var planDetails = Provider.of<AppConfig>(context).planList;
    return Text(
      "${planDetails[indexPer].amount}" +
          " ${currency(planDetails[indexPer].currency)}",
      style: TextStyle(
        fontSize: 12.0,
        height: 1.3,
      ),
    );
  }

//  Tab label text
  Widget tabLabelText(label) {
    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      child: new Text(
        label,
        style: TextStyle(
          fontFamily: 'Lato',
          fontSize: 13.0,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.9,
        ),
      ),
    );
  }

// Swipe down row
  Widget swipeDownRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        SizedBox(
          height: 100.0,
        ),
        swipeIconContainer(),
        SizedBox(
          width: 10.0,
        ),
        swipeDownText(),
      ],
    );
  }

// Swipe icon container
  Widget swipeIconContainer() {
    return Container(
      height: 25.0,
      width: 25.0,
      decoration: BoxDecoration(
        border: Border.all(
          width: 2.0,
          color: Color.fromRGBO(125, 183, 91, 1.0),
        ),
        shape: BoxShape.circle,
        color: Theme.of(context).colorScheme.background,
      ),
      child: Icon(
        Icons.keyboard_arrow_down,
        size: 21.0,
      ),
    );
  }

//  Swipe down text
  Widget swipeDownText() {
    return Text(
      translate("Swipe_down_wallet_to_pay"),
      style: TextStyle(
        fontSize: 16.0,
      ),
    );
  }

  // Instamojo Payment
  Widget instamojo(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
                direction: DismissDirection.down,
                key: Key('$indexPer'),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }

                  if (couponCode == '') {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.instaMojo,
                      arguments: InstamojoPaymentPage(
                        indexPer,
                        null,
                      ),
                    );
                  } else {
                    if (afterDiscountAmount > 0 && !isStripeCoupon) {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.instaMojo,
                        arguments: InstamojoPaymentPage(
                          indexPer,
                          afterDiscountAmount,
                        ),
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.instaMojo,
                        arguments: InstamojoPaymentPage(
                          indexPer,
                          null,
                        ),
                      );
                    }
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/instamojo.png"),
                )),
          ],
        ),
      ),
    );
  }

  // Bank Payment wallet <-
  Widget bankPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
            ),
            swipeDownRow(),
            Dismissible(
                direction: DismissDirection.down,
                key: Key("$indexPer"),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }

                  if (couponCode == '') {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => BankPayment(),
                      ),
                    );
                  } else {
                    if (afterDiscountAmount > 0 && !isStripeCoupon) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => BankPayment(),
                        ),
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) => BankPayment(),
                        ),
                      );
                    }
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/bankwallets.png"),
                )),
          ],
        ),
      ),
    );
  }

  // Razorpay Payment wallet
  Widget razorPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
                direction: DismissDirection.down,
                key: Key("$indexPer"),
                confirmDismiss: (direction) async {
                  if (direction == DismissDirection.startToEnd) {
                    return false;
                  } else if (direction == DismissDirection.endToStart) {
                    return true;
                  }

                  if (couponCode == '') {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.razorpay,
                      arguments: RazorPayment(
                        indexPer,
                        null,
                      ),
                    );
                  } else {
                    if (afterDiscountAmount > 0 && !isStripeCoupon) {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.razorpay,
                        arguments: RazorPayment(
                          indexPer,
                          afterDiscountAmount,
                        ),
                      );
                    } else {
                      Navigator.pushNamed(
                        context,
                        RoutePaths.razorpay,
                        arguments: RazorPayment(
                          indexPer,
                          null,
                        ),
                      );
                    }
                  }
                  return null;
                },
                child: Padding(
                  padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                  child: Image.asset("assets/razorpay.png"),
                )),
          ],
        ),
      ),
    );
  }

  // Paytm Payment wallet
  Widget paytmPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
              direction: DismissDirection.down,
              key: Key("$indexPer"),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.paytm,
                    arguments: PaytmPayment(
                      indexPer,
                      null,
                    ),
                  );
                  return Future.value(direction == DismissDirection.endToStart);
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.paytm,
                      arguments: PaytmPayment(
                        indexPer,
                        afterDiscountAmount,
                      ),
                    );
                    return Future.value(
                        direction == DismissDirection.endToStart);
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.paytm,
                      arguments: PaytmPayment(
                        indexPer,
                        null,
                      ),
                    );
                    return Future.value(
                        direction == DismissDirection.endToStart);
                  }
                }
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/paytm.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Paystack Payment wallet
  Widget paystackPaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
              direction: DismissDirection.down,
              key: Key("$indexPer"),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.paystack,
                    arguments: PaystackPayment(
                      indexPer,
                      null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.paystack,
                      arguments: PaystackPayment(
                        indexPer,
                        afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.paystack,
                      arguments: PaystackPayment(
                        indexPer,
                        null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/paystackwallets.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stripe Payment wallet
  Widget stripePaymentWallet(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            swipeDownRow(),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  Fluttertoast.showToast(msg: couponMSG);
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.stripe,
                    arguments: StripePayment(
                      indexPer,
                      couponCode,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.stripe,
                      arguments: StripePayment(
                        indexPer,
                        couponCode,
                      ),
                    );
                  } else if (isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.stripe,
                      arguments: StripePayment(
                        indexPer,
                        couponCode,
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                        msg: translate(
                            "This_coupon_cant_be_applicable_for_Stripe_payment"));
                    return false;
                  }
                }
                Future.delayed(Duration(seconds: 1)).then((_) {
                  validCoupon == false
                      ? Fluttertoast.showToast(msg: couponMSG)
                      : SizedBox.shrink();
                });

                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/stripe.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // PayU Payment - Incomplete
  Widget payu(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.payu,
                    arguments: PayuPayment(
                      planIndex: indexPer,
                      payAmount: null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.payu,
                      arguments: PayuPayment(
                        planIndex: indexPer,
                        payAmount: afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.payu,
                      arguments: PayuPayment(
                        planIndex: indexPer,
                        payAmount: null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/payumoney.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Braintree Payment wallet
  Widget braintreePayment(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.braintree,
                    arguments: BraintreePaymentScreen(
                      indexPer,
                      null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.braintree,
                      arguments: BraintreePaymentScreen(
                        indexPer,
                        afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.braintree,
                      arguments: BraintreePaymentScreen(
                        indexPer,
                        null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/braintreewallet.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Paypal Payment wallet
  Widget paypalPayment(indexPer) {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    var appConfig = Provider.of<AppConfig>(context, listen: false).appModel;
    var planDetails = Provider.of<AppConfig>(context).planList;
    planDetails.sort((a, b) => a.amount!.compareTo(b.amount!));

    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  onPayWithPayPal(
                    appConfig,
                    userDetails,
                    indexPer,
                    null,
                    planDetails,
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    onPayWithPayPal(
                      appConfig,
                      userDetails,
                      indexPer,
                      afterDiscountAmount,
                      planDetails,
                    );
                  } else {
                    onPayWithPayPal(
                      appConfig,
                      userDetails,
                      indexPer,
                      null,
                      planDetails,
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/paypal.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void onPayWithPayPal(appConfig, userDetails, indexPer, amount, planDetails) {
    print("currency codes for pay pal : ${appConfig.config.currencyCode}");
    print("currency codes for amount1 : ${appConfig.plans[indexPer].amount}");
    print("currency codes for amount2 : $amount");
    print("id for paypal : ${appConfig.plans[widget.planIndex].id}");
    print("name for paypal : ${appConfig.plans[widget.planIndex].name}");

    print("id for paypal : ${planDetails[widget.planIndex].id}");
    print("name for paypal : ${planDetails[widget.planIndex].name}");

    Navigator.pushNamed(
      context,
      RoutePaths.paypal,
      arguments: PaypalPayment(
        onFinish: (number) async {},
        currency: "${planDetails[widget.planIndex].currency}",
        userFirstName: userDetails.user.name,
        userLastName: "",
        userEmail: userDetails.user.email,
        payAmount: amount == null
            ? "${planDetails[widget.planIndex].amount}"
            : "$amount",
        planName: planDetails[widget.planIndex].name,
        planIndex: planDetails[widget.planIndex].id,
      ),
    );
  }

  // InApp Payment wallet - Incomplete
  Widget inappPayment(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  if (genCoupon == null) {
                    Navigator.pushNamed(context, RoutePaths.inApp,
                        arguments: InApp(indexPer));
                  } else {
                    Fluttertoast.showToast(
                        msg: translate(
                            "Coupon_cant_be_applied_for_this_payment_gateway"));
                    return false;
                  }
                } else {
                  Future.delayed(Duration(seconds: 1)).then((_) {
                    Fluttertoast.showToast(
                        msg: translate("Coupon_is_only_applicable_to_Stripe"));
                  });
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/inapp.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Manual Payment
  Widget manualPayment(indexPer) {
    log('Bearer Token :-> $authToken');
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.ManualPaymentList,
                    arguments: ManualPaymentList(
                      manualPaymentModel:
                          manualPaymentProvider.manualPaymentModel!,
                      planIndex: indexPer,
                      payAmount: null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.ManualPaymentList,
                      arguments: ManualPaymentList(
                        manualPaymentModel:
                            manualPaymentProvider.manualPaymentModel!,
                        planIndex: indexPer,
                        payAmount: afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.ManualPaymentList,
                      arguments: ManualPaymentList(
                        manualPaymentModel:
                            manualPaymentProvider.manualPaymentModel!,
                        planIndex: indexPer,
                        payAmount: null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/manualpayment.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Cashfree Payment
  Widget cashfreePayment(indexPer) {
    log('Bearer Token :-> $authToken');
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.CashfreePayment,
                    arguments: CashfreePayment(
                      planIndex: indexPer,
                      payAmount: null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.CashfreePayment,
                      arguments: CashfreePayment(
                        planIndex: indexPer,
                        payAmount: afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.CashfreePayment,
                      arguments: CashfreePayment(
                        planIndex: indexPer,
                        payAmount: null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/cashfree.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rave Payment
  Widget ravePayment(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.RavePayment,
                    arguments: RavePayment(
                      planIndex: indexPer,
                      payAmount: null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.RavePayment,
                      arguments: RavePayment(
                        planIndex: indexPer,
                        payAmount: afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.RavePayment,
                      arguments: RavePayment(
                        planIndex: indexPer,
                        payAmount: null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/rave.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Payhere Payment
  Widget payherePayment(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.PayherePayment,
                    arguments: PayHerePayment(
                      planIndex: indexPer,
                      payAmount: null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.PayherePayment,
                      arguments: PayHerePayment(
                        planIndex: indexPer,
                        payAmount: afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.PayherePayment,
                      arguments: PayHerePayment(
                        planIndex: indexPer,
                        payAmount: null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/payhere.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Payhere Payment
  Widget upiPayment(indexPer) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Theme.of(context).colorScheme.background,
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  height: 100.0,
                ),
                Container(
                  height: 25.0,
                  width: 25.0,
                  decoration: BoxDecoration(
                    border: Border.all(
                        width: 2.0, color: Color.fromRGBO(125, 183, 91, 1.0)),
                    shape: BoxShape.circle,
                    color: Theme.of(context).colorScheme.background,
                  ),
                  child: Icon(
                    Icons.keyboard_arrow_down,
                    size: 21.0,
                  ),
                ),
                SizedBox(
                  width: 10.0,
                ),
                Text(
                  translate("Swipe_down_wallet_to_pay"),
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
            Dismissible(
              direction: DismissDirection.down,
              key: Key('$indexPer'),
              confirmDismiss: (direction) async {
                if (direction == DismissDirection.startToEnd) {
                  return false;
                } else if (direction == DismissDirection.endToStart) {
                  return true;
                }

                if (couponCode == '') {
                  Navigator.pushNamed(
                    context,
                    RoutePaths.UpiPayment,
                    arguments: UPIPayment(
                      planIndex: indexPer,
                      payAmount: null,
                    ),
                  );
                } else {
                  if (afterDiscountAmount > 0 && !isStripeCoupon) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.UpiPayment,
                      arguments: UPIPayment(
                        planIndex: indexPer,
                        payAmount: afterDiscountAmount,
                      ),
                    );
                  } else {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.UpiPayment,
                      arguments: UPIPayment(
                        planIndex: indexPer,
                        payAmount: null,
                      ),
                    );
                  }
                }
                return null;
              },
              child: Padding(
                padding: EdgeInsets.fromLTRB(120.0, 0.0, 100.0, 0.0),
                child: Image.asset("assets/upi.png"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  Sliver List
  Widget _sliverList(dailyAmountAp, afterDiscountAmount, planDetails) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int j) {
          return Container(
            child: Column(
              children: <Widget>[
                new Container(
                  child: Column(
                    children: <Widget>[
                      Stack(
                        children: <Widget>[
                          appbarMaterialDesign(),
                          Container(
                            margin: EdgeInsets.only(top: 60.0),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColorLight,
                              borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20.0),
                                  topRight: Radius.circular(20.0)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                AspectRatio(
                                  aspectRatio: validCoupon == true
                                      ? 16.0 / 15.0
                                      : 16.0 / 13.0,
                                  child: Column(
                                    children: <Widget>[
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 0.0, 0.0),
                                      ),
                                      selectPaymentText(),
                                      planAndUserName(widget.planIndex),
                                      Padding(
                                        padding: EdgeInsets.fromLTRB(
                                            0.0, 10.0, 0.0, 0.0),
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: <Widget>[
                                            Padding(
                                              padding:
                                                  EdgeInsets.only(left: 20.0),
                                            ),
                                            minDuration(widget.planIndex),
                                            planAmountText(widget.planIndex,
                                                dailyAmountAp),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(top: 40.0),
                                      ),
                                      InkWell(
                                        child: Container(
                                          margin: EdgeInsets.only(
                                              left: 20.0, right: 20.0),
                                          height: 50.0,
                                          width:
                                              MediaQuery.of(context).size.width,
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: <Widget>[
                                              Expanded(
                                                flex: 5,
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    giftIcon(),
                                                    Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 10.0),
                                                      child: isCouponApplied
                                                          ? Text("Apply Coupon")
                                                          : Text(
                                                              couponCode,
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                            ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                              applyCouponIcon(),
                                            ],
                                          ),
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                              width: 2.0,
                                            ),
                                          ),
                                        ),
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            RoutePaths.applyCoupon,
                                            arguments: ApplyCouponScreen(
                                              planDetails[widget.planIndex]
                                                  .amount,
                                              setState_,
                                            ),
                                          );
                                        },
                                      ),
                                      Container(
                                        height: 30.0,
                                        child: isCouponApplied
                                            ? SizedBox.shrink()
                                            : Padding(
                                                padding:
                                                    EdgeInsets.only(left: 40.0),
                                                child: Row(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.center,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    validCoupon == true
                                                        ? Icon(
                                                            FontAwesomeIcons
                                                                .solidCircleCheck,
                                                            color:
                                                                activeDotColor,
                                                            size: 13.0,
                                                          )
                                                        : Icon(
                                                            FontAwesomeIcons
                                                                .solidCircleXmark,
                                                            color: Colors.red,
                                                            size: 13.0,
                                                          ),
                                                    SizedBox(
                                                      width: 10.0,
                                                    ),
                                                    Text(
                                                      couponMSG,
                                                      style: TextStyle(
                                                        color:
                                                            validCoupon == true
                                                                ? Colors.green
                                                                : Colors.red,
                                                        fontSize: 12.0,
                                                        letterSpacing: 0.7,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                      ),
                                      validCoupon == true
                                          ? couponProcessing(
                                              afterDiscountAmount,
                                              widget.planIndex,
                                            )
                                          : SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 2.0,
                                ),
                              ],
                            ),
                          ),
                          new Positioned(
                            top: 8.0,
                            left: 4.0,
                            child: new BackButton(color: Colors.white),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
        addSemanticIndexes: true,
        childCount: 1,
      ),
    );
  }

  //  Scaffold body
  Widget _scaffoldBody(dailyAmountAp, afterDiscountAmount, planDetails) {
    return NestedScrollView(
      physics: ClampingScrollPhysics(),
      controller: _scrollViewController,
      headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
        return <Widget>[
          _sliverList(dailyAmountAp, afterDiscountAmount, planDetails),
          paymentMethodTabs(),
        ];
      },
      body: _nestedScrollViewBody(),
    );
  }

  // NestedScrollView body
  Widget _nestedScrollViewBody() {
    return listPaymentGateways.length == 0
        ? Center(
            child: Text(translate("No_payment_method_available")),
          )
        : TabBarView(
            controller: _paymentTabController,
            physics: PageScrollPhysics(),
            children: List<Widget>.generate(
                listPaymentGateways.isEmpty ? 0 : listPaymentGateways.length,
                (int index) {
              if (listPaymentGateways[index].title == 'PayU') {
                return InkWell(
                  child: payu(widget.planIndex),
                );
              }

              if (listPaymentGateways[index].title == 'InstaMojo') {
                return InkWell(
                  child: instamojo(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'btree') {
                return InkWell(
                  child: braintreePayment(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'stripe') {
                return InkWell(
                  child: stripePaymentWallet(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'paystack') {
                return InkWell(
                  child: paystackPaymentWallet(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'bankPayment') {
                return InkWell(
                  child: bankPaymentWallet(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'razorPayment') {
                return InkWell(
                  child: razorPaymentWallet(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'paytmPayment') {
                return InkWell(
                  child: paytmPaymentWallet(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'paypalPayment') {
                return InkWell(
                  child: paypalPayment(widget.planIndex),
                );
              }
              if (listPaymentGateways[index].title == 'inapp') {
                return InkWell(
                  child: inappPayment(widget.planIndex),
                );
              }
              // Manual Payment
              if (listPaymentGateways[index].title == 'manualPayment') {
                return InkWell(
                  child: manualPayment(widget.planIndex),
                );
              }
              // Cashfree Payment
              if (listPaymentGateways[index].title == 'cashfreePayment') {
                return InkWell(
                  child: cashfreePayment(widget.planIndex),
                );
              }
              // Rave Payment
              if (listPaymentGateways[index].title == 'ravePayment') {
                return InkWell(
                  child: ravePayment(widget.planIndex),
                );
              }
              // Payhere Payment
              if (listPaymentGateways[index].title == 'payherePayment') {
                return InkWell(
                  child: payherePayment(widget.planIndex),
                );
              }
              // UPI Payment
              if (listPaymentGateways[index].title == 'upiPayment') {
                return InkWell(
                  child: upiPayment(widget.planIndex),
                );
              }
              return widget;
            }));
  }

  void setState_() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var planDetails = Provider.of<AppConfig>(context).planList;
    var dailyAmount1;
    var intervalCount;
    dynamic planAm = planDetails[widget.planIndex].amount;
    switch (planAm.runtimeType) {
      case int:
        dailyAmount1 = planAm;
        break;
      case String:
        dailyAmount1 = double.parse(planAm);
        break;
      case double:
        dailyAmount1 = planAm;
        break;
    }
    dynamic interCount = planDetails[widget.planIndex].intervalCount;
    switch (interCount.runtimeType) {
      case int:
        intervalCount = interCount;
        break;
      case String:
        intervalCount = int.parse(interCount);
        break;
    }
    var dailyAmount = dailyAmount1 / intervalCount;
    String? dailyAmountAp = dailyAmount.toStringAsFixed(2);
    var planAmount;
    if (planDetails[widget.planIndex].amount != null) {
      if (planDetails[widget.planIndex].amount.runtimeType == String) {
        planAmount = double.parse(planDetails[widget.planIndex].amount);
      } else {
        planAmount = planDetails[widget.planIndex].amount;
      }
    }
    var amountOff = validCoupon == true
        ? percentOFF != null
            ? (percentOFF / 100) * planAmount
            : amountOFF
        : 0;
    afterDiscountAmount = validCoupon == true ? planAmount - amountOff : 0;

    return SafeArea(
      child: WillPopScope(
        child: DefaultTabController(
          length: 2,
          child: Scaffold(
            key: _scaffoldKey,
            body: loading == true
                ? Center(
                    child: CircularProgressIndicator(
                      valueColor: new AlwaysStoppedAnimation<Color>(
                          Theme.of(context).primaryColor),
                    ),
                  )
                : _scaffoldBody(
                    dailyAmountAp, afterDiscountAmount, planDetails),
          ),
        ),
        onWillPop: () async {
          return true;
        },
      ),
    );
  }
}

class PaymentGateInfo {
  String? title;
  dynamic status;

  PaymentGateInfo({this.title, this.status});
}
