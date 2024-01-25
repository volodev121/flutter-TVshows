import 'datum.dart';

class MenuByCategory {
  MenuByCategory({this.auth, this.data, this.audio, this.liveEvent});

  Auth? auth;
  List<List<Datum>>? data;
  List<Audio>? audio;
  List<LiveEvent>? liveEvent;

  factory MenuByCategory.fromJson(Map<String, dynamic> json) {
    List<Audio>? _audio = [];
    if (json['audio'] != null) {
      json['audio'].forEach((v) {
        _audio.add(Audio.fromJson(v));
      });
    }

    List<LiveEvent>? _liveEvent = [];
    if (json['liveEvent'] != null) {
      json['liveEvent'].forEach((v) {
        _liveEvent.add(LiveEvent.fromJson(v));
      });
    }
    return MenuByCategory(
      auth: Auth.fromJson(json["auth"]),
      data: json["data"] == null
          ? null
          : List<List<Datum>>.from(
              json["data"].map(
                (x) => List<Datum>.from(
                  x.map(
                    (x) => Datum.fromJson(x),
                  ),
                ),
              ),
            ),
      audio: _audio,
      liveEvent: _liveEvent,
    );
  }

  Map<String, dynamic> toJson() => {
        "auth": auth!.toJson(),
        "data": data == null
            ? null
            : List<dynamic>.from(
                data!.map(
                  (x) => List<dynamic>.from(
                    x.map(
                      (x) => x.toJson(),
                    ),
                  ),
                ),
              ),
      };
}

class Auth {
  Auth({
    this.id,
    this.name,
    this.image,
    this.email,
    this.verifyToken,
    this.status,
    this.googleId,
    this.facebookId,
    this.gitlabId,
    this.dob,
    this.age,
    this.mobile,
    this.braintreeId,
    this.code,
    this.stripeId,
    this.cardBrand,
    this.cardLastFour,
    this.trialEndsAt,
    this.isAdmin,
    this.isAssistant,
    this.isBlocked,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  String? name;
  dynamic image;
  String? email;
  dynamic verifyToken;
  dynamic status;
  dynamic googleId;
  dynamic facebookId;
  dynamic gitlabId;
  dynamic dob;
  dynamic age;
  dynamic mobile;
  dynamic braintreeId;
  dynamic code;
  dynamic stripeId;
  dynamic cardBrand;
  dynamic cardLastFour;
  dynamic trialEndsAt;
  dynamic isAdmin;
  dynamic isAssistant;
  dynamic isBlocked;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Auth.fromJson(Map<String, dynamic> json) => Auth(
        id: json["id"],
        name: json["name"],
        image: json["image"],
        email: json["email"],
        verifyToken: json["verifyToken"],
        status: json["status"],
        googleId: json["google_id"],
        facebookId: json["facebook_id"],
        gitlabId: json["gitlab_id"],
        dob: json["dob"],
        age: json["age"],
        mobile: json["mobile"],
        braintreeId: json["braintree_id"],
        code: json["code"],
        stripeId: json["stripe_id"],
        cardBrand: json["card_brand"],
        cardLastFour: json["card_last_four"],
        trialEndsAt: json["trial_ends_at"],
        isAdmin: json["is_admin"],
        isAssistant: json["is_assistant"],
        isBlocked: json["is_blocked"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image,
        "email": email,
        "verifyToken": verifyToken,
        "status": status,
        "google_id": googleId,
        "facebook_id": facebookId,
        "gitlab_id": gitlabId,
        "dob": dob,
        "age": age,
        "mobile": mobile,
        "braintree_id": braintreeId,
        "code": code,
        "stripe_id": stripeId,
        "card_brand": cardBrand,
        "card_last_four": cardLastFour,
        "trial_ends_at": trialEndsAt,
        "is_admin": isAdmin,
        "is_assistant": isAssistant,
        "is_blocked": isBlocked,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}

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
  String? slug;
  dynamic keyword;
  dynamic description;
  String? thumbnail;
  String? poster;
  dynamic rating;
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

class LiveEvent {
  LiveEvent({
    this.id,
    this.title,
    this.slug,
    this.description,
    this.type,
    this.iframeurl,
    this.readyUrl,
    this.startTime,
    this.endTime,
    this.status,
    this.thumbnail,
    this.poster,
    this.genreId,
    this.detail,
    this.organizedBy,
    this.createdAt,
    this.updatedAt,
  });

  LiveEvent.fromJson(dynamic json) {
    id = json['id'];
    title = json['title'];
    slug = json['slug'];
    description = json['description'];
    type = json['type'];
    iframeurl = json['iframeurl'];
    readyUrl = json['ready_url'];
    startTime = json['start_time'];
    endTime = json['end_time'];
    status = json['status'];
    thumbnail = json['thumbnail'];
    poster = json['poster'];
    genreId = json['genre_id'];
    detail = json['detail'];
    organizedBy = json['organized_by'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  int? id;
  String? title;
  String? slug;
  String? description;
  String? type;
  dynamic iframeurl;
  String? readyUrl;
  String? startTime;
  String? endTime;
  int? status;
  String? thumbnail;
  String? poster;
  dynamic genreId;
  dynamic detail;
  String? organizedBy;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['title'] = title;
    map['slug'] = slug;
    map['description'] = description;
    map['type'] = type;
    map['iframeurl'] = iframeurl;
    map['ready_url'] = readyUrl;
    map['start_time'] = startTime;
    map['end_time'] = endTime;
    map['status'] = status;
    map['thumbnail'] = thumbnail;
    map['poster'] = poster;
    map['genre_id'] = genreId;
    map['detail'] = detail;
    map['organized_by'] = organizedBy;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
