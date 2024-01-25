import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:share_plus/share_plus.dart';

// Share tab
class SharePage extends StatelessWidget {
  SharePage(this.shareType, this.shareId);
  final shareType;
  final shareId;

  Widget shareText() {
    return Text(
      translate("Share_"),
      style: TextStyle(
        fontFamily: 'Lato',
        fontSize: 12.0,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.0,
      ),
    );
  }

  Widget shareTabColumn() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Icon(
          Icons.share,
          size: 30.0,
        ),
        new Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
        ),
        shareText(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Material(
        child: new InkWell(
          onTap: () {
            Share.share('$shareType' + '$shareId');
          },
          child: shareTabColumn(),
        ),
        color: Colors.transparent,
      ),
    );
  }
}
