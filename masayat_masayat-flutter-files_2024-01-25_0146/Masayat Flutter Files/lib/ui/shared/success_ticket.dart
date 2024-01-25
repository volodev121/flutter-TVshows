import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/common/apipath.dart';
import '/providers/app_config.dart';
import '/providers/user_profile_provider.dart';
import '/ui/widgets/profile_tile.dart';
import 'package:provider/provider.dart';

//  Container having details that is used in success dialog

class SuccessTicket extends StatelessWidget {
  SuccessTicket({this.msgResponse, this.subDate, this.time, this.planAmount});
  final dynamic msgResponse;
  final dynamic subDate;
  final dynamic time;
  final dynamic planAmount;

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    var currency = Provider.of<AppConfig>(context, listen: false)
        .appModel!
        .config!
        .currencyCode;
    return WillPopScope(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Material(
          color: Color.fromRGBO(250, 250, 250, 1.0),
          clipBehavior: Clip.antiAlias,
          elevation: 2.0,
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ProfileTile(
                  title: translate("Thank_You_"),
                  textColor: Color.fromRGBO(125, 183, 91, 1.0),
                  subtitle: msgResponse,
                ),
                ListTile(
                  title: Text(
                    translate("Date_"),
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    subDate,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  trailing: Text(
                    time,
                    style: TextStyle(color: Colors.black),
                  ),
                ),
                ListTile(
                  title: Text(
                    userDetails.user!.name!,
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    userDetails.user!.email!,
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  trailing: userDetails.user!.image != null
                      ? Image.network(
                          "${APIData.profileImageUri}" +
                              "${userDetails.user!.image}",
                          scale: 1.7,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/avatar.png",
                          scale: 1.7,
                          fit: BoxFit.cover,
                        ),
                ),
                ListTile(
                  title: Text(
                    translate("Amount_"),
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    "$planAmount" + " $currency",
                    style:
                        TextStyle(color: Theme.of(context).primaryColorLight),
                  ),
                  trailing: Text(
                    translate("Completed_"),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }
}

class SuccessTicket2 extends StatelessWidget {
  SuccessTicket2(
      this.msgResponse, this.subdate, this.name, this.time, this.planAmount);
  final msgResponse;
  final subdate;
  final name;
  final time;
  final planAmount;

  @override
  Widget build(BuildContext context) {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    var currency = Provider.of<AppConfig>(context, listen: false)
        .appModel!
        .config!
        .currencyCode;
    return WillPopScope(
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        child: Material(
          color: Color.fromRGBO(250, 250, 250, 1.0),
          clipBehavior: Clip.antiAlias,
          elevation: 2.0,
          borderRadius: BorderRadius.circular(4.0),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                ProfileTile(
                  title: translate("Thank_You_"),
                  textColor: Color.fromRGBO(125, 183, 91, 1.0),
                  subtitle: msgResponse,
                ),
                ListTile(
                  title: Text(translate("Date_"),
                      style: TextStyle(color: Colors.black)),
                  subtitle: Text(
                    subdate,
                    style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                  ),
                  trailing: Text(time, style: TextStyle(color: Colors.black)),
                ),
                ListTile(
                  title: Text(
                    name,
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    userDetails.user!.email!,
                    style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                  ),
                  trailing: userDetails.user!.image != null
                      ? Image.network(
                          "${APIData.profileImageUri}" +
                              "${userDetails.user!.image}",
                          scale: 1.7,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          "assets/avatar.png",
                          scale: 1.7,
                          fit: BoxFit.cover,
                        ),
                ),
                ListTile(
                  title: Text(
                    translate("Amount_"),
                    style: TextStyle(color: Colors.black),
                  ),
                  subtitle: Text(
                    "$planAmount" + " $currency",
                    style: TextStyle(color: Color.fromRGBO(20, 20, 20, 1.0)),
                  ),
                  trailing: Text(
                    translate("Completed_"),
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      onWillPop: () async => false,
    );
  }
}
