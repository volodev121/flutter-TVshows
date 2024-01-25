class TopMoviesTv {
  TopMoviesTv({
    this.id,
    this.movieId,
    this.tvSeriesId,
    this.isActive,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  dynamic movieId;
  dynamic tvSeriesId;
  dynamic isActive;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory TopMoviesTv.fromJson(Map<String, dynamic> json) => TopMoviesTv(
    id: json["id"],
    movieId: json["movie_id"] == null ? null : json["movie_id"],
    tvSeriesId: json["tv_series_id"] == null ? null : json["tv_series_id"],
    isActive: json["is_active"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "movie_id": movieId == null ? null : movieId,
    "tv_series_id": tvSeriesId == null ? null : tvSeriesId,
    "is_active": isActive,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
