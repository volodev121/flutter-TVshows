import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:nexthour/models/datum.dart';

// Share tab
class CopyPassword extends StatelessWidget {
  CopyPassword(this.videoDetail);
  final Datum videoDetail;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: new InkWell(
          onTap: () {
            Clipboard.setData(
              new ClipboardData(text: ''
                  //        protectedContentPwd['${videoDetail.id}_${videoDetail.id}'],
                  ),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(translate(
                    'Protected_Content_Password_copied_Just_paste_it_when_ask_for_password')),
              ),
            );
          },
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.copy,
                size: 30.0,
              ),
              new Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
              ),
              Text(
                translate("Copy_"),
                style: TextStyle(
                  fontFamily: 'Lato',
                  fontSize: 12.0,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.0,
                ),
              ),
            ],
          ),
        ),
        color: Colors.transparent,
      ),
    );
  }
}
