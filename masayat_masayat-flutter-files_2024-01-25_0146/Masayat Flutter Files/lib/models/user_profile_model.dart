import 'plans_model.dart';

class UserProfileModel {
  UserProfileModel(
      {this.code,
      this.user,
      this.paypal,
      this.currentDate,
      this.payment,
      this.id,
      this.currentSubscription,
      this.payid,
      this.start,
      this.end,
      this.active,
      this.screen,
      this.limit,
      this.removeAds});
  dynamic id;
  String? code;
  User? user;
  List<Paypal>? paypal;
  DateTime? currentDate;
  String? payment;
  String? currentSubscription;
  String? payid;
  DateTime? start;
  DateTime? end;
  dynamic active;
  dynamic screen;
  dynamic limit;
  dynamic removeAds;
  factory UserProfileModel.fromJson(Map<String, dynamic> json) =>
      UserProfileModel(
        code: json["code"],
        user: User.fromJson(json["user"]),
        paypal: json["paypal"] == null
            ? null
            : List<Paypal>.from(json["paypal"].map((x) => Paypal.fromJson(x))),
        currentDate: json["current_date"] == null
            ? null
            : DateTime.parse(json["current_date"]),
        payment: json["payment"] == null ? null : json["payment"],
        id: json["id"] == null ? null : json["id"],
        currentSubscription: json["current_subscription"] == null
            ? null
            : json["current_subscription"],
        payid: json["payid"] == null ? null : json["payid"],
        start: json["start"] == null ? null : DateTime.parse(json["start"]),
        end: json["end"] == null ? null : DateTime.parse(json["end"]),
        active: json["active"] == null ? null : json["active"],
        screen: json["screen"] == null ? null : json["screen"],
        limit: json["limit"] == null ? null : json["limit"],
        removeAds: json["remove_ads"] == null ? null : json["remove_ads"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "user": user!.toJson(),
        "paypal": List<dynamic>.from(paypal!.map((x) => x.toJson())),
        "current_date":
            "${currentDate!.year.toString().padLeft(4, '0')}-${currentDate!.month.toString().padLeft(2, '0')}-${currentDate!.day.toString().padLeft(2, '0')}",
        "payment": payment,
        "id": id,
        "current_subscription": currentSubscription,
        "payid": payid,
        "start": start!.toIso8601String(),
        "end": end!.toIso8601String(),
        "active": active,
        "screen": screen,
        "limit": limit,
        "remove_ads": removeAds
      };
}

class Paypal {
  Paypal({
    this.id,
    this.userId,
    this.paymentId,
    this.userName,
    this.packageId,
    this.price,
    this.status,
    this.method,
    this.subscriptionFrom,
    this.subscriptionTo,
    this.createdAt,
    this.updatedAt,
    this.plan,
  });

  dynamic id;
  dynamic userId;
  String? paymentId;
  String? userName;
  dynamic packageId;
  dynamic price;
  dynamic status;
  String? method;
  DateTime? subscriptionFrom;
  DateTime? subscriptionTo;
  DateTime? createdAt;
  DateTime? updatedAt;
  Plan? plan;

