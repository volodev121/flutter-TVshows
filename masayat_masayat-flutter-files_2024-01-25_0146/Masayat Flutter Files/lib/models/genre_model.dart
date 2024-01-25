class GenreModel {
  GenreModel({
    this.auth,
    this.actor,
    this.director,
    this.audio,
    this.subtitles,
    this.genre,
  });

  Auth? auth;
  List<Actor>? actor;
  List<Director>? director;
  List<Audio>? audio;
  List<dynamic>? subtitles;
  List<Genre>? genre;

  factory GenreModel.fromJson(Map<String, dynamic> json) => GenreModel(
        auth: Auth.fromJson(json["auth"]),
        actor: List<Actor>.from(json["actor"].map((x) => Actor.fromJson(x))),
        director: List<Director>.from(
            json["director"].map((x) => Director.fromJson(x))),
        audio: List<Audio>.from(json["audio"].map((x) => Audio.fromJson(x))),
        subtitles: List<dynamic>.from(json["subtitles "].map((x) => x)),
        genre: List<Genre>.from(json["genre"].map((x) => Genre.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "auth": auth!.toJson(),
        "actor": List<dynamic>.from(actor!.map((x) => x.toJson())),
        "director": List<dynamic>.from(director!.map((x) => x.toJson())),
        "audio": List<dynamic>.from(audio!.map((x) => x.toJson())),
        "subtitles ": List<dynamic>.from(subtitles!.map((x) => x)),
        "genre": List<dynamic>.from(genre!.map((x) => x.toJson())),
      };
}

class Actor {
  Actor({
    this.id,
    this.name,
    this.image,
    this.biography,
    this.placeOfBirth,
    this.dob,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  String? name;
  String? image;
  String? biography;
  String? placeOfBirth;
  DateTime? dob;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Actor.fromJson(Map<String, dynamic> json) => Actor(
        id: json["id"],
        name: json["name"],
        image: json["image"] == null ? null : json["image"],
        biography: json["biography"],
        placeOfBirth:
            json["place_of_birth"] == null ? null : json["place_of_birth"],
        dob: json["DOB"] == null ? null : DateTime.parse(json["DOB"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image == null ? null : image,
        "biography": biography,
        "place_of_birth": placeOfBirth == null ? null : placeOfBirth,
        "DOB": dob == null
            ? null
            : "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}

class Director {
  Director({
    this.id,
    this.name,
    this.image,
    this.biography,
    this.placeOfBirth,
    this.dob,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  String? name;
  String? image;
  String? biography;
  String? placeOfBirth;
  DateTime? dob;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Director.fromJson(Map<String, dynamic> json) => Director(
        id: json["id"],
        name: json["name"],
        image: json["image"] == null ? null : json["image"],
        biography: json["biography"],
        placeOfBirth:
            json["place_of_birth"] == null ? null : json["place_of_birth"],
        dob: json["DOB"] == null ? null : DateTime.parse(json["DOB"]),
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image": image == null ? null : image,
        "biography": biography,
        "place_of_birth": placeOfBirth == null ? null : placeOfBirth,
        "DOB": dob == null
            ? null
            : "${dob!.year.toString().padLeft(4, '0')}-${dob!.month.toString().padLeft(2, '0')}-${dob!.day.toString().padLeft(2, '0')}",
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}

class Audio {
  Audio({
    this.id,
    this.language,
    this.createdAt,
    this.updatedAt,
    this.name,
  });

  dynamic id;
  String? language;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;

  factory Audio.fromJson(Map<String, dynamic> json) => Audio(
        id: json["id"],
        language: json["language"] == null ? null : json["language"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "language": language == null ? null : language,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "name": name == null ? null : name,
      };
}

class Genre {
  Genre({
    this.id,
    this.createdAt,
    this.updatedAt,
    this.name,
  });

  dynamic id;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? name;

  factory Genre.fromJson(Map<String, dynamic> json) => Genre(
        id: json["id"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        name: json["name"] == null ? null : json["name"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "name": name == null ? null : name,
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

class HomeTranslation {
  HomeTranslation({
    this.id,
    this.key,
    this.value,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  String? key;
  String? value;
  dynamic status;
  dynamic createdAt;
  DateTime? updatedAt;

  factory HomeTranslation.fromJson(Map<String, dynamic> json) =>
      HomeTranslation(
        id: json["id"],
        key: json["key"],
        value: json["value"],
        status: json["status"],
        createdAt: json["created_at"],
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "key": key,
        "value": value,
        "status": status,
        "created_at": createdAt,
        "updated_at": updatedAt!.toIso8601String(),
      };
}
