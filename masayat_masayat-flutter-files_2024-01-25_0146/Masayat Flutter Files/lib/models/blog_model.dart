import 'package:flutter/foundation.dart';
import 'comment.dart';

class Blog extends ChangeNotifier{
  Blog({
    this.id,
    this.userId,
    this.title,
    this.slug,
    this.image,
    this.detail,
    this.createdAt,
    this.updatedAt,
    this.isActive,
    this.comments,
  });

  dynamic  id;
  dynamic userId;
  String? title;
  String? slug;
  String? image;
  String? detail;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic isActive;
  List<Comment>? comments;

  factory Blog.fromJson(Map<String, dynamic> json) => Blog(
    id: json["id"],
    userId: json["user_id"],
    title: json["title"],
    slug: json["slug"],
    image: json["image"],
    detail: json["detail"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
    isActive: json["is_active"],
    comments: List<Comment>.from(json["comments"].map((x) => Comment.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "title": title,
    "slug": slug,
    "image": image,
    "detail": detail,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "is_active": isActive,
    "comments": List<dynamic>.from(comments!.map((x) => x.toJson())),
  };
}