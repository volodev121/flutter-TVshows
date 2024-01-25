import '/models/genre_model.dart';
import 'Subtitles.dart';
import 'episode.dart';

class Season {
  Season(
      {this.id,
      this.tvSeriesId,
      this.tmdbId,
      this.seasonNo,
      this.tmdb,
      this.publishYear,
      this.thumbnail,
      this.poster,
      this.actorId,
      this.aLanguage,
      this.subtitle,
      this.subtitles,
      this.detail,
      this.featured,
      this.type,
      this.createdAt,
      this.updatedAt,
      this.episodes,
      this.actorList,
      this.directorList,
      this.audiosList,
      this.actor,
      this.strailerUrl});

  dynamic id;
  dynamic tvSeriesId;
  String? tmdbId;
  dynamic seasonNo;
  Tmdb? tmdb;
  String? publishYear;
  String? thumbnail;
  dynamic poster;
  String? actorId;
  dynamic aLanguage;
  dynamic subtitle;
  Subtitles1? subtitles;
  String? detail;
  dynamic featured;
  SeasonType? type;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Episode>? episodes;
  List<Actor?>? actorList;
  List<Director>? directorList;
  List<String?>? audiosList;
  List<String>? actor;
  String? strailerUrl;

  factory Season.fromJson(Map<String, dynamic> json) => Season(
        id: json["id"],
        tvSeriesId: json["tv_series_id"],
        tmdbId: json["tmdb_id"],
        seasonNo: json["season_no"],
        tmdb: tmdbValues.map[json["tmdb"]],
        publishYear: json["publish_year"],
        thumbnail: json["thumbnail"],
        poster: json["poster"],
        actorId: json["actor_id"] == "" ? null : json["actor_id"],
        aLanguage: json["a_language"],
        subtitle: json["subtitle"],
        subtitles: Subtitles1.fromJson(json["subtitles"]),
        detail: json["detail"],
        featured: json["featured"],
        type: seasonTypeValues.map[json["type"]],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        episodes: json["episodes"] == null
            ? null
            : List<Episode>.from(
                json["episodes"].map((x) => Episode.fromJson(x))),
        strailerUrl: json["trailer_url"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "tv_series_id": tvSeriesId,
        "tmdb_id": tmdbId,
        "season_no": seasonNo,
        "tmdb": tmdbValues.reverse![tmdb!],
        "publish_year": publishYear,
        "thumbnail": thumbnail,
        "poster": poster,
        "actor_id": actorId,
        "a_language": aLanguage,
        "subtitle": subtitle,
        "subtitles": subtitles,
        "detail": detail,
        "featured": featured,
        "type": seasonTypeValues.reverse![type],
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "episodes": List<dynamic>.from(episodes!.map((x) => x.toJson())),
        "trailer_url": strailerUrl
      };
}

enum SeasonType { S }

final seasonTypeValues = EnumValues({"S": SeasonType.S});

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
