import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PayStackPlatformButton extends StatelessWidget {
  PayStackPlatformButton(this.string, this.function);
  final String string;
  final Function() function;
  @override
  Widget build(BuildContext context) {
    Widget widget;
    if (Platform.isIOS) {
      widget = new CupertinoButton(
        onPressed: function,
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        color: CupertinoColors.activeBlue,
        child: new Text(
          string,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      );
    } else {
      widget = new Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomRight,
            stops: [0.1, 0.5, 0.7, 0.9],
            colors: [
              Color.fromRGBO(72, 163, 198, 0.4).withOpacity(0.4),
              Color.fromRGBO(72, 163, 198, 0.3).withOpacity(0.5),
              Color.fromRGBO(72, 163, 198, 0.2).withOpacity(0.6),
              Color.fromRGBO(72, 163, 198, 0.1).withOpacity(0.7),
            ],
          ),
        ),
        child: ElevatedButton(
          onPressed: function,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(
              Color.fromRGBO(72, 163, 198, 1.0),
            ),
            textStyle: MaterialStateProperty.all<TextStyle?>(
              TextStyle(color: Colors.white),
            ),
            padding: MaterialStateProperty.all<EdgeInsetsGeometry?>(
              EdgeInsets.symmetric(vertical: 13.0, horizontal: 10.0),
            ),
          ),
          child: new Text(
            string.toUpperCase(),
            style: const TextStyle(fontSize: 17.0),
          ),
        ),
      );
    }
    return widget;
  }
}
