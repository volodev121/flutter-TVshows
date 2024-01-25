import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import '../../stripe-sdk/model/card.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/providers/app_config.dart';
import '/providers/payment_key_provider.dart';
import '/providers/user_profile_provider.dart';
// ignore: import_of_legacy_library_into_null_safe
import '/stripe-sdk/stripe_api.dart';
import '/ui/screens/splash_screen.dart';
import '/ui/widgets/credit_card_form.dart';
import '/ui/widgets/credit_card_model.dart';
import '/ui/widgets/credit_card_widget.dart';
import '/ui/widgets/profile_tile.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;

class StripePayment extends StatefulWidget {
  StripePayment(this.index, this.couponCode);
  final int index;
  final String couponCode;
  @override
  _StripePaymentState createState() => _StripePaymentState();
}

class _StripePaymentState extends State<StripePayment> {
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
  String? cardNumber = '';
  String? expiryDate = '';
  String? cardHolderName = '';
  String? cvvCode = '';
  bool isCvvFocused = false;
  bool isDataAvailable = true;
  bool isAmex = false;
  var cardLast4;
  var cardtype;
  var customerStripeId;
  var planId;
  var subId;
  var stripeCustomerId;
  bool _visible = false;

  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
//  Customer is created on stripe for making payment.
  Future<String?> _createCustomer(name, email, stripePass, planId) async {
    final menuResponse = await http.post(
        Uri.parse("https://api.stripe.com/v1/customers?name=" +
            "$name" +
            "&email=" +
            "$email"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $stripePass"});
    if (menuResponse.statusCode == 200) {
      var customerStripeDetails = json.decode(menuResponse.body);
      print("Customer_Created");
      setState(() {
        customerStripeId = customerStripeDetails['id'];
      });

      _saveCard(customerStripeId, stripePass, planId);
    }
    return null;
  }

  void _saveCard(customerStripeId, stripePass, planId) {
    List x = expiryDate!.split("/");
    var x1 = int.parse(x[0]);
    var x2 = int.parse(x[1]);
    StripeCard card = new StripeCard(
        id: '', number: cardNumber!, cvc: cvvCode!, expMonth: x1, expYear: x2);
    card.name = cardHolderName!;
    Stripe.instance!
        .createCardToken(card)
        .then((c) {
          print("Card Saved");
          _saveCardForCustomer(customerStripeId, c.id, stripePass, planId);
        })
        .then((source) {})
        .catchError((error) {
          String message = '$error';
          showErrorDialog(message);
        });
  }

//  Stripe card is automatically saved for customer for future payment.

  Future<String?> _saveCardForCustomer(
      customerStripeId, cardid, stripePass, planId) async {
    final saveCardResponse = await http.post(
        Uri.parse("https://api.stripe.com/v1/customers/" +
            "$customerStripeId" +
            "/sources?source=" +
            "$cardid"),
        headers: {HttpHeaders.authorizationHeader: "Bearer $stripePass"});

    var cardDetails = json.decode(saveCardResponse.body);
    if (saveCardResponse.statusCode == 200) {
      print("Card Saved for customer");
      cardid = cardDetails['id'];
      cardtype = cardDetails['funding'];
      cardtype = capitalize(cardtype);
      var cardBrand = cardDetails['brand'];
      cardLast4 = cardDetails['last4'];
      _createSubscription(customerStripeId, cardid, cardtype, cardBrand,
          cardLast4, stripePass, planId);
    } else {
      print("errors Card Saved for customer");
      var code = cardDetails['error']['code'];
      if (code == 'card_declined') {
        var message = 'Your card was declined!';
        showErrorDialog(message);
      }
      setState(() {
        isDataAvailable = true;
      });
    }

    return null;
  }

//  Creating stripe subscription form the customer using customer Id and plan.
  Future<String?> _createSubscription(customerStripeId, cardid, cardtype,
      cardBrand, cardLast4, stripePass, planId) async {
    var subscriptionResponse;
    if (widget.couponCode != '') {
      print('01');
      var stripeUri = "https://api.stripe.com/v1/customers/" +
          "$customerStripeId" +
          "/subscriptions?plan="
              "" +
          "$planId" +
          "&quantity=1&default_source=" +
          "$cardid" +
          "&coupon=" +
          "${widget.couponCode}";
      subscriptionResponse = await http.post(Uri.parse("$stripeUri"),
          headers: {HttpHeaders.authorizationHeader: "Bearer $stripePass"});
    } else {
      print('02');
      subscriptionResponse = await http.post(
          Uri.parse("https://api.stripe.com/v1/customers/" +
              "$customerStripeId" +
              "/subscriptions?plan=" +
              "$planId" +
              "&quantity=1&default_source=" +
              "$cardid"),
          headers: {HttpHeaders.authorizationHeader: "Bearer $stripePass"});
    }
    var subscriptionDetail = json.decode(subscriptionResponse.body);
    var subscriptionDate = subscriptionDetail['created'];
    var transResponse = subscriptionDetail['id'];

    if (subscriptionResponse.statusCode == 200) {
      print('subscription Successful');
      readTimestamp(subscriptionDate, cardtype, cardBrand, cardLast4);
      subId = transResponse;
      _sendStripeDetailsToServer();
    } else {
      print('Subscription Unsuccessful');
      print('details: $subscriptionDetail');
      print('details: ${subscriptionResponse.statusCode}');
      Fluttertoast.showToast(msg: "This plan not Registered on Strip A/c");
      var code = subscriptionDetail['error']['code'];
      if (code == 'customer_max_subscriptions') {
        var message = 'Already has the maximum 25 current subscriptions!';
        showErrorDialog(message);
      }

      setState(() {
        isDataAvailable = true;
      });
    }
    return null;
  }

//  Send stripe payment subscription to the next hour server
  Future<String?> _sendStripeDetailsToServer() async {
    final response =
        await http.post(Uri.parse(APIData.stripeProfileApi), body: {
      "customer": customerStripeId,
      "type": cardtype,
      "card": cardLast4,
      "transaction": subId,
    }, headers: {
      HttpHeaders.authorizationHeader: "Bearer $authToken",
    });
    print('fina;l resp : ${response.statusCode}');
    return null;
  }

//    Validation alert dialog
  Future<void> _ackAlert(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(40.0),
            ),
            child: AlertDialog(
              backgroundColor: Color.fromRGBO(30, 30, 30, 1.0),
              contentPadding: const EdgeInsets.all(16.0),
              title: Text('Oops!'),
              content: const Text('Please enter all fields!'),
              actions: <Widget>[
                TextButton(
                  child: Text(
                    'Ok',
                    style: TextStyle(fontSize: 16.0),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void onCreditCardModelChange(CreditCardModel creditCardModel) {
    setState(() {
      cardNumber = creditCardModel.cardNumber;
      expiryDate = creditCardModel.expiryDate;
      cardHolderName = creditCardModel.cardHolderName;
      cvvCode = creditCardModel.cvvCode;
      isCvvFocused = creditCardModel.isCvvFocused;
    });
  }

//  Show success dialog
  void showSuccessDialog() {
    setState(() {
      isDataAvailable = false;
    });
  }

//  Show error dialog
  void showErrorDialog(message) {
    setState(() {
      isDataAvailable = true;
    });
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => Center(
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              errorTicket(message),
              SizedBox(
                height: 10.0,
              ),
              FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  Navigator.pop(context);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  String readTimestamp(int timestamp, cardtype, cardBrand, cardLast4) {
    var now = new DateTime.now();
    var format1 = new DateFormat('d MMM y');
    var format2 = new DateFormat('HH:mm a');
    var date = new DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    var diff = now.difference(date);
    var subdate = '';
    var time = '';
    subdate = format1.format(date);
    if (diff.inSeconds <= 0 ||
        diff.inSeconds > 0 && diff.inMinutes == 0 ||
        diff.inMinutes > 0 && diff.inHours == 0 ||
        diff.inHours > 0 && diff.inDays == 0) {
      time = format2.format(date);
    } else if (diff.inDays > 0 && diff.inDays < 7) {
      if (diff.inDays == 1) {
        time = diff.inDays.toString() + ' DAY AGO';
      } else {
        time = diff.inDays.toString() + ' DAYS AGO';
      }
    } else {
      if (diff.inDays == 7) {
        time = (diff.inDays / 7).floor().toString() + ' WEEK AGO';
      } else {
        time = (diff.inDays / 7).floor().toString() + ' WEEKS AGO';
      }
    }
    setState(() {
      Future.delayed(Duration(seconds: 1)).then(
          (_) => goToDialog(subdate, time, cardtype, cardBrand, cardLast4));
    });
    return time;
  }

  getCardTypeIcon(String cardNumber) {
    Widget icon;
    switch (detectCCType(cardNumber)) {
      case CardType.visa:
        icon = Image.asset(
          'icons/visa2.png',
          height: 48,
          width: 48,
        );
        isAmex = false;
        break;

      case CardType.americanExpress:
        icon = Image.asset(
          'icons/amex.png',
          height: 48,
          width: 48,
        );
        isAmex = true;
        break;

      case CardType.mastercard:
        icon = Image.asset(
          'icons/mastercard.png',
          height: 48,
          width: 48,
        );
        isAmex = false;
        break;

      case CardType.discover:
        icon = Image.asset(
          'icons/discover.png',
          height: 48,
          width: 48,
        );
        isAmex = false;
        break;

      default:
        icon = Container(
          height: 48,
          width: 48,
        );
        isAmex = false;
        break;
    }

    return icon;
  }

  Widget appBar(logo) {
    return AppBar(
      leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          }),
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
//    Setting logo in the app bar from server
          Image.network(
            '${APIData.logoImageUri}$logo',
            scale: 1.7,
          )
        ],
      ),
      backgroundColor: Color.fromRGBO(34, 34, 34, 1.0).withOpacity(0.98),
    );
  }

//  Payment Process on tapping button
  Widget floatingBar() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel;
    var stripeKey = Provider.of<PaymentKeyProvider>(context, listen: false)
        .paymentKeyModel!
        .key;
    var stripePass = Provider.of<PaymentKeyProvider>(context, listen: false)
        .paymentKeyModel!
        .pass;
    var planList = Provider.of<AppConfig>(context, listen: false).planList;
    return Container(
      child: isDataAvailable
          ? Material(
              borderRadius: BorderRadius.circular(25.0),
              child: Container(
                decoration: ShapeDecoration(
                  shape: StadiumBorder(),
                  color: Color(0xFFF1E32A),
                ),
                child: FloatingActionButton.extended(
                  onPressed: () {
                    if (cardNumber!.length == 0 ||
                        expiryDate!.length == 0 ||
                        cardHolderName!.length == 0 ||
                        cvvCode!.length == 0) {
                      _ackAlert(context);
                    } else {
                      if (stripeKey == null) {
                        Fluttertoast.showToast(msg: "Stripe key not entered.");
                      } else {
                        SystemChannels.textInput.invokeMethod('TextInput.hide');
                        Fluttertoast.showToast(msg: "Don't press back button.");
                        if (stripeCustomerId != null) {
                          setState(() {
                            customerStripeId = stripeCustomerId;
                          });
                          _saveCard(stripeCustomerId, stripePass, planId);
                        } else {
                          _createCustomer(
                              userDetails!.user!.name,
                              userDetails.user!.email,
                              stripePass,
                              planList[widget.index].planId);
                        }
                        showSuccessDialog();
                      }
                    }
                  },
                  backgroundColor: Colors.transparent,
                  icon: Icon(
                    FontAwesomeIcons.amazonPay,
                    color: Colors.white,
                  ),
                  label: Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            )
          : CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
            ),
    );
  }

  Widget successTicket(subdate, time, cardtype, cardBrand, cardLast4) {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    var planList = Provider.of<AppConfig>(context, listen: false).planList;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Material(
        color: Color.fromRGBO(250, 250, 250, 1.0),
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ProfileTile(
                title: "Thank You!",
                textColor: Color.fromRGBO(125, 183, 91, 1.0),
                subtitle: "Your transaction was successful",
              ),
              ListTile(
                title: Text("Date", style: TextStyle(color: Colors.black)),
                subtitle: Text(
                  subdate,
                  style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                ),
                trailing: Text(time, style: TextStyle(color: Colors.black)),
              ),
              ListTile(
                title: Text(
                  userDetails.user!.name!,
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  userDetails.user!.email!,
                  style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                ),
                trailing: userDetails.user!.image != null
                    ? Image.network(
                        "${APIData.profileImageUri}" +
                            "${userDetails.user!.image}",
                        scale: 1.7,
                        fit: BoxFit.cover,
                      )
                    : Image.asset(
                        "assets/avatar.png",
                        scale: 1.7,
                        fit: BoxFit.cover,
                      ),
              ),
              ListTile(
                title: Text(
                  "Amount",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: Text(
                  "${planList[widget.index].amount}" +
                      " ${planList[widget.index].currency}",
                  style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                ),
                trailing: Text(
                  "Completed",
                  style: TextStyle(color: Colors.black),
                ),
              ),
              Card(
                clipBehavior: Clip.antiAlias,
                elevation: 0.0,
                child: ListTile(
                  leading: getCardTypeIcon(cardNumber!),
                  title: Text("$cardtype Card"),
                  subtitle: Text("$cardBrand ending $cardLast4"),
                  trailing: Icon(
                    FontAwesomeIcons.ccStripe,
                    color: Color.fromRGBO(125, 183, 91, 1.0),
                    size: 30.0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

//  Container for error message
  Widget errorTicket(message) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16.0),
      child: Material(
        color: Color.fromRGBO(250, 250, 250, 1.0),
        clipBehavior: Clip.antiAlias,
        elevation: 2.0,
        borderRadius: BorderRadius.circular(4.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              ProfileTile(
                title: "Oops!",
                textColor: Colors.red,
                subtitle: "Your transaction was rejected",
              ),
              ListTile(
                title: Text(message, style: TextStyle(color: Colors.black)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _scaffoldBody() {
    return SafeArea(
      child: Column(
        children: <Widget>[
          CreditCardWidget(
            cardNumber: cardNumber!,
            expiryDate: expiryDate!,
            cardHolderName: cardHolderName!,
            cvvCode: cvvCode!,
            showBackView: isCvvFocused,
            obscureCardNumber: true,
            obscureCardCvv: true,
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  CreditCardForm(
                    formKey: formKey,
                    obscureCvv: true,
                    obscureNumber: true,
                    cardNumber: cardNumber!,
                    cvvCode: cvvCode!,
                    cardHolderName: cardHolderName!,
                    expiryDate: expiryDate!,
                    themeColor: Colors.blue,
                    cardNumberDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Number',
                      hintText: 'XXXX XXXX XXXX XXXX',
                    ),
                    expiryDateDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Expired Date',
                      hintText: 'XX/XX',
                    ),
                    cvvCodeDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'CVV',
                      hintText: 'XXX',
                    ),
                    cardHolderDecoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      labelText: 'Card Holder',
                    ),
                    onCreditCardModelChange: onCreditCardModelChange,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  goToDialog(subdate, time, cardtype, cardBrand, cardLast4) {
    setState(() {
      isDataAvailable = true;
    });
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => new GestureDetector(
        child: Container(
          color: Colors.black.withOpacity(0.6),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              successTicket(subdate, time, cardtype, cardBrand, cardLast4),
              SizedBox(
                height: 10.0,
              ),
              FloatingActionButton(
                backgroundColor: Colors.black,
                child: Icon(
                  Icons.clear,
                  color: Colors.white,
                ),
                onPressed: () {
                  var router = new MaterialPageRoute(
                    builder: (BuildContext context) => SplashScreen(
                      token: authToken,
                    ),
                  );
                  Navigator.of(context).push(router);
                },
              )
            ],
          ),
        ),
      ),
    );
  }

  Map<CardType, Set<List<String>>> cardNumPatterns =
      <CardType, Set<List<String>>>{
    CardType.visa: <List<String>>{
      <String>['4'],
    },
    CardType.americanExpress: <List<String>>{
      <String>['34'],
      <String>['37'],
    },
    CardType.discover: <List<String>>{
      <String>['6011'],
      <String>['622126', '622925'],
      <String>['644', '649'],
      <String>['65']
    },
    CardType.mastercard: <List<String>>{
      <String>['51', '55'],
      <String>['2221', '2229'],
      <String>['223', '229'],
      <String>['23', '26'],
      <String>['270', '271'],
      <String>['2720'],
    },
  };

  /// This function determines the Credit Card type based on the cardPatterns
  /// and returns it.
  CardType detectCCType(String cardNumber) {
    //Default card type is other
    CardType cardType = CardType.otherBrand;

    if (cardNumber.isEmpty) {
      return cardType;
    }

    cardNumPatterns.forEach(
      (CardType type, Set<List<String>> patterns) {
        for (List<String> patternRange in patterns) {
          // Remove any spaces
          String ccPatternStr =
              cardNumber.replaceAll(RegExp(r'\s+\b|\b\s'), '');
          final int rangeLen = patternRange[0].length;
          // Trim the Credit Card number string to match the pattern prefix length
          if (rangeLen < cardNumber.length) {
            ccPatternStr = ccPatternStr.substring(0, rangeLen);
          }

          if (patternRange.length > 1) {
            // Convert the prefix range into numbers then make sure the
            // Credit Card num is in the pattern range.
            // Because Strings don't have '>=' type operators
            final int ccPrefixAsInt = int.parse(ccPatternStr);
            final int startPatternPrefixAsInt = int.parse(patternRange[0]);
            final int endPatternPrefixAsInt = int.parse(patternRange[1]);
            if (ccPrefixAsInt >= startPatternPrefixAsInt &&
                ccPrefixAsInt <= endPatternPrefixAsInt) {
              // Found a match
              cardType = type;
              break;
            }
          } else {
            // Just compare the single pattern prefix with the Credit Card prefix
            if (ccPatternStr == patternRange[0]) {
              // Found a match
              cardType = type;
              break;
            }
          }
        }
      },
    );

    return cardType;
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      _visible = false;
    });
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      var stripeKey = Provider.of<PaymentKeyProvider>(context, listen: false)
          .paymentKeyModel!
          .key!;
      Stripe.init(stripeKey);
      setState(() {
        _visible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    var logo =
        Provider.of<AppConfig>(context, listen: false).appModel!.config!.logo;
    return Scaffold(
      appBar: appBar(logo) as PreferredSizeWidget?,
      backgroundColor: Colors.white,
      body: _visible == false
          ? Center(
              child: CircularProgressIndicator(
                valueColor: new AlwaysStoppedAnimation<Color>(Colors.green),
              ),
            )
          : _scaffoldBody(),
      floatingActionButton: floatingBar(),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
