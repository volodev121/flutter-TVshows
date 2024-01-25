import '/models/top_movies_tv.dart';
import 'datum.dart';

class MovieTv {
  MovieTv({
    this.data,
    this.topMoviesTv,
  });

  List<Datum>? data;
  List<TopMoviesTv>? topMoviesTv;

  factory MovieTv.fromJson(Map<String, dynamic> json) => MovieTv(
        data: List<Datum>.from(json["data"].map((x) => Datum.fromJson(x))),
        topMoviesTv: List<TopMoviesTv>.from(
            json["top_movies_tv"].map((x) => TopMoviesTv.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "data": List<dynamic>.from(data!.map((x) => x.toJson())),
        "top_movies_tv":
            List<dynamic>.from(topMoviesTv!.map((x) => x.toJson())),
      };
}
