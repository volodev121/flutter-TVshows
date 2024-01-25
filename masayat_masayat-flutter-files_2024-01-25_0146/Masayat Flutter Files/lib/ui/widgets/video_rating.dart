import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import '../../models/CountViewModel.dart';
import '../../models/episode.dart';
import '../../providers/count_view_provider.dart';
import '/models/datum.dart';

class RatingInformation extends StatelessWidget {
  RatingInformation(this.mVideo);

  final Datum? mVideo;

  _buildRatingBar(ThemeData theme) {
    var stars = <Widget>[];
    var vRating;
    if (mVideo!.rating is String) {
      double ra = double.parse(mVideo!.rating);
      vRating = ra / 2;
    } else {
      vRating = mVideo!.rating / 2;
    }
    for (var i = 1; i <= 5; i++) {
      var star;
      if (i + 1 <= vRating + 1) {
        var color = theme.colorScheme.secondary;
        star = new Icon(
          Icons.star,
          color: color,
        );
      } else {
        if (i + 0.5 <= vRating + 1) {
          var color = theme.colorScheme.secondary;
          star = new Icon(
            Icons.star_half,
            color: color,
          );
        } else {
          var color = theme.colorScheme.secondary;
          star = new Icon(
            Icons.star_border,
            color: color,
          );
        }
      }

      stars.add(star);
    }

    return new Flex(direction: Axis.horizontal, children: stars);
  }

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var textTheme = theme.textTheme;
    var ratingCaptionStyle =
        textTheme.bodySmall!.copyWith(color: Colors.white70);
    var vRating;
    if (mVideo!.rating is String) {
      double ra = double.parse(mVideo!.rating);
      vRating = ra / 2;
      print("sss");
    } else {
      vRating = mVideo!.rating / 2;
    }
    var numericRating = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        new Text(
          "$vRating",
          style: textTheme.titleLarge!.copyWith(
            fontWeight: FontWeight.w400,
            color: theme.colorScheme.secondary,
          ),
        ),
        new Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: new Text(
            translate('Rating_'),
            style: ratingCaptionStyle,
          ),
        ),
      ],
    );

    CountViewModel countViewModel =
        Provider.of<CountViewProvider>(context, listen: false).countViewModel;
    int views = 0;
    print("Movie ID :-> ${mVideo?.id}");
    countViewModel.movies?.forEach((element) {
      if (element.id == mVideo?.id && element.title == mVideo?.title) {
        views = element.views! + element.uniqueViewsCount!;
      }
    });

    var viewsCount = Row(
      children: <Widget>[
        Icon(
          Icons.visibility,
          size: 16,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 5.0,
          ),
          child: Text(
            "$views views",
            style: TextStyle(
              fontSize: 12.0,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );

    var starRating = new Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildRatingBar(theme),
        if (mVideo?.type == DatumType.M) viewsCount,
      ],
    );

    return new Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        numericRating,
        new Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: starRating,
        ),
      ],
    );
  }
}
