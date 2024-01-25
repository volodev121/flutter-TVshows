import '../models/comment.dart';
import '../models/genre_model.dart';
import '../models/seasons.dart';
import '../models/video_link.dart';
import 'Subtitles.dart';
import 'episode.dart';

class Datum {
  Datum({
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
    this.subtitles,
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
    this.isUpcoming,
    this.userRating,
    this.movieSeries,
    this.videoLink,
    this.comments,
    this.episodeRuntime,
    this.seasons,
    this.genre,
    this.genres,
    this.directors,
    this.actors,
    this.audios,
    this.actor,
    this.country,
    this.isKids,
  });

  dynamic id;
  dynamic tmdbId;
  String? title;
  String? keyword;
  String? description;
  String? duration;
  String? thumbnail;
  String? poster;
  Tmdb? tmdb;
  FetchBy? fetchBy;
  String? directorId;
  String? actorId;
  String? genreId;
  String? trailerUrl;
  String? detail;
  dynamic rating;
  MaturityRating? maturityRating;
  dynamic subtitle;
  Subtitles1? subtitles;
  dynamic publishYear;
  DateTime? released;
  dynamic uploadVideo;
  dynamic featured;
  dynamic series;
  String? aLanguage;
  dynamic audioFiles;
  DatumType? type;
  dynamic live;
  dynamic status;
  dynamic createdBy;
  DateTime? createdAt;
  DateTime? updatedAt;
  dynamic isUpcoming;
  dynamic userRating;
  List<MovieSery>? movieSeries;
  VideoLink? videoLink;
  List<Comment>? comments;
  dynamic episodeRuntime;
  List<Season>? seasons;
  List<String>? genre;
  List<String?>? genres;
  List<Director?>? directors;
  List<Actor?>? actors;
  List<String?>? audios;
  List<String>? actor;
  List<String>? country;
  int? isKids;

