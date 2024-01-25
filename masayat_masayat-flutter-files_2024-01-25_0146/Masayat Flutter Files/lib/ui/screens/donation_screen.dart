import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/providers/app_config.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

class DonationScreen extends StatefulWidget {
  @override
  _DonationScreenState createState() => _DonationScreenState();
}

class _DonationScreenState extends State<DonationScreen> {
  @override
  Widget build(BuildContext context) {
    var donationURL =
        Provider.of<AppConfig>(context).appModel!.config!.donationLink;
    return Scaffold(
      appBar:
          customAppBar(context, translate("Donate_")) as PreferredSizeWidget?,
      body: donationURL == null
          ? Center(
              child: Text(translate("Donation_link_not_available")),
            )
          : Container(
              child: WebView(
                initialUrl: '$donationURL',
                javascriptMode: JavascriptMode.unrestricted,
              ),
            ),
    );
  }
}
