import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/notifications.dart';
import 'package:http/http.dart' as http;

class NotificationsProvider extends ChangeNotifier {
  Notifications? notifications;
  List<Notification> notificationsList = [];
  Future<Notifications?> fetchNotifications() async {
    final response =
        await http.get(Uri.parse(APIData.notificationsApi), headers: {
      "Content-Type": "application/x-www-form-urlencoded",
      HttpHeaders.authorizationHeader: "Bearer $authToken",
    });
    if (response.statusCode == 200) {
      notifications = Notifications.fromJson(json.decode(response.body));
      notificationsList = List.generate(
          notifications!.notifications!.length,
          (index) => Notification(
                id: notifications!.notifications![index].id,
                type: notifications!.notifications![index].type,
                notifiableId: notifications!.notifications![index].notifiableId,
                notifiableType:
                    notifications!.notifications![index].notifiableType,
                title: notifications!.notifications![index].title,
                data: notifications!.notifications![index].data,
                movieId: notifications!.notifications![index].movieId,
                tvId: notifications!.notifications![index].tvId,
                readAt: notifications!.notifications![index].readAt,
                createdAt: notifications!.notifications![index].createdAt,
                updatedAt: notifications!.notifications![index].updatedAt,
              ));
    } else {
      print("jsjnjns");
    }
    return notifications;
  }
}
