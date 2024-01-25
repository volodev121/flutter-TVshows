class Notifications {
  Notifications({
    this.notifications,
  });

  List<Notification>? notifications;

  factory Notifications.fromJson(Map<String, dynamic> json) => Notifications(
        notifications: List<Notification>.from(
            json["notifications"].map((x) => Notification.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "notifications":
            List<dynamic>.from(notifications!.map((x) => x.toJson())),
      };
}

class Notification {
  Notification({
    this.id,
    this.type,
    this.notifiableId,
    this.notifiableType,
    this.title,
    this.data,
    this.movieId,
    this.tvId,
    this.readAt,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  dynamic type;
  dynamic notifiableId;
  dynamic notifiableType;
  dynamic title;
  Data? data;
  dynamic movieId;
  dynamic tvId;
  dynamic readAt;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Notification.fromJson(Map<String, dynamic> json) => Notification(
        id: json["id"],
        type: json["type"],
        notifiableId: json["notifiable_id"],
        notifiableType: json["notifiable_type"],
        title: json["title"],
        data: Data.fromJson(json["data"]),
        movieId: json["movie_id"],
        tvId: json["tv_id"],
        readAt: json["read_at"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "type": type,
        "notifiable_id": notifiableId,
        "notifiable_type": notifiableType,
        "title": title,
        "data": data!.toJson(),
        "movie_id": movieId,
        "tv_id": tvId,
        "read_at": readAt,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}

class Data {
  Data({
    this.title,
    this.data,
    this.movieId,
    this.tvId,
    this.notifiableId,
  });

  String? title;
  String? data;
  String? movieId;
  String? tvId;
  List<dynamic>? notifiableId;

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        title: json["title"],
        data: json["data"],
        movieId: json["movie_id"],
        tvId: json["tv_id"],
        notifiableId: List<dynamic>.from(json["notifiable_id"].map((x) => x)),
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "data": data,
        "movie_id": movieId,
        "tv_id": tvId,
        "notifiable_id": List<dynamic>.from(notifiableId!.map((x) => x)),
      };
}
