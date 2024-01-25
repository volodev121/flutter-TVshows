import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class BlankWatchHistory extends StatefulWidget {
  @override
  _BlankWatchHistoryState createState() => _BlankWatchHistoryState();
}

class _BlankWatchHistoryState extends State<BlankWatchHistory> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              FontAwesomeIcons.solidCirclePlay,
              size: 150,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  translate("Lets_watch_the_most_recent_motion_pictures_") +
                      " " +
                      translate("elite_TV_appears_at_simply_least_cost"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        )
      ],
    );
  }
}
