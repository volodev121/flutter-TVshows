class WishListModel {
  WishListModel({
    this.wishlist,
  });

  List<Wishlist>? wishlist;

  factory WishListModel.fromJson(Map<String, dynamic> json) => WishListModel(
    wishlist: List<Wishlist>.from(json["wishlist"].map((x) => Wishlist.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "wishlist": List<dynamic>.from(wishlist!.map((x) => x.toJson())),
  };
}

class Wishlist{
  Wishlist({
    this.id,
    this.userId,
    this.movieId,
    this.seasonId,
    this.added,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  dynamic userId;
  dynamic movieId;
  dynamic seasonId;
  dynamic added;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Wishlist.fromJson(Map<String, dynamic> json) => Wishlist(
    id: json["id"],
    userId: json["user_id"],
    movieId: json["movie_id"],
    seasonId: json["season_id"],
    added: json["added"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "movie_id": movieId,
    "season_id": seasonId,
    "added": added,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
