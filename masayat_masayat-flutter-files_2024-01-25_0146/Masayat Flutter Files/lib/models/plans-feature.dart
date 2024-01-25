class PlansFeature {
  PlansFeature({
    this.id,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  String? name;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory PlansFeature.fromJson(Map<String, dynamic> json) => PlansFeature(
        id: json["id"],
        name: json["name"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "created_at": createdAt == null ? null : createdAt!.toIso8601String(),
        "updated_at": updatedAt == null ? null : updatedAt!.toIso8601String(),
      };
}
