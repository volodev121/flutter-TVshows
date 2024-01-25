import 'package:flutter/material.dart';
class CustomBorder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.black54,
            width: 2.0,
          ),
        ),
      ),
    );
  }
}
