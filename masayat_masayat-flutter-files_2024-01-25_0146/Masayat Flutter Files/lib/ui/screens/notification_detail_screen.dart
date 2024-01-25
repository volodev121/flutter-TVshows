import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/ui/shared/appbar.dart';

class NotificationDetailScreen extends StatefulWidget {
  NotificationDetailScreen(
    this.title,
    this.message,
  );
  final String? title;
  final String? message;
  @override
  _NotificationDetailScreenState createState() =>
      _NotificationDetailScreenState();
}

class _NotificationDetailScreenState extends State<NotificationDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Notification_"))
          as PreferredSizeWidget?,
      body: SingleChildScrollView(
          child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        child: Column(
          children: [
            Text(
              "${widget.title}",
              style: TextStyle(
                fontSize: 20.0,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(
              height: 10.0,
            ),
            Text("${widget.message}"),
          ],
        ),
      )),
    );
  }
}
