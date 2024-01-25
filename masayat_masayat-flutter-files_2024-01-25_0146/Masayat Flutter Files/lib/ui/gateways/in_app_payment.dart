import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_inapp_purchase/flutter_inapp_purchase.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/common/styles.dart';
import '/providers/app_config.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

class InApp extends StatefulWidget {
  InApp(this.index);
  final int index;
  @override
  _InAppState createState() => new _InAppState();
}

class _InAppState extends State<InApp> {
  // ignore: cancel_subscriptions
  StreamSubscription? _purchaseUpdatedSubscription;
  // ignore: cancel_subscriptions
  StreamSubscription? _purchaseErrorSubscription;
  // ignore: cancel_subscriptions
  StreamSubscription? _conectionSubscription;

  List<String> _productLists = [];

  List<IAPItem> _items = [];

  startMyConnection() async {
    await FlutterInappPurchase.instance.initialize();
  }

  endMyConnection() async {
    print("---------- End Connection Button Pressed");
    await FlutterInappPurchase.instance.finalize();
    if (_purchaseUpdatedSubscription != null) {
      _purchaseUpdatedSubscription!.cancel();
      _purchaseUpdatedSubscription = null;
    }
    if (_purchaseErrorSubscription != null) {
      _purchaseErrorSubscription!.cancel();
      _purchaseErrorSubscription = null;
    }
    setState(() {
      this._items = [];
    });
  }

  Future _getProduct() async {
    List<IAPItem> items =
        await FlutterInappPurchase.instance.getSubscriptions(_productLists);
    for (var item in items) {
      print('${item.toString()}');
      this._items.add(item);
    }

    setState(() {
      this._items = items;
    });
  }

  @override
  void initState() {
    super.initState();
    initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
//      For Testing
      _productLists.add("android.test.canceled");

      this._getProduct();
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (_conectionSubscription != null) {
      _conectionSubscription!.cancel();
      _conectionSubscription = null;
    }
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    // prepare
    var result = FlutterInappPurchase.instance.toString();
    print('result: $result');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {});

    // refresh items for android
    try {
      String? msg = await (FlutterInappPurchase.instance.consumeAll()
          as FutureOr<String?>);
      print('consumeAllItems: $msg');
    } catch (err) {
      print('consumeAllItems error: $err');
    }

    _conectionSubscription =
        FlutterInappPurchase.connectionUpdated.listen((connected) {
      print('connected: $connected');
    });

    _purchaseUpdatedSubscription =
        FlutterInappPurchase.purchaseUpdated.listen((productItem) {
      print('purchase-updated: $productItem');
    });

    _purchaseErrorSubscription =
        FlutterInappPurchase.purchaseError.listen((purchaseError) {
      print('purchase-error: $purchaseError');
    });
  }

  void _requestPurchase(IAPItem item) {
    FlutterInappPurchase.instance.requestSubscription(item.productId!);
  }

  List<Widget> _renderInApps() {
    List<Widget> widgets = this
        ._items
        .map((item) => Container(
              margin: EdgeInsets.symmetric(vertical: 10.0),
              child: Container(
                child: Column(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 15.0),
                      child: Row(
                        children: [
                          Expanded(
                            flex: 1,
                            child: ButtonTheme(
                              height: 48,
                              child: ElevatedButton(
                                onPressed: () {
                                  this._requestPurchase(item);
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all<Color?>(
                                    primaryBlue,
                                  ),
                                  overlayColor:
                                      MaterialStateProperty.all<Color?>(
                                    Color.fromRGBO(72, 163, 198, 1.0),
                                  ),
                                ),
                                child: Text(
                                  'Subscribe',
                                  // style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              ),
            ))
        .toList();
    return widgets;
  }

  Widget makeListTile1() {
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
          '${planDetails[widget.index].name}',
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
                        '${planDetails[widget.index].intervalCount}' +
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
        Text("Amount: " +
            '\n' +
            '${planDetails[widget.index].amount} ' +
            '${planDetails[widget.index].currency}'),
      ]),
    );
  }

  Widget razorLogoContainer() {
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
              "assets/gpay.png",
              scale: 1.0,
              width: 150.0,
            ),
          )
        ],
      ),
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
          children: <Widget>[makeListTile1()],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, "InApp Payment") as PreferredSizeWidget?,
      body: Container(
        padding: EdgeInsets.all(10.0),
        child: ListView(
          children: <Widget>[
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Column(
                  children: <Widget>[
                    Container(
                      height: 20.0,
                    ),
                    Card(
                      elevation: 8.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      margin: new EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 6.0),
                      child: razorLogoContainer(),
                    ),
                    SizedBox(
                      height: 30.0,
                    ),
                    paymentDetailsCard(),
                    SizedBox(
                      height: 20.0,
                    ),
                  ],
                ),
                Column(
                  children: this._renderInApps(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
