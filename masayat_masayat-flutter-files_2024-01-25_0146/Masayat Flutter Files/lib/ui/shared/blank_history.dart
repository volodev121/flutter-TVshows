import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/ui/shared/appbar.dart';

//  When history is not available then this widget will called
class BlankHistoryContainer extends StatelessWidget {
//  Blank history icon
  Widget blankHistoryIcon() {
    return Container(
      child: Icon(
        Icons.history,
        size: 150.0,
        color: Color.fromRGBO(70, 70, 70, 1.0),
      ),
    );
  }

//  Blank history message
  Widget blankHistoryMessage() {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Text(
        translate("No_History_Available"),
        style: TextStyle(
          height: 1.5,
        ),
      ),
    );
  }

//  Blank history column
  Widget blankHistoryColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        blankHistoryIcon(),
        SizedBox(
          height: 25.0,
        ),
        blankHistoryMessage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(context, translate("Payment_History"))
          as PreferredSizeWidget?,
      body: Container(
        alignment: Alignment.center,
        child: blankHistoryColumn(),
      ),
    );
  }
}

class NoMovies extends StatelessWidget {
//  Blank history icon
  Widget blankHistoryIcon() {
    return Container(
      child: Icon(
        Icons.search,
        size: 150.0,
        color: Color.fromRGBO(70, 70, 70, 1.0),
      ),
    );
  }

//  Blank history message
  Widget blankHistoryMessage() {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Text(
        translate("No_movies_or_TV_series_found_of_this_artist"),
        style: TextStyle(
          height: 1.5,
        ),
      ),
    );
  }

//  Blank history column
  Widget blankHistoryColumn() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        blankHistoryIcon(),
        SizedBox(
          height: 25.0,
        ),
        blankHistoryMessage(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      child: blankHistoryColumn(),
    );
  }
}
