/// language : [{"id":1,"local":"en","name":"English","def":"1","created_at":"2020-01-21T07:38:34.000000Z","updated_at":"2020-01-21T07:38:34.000000Z"},{"id":2,"local":"ar","name":"Arabic","def":"0","created_at":"2020-03-12T07:25:22.000000Z","updated_at":"2020-03-12T07:25:22.000000Z"},{"id":4,"local":"ur","name":"Urdu","def":"0","created_at":"2020-05-22T09:15:48.000000Z","updated_at":"2020-05-22T09:15:48.000000Z"}]

class LanguageModel {
  List<Language>? _language;

  List<Language>? get language => _language;

  LanguageModel({List<Language>? language}) {
    _language = language;
  }

  LanguageModel.fromJson(dynamic json) {
    if (json["language"] != null) {
      _language = [];
      json["language"].forEach((v) {
        _language?.add(Language.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    if (_language != null) {
      map["language"] = _language?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1
/// local : "en"
/// name : "English"
/// def : "1"
/// created_at : "2020-01-21T07:38:34.000000Z"
/// updated_at : "2020-01-21T07:38:34.000000Z"

class Language {
  int? _id;
  String? _local;
  String? _name;
  dynamic _def;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;
  String? get local => _local;
  String? get name => _name;
  dynamic get def => _def;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Language(
      {int? id,
      String? local,
      String? name,
      dynamic def,
      String? createdAt,
      String? updatedAt}) {
    _id = id;
    _local = local;
    _name = name;
    _def = def;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  Language.fromJson(dynamic json) {
    _id = json["id"];
    _local = json["local"];
    _name = json["name"];
    _def = json["def"];
    _createdAt = json["created_at"];
    _updatedAt = json["updated_at"];
  }

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{};
    map["id"] = _id;
    map["local"] = _local;
    map["name"] = _name;
    map["def"] = _def;
    map["created_at"] = _createdAt;
    map["updated_at"] = _updatedAt;
    return map;
  }
}
