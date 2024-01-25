class CouponModel {
  CouponModel({
    this.coupon,
  });

  List<Coupon>? coupon;

  factory CouponModel.fromJson(Map<String, dynamic> json) => CouponModel(
    coupon: List<Coupon>.from(json["coupon"].map((x) => Coupon.fromJson(x))),
  );

  Map<String, dynamic> toJson() => {
    "coupon": List<dynamic>.from(coupon!.map((x) => x.toJson())),
  };
}

class Coupon {
  Coupon({
    this.id,
    this.couponCode,
    this.percentOff,
    this.currency,
    this.amountOff,
    this.duration,
    this.maxRedemptions,
    this.redeemBy,
    this.inStripe,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  String? couponCode;
  dynamic percentOff;
  String? currency;
  dynamic amountOff;
  String? duration;
  String? maxRedemptions;
  DateTime? redeemBy;
  dynamic inStripe;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Coupon.fromJson(Map<String, dynamic> json) => Coupon(
    id: json["id"],
    couponCode: json["coupon_code"],
    percentOff: json["percent_off"],
    currency: json["currency"],
    amountOff: json["amount_off"],
    duration: json["duration"],
    maxRedemptions: json["max_redemptions"],
    redeemBy: DateTime.parse(json["redeem_by"]),
    inStripe: json["in_stripe"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "coupon_code": couponCode,
    "percent_off": percentOff,
    "currency": currency,
    "amount_off": amountOff,
    "duration": duration,
    "max_redemptions": maxRedemptions,
    "redeem_by": redeemBy!.toIso8601String(),
    "in_stripe": inStripe,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
