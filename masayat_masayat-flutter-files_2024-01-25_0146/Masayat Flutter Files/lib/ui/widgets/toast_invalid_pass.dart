import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';

Widget toast = Container(
  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 12.0),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(25.0),
    color: Colors.red,
  ),
  child: Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(
        Icons.close,
        color: Colors.white,
      ),
      SizedBox(
        width: 12.0,
      ),
      Text(
        translate("The_user_credentials_were_incorrect"),
        style: TextStyle(color: Colors.white),
      ),
    ],
  ),
);
