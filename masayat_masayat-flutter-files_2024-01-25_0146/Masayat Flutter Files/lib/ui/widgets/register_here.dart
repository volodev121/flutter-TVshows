import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '../../common/global.dart';
import '/common/route_paths.dart';

Widget registerHereText(context) {
  return ListTile(
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: InkWell(
            child: RichText(
              text: TextSpan(children: [
                TextSpan(
                  text: translate("If_you_dont_have_an_account") + " ",
                  style: new TextStyle(
                    color: isLight ? Colors.black54 : Colors.white,
                    fontSize: 16.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: translate('Sign_Up'),
                  style: new TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 17.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ]),
            ),
            onTap: () => Navigator.pushNamed(context, RoutePaths.register),
          ),
        ),
      ],
    ),
  );
}

Widget loginHereText(context) {
  return ListTile(
    title: Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Flexible(
          flex: 1,
          fit: FlexFit.loose,
          child: InkWell(
            child: new RichText(
              text: new TextSpan(children: [
                new TextSpan(
                  text: translate("Already_have_an_account") + " ",
                  style: new TextStyle(
                    color: isLight ? Colors.black54 : Colors.white,
                    fontSize: 16.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: translate('Sign_In'),
                  style: new TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: 17.5,
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.bold,
                  ),
                )
              ]),
            ),
            onTap: () => Navigator.pushNamed(context, RoutePaths.login),
          ),
        ),
      ],
    ),
  );
}
