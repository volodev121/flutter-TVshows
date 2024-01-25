class BTreeToken{
  BTreeToken({
    this.client,
  });

  String? client;

  factory BTreeToken.fromJson(Map<String, dynamic> json) => BTreeToken(
    client: json["client"],
  );

  Map<String, dynamic> toJson() => {
    "client": client,
  };
}
