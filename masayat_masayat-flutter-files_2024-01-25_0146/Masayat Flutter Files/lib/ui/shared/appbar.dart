import 'package:flutter/material.dart';

Widget customAppBar(context, title) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16.0,
        letterSpacing: 0.9,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColorDark,
  );
}

Widget customAppBar1(context, title) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16.0,
        letterSpacing: 0.9,
      ),
    ),
    centerTitle: true,
    automaticallyImplyLeading: false,
    backgroundColor: Theme.of(context).primaryColorDark,
  );
}

Widget customAppBar2(context, title, iconButton) {
  return AppBar(
    title: Text(
      title,
      style: TextStyle(
        fontSize: 16.0,
        letterSpacing: 0.9,
      ),
    ),
    centerTitle: true,
    backgroundColor: Theme.of(context).primaryColorLight,
    actions: [iconButton],
  );
}
