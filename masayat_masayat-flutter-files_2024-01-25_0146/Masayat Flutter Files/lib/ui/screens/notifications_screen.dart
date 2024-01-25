import 'package:flutter/material.dart';
import 'package:flutter_translate/flutter_translate.dart';
import '/common/route_paths.dart';
import '/common/styles.dart';
import '/providers/notifications_provider.dart';
import '/ui/screens/notification_detail_screen.dart';
import '/ui/shared/appbar.dart';
import 'package:provider/provider.dart';

class NotificationsScreen extends StatefulWidget {
  @override
  _NotificationsScreenState createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {});
    try {
      NotificationsProvider notificationsProvider =
          Provider.of<NotificationsProvider>(context, listen: false);
      notificationsProvider.fetchNotifications();
      if (mounted) {
        setState(() {
          _visible = true;
        });
      }
    } catch (err) {
      return null;
    }
  }

  Widget notificationIconContainer() {
    return Container(
      child: Icon(
        Icons.notifications,
        size: 170.0,
        color: Color.fromRGBO(70, 70, 70, 1.0),
      ),
    );
  }

//  Message when any notification is not available
  Widget message() {
    return Padding(
      padding: EdgeInsets.only(left: 50.0, right: 50.0),
      child: Text(
        translate("You_dont_have_any_notification"),
        style: TextStyle(
          height: 1.5,
          fontSize: 18.0,
        ),
      ),
    );
  }

//  When don't have any notification.
  Widget blankNotification() {
    return Container(
      alignment: Alignment.center,
      child: Column(
        children: <Widget>[
          SizedBox(
            height: MediaQuery.of(context).size.height / 4,
          ),
          notificationIconContainer(),
          SizedBox(
            height: 25.0,
          ),
          message(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var notifications =
        Provider.of<NotificationsProvider>(context).notificationsList;
    return Scaffold(
      appBar: customAppBar(context, translate("Notifications_"))
          as PreferredSizeWidget?,
      body: _visible == false
          ? Center(
              child: CircularProgressIndicator(),
            )
          : notifications.length == 0
              ? blankNotification()
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Column(
                      children: <Widget>[
                        ListTile(
                          leading: CircleAvatar(
                            radius: 35.0,
                            backgroundColor: primaryBlue,
                            child: Text(
                              "${index + 1}",
                              // style: TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text("${notifications[index].title}"),
                          subtitle: Text(
                            "${notifications[index].data!.data}",
                            style: TextStyle(
                              fontSize: 12.0,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              RoutePaths.notificationDetail,
                              arguments: NotificationDetailScreen(
                                notifications[index].title,
                                notifications[index].data!.data,
                              ),
                            );
                          },
                        ),
                        SizedBox(
                          height: 5.0,
                        ),
                        Container(
                          color: Colors.white,
                          height: 0.15,
                        ),
                      ],
                    );
                  },
                ),
    );
  }
}
