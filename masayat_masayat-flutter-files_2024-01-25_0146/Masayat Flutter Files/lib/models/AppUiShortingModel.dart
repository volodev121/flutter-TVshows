/// appUiShorting : [{"id":1,"name":"genre","position":1,"is_active":1},{"id":4,"name":"movies","position":2,"is_active":1},{"id":5,"name":"tv_series","position":3,"is_active":1},{"id":3,"name":"trending","position":4,"is_active":1},{"id":6,"name":"coming_soon","position":5,"is_active":1},{"id":7,"name":"blog","position":6,"is_active":1},{"id":8,"name":"live","position":7,"is_active":1},{"id":2,"name":"artist","position":8,"is_active":1}]

class AppUiShortingModel {
  AppUiShortingModel({
    this.appUiShorting,
  });

  AppUiShortingModel.fromJson(dynamic json) {
    if (json['appUiShorting'] != null) {
      appUiShorting = [];
      json['appUiShorting'].forEach((v) {
        appUiShorting?.add(AppUiShorting.fromJson(v));
      });
    }
  }
  List<AppUiShorting>? appUiShorting;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (appUiShorting != null) {
      map['appUiShorting'] = appUiShorting?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1
/// name : "genre"
/// position : 1
/// is_active : 1

class AppUiShorting {
  AppUiShorting({
    this.id,
    this.name,
    this.position,
    this.isActive,
  });

  AppUiShorting.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    position = int.parse(json['position'].toString());
    isActive = int.parse(json['is_active'].toString());
  }
  int? id;
  String? name;
  int? position;
  int? isActive;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['position'] = position;
    map['is_active'] = isActive;
    return map;
  }
}
