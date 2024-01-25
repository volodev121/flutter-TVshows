import '/models/seasons.dart';

class WatchHistoryModel {
  WatchHistoryModel({
    this.watchHistory,
  });

  List<WatchHistory>? watchHistory;

  factory WatchHistoryModel.fromJson(Map<String, dynamic> json) =>
      WatchHistoryModel(
        watchHistory: json["watch_history"] == null
            ? null
            : List<WatchHistory>.from(
                json["watch_history"].map((x) => WatchHistory.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "watch_history":
            List<dynamic>.from(watchHistory!.map((x) => x.toJson())),
      };
}

class WatchHistory {
  WatchHistory({
    this.id,
    this.movieId,
    this.tvId,
    this.userId,
    this.createdAt,
    this.updatedAt,
    this.movies,
    this.tvseries,
  });

  dynamic id;
  dynamic movieId;
  dynamic tvId;
  dynamic userId;
  DateTime? createdAt;
  DateTime? updatedAt;
  Movies? movies;
  Tvseries? tvseries;

  factory WatchHistory.fromJson(Map<String, dynamic> json) => WatchHistory(
        id: json["id"],
        movieId: json["movie_id"] == null ? null : json["movie_id"],
        tvId: json["tv_id"] == null ? null : json["tv_id"],
        userId: json["user_id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        movies: json["movies"] == null ? null : Movies.fromJson(json["movies"]),
        tvseries: json["tvseries"] == null
            ? null
            : Tvseries.fromJson(json["tvseries"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "movie_id": movieId == null ? null : movieId,
        "tv_id": tvId == null ? null : tvId,
        "user_id": userId,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "movies": movies == null ? null : movies!.toJson(),
        "tvseries": tvseries == null ? null : tvseries!.toJson(),
      };
}

class Movies {
  Movies({
    this.id,
    this.tmdbId,
    this.title,
    this.keyword,
    this.description,
    this.duration,
    this.thumbnail,
    this.poster,
    this.tmdb,
    this.fetchBy,
    this.directorId,
    this.actorId,
    this.genreId,
    this.trailerUrl,
    this.detail,
    this.rating,
    this.maturityRating,
    this.subtitle,
    this.subtitleList,
    this.subtitleFiles,
    this.publishYear,
    this.released,
    this.uploadVideo,
    this.featured,
    this.series,
    this.aLanguage,
    this.audioFiles,
    this.type,
    this.live,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.userRating,
  });

  dynamic id;
  dynamic tmdbId;
  String? title;
  String? keyword;
  String? description;
  String? duration;
  String? thumbnail;
  String? poster;
  String? tmdb;
  String? fetchBy;
  String? directorId;
  String? actorId;
  String? genreId;
  String? trailerUrl;
  String? detail;
  dynamic rating;
  String? maturityRating;
  dynamic subtitle;
  dynamic subtitleList;
  dynamic subtitleFiles;
  dynamic publishYear;
  DateTime? released;
  dynamic uploadVideo;
  dynamic featured;
  dynamic series;
  String? aLanguage;
  dynamic audioFiles;
  String? type;
  dynamic live;
  dynamic status;
  dynamic createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic userRating;

  factory Movies.fromJson(Map<String, dynamic> json) => Movies(
        id: json["id"],
        tmdbId: json["tmdb_id"],
        title: json["title"],
        keyword: json["keyword"],
        description: json["description"],
        duration: json["duration"],
        thumbnail: json["thumbnail"],
        poster: json["poster"],
        tmdb: json["tmdb"],
        fetchBy: json["fetch_by"],
        directorId: json["director_id"],
        actorId: json["actor_id"],
        genreId: json["genre_id"],
        trailerUrl: json["trailer_url"],
        detail: json["detail"],
        rating: json["rating"],
        maturityRating: json["maturity_rating"],
        subtitle: json["subtitle"],
        subtitleList: json["subtitle_list"],
        subtitleFiles: json["subtitle_files"],
        publishYear: json["publish_year"],
        released:
            json['released'] == null ? null : DateTime.parse(json["released"]),
        uploadVideo: json["upload_video"],
        featured: json["featured"],
        series: json["series"],
        aLanguage: json["a_language"] == null ? null : json["a_language"],
        audioFiles: json["audio_files"],
        type: json["type"],
        live: json["live"],
        status: json["status"],
        createdBy: json["created_by"],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        userRating: json["user-rating"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tmdb_id": tmdbId,
        "title": title,
        "keyword": keyword,
        "description": description,
        "duration": duration,
        "thumbnail": thumbnail,
        "poster": poster,
        "tmdb": tmdb,
        "fetch_by": fetchBy,
        "director_id": directorId,
        "actor_id": actorId,
        "genre_id": genreId,
        "trailer_url": trailerUrl,
        "detail": detail,
        "rating": rating,
        "maturity_rating": maturityRating,
        "subtitle": subtitle,
        "subtitle_list": subtitleList,
        "subtitle_files": subtitleFiles,
        "publish_year": publishYear,
        "released":
            "${released!.year.toString().padLeft(4, '0')}-${released!.month.toString().padLeft(2, '0')}-${released!.day.toString().padLeft(2, '0')}",
        "upload_video": uploadVideo,
        "featured": featured,
        "series": series,
        "a_language": aLanguage == null ? null : aLanguage,
        "audio_files": audioFiles,
        "type": type,
        "live": live,
        "status": status,
        "created_by": createdBy,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "user-rating": userRating,
      };
}

class Tvseries {
  Tvseries({
    this.id,
    this.keyword,
    this.description,
    this.title,
    this.tmdbId,
    this.tmdb,
    this.fetchBy,
    this.thumbnail,
    this.poster,
    this.genreId,
    this.detail,
    this.rating,
    this.episodeRuntime,
    this.maturityRating,
    this.featured,
    this.type,
    this.status,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.userRating,
    this.seasons,
  });

  dynamic id;
  String? keyword;
  String? description;
  String? title;
  String? tmdbId;
  String? tmdb;
  String? fetchBy;
  String? thumbnail;
  String? poster;
  String? genreId;
  String? detail;
  dynamic rating;
  dynamic episodeRuntime;
  String? maturityRating;
  dynamic featured;
  String? type;
  dynamic status;
  dynamic createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic userRating;
  List<Season>? seasons;

  factory Tvseries.fromJson(Map<String, dynamic> json) => Tvseries(
        id: json["id"],
        keyword: json["keyword"],
        description: json["description"],
        title: json["title"],
        tmdbId: json["tmdb_id"],
        tmdb: json["tmdb"],
        fetchBy: json["fetch_by"],
        thumbnail: json["thumbnail"],
        poster: json["poster"],
        genreId: json["genre_id"],
        detail: json["detail"],
        rating: json["rating"],
        episodeRuntime: json["episode_runtime"],
        maturityRating: json["maturity_rating"],
        featured: json["featured"],
        type: json["type"],
        status: json["status"],
        createdBy: json["created_by"],
        createdAt: json["created_at"] != null
            ? DateTime.parse(json["created_at"])
            : null,
        updatedAt: json["updated_at"] != null
            ? DateTime.parse(json["updated_at"])
            : null,
        userRating: json["user-rating"],
        seasons: json["seasons"] == null
            ? []
            : List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "keyword": keyword,
        "description": description,
        "title": title,
        "tmdb_id": tmdbId,
        "tmdb": tmdb,
        "fetch_by": fetchBy,
        "thumbnail": thumbnail,
        "poster": poster,
        "genre_id": genreId,
        "detail": detail,
        "rating": rating,
        "episode_runtime": episodeRuntime,
        "maturity_rating": maturityRating,
        "featured": featured,
        "type": type,
        "status": status,
        "created_by": createdBy,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "user-rating": userRating,
        "seasons": List<dynamic>.from(seasons!.map((x) => x.toJson())),
      };
}
