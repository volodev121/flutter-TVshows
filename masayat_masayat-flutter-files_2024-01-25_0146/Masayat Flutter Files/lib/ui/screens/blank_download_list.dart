import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '/common/route_paths.dart';
import 'package:flutter_translate/flutter_translate.dart';

class BlankDownloadList extends StatefulWidget {
  @override
  _BlankDownloadListState createState() => _BlankDownloadListState();
}

class _BlankDownloadListState extends State<BlankDownloadList> {
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
              FontAwesomeIcons.download,
              size: 150,
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 35.0, vertical: 15.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                flex: 1,
                child: Text(
                  translate(
                      "Download_movies_&_TV_shows_to_your_Device_so_you_can_easily_watch_them_later"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 40.0,
        ),
        TextButton(
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all<Color?>(
              Theme.of(context).primaryColor,
            ),
          ),
          onPressed: () {
            Navigator.pushNamed(context, RoutePaths.bottomNavigationHome);
          },
          child: Text(
            translate("Find_Something_to_watch").toUpperCase(),
            style: TextStyle(color: Colors.white70),
          ),
        )
      ],
    );
  }
}
