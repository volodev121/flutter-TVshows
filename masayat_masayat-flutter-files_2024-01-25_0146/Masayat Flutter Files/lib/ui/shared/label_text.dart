import 'package:flutter/material.dart';

// Username label text
class LabelText extends StatelessWidget {
  final String label;
  LabelText(this.label);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, right: 10.0, bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: TextStyle(
              color: Color.fromRGBO(34, 34, 34, 0.5),
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.start,
          ),
        ],
      ),
    );
  }
}
