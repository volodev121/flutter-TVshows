import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import '../../common/global.dart';
import '../../models/user_profile_model.dart';
import '/common/apipath.dart';
import '/common/route_paths.dart';
import '/providers/user_profile_provider.dart';
import '/ui/seekbar/fluttery_seekbar.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

var sw = '';

class ManageProfileScreen extends StatefulWidget {
  @override
  _ManageProfileScreenState createState() => _ManageProfileScreenState();
}

class _ManageProfileScreenState extends State<ManageProfileScreen> {
  DateTime? _date;
  DateTime? currentDate;
  var userPlanStart;
  var userPlanEnd;
  var planDays;
  var progressWidth;
  late var diff;
  var difference;

  final scaffoldKey = new GlobalKey<ScaffoldState>();
  final formKey = new GlobalKey<FormState>();

//  Pop menu button to edit profile
  Widget _selectPopup(isAdmin) {
    return isAdmin == "1"
        ? PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text(translate("Change_Password")),
              ),
            ],
            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {
              if (value == 1) {
                Navigator.pushNamed(context, RoutePaths.changePassword);
              }
            },
            icon: Icon(Icons.more_vert),
          )
        : PopupMenuButton<int>(
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 1,
                child: Text(translate("Edit_Profile")),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(translate("Change_Password")),
              ),
              PopupMenuItem(
                value: 3,
                child: Text(translate("Delete_Account")),
              ),
            ],
            onCanceled: () {
              print("You have canceled the menu.");
            },
            onSelected: (value) {
              if (value == 1) {
                print("value:$value");
                Navigator.pushNamed(context, RoutePaths.updateProfile);
              } else if (value == 2) {
                Navigator.pushNamed(context, RoutePaths.changePassword);
              } else if (value == 3) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0)),
                    title: Text(
                      translate("Confirm_Account_Deletion"),
                      style: TextStyle(
                        fontFamily: 'Mada',
                        fontWeight: FontWeight.w700,
                        color: Colors.red,
                      ),
                    ),
                    content: Text(
                      translate(
                          "Are_you_sure_that_you_want_to_delete_your_account"),
                      style: TextStyle(
                        fontFamily: 'Mada',
                      ),
                    ),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          print("User ID : ${userDetails.user?.id}");
                          Navigator.pop(context);
                        },
                        child: Text(
                          translate("No_").toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFF0284A2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          deleteAccount();
                          Navigator.pop(context);
                        },
                        child: Text(
                          translate("Yes_").toUpperCase(),
                          style: TextStyle(
                            color: Color(0xFF0284A2),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }
            },
            icon: Icon(Icons.more_vert),
          );
  }

  Future<void> deleteAccount() async {
    Response response =
        await Dio().delete(APIData.deleteAccount + "${userDetails.user?.id}");

    if (response.statusCode == 200) {
      print("Delete Account API Response : ${response.data}");
      await storage.deleteAll();
      Fluttertoast.showToast(
          msg: translate("Your Account has been deleted successfully."));
      Navigator.pushNamed(context, RoutePaths.loginHome);
    } else {
      print("Delete Account API Response : ${response.data}");
      Fluttertoast.showToast(
          msg: translate("Failed! Your Account could not be deleted."));
    }
  }

//  User profile image
  Widget userProfileImage() {
    var userDetails =
        Provider.of<UserProfileProvider>(context).userProfileModel!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Container(
          height: 170.0,
          width: 130.0,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0)),
          ),
          child: ClipRRect(
            borderRadius: new BorderRadius.only(
                bottomLeft: Radius.circular(8.0),
                bottomRight: Radius.circular(8.0)),
            child: userDetails.user!.image != null
                ? Image.network(
                    "${APIData.profileImageUri}" + "${userDetails.user!.image}",
                    scale: 1.7,
                    fit: BoxFit.cover,
                  )
                : Image.asset(
                    "assets/avatar.png",
                    scale: 1.7,
                    fit: BoxFit.cover,
                  ),
          ),
        ),
      ],
    );
  }

//  Rounded SeekBar
  Widget roundedSeekBar() {
    diff =
        difference == null ? sw : '$difference ' + translate('Days_Remaining');
    return RadialSeekBar(
      trackColor: Color.fromRGBO(20, 20, 20, 1.0),
      trackWidth: 8.0,
      progressColor:
          difference == null ? Colors.red : Color.fromRGBO(72, 163, 198, 1.0),
      progressWidth: 8.0,
      progress: difference == null ? 1.0 : progressWidth,
      centerContent: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Padding(
            padding: EdgeInsets.all(15.0),
            child: Text(diff),
          )
        ],
      ),
    );
  }

