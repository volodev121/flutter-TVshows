class VideoLink {
  VideoLink({
    this.id,
    this.movieId,
    this.episodeId,
    this.uploadVideo,
    this.iframeurl,
    this.readyUrl,
    this.url360,
    this.url480,
    this.url720,
    this.url1080,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  dynamic movieId;
  dynamic episodeId;
  dynamic uploadVideo;
  String? iframeurl;
  String? readyUrl;
  dynamic url360;
  dynamic url480;
  dynamic url720;
  dynamic url1080;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory VideoLink.fromJson(Map<String, dynamic> json) => VideoLink(
        id: json["id"],
        movieId: json["movie_id"] == null ? null : json["movie_id"],
        episodeId: json["episode_id"] == null ? null : json["episode_id"],
        uploadVideo: json["upload_video"] == null ? null : json["upload_video"],
        iframeurl: json["iframeurl"] == null ? null : json["iframeurl"],
        readyUrl: json["ready_url"] == null ? null : json["ready_url"],
        url360: json["url_360"] == null ? null : json["url_360"],
        url480: json["url_480"] == null ? null : json["url_480"],
        url720: json["url_720"] == null ? null : json["url_720"],
        url1080: json["url_1080"] == null ? null : json["url_1080"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "movie_id": movieId == null ? null : movieId,
        "episode_id": episodeId == null ? null : episodeId,
        "upload_video": uploadVideo,
        "iframeurl": iframeurl == null ? null : iframeurl,
        "ready_url": readyUrl == null ? null : readyUrl,
        "url_360": url1080 == null ? null : url360,
        "url_480": url1080 == null ? null : url480,
        "url_720": url1080 == null ? null : url720,
        "url_1080": url1080 == null ? null : url1080,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": createdAt == null ? null : updatedAt!.toIso8601String(),
      };
}
