import 'package:flutter/material.dart';
import '/models/datum.dart';

class RatingInformationSearch extends StatelessWidget {
  RatingInformationSearch(this.mVideo);

  final Datum mVideo;

  _buildRatingBar(ThemeData theme) {
    var stars = <Widget>[];

    for (var i = 1; i <= 5; i++) {
      var star;
      if (mVideo.rating == null) {
        if (i + 1 <= 1) {
          var color = theme.colorScheme.secondary;
          star = new Icon(
            Icons.star,
            color: color,
            size: 15.0,
          );
        } else {
          if (i + 0.5 <= 1) {
            var color = theme.colorScheme.secondary;
            star = new Icon(
              Icons.star_half,
              color: color,
              size: 15.0,
            );
          } else {
            var color = theme.colorScheme.secondary;
            star = new Icon(
              Icons.star_border,
              color: color,
              size: 15.0,
            );
          }
        }
      } else {
        if (i + 1 <= mVideo.rating + 1) {
          var color = theme.colorScheme.secondary;
          star = new Icon(
            Icons.star,
            color: color,
            size: 15.0,
          );
        } else {
          if (i + 0.5 <= mVideo.rating + 1) {
            var color = theme.colorScheme.secondary;
            star = new Icon(
              Icons.star_half,
              color: color,
              size: 15.0,
            );
          } else {
            var color = theme.colorScheme.secondary;
            star = new Icon(
              Icons.star_border,
              color: color,
              size: 15.0,
            );
          }
        }
      }

      stars.add(star);
    }
    print(stars.length);
    return new Row(children: stars);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);

    var starRating = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRatingBar(theme),
      ],
    );

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        new Padding(
          padding: const EdgeInsets.only(left: 0.0),
          child: starRating,
        ),
      ],
    );
  }
}