  factory Datum.fromJson(Map<String, dynamic> json) {
    return Datum(
      id: json["id"],
      tmdbId: json["tmdb_id"] == null ? null : json["tmdb_id"],
      title: json["title"],
      keyword: json["keyword"],
      description: json["description"],
      duration: json["duration"] == null ? null : json["duration"],
      thumbnail: json["thumbnail"] == null ? null : json["thumbnail"],
      poster: json["poster"] == null ? null : json["poster"],
      tmdb: json["tmdb"] == null ? null : tmdbValues.map[json["tmdb"]],
      fetchBy:
          json["fetch_by"] == null ? null : fetchByValues.map[json["fetch_by"]],
      directorId: json["director_id"] == null ? null : json["director_id"],
      actorId: json["actor_id"] == null ? null : json["actor_id"],
      genreId: json["genre_id"] == null ? null : json["genre_id"],
      trailerUrl: json["trailer_url"] == null ? null : json["trailer_url"],
      detail: json["detail"] == null ? null : json["detail"],
      rating: json["rating"] == null ? null : json["rating"],
      maturityRating: maturityRatingValues.map[json["maturity_rating"]],
      subtitle: json["subtitle"] == null ? null : json["subtitle"],
      subtitles: json["subtitles"] == null
          ? null
          : Subtitles1.fromJson(json["subtitles"]),
      publishYear: json["publish_year"] == null ? null : json["publish_year"],
      released: json["released"] == null || json["released"] == ''
          ? null
          : DateTime.parse(json["released"]),
      uploadVideo: json["upload_video"] == null ? null : json["upload_video"],
      featured: json["featured"] == null ? null : json["featured"],
      series: json["series"] == null ? null : json["series"],
      aLanguage: json["a_language"] == null ? null : json["a_language"],
      audioFiles: json["audio_files"] == null ? null : json["audio_files"],
      type: json["type"] == null ? null : datumTypeValues.map[json["type"]],
      live: json["live"] == null ? null : json["live"],
      status: json["status"] == null ? null : json["status"],
      createdBy: json["created_by"] == null ? null : json["created_by"],
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json["created_at"]),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json["updated_at"]),
      isUpcoming: json["is_upcoming"] == null ? null : json["is_upcoming"],
      userRating: json["user-rating"] == null ? null : json["user-rating"],
      movieSeries:
          json["movie_series"] == null || json["movie_series"].length == 0
              ? null
              : List<MovieSery>.from(
                  json["movie_series"].map((x) => MovieSery.fromJson(x))),
      videoLink: json["video_link"] == null
          ? null
          : VideoLink.fromJson(json["video_link"]),
      comments: json["comments"].length == 0 || json["comments"] == null
          ? [
              Comment(
                id: 0,
                name: "xx",
                email: "xx",
                comment: "No Comments",
                status: 1,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              )
            ]
          : List<Comment>.from(
              json["comments"].map((x) => Comment.fromJson(x))),
      episodeRuntime: json["episode_runtime"],
      seasons: json["seasons"] == null || json["seasons"].length == 0
          ? null
          : List<Season>.from(json["seasons"].map((x) => Season.fromJson(x))),
      country: (json['country'] != null && json['country'] != 0)
          ? List<String>.from(json["country"].map((x) => x))
          : [],
      isKids: json["is_kids"] == null
          ? 0
          : int.tryParse(json["is_kids"].toString()),
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "tmdb_id": tmdbId == null ? null : tmdbId,
        "title": title == null ? null : title,
        "keyword": keyword == null ? null : keyword,
        "description": description == null ? null : description,
        "duration": duration == null ? null : duration,
        "thumbnail": thumbnail == null ? null : thumbnail,
        "poster": poster == null ? null : poster,
        "tmdb": tmdb == null ? null : tmdbValues.reverse![tmdb!],
        "fetch_by": fetchBy == null ? null : fetchByValues.reverse![fetchBy!],
        "director_id": directorId == null ? null : directorId,
        "actor_id": actorId == null ? null : actorId,
        "genre_id": genreId == null ? null : genreId,
        "trailer_url": trailerUrl == null ? null : trailerUrl,
        "detail": detail == null ? null : detail,
        "rating": rating == null ? null : rating,
        "maturity_rating": maturityRating == null
            ? null
            : maturityRatingValues.reverse![maturityRating!],
        "subtitle": subtitle == null ? null : subtitle,
        "subtitles": subtitles == null ? null : subtitles?.toJson(),
        "publish_year": publishYear == null ? null : publishYear,
        "released": released == null
            ? null
            : "${released!.year.toString().padLeft(4, '0')}-${released!.month.toString().padLeft(2, '0')}-${released!.day.toString().padLeft(2, '0')}",
        "upload_video": uploadVideo == null ? null : uploadVideo,
        "featured": featured,
        "series": series == null ? null : series,
        "a_language": aLanguage == null ? null : aLanguage,
        "audio_files": audioFiles == null ? null : audioFiles,
        "type": type == null ? null : datumTypeValues.reverse![type!],
        "live": live == null ? null : live,
        "status": status == null ? null : status,
        "created_by": createdBy == null ? null : createdBy,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
        "is_upcoming": isUpcoming == null ? null : isUpcoming,
        "user-rating": userRating == null ? null : userRating,
        "movie_series": movieSeries == null
            ? null
            : List<dynamic>.from(movieSeries!.map((x) => x.toJson())),
        "video_link": videoLink == null ? null : videoLink!.toJson(),
        "comments": List<dynamic>.from(comments!.map((x) => x.toJson())),
        "episode_runtime": episodeRuntime == null ? null : episodeRuntime,
        "seasons": seasons == null
            ? null
            : List<dynamic>.from(seasons!.map((x) => x.toJson())),
        "country":
            country == [] ? [] : List<String>.from(country!.map((x) => x)),
        "is_kids": isKids,
      };
}

enum FetchBy { TITLE, BY_ID }

final fetchByValues =
    EnumValues({"byID": FetchBy.BY_ID, "title": FetchBy.TITLE});

enum MaturityRating { ALL_AGE, ADULT }

final maturityRatingValues = EnumValues(
    {"all age": MaturityRating.ALL_AGE, "18+": MaturityRating.ADULT});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}

class MovieSery {
  MovieSery({
    this.id,
    this.movieId,
    this.seriesMovieId,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  dynamic movieId;
  String? seriesMovieId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory MovieSery.fromJson(Map<String, dynamic> json) => MovieSery(
        id: json["id"],
        movieId: json["movie_id"],
        seriesMovieId: json["series_movie_id"],
        createdAt: json['created_at'] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json['updated_at'] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id == null ? null : id,
        "movie_id": movieId == null ? null : movieId,
        "series_movie_id": seriesMovieId == null ? null : seriesMovieId,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
      };
}