//  Rounded SeekBar Container
  Widget roundedSeekBarContainer() {
    return Container(
      height: 200.0,
      margin: EdgeInsets.only(top: 450.0, bottom: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 0,
            child: SizedBox(
              width: 200.0,
              height: 200.0,
              child: roundedSeekBar(),
            ),
          ),
        ],
      ),
    );
  }

//  Pop menu button to edit profile
  Widget popUpMenu() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _selectPopup(userDetails.user!.isAdmin),
        ],
      ),
    );
  }

//  Account status text
  Widget accountStatusText() {
    return new Padding(
      padding: EdgeInsets.only(right: 70.0, top: 60.0),
      child: Text(
        translate('Account_status_'),
        textAlign: TextAlign.left,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.0),
      ),
    );
  }

//  When user is active
  Widget activeStatus() {
    return Padding(
      padding: EdgeInsets.only(right: 70.0),
      child: Row(
        children: <Widget>[
          new Container(
            margin: EdgeInsets.only(top: 10.0),
            width: 20.0,
            height: 20.0,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                    color: Color.fromRGBO(125, 183, 91, 1.0), width: 1.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: Color.fromRGBO(125, 183, 91, 1.0),
                          width: 2.5)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 5.0),
            child: Text(
              translate('Active_'),
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

//  When user is inactive
  Widget inactiveStatus() {
    return Padding(
      padding: EdgeInsets.only(right: 70.0),
      child: Row(
        children: <Widget>[
          new Container(
            margin: EdgeInsets.only(top: 10.0),
            width: 20.0,
            height: 20.0,
            decoration: new BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.red, width: 1.0)),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                new Container(
                  width: 12.0,
                  height: 12.0,
                  decoration: new BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.red, width: 2.5)),
                )
              ],
            ),
          ),
          Container(
            margin: EdgeInsets.only(top: 10.0, left: 5.0),
            child: Text(
              translate('Inactive_'),
              style: TextStyle(
                fontSize: 12.0,
              ),
            ),
          ),
        ],
      ),
    );
  }

//  When user account status
  Widget userAccountStatus() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            accountStatusText(),
            //    Radial progress bar is used to show the remaining days of user subscription
            userDetails.active == "0" ? inactiveStatus() : activeStatus(),
          ],
        ),
      ],
    );
  }

//  User subscription end date
  Widget subExpiryDate() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            //    This shows subscription end date on manage profile page and also show status of user subscription.
            Container(
              margin: EdgeInsets.only(top: 125.0, right: 40.0),
              child: Text(
                "${userDetails.end}" == ''
                    ? ''
                    : translate('Subscription_will_end_on'),
                style: TextStyle(
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              margin: EdgeInsets.only(top: 2.0, right: 40.0),
              child: userDetails.active == "1"
                  ? Text(
                      "${userDetails.end}" == ''
                          ? sw
                          : _date != null
                              ? '${DateFormat.yMMMd().format(_date!)}'
                              : sw,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.right,
                    )
                  : Text(
                      sw,
                      style: TextStyle(
                        fontSize: 12.0,
                      ),
                      textAlign: TextAlign.right,
                    ),
            )
          ],
        )
      ],
    );
  }

//  Divider Container
  Widget dividerContainer() {
    return Expanded(
      flex: 0,
      child: new Container(
        height: 80.0,
        width: 1.0,
        decoration: new BoxDecoration(
          border: Border(
            right: BorderSide(
              color: Colors.white10,
              width: 2.0,
            ),
          ),
        ),
      ),
    );
  }

//  Show mobile number
  Widget mobileNumberText(mobile) {
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.only(top: 0.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                translate('Mobile_Number'),
                style: TextStyle(
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                mobile == null ? "N/A" : "$mobile",
                style: TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.right,
              )
            ]),
      ),
    );
  }

