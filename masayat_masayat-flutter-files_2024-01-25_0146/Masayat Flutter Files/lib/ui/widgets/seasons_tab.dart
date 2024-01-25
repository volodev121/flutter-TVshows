import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:provider/provider.dart';
import '../../common/global.dart';
import '../../models/CountViewModel.dart' as CVM;
import '../../models/datum.dart';
import '../../models/seasons.dart';
import '../../providers/count_view_provider.dart';

class SeasonsTab extends StatelessWidget {
  SeasonsTab(this.season, this.videoDetail);
  final Season season;
  final Datum videoDetail;

  @override
  Widget build(BuildContext context) {
    CVM.CountViewModel countViewModel =
        Provider.of<CountViewProvider>(context, listen: false).countViewModel;

    int views = 0;

    print("Season ID :-> ${season.id}");
    print("Series ID :-> ${videoDetail.id}");

    countViewModel.season?.forEach((element) {
      if (element.tvSeriesId == videoDetail.id && element.id == season.id) {
        // View Count
        views = element.views! + element.uniqueViewsCount!;
        // Protected Content Password
        if (element.isProtect == 1) {
          String password =
              element.password != null ? element.password.toString() : "N/A";
          if (protectedContentPwd.length > 0) {
            if (!protectedContentPwd
                .containsKey('${videoDetail.id}_${season.id}')) {
              protectedContentPwd['${videoDetail.id}_${season.id}'] = password;
            }
          } else {
            protectedContentPwd['${videoDetail.id}_${season.id}'] = password;
          }
        }
      }
    });

    return Container(
      alignment: Alignment.center,
      padding: EdgeInsets.only(left: 5.0, right: 5.0),
      margin: EdgeInsets.only(top: 7.0),
      child: Column(
        children: [
          new Text(
            translate("Season_") + ' ${season.seasonNo}',
            style: TextStyle(
              fontFamily: 'Lato',
              fontSize: 15.0,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.9,
            ),
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.visibility,
                size: 16,
              ),
              Padding(
                padding: EdgeInsets.only(
                  left: 2.0,
                ),
                child: Text(
                  "${valueToKMB(value: views)}",
                  style: TextStyle(
                    fontSize: 12.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
