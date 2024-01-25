import 'package:flutter/material.dart';

class Separator extends StatelessWidget {
  Separator({this.width = 18.0, this.height = 2.0, this.color = const Color(0xff00c6ff)});
  final double width;
  final double height;
  final Color color;
  @override
  Widget build(BuildContext context) {

    return new Container(
        margin: new EdgeInsets.symmetric(vertical: 8.0),
        height: height,
        width: width,
        color: color
    );
  }
}