//  Show date of birth
  Widget dobText(dob) {
    var ndob = "N/A";
    if (dob != null) {
      DateTime parseDate = new DateFormat("yyyy-MM-dd").parse(dob);
      var inputDate = DateTime.parse(parseDate.toString());
      ndob = DateFormat.yMMMd().format(inputDate);
    } else {
      ndob = "N/A";
    }
    return Expanded(
      flex: 1,
      child: Container(
        margin: EdgeInsets.only(top: 0.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                translate('Date_of_Birth'),
                style: TextStyle(
                  fontSize: 12.0,
                ),
                textAlign: TextAlign.right,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                dob == null ? "N/A" : ndob,
                style: TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.right,
              )
            ]),
      ),
    );
  }

//  Date of birth and mobile text container
  Widget dobAndMobile() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;

    return Container(
      height: 80.0,
      margin: EdgeInsets.only(top: 210.0),
      padding: EdgeInsets.only(left: 0.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          dobText(userDetails.user!.dob),
          dividerContainer(),
          mobileNumberText(userDetails.user!.mobile),
        ],
      ),
    );
  }

//  Show joined date text
  Widget joinedDateText(createdAt) {
    var sd = DateFormat("dd-mm-y HH:MM").format(createdAt);

    return Expanded(
      flex: 1,
      child: Container(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Text(
                translate("Joined_on"),
                style: TextStyle(
                  fontSize: 24.0,
                ),
                textAlign: TextAlign.left,
              ),
              SizedBox(
                height: 5.0,
              ),
              Text(
                sd,
                style: TextStyle(
                  fontSize: 14.0,
                ),
                textAlign: TextAlign.left,
              )
            ]),
      ),
    );
  }

//  Show name and joined date container
  Widget nameAndJoinedDateContainer() {
    var userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    return Container(
      height: 100.0,
      margin: EdgeInsets.only(top: 322.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Expanded(
            flex: 1,
            child: Container(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    userDetails.user!.name!,
                    style: TextStyle(
                      fontSize: 24.0,
                    ),
                    textAlign: TextAlign.left,
                  ),
                  SizedBox(
                    height: 5.0,
                  ),
                  Flexible(
                    child: Text(
                      userDetails.user!.email!,
                      style: TextStyle(
                        fontSize: 14.0,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
          joinedDateText(userDetails.user!.createdAt),
        ],
      ),
    );
  }

//  Container used as border
  Widget borderContainer1() {
    return Container(
      margin: EdgeInsets.only(left: 0.0, right: 0.0),
      height: 210.0,
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white10,
            width: 2.0,
          ),
        ),
      ),
    );
  }

//  Container used as border
  Widget borderContainer2() {
    return Container(
      height: 292.0,
      decoration: new BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Colors.white10,
            width: 2.0,
          ),
        ),
      ),
    );
  }

//  Overall UI of this page is in stack
  Widget stack() {
    return Stack(
      children: <Widget>[
        userProfileImage(),
        userAccountStatus(),
        subExpiryDate(),
        borderContainer1(),
        dobAndMobile(),
        borderContainer2(),
        nameAndJoinedDateContainer(),
        roundedSeekBarContainer(),
        popUpMenu(),
      ],
    );
  }

//  Scaffold body
  Widget scaffoldBody() {
    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: Stack(
            children: <Widget>[
              userProfileImage(),
              userAccountStatus(),
              subExpiryDate(),
              borderContainer1(),
              dobAndMobile(),
              borderContainer2(),
              nameAndJoinedDateContainer(),
              roundedSeekBarContainer(),
              popUpMenu(),
            ],
          ),
        ),
      ),
    );
  }

  late UserProfileModel userDetails;
  @override
  Widget build(BuildContext context) {
    userDetails = Provider.of<UserProfileProvider>(context, listen: false)
        .userProfileModel!;
    if ("${userDetails.end}" == '' ||
        "${userDetails.end}" == 'N/A' ||
        "${userDetails.active}" == "0") {
      sw = translate('You_are_not_Subscribed');
      setState(() {
        difference = null;
      });
    } else {
      setState(() {
        _date = userDetails.end;
      });
      difference = "${userDetails.active}" == "1" && _date != null
          ? _date!.difference(userDetails.currentDate!).inDays
          : 0.0;
      planDays = userDetails.end != null
          ? userDetails.end!.difference(userDetails.start!).inDays
          : 0.0;
      print(difference / planDays);
      progressWidth = difference / planDays;
    }
    return SafeArea(
      child: Scaffold(
        appBar: customAppBar(context, translate("Manage_Profile"))
            as PreferredSizeWidget?,
        body: scaffoldBody(),
      ),
    );
  }
}