  factory Paypal.fromJson(Map<String, dynamic> json) => Paypal(
        id: json["id"],
        userId: json["user_id"] == null ? null : json["user_id"],
        paymentId: json["payment_id"] == null ? null : json["payment_id"],
        userName: json["user_name"] == null ? null : json["user_name"],
        packageId: json["package_id"] == null ? null : json["package_id"],
        price: json["price"] == null ? null : json["price"],
        status: json["status"] == null ? null : json["status"],
        method: json["method"] == null ? null : json["method"],
        subscriptionFrom: json["subscription_from"] == null
            ? null
            : DateTime.parse(json["subscription_from"]),
        subscriptionTo: json["subscription_to"] == null
            ? null
            : json["plan"] == null
                ? null
                : DateTime.parse(json["subscription_to"]),
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        plan: json["plan"] == null ? null : Plan.fromJson(json["plan"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "payment_id": paymentId,
        "user_name": userName,
        "package_id": packageId,
        "price": price,
        "status": status,
        "method": method,
        "subscription_from": subscriptionFrom!.toIso8601String(),
        "subscription_to": subscriptionTo!.toIso8601String(),
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "plan": plan!.toJson(),
      };
}

class User {
  User(
      {this.id,
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
      this.subscriptions});

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
  List<Subscription>? subscriptions;

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"],
        name: json["name"],
        image: json["image"] == null ? null : json["image"],
        email: json["email"],
        verifyToken: json["verifyToken"] == null ? null : json["verifyToken"],
        status: json["status"] == null ? null : json["status"],
        googleId: json["google_id"] == null ? null : json["google_id"],
        facebookId: json["facebook_id"] == null ? null : json["facebook_id"],
        gitlabId: json["gitlab_id"] == null ? null : json["gitlab_id"],
        dob: json["dob"] == null ? null : json["dob"],
        age: json["age"] == null ? null : json["age"],
        mobile: json["mobile"] == null ? null : json["mobile"],
        braintreeId: json["braintree_id"] == null ? null : json["braintree_id"],
        code: json["code"],
        stripeId: json["stripe_id"] == null ? null : json["stripe_id"],
        cardBrand: json["card_brand"] == null ? null : json["card_brand"],
        cardLastFour:
            json["card_last_four"] == null ? null : json["card_last_four"],
        trialEndsAt:
            json["trial_ends_at"] == null ? null : json["trial_ends_at"],
        isAdmin: json["is_admin"] == null ? null : json["is_admin"],
        isAssistant: json["is_assistant"] == null ? null : json["is_assistant"],
        isBlocked: json["is_blocked"] == null ? null : json["is_blocked"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
        subscriptions: json["subscriptions"] == null
            ? null
            : List<Subscription>.from(
                json["subscriptions"].map((x) => Subscription.fromJson(x))),
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
        "subscriptions":
            List<dynamic>.from(subscriptions!.map((x) => x.toJson())),
      };
}

class Subscription {
  Subscription({
    this.id,
    this.userId,
    this.name,
    this.stripeId,
    this.stripePlan,
    this.quantity,
    this.trialEndsAt,
    this.endsAt,
    this.subscriptionFrom,
    this.subscriptionTo,
    this.amount,
    this.stripeStatus,
    this.createdAt,
    this.updatedAt,
    this.items,
  });

  dynamic id;
  dynamic userId;
  Name? name;
  String? stripeId;
  StripePlan? stripePlan;
  dynamic quantity;
  dynamic trialEndsAt;
  dynamic endsAt;
  dynamic subscriptionFrom;
  dynamic subscriptionTo;
  dynamic amount;
  StripeStatus? stripeStatus;
  DateTime? createdAt;
  DateTime? updatedAt;
  List<Item>? items;

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
        id: json["id"],
        userId: json["user_id"],
        name: nameValues.map[json["name"]],
        stripeId: json["stripe_id"],
        stripePlan: stripePlanValues.map[json["stripe_plan"]],
        quantity: json["quantity"],
        trialEndsAt: json["trial_ends_at"],
        endsAt: json["ends_at"],
        subscriptionFrom: json["subscription_from"],
        subscriptionTo: json["subscription_to"],
        amount: json["amount"],
        stripeStatus: stripeStatusValues.map[json["stripe_status"]],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "name": nameValues.reverse![name!],
        "stripe_id": stripeId,
        "stripe_plan": stripePlanValues.reverse![stripePlan!],
        "quantity": quantity,
        "trial_ends_at": trialEndsAt,
        "ends_at": endsAt,
        "subscription_from": subscriptionFrom,
        "subscription_to": subscriptionTo,
        "amount": amount,
        "stripe_status": stripeStatusValues.reverse![stripeStatus!],
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
        "items": List<dynamic>.from(items!.map((x) => x.toJson())),
      };
}

class Item {
  Item({
    this.id,
    this.subscriptionId,
    this.stripeId,
    this.stripePlan,
    this.quantity,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  dynamic subscriptionId;
  String? stripeId;
  StripePlan? stripePlan;
  dynamic quantity;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        id: json["id"],
        subscriptionId: json["subscription_id"],
        stripeId: json["stripe_id"],
        stripePlan: stripePlanValues.map[json["stripe_plan"]],
        quantity: json["quantity"],
        createdAt: DateTime.parse(json["created_at"]),
        updatedAt: DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "subscription_id": subscriptionId,
        "stripe_id": stripeId,
        "stripe_plan": stripePlanValues.reverse![stripePlan!],
        "quantity": quantity,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}

enum StripePlan { BSICPLAN1 }

final stripePlanValues = EnumValues({"bsicplan1": StripePlan.BSICPLAN1});

enum Name { TEST, BASIC_PLAN }

final nameValues =
    EnumValues({"Basic plan": Name.BASIC_PLAN, "test": Name.TEST});

enum StripeStatus { ACTIVE }

final stripeStatusValues = EnumValues({"active": StripeStatus.ACTIVE});

class EnumValues<T> {
  Map<String, T> map;
  Map<T, String>? reverseMap;

  EnumValues(this.map);

  Map<T, String>? get reverse {
    if (reverseMap == null) {
      reverseMap = map.map((k, v) => new MapEntry(v, k));
    }
    return reverseMap;
  }
}
