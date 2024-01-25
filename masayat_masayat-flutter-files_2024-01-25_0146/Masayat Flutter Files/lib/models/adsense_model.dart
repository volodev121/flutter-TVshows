class Adsense {
  Adsense({
    this.id,
    this.code,
    this.status,
    this.ishome,
    this.isviewall,
    this.issearch,
    this.iswishlist,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  String? code;
  dynamic status;
  dynamic ishome;
  dynamic isviewall;
  dynamic issearch;
  dynamic iswishlist;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Adsense.fromJson(Map<String, dynamic> json) => Adsense(
    id: json["id"],
    code: json["code"],
    status: json["status"],
    ishome: json["ishome"],
    isviewall: json["isviewall"],
    issearch: json["issearch"],
    iswishlist: json["iswishlist"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "code": code,
    "status": status,
    "ishome": ishome,
    "isviewall": isviewall,
    "issearch": issearch,
    "iswishlist": iswishlist,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}