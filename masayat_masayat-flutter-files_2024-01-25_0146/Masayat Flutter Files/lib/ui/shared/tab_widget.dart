import 'package:flutter/material.dart';

class TabWidget extends StatelessWidget {
  TabWidget(this.title);
  final title;
  @override
  Widget build(BuildContext context) {
    return Tab(
      child: new Container(
        alignment: Alignment.center,
        child: new Text(
          title,
          style: TextStyle(
            fontFamily: 'Lato',
            fontSize: 13.0,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.7,
          ),
        ),
      ),
    );
  }
}
