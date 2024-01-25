import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nexthour/common/route_paths.dart';
import 'package:nexthour/models/manual_payment_model.dart';
import 'package:nexthour/ui/shared/appbar.dart';
import 'manual_payment_screen.dart';

class ManualPaymentList extends StatefulWidget {
  ManualPaymentList(
      {required this.manualPaymentModel,
      required this.planIndex,
      required this.payAmount});

  final ManualPaymentModel manualPaymentModel;
  final int planIndex;
  final payAmount;

  @override
  _ManualPaymentListState createState() => _ManualPaymentListState();
}

final scaffoldKey = new GlobalKey<ScaffoldState>();

class _ManualPaymentListState extends State<ManualPaymentList> {
  @override
  Widget build(BuildContext context) {
    print('Amount :-> ${widget.payAmount}');
    return Scaffold(
      key: scaffoldKey,
      appBar:
          customAppBar(context, "Manual Payment List") as PreferredSizeWidget?,
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 5.0,
            ),
            child: Card(
              elevation: 4,
              child: ListTile(
                leading: Image.network(
                  widget.manualPaymentModel.manualPayment![index].thumbPath! +
                      '/' +
                      widget
                          .manualPaymentModel.manualPayment![index].thumbnail!,
                  height: 45,
                ),
                title: Text(
                  widget.manualPaymentModel.manualPayment![index].paymentName!
                      .toUpperCase(),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  widget.manualPaymentModel.manualPayment![index].description!,
                  style: TextStyle(
                    fontSize: 15,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                onTap: () {
                  if (widget.manualPaymentModel.manualPayment![index].status ==
                      1) {
                    Navigator.pushNamed(
                      context,
                      RoutePaths.ManualPayment,
                      arguments: ManualPaymentScreen(
                        manualPayment:
                            widget.manualPaymentModel.manualPayment![index],
                        planIndex: widget.planIndex,
                        payAmount: widget.payAmount,
                      ),
                    );
                  } else {
                    Fluttertoast.showToast(
                      msg: "Not_Active",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 16.0,
                    );
                  }
                },
              ),
            ),
          );
        },
        itemCount: widget.manualPaymentModel.manualPayment!.length,
      ),
    );
  }
}
