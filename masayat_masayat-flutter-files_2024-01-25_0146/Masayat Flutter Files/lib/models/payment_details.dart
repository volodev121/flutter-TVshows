class PaymentDetail {
  PaymentDetail({
    this.key,
    this.pass,
    this.paystack,
    this.razorkey,
    this.razorpass,
    this.paytmkey,
    this.paytmpass,
  });

  String? key;
  String? pass;
  String? paystack;
  String? razorkey;
  String? razorpass;
  String? paytmkey;
  String? paytmpass;

  factory PaymentDetail.fromJson(Map<String, dynamic> json) => PaymentDetail(
        key: json["key"],
        pass: json["pass"],
        paystack: json["paystack"],
        razorkey: json["razorkey"],
        razorpass: json["razorpass"],
        paytmkey: json["paytmkey"],
        paytmpass: json["paytmpass"],
      );

  Map<String, dynamic> toJson() => {
        "key": key,
        "pass": pass,
        "paystack": paystack,
        "razorkey": razorkey,
        "razorpass": razorpass,
        "paytmkey": paytmkey,
        "paytmpass": paytmpass,
      };
}
