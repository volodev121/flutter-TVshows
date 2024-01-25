import 'package:flutter/foundation.dart';

class SliderModel extends ChangeNotifier {
  SliderModel({
    this.slider,
  });

  List<Slider>? slider;

  factory SliderModel.fromJson(Map<dynamic, dynamic> json) => SliderModel(
        slider: json["app_slider"] == null
            ? []
            : List<Slider>.from(
                json["app_slider"].map((x) => Slider.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "app_slider": List<dynamic>.from(slider!.map((x) => x.toJson())),
      };
}

class Slider {
  Slider({
    this.id,
    this.movieId,
    this.tvSeriesId,
    this.slideImage,
    this.active,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  dynamic movieId;
  dynamic tvSeriesId;
  dynamic slideImage;
  dynamic active;
  dynamic position;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Slider.fromJson(Map<String, dynamic> json) => Slider(
        id: json["id"],
        movieId: json["movie_id"],
        tvSeriesId: json["tv_series_id"],
        slideImage: json["slide_image"],
        active: json["active"],
        position: json["position"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "movie_id": movieId,
        "tv_series_id": tvSeriesId,
        "slide_image": slideImage,
        "active": active,
        "position": position,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
