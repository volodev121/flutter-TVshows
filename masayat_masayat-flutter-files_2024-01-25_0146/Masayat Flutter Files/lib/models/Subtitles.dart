class Subtitles1 {
  Subtitles1({
    this.subtitles,
  });

  Subtitles1.fromJson(dynamic json) {
    if (json != null) {
      subtitles = [];
      json.forEach((v) {
        subtitles?.add(Subtitle1.fromJson(v));
      });
    }
  }

  List<Subtitle1>? subtitles;

  List<Map<String, dynamic>>? toJson() {
    List<Map<String, dynamic>>? map = [];
    if (subtitles != null) {
      map = subtitles?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

class Subtitle1 {
  Subtitle1(
    String s, {
    this.id,
    this.subLang,
    this.subT,
    this.mTId,
    this.epId,
    this.createdAt,
    this.updatedAt,
  });

  Subtitle1.fromJson(dynamic json) {
    id = json['id'];
    subLang = json['sub_lang'];
    subT = json['sub_t'];
    mTId = json['m_t_id'];
    epId = json['ep_id'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  int? id;
  String? subLang;
  String? subT;
  String? mTId;
  dynamic epId;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['sub_lang'] = subLang;
    map['sub_t'] = subT;
    map['m_t_id'] = mTId;
    map['ep_id'] = epId;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
