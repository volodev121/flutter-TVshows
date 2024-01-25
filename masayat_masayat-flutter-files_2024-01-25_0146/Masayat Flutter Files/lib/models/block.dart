class Block {
  Block({
    this.id,
    this.image,
    this.heading,
    this.detail,
    this.button,
    this.buttonText,
    this.buttonLink,
    this.left,
    this.position,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  String? image;
  String? heading;
  String? detail;
  dynamic button;
  String? buttonText;
  String? buttonLink;
  dynamic left;
  dynamic position;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Block.fromJson(Map<String, dynamic> json) => Block(
        id: json["id"],
        image: json["image"],
        heading: json["heading"],
        detail: json["detail"],
        button: json["button"],
        buttonText: json["button_text"],
        buttonLink: json["button_link"],
        left: json["left"],
        position: json["position"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "heading": heading,
        "detail": detail,
        "button": button,
        "button_text": buttonText,
        "button_link": buttonLink,
        "left": left,
        "position": position,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
