class Comment {
  Comment({
    this.id,
    this.name,
    this.email,
    this.movieId,
    this.tvSeriesId,
    this.comment,
    this.createdAt,
    this.updatedAt,
    this.subcomments,
    this.status,
  });

  dynamic id;
  String? name;
  String? email;
  dynamic movieId;
  dynamic tvSeriesId;
  String? comment;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic status;
  List<SubComment>? subcomments;

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: json["id"] == null ? null : json["id"],
        name: json["name"] == null ? null : json["name"],
        email: json["email"] == null ? null : json["email"],
        movieId: json["movie_id"] == null ? null : json["movie_id"],
        tvSeriesId: json["tv_series_id"] == null ? null : json["tv_series_id"],
        status: json["status"],
        comment: json["comment"] == null ? null : json["comment"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        subcomments: json["subcomments"] == null
            ? null
            : List<SubComment>.from(
                json["subcomments"].map((x) => SubComment.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "name": name == null ? null : name,
        "email": email == null ? null : email,
        "movie_id": movieId == null ? null : movieId,
        "tv_series_id": tvSeriesId == null ? null : tvSeriesId,
        "comment": comment == null ? null : comment,
        "status": status,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "subcomments": subcomments == null
            ? null
            : List<dynamic>.from(subcomments!.map((x) => x.toJson())),
      };
}

class SubComment {
  SubComment({
    this.id,
    this.userId,
    this.commentId,
    this.reply,
    this.createdAt,
    this.updatedAt,
    this.status
  });

  dynamic id;
  dynamic userId;
  dynamic commentId;
  String? reply;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic status;

  factory SubComment.fromJson(Map<String, dynamic> json) => SubComment(
        id: json["id"] == null ? null : json["id"],
        userId: json["user_id"] == null ? null : json["user_id"],
        commentId: json["comment_id"] == null ? null : json["comment_id"],
        reply: json["reply"] == null ? null : json["reply"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "user_id": userId == null ? null : userId,
        "comment_id": commentId == null ? null : commentId,
        "reply": reply == null ? null : reply,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "status": status,
      };
}
