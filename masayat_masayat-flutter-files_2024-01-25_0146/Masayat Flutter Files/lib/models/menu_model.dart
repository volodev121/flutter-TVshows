class MenuModel {
  MenuModel({
    this.menu,
  });

  List<Menu>? menu;

  factory MenuModel.fromJson(Map<String, dynamic> json) => MenuModel(
    menu: List<Menu>.from(json["menu"].map((x) => Menu.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "menu": List<dynamic>.from(menu!.map((x) => x.toJson())),
  };
}

class Menu {
  Menu({
    this.id,
    this.name,
    this.slug,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  String? name;
  String? slug;
  dynamic position;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
    id: json["id"],
    name: json["name"],
    slug: json["slug"],
    position: json["position"],
    createdAt: json["created_at"] == null ? null : DateTime.parse(json["created_at"]),
    updatedAt: json["updated_at"] == null ? null : DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "name": name,
    "slug": slug,
    "position": position,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
