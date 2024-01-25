import 'genre_model.dart';

class ActorMoviesDetails {
  ActorMoviesDetails({
    this.actormovies,
    this.actor,
  });

  List<Actormovie>? actormovies;
  Actor? actor;

  factory ActorMoviesDetails.fromJson(Map<String, dynamic> json) => ActorMoviesDetails(
    actormovies: List<Actormovie>.from(json["actormovies"].map((x) => Actormovie.fromJson(x))),
    actor: Actor.fromJson(json["actor"]),
  );

  Map<String, dynamic> toJson() => {
    "actormovies": List<dynamic>.from(actormovies!.map((x) => x.toJson())),
    "actor": actor!.toJson(),
  };
}

class Actormovie {
  Actormovie({
    this.id,
    this.tvSeriesId,
    this.seasonNo,
    this.seasonSlug,
    this.subtitleList,
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
    this.publishYear,
    this.released,
    this.uploadVideo,
    this.featured,
    this.series,
    this.aLanguage,
    this.audioFiles,
    this.type,
    this.live,
    this.livetvicon,
    this.status,
    this.slug,
    this.isProtect,
    this.password,
    this.createdBy,
    this.createdAt,
    this.updatedAt,
    this.userRating,
  });

  dynamic  id;
  dynamic tvSeriesId;
  dynamic seasonNo;
  String? seasonSlug;
  dynamic subtitleList;
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
  dynamic publishYear;
  DateTime? released;
  dynamic uploadVideo;
  dynamic featured;
  dynamic series;
  dynamic aLanguage;
  dynamic audioFiles;
  String? type;
  dynamic live;
  dynamic livetvicon;
  dynamic status;
  String? slug;
  dynamic isProtect;
  dynamic password;
  dynamic createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic userRating;

  factory Actormovie.fromJson(Map<String, dynamic> json) => Actormovie(
    id: json["id"],
    tvSeriesId: json["tv_series_id"] == null ? null : json["tv_series_id"],
    seasonNo: json["season_no"],
    seasonSlug: json["season_slug"],
    subtitleList: json["subtitle_list"] == null ? null : json["subtitle_list"],
    tmdbId: json["tmdb_id"],
    title: json["title"],
    keyword: json["keyword"],
    description: json["description"],
    duration: json["duration"],
    thumbnail: json["thumbnail"],
    poster: json["poster"],
    tmdb: json["tmdb"],
    fetchBy: json["fetch_by"],
    directorId: json["director_id"] == null ? null : json["director_id"],
    actorId: json["actor_id"] == null ? null : json["actor_id"],
    genreId: json["genre_id"] == null ? null: json["genre_id"],
    trailerUrl: json["trailer_url"] == null ? null : json["trailer_url"],
    detail: json["detail"],
    rating: json["rating"] == null ? null : json["rating"],
    maturityRating: json["maturity_rating"],
    subtitle: json["subtitle"],
    publishYear: json["publish_year"] == null ? null : json["publish_year"],
    released: json["released"] == null ? null : DateTime.parse(json["released"]),
    uploadVideo: json["upload_video"],
    featured: json["featured"],
    series: json["series"],
    aLanguage: json["a_language"],
    audioFiles: json["audio_files"],
    type: json["type"],
    live: json["live"],
    livetvicon: json["livetvicon"],
    status: json["status"],
    slug: json["slug"],
    isProtect: json["is_protect"],
    password: json["password"],
    createdBy: json["created_by"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
    userRating: json["user-rating"] == null ? null : json["user-rating"],
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
    "trailer_url": trailerUrl == null ? null : trailerUrl,
    "detail": detail,
    "rating": rating,
    "maturity_rating": maturityRating,
    "subtitle": subtitle,
    "publish_year": publishYear,
    "released": "${released!.year.toString().padLeft(4, '0')}-${released!.month.toString().padLeft(2, '0')}-${released!.day.toString().padLeft(2, '0')}",
    "upload_video": uploadVideo,
    "featured": featured,
    "series": series,
    "a_language": aLanguage,
    "audio_files": audioFiles,
    "type": type,
    "live": live,
    "livetvicon": livetvicon,
    "status": status,
    "slug": slug,
    "is_protect": isProtect,
    "password": password,
    "created_by": createdBy,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
    "user-rating": userRating,
  };
}


class ActorTvSeriesDetails {
  ActorTvSeriesDetails({
    this.actormovies,
    this.actor,
  });

  List<ActorTvSeries>? actormovies;
  Actor? actor;

  factory ActorTvSeriesDetails.fromJson(Map<String, dynamic> json) => ActorTvSeriesDetails(
    actormovies: List<ActorTvSeries>.from(json["actormovies"].map((x) => ActorTvSeries.fromJson(x))),
    actor: Actor.fromJson(json["actor"]),
  );

  Map<String, dynamic> toJson() => {
    "actormovies": List<dynamic>.from(actormovies!.map((x) => x.toJson())),
    "actor": actor!.toJson(),
  };
}


class ActorTvSeries {
  ActorTvSeries({
    this.id,
    this.tvSeriesId,
    this.tmdbId,
    this.seasonNo,
    this.seasonSlug,
    this.tmdb,
    this.publishYear,
    this.thumbnail,
    this.poster,
    this.actorId,
    this.aLanguage,
    this.subtitle,
    this.subtitleList,
    this.detail,
    this.featured,
    this.type,
    this.trailerUrl,
    this.isProtect,
    this.password,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  dynamic  tvSeriesId;
  dynamic tmdbId;
  dynamic seasonNo;
  String? seasonSlug;
  String? tmdb;
  String? publishYear;
  String? thumbnail;
  String? poster;
  String? actorId;
  String? aLanguage;
  dynamic subtitle;
  dynamic subtitleList;
  String? detail;
  dynamic featured;
  String? type;
  String? trailerUrl;
  dynamic isProtect;
  dynamic password;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory ActorTvSeries.fromJson(Map<String, dynamic> json) => ActorTvSeries(
    id: json["id"],
    tvSeriesId: json["tv_series_id"],
    tmdbId: json["tmdb_id"],
    seasonNo: json["season_no"],
    seasonSlug: json["season_slug"],
    tmdb: json["tmdb"],
    publishYear: json["publish_year"] == null ? null : json["publish_year"],
    thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
    poster: json["poster"] == null ? null : json["poster"],
    actorId: json["actor_id"],
    aLanguage: json["a_language"],
    subtitle: json["subtitle"],
    subtitleList: json["subtitle_list"],
    detail: json["detail"],
    featured: json["featured"],
    type: json["type"],
    trailerUrl: json["trailer_url"] == null ? null : json["trailer_url"],
    isProtect: json["is_protect"],
    password: json["password"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "tv_series_id": tvSeriesId,
    "tmdb_id": tmdbId,
    "season_no": seasonNo,
    "season_slug": seasonSlug,
    "tmdb": tmdb,
    "publish_year": publishYear == null ? null : publishYear,
    "thumbnail": thumbnail == null ? null : thumbnail,
    "poster": poster == null ? null : poster,
    "actor_id": actorId,
    "a_language": aLanguage,
    "subtitle": subtitle,
    "subtitle_list": subtitleList,
    "detail": detail,
    "featured": featured,
    "type": type,
    "trailer_url": trailerUrl == null ? null : trailerUrl,
    "is_protect": isProtect,
    "password": password,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}


