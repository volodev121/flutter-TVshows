/// auido : [{"id":1,"title":"Test Audio","slug":null,"keyword":null,"description":null,"thumbnail":null,"poster":null,"rating":5,"maturity_rating":"all age","upload_audio":"audio_162799954701.mp3","type":null,"genre_id":"1","detail":"Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum.","is_protect":0,"password":null,"audiourl":null,"featured":0,"status":null,"created_at":"2021-08-03T14:05:47.000000Z","updated_at":"2021-08-03T14:05:47.000000Z"},{"id":2,"title":"testing","slug":null,"keyword":null,"description":null,"thumbnail":null,"poster":null,"rating":null,"maturity_rating":"all age","upload_audio":"3 Salan Da Pyar - Balraj (DjPunjab.Com).mp3","type":null,"genre_id":null,"detail":null,"is_protect":0,"password":null,"audiourl":null,"featured":0,"status":null,"created_at":"2022-06-02T02:07:35.000000Z","updated_at":"2022-06-02T02:07:35.000000Z"}]

class AudioModel {
  AudioModel({
    this.audio,
  });

  AudioModel.fromJson(dynamic json) {
    if (json['audio'] != null) {
      audio = [];
      json['audio'].forEach((v) {
        audio?.add(Audio.fromJson(v));
      });
    }
  }
  List<Audio>? audio;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (audio != null) {
      map['audio'] = audio?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1
/// title : "Test Audio"
/// slug : null
/// keyword : null
/// description : null
/// thumbnail : null
/// poster : null
/// rating : 5
/// maturity_rating : "all age"
/// upload_audio : "audio_162799954701.mp3"
/// type : null
/// genre_id : "1"
/// detail : "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries, but also the leap into electronic typesetting, remaining essentially unchanged. It was popularised in the 1960s with the release of Letraset sheets containing Lorem Ipsum passages, and more recently with desktop publishing software like Aldus PageMaker including versions of Lorem Ipsum."
/// is_protect : 0
/// password : null
/// audiourl : null
/// featured : 0
/// status : null
/// created_at : "2021-08-03T14:05:47.000000Z"
/// updated_at : "2021-08-03T14:05:47.000000Z"

class Audio {
  Audio({
    this.id,
    this.title,
    this.slug,
    this.keyword,
    this.description,
    this.thumbnail,
    this.poster,
    this.rating,
    this.maturityRating,
    this.uploadAudio,
    this.type,
    this.genreId,
    this.detail,
    this.isProtect,
    this.password,
    this.audiourl,
    this.featured,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Audio.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    keyword = json['keyword'];
    description = json['description'];
    thumbnail = json['thumbnail'];
    poster = json['poster'];
    rating = json['rating'];
    maturityRating = json['maturity_rating'];
    uploadAudio = json['upload_audio'];
    type = json['type'];
    genreId = json['genre_id'];
    detail = json['detail'];
    isProtect = json['is_protect'];
    password = json['password'];
    audiourl = json['audiourl'];
    featured = json['featured'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  int? id;
  String? title;
  dynamic slug;
  dynamic keyword;
  dynamic description;
  dynamic thumbnail;
  dynamic poster;
  int? rating;
  String? maturityRating;
  String? uploadAudio;
  dynamic type;
  String? genreId;
  String? detail;
  int? isProtect;
  dynamic password;
  dynamic audiourl;
  int? featured;
  dynamic status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['slug'] = slug;
    map['keyword'] = keyword;
    map['description'] = description;
    map['thumbnail'] = thumbnail;
    map['poster'] = poster;
    map['rating'] = rating;
    map['maturity_rating'] = maturityRating;
    map['upload_audio'] = uploadAudio;
    map['type'] = type;
    map['genre_id'] = genreId;
    map['detail'] = detail;
    map['is_protect'] = isProtect;
    map['password'] = password;
    map['audiourl'] = audiourl;
    map['featured'] = featured;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
