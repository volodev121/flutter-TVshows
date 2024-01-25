import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_widget_from_html/flutter_widget_from_html.dart';
import 'package:nexthour/common/apipath.dart';
import 'package:nexthour/common/global.dart';
import 'package:nexthour/common/route_paths.dart';
import 'package:nexthour/models/manual_payment_model.dart';
import 'package:nexthour/providers/app_config.dart';
import 'package:nexthour/providers/manual_payment_provider.dart';
import 'package:nexthour/ui/screens/splash_screen.dart';
import 'package:nexthour/ui/shared/appbar.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

class ManualPaymentScreen extends StatefulWidget {
  final ManualPayment manualPayment;
  final int planIndex;
  final payAmount;

  ManualPaymentScreen(
      {required this.manualPayment, required this.planIndex, this.payAmount});

  @override
  _ManualPaymentScreenState createState() => _ManualPaymentScreenState();
}

class _ManualPaymentScreenState extends State<ManualPaymentScreen> {
  ManualPaymentProvider? manualPaymentProvider;

  Widget _buildCard() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Name",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  widget.manualPayment.paymentName!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 18.0,
                    letterSpacing: 1.0,
                  ),
                ),
                Divider(
                  height: 10,
                ),
                Text(
                  "Description",
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                HtmlWidget(
                  widget.manualPayment.description!,
                  textStyle: TextStyle(
                    fontSize: 16.0,
                  ),
                  customStylesBuilder: (element) {
                    return {
                      'font-weight': '600',
                      'font-size': '16',
                      'align': 'justify'
                    };
                  },
                ),
                Divider(
                  height: 10,
                ),
              ],
            ),
          ),
          Column(
            children: [
              Image.network(
                widget.manualPayment.thumbPath! +
                    '/' +
                    widget.manualPayment.thumbnail!,
                fit: BoxFit.fitWidth,
              ),
              proofPicker(),
              submitButton()
            ],
          ),
        ],
      );

  // final _form
  bool submitLoading = false;

  goToDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(12.0)), //this right here
                child: Container(
                  height: 300.0,
                  width: 300.0,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                          "Request Sent!",
                          style: TextStyle(color: Colors.black, fontSize: 22),
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Padding(
                        padding: EdgeInsets.all(15.0),
                        child: Text(
                            "We have received you request ! we will check and update the details in few hours !",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[600], fontSize: 16)),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      FloatingActionButton(
                        backgroundColor: Colors.white,
                        child: Icon(
                          Icons.clear,
                          color: Colors.black,
                        ),
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            RoutePaths.splashScreen,
                            arguments: SplashScreen(
                              token: authToken,
                            ),
                          );
                        },
                      )
                    ],
                  ),
                ),
              ),
            ));
  }

  Widget submitButton() {
    return ElevatedButton(
      onPressed: () async {
        if (proofCtrl.text.length > 0) {
          setState(() {
            submitLoading = true;
          });
          bool x = await sendDetails();

          if (x) {
            goToDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Something went wrong! Try Again later."),
              ),
            );
          }
        }
        setState(() {
          submitLoading = false;
        });
      },
      child: Container(
        padding: EdgeInsets.all(submitLoading ? 5 : 0),
        height: 50,
        width: 120,
        alignment: Alignment.center,
        child: submitLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Center(
                child: Text(
                  "Submit",
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
      ),
    );
  }

  File? _proof;

  String extractName(String path) {
    int i;
    for (i = path.length - 1; i >= 0; i--) {
      if (path[i] == "/") break;
    }
    return path.substring(i + 1);
  }

  Future<bool> sendDetails() async {
    String _proofName = _proof!.path.split('/').last;

    var planDetails = Provider.of<AppConfig>(context, listen: false).planList;

    String url = APIData.storeManualPayments;

    var _body = FormData.fromMap({
      "plan_id": "${planDetails[widget.planIndex].id}",
      "amount": widget.payAmount != null
          ? "${widget.payAmount}"
          : "${planDetails[widget.planIndex].amount}",
      "reference":
          "${widget.manualPayment.paymentName!.toUpperCase()}${DateTime.now().millisecondsSinceEpoch.toString()}",
      "method": "${widget.manualPayment.paymentName}",
      "proof": await MultipartFile.fromFile(_proof!.path, filename: _proofName),
    });
    Response? response;
    try {
      response = await Dio().post(
        url,
        data: _body,
        options: Options(
          method: 'POST',
          headers: {
            'Accept': 'application/json',
            'Authorization': 'Bearer $authToken',
          },
        ),
      );
    } catch (e) {}
    if (response!.statusCode == 200) {
      return true;
    } else
      return false;
  }

  String prooftxt = "Upload Proof here";

  TextEditingController proofCtrl =
      new TextEditingController(text: "Upload Proof Here!");

  Widget proofPicker() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(
          color: Colors.grey.shade500,
        ),
      ),
      padding: EdgeInsets.all(4),
      margin: EdgeInsets.all(18),
      child: TextFormField(
        validator: (value) {
          if (value == "")
            return 'Please upload your resume here!';
          else
            return null;
        },
        controller: proofCtrl,
        readOnly: true,
        style: TextStyle(
          color: Colors.black,
          fontSize: 17,
          fontWeight: FontWeight.normal,
        ),
        decoration: InputDecoration(
          suffixIcon: IconButton(
              icon: Icon(
                FontAwesomeIcons.upload,
                color: Colors.grey,
              ),
              onPressed: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom, allowedExtensions: ["pdf", "doc"]);

                if (result != null) {
                  _proof = File(result.files.single.path!);
                  setState(() {
                    proofCtrl.text = extractName(_proof!.path);
                  });
                }
              }),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

  Widget whenNull() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          "assets/images/serverError.png",
          height: 180,
          width: 180,
        ),
        Text(
          "No details available ",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 50.0),
          child: Text(
            "Looks like there is no details enter for bank payment",
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 15, color: Colors.black.withOpacity(0.7)),
          ),
        ),
      ],
    );
  }

  final scaffoldKey = new GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    print('Amount :-> ${widget.payAmount}');
    return Scaffold(
      key: scaffoldKey,
      appBar: customAppBar(context, "Manual Payment") as PreferredSizeWidget?,
      body: widget.manualPayment.id == null
          ? whenNull()
          : SingleChildScrollView(
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.all(10.0),
                    child: _buildCard(),
                  )
                ],
              ),
            ),
    );
  }
}
