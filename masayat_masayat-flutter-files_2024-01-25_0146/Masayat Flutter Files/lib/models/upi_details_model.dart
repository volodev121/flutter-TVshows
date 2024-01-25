/// upi : {"id":1,"name":"Mr. Doe","upiid":"doe@example.com","status":1,"created_at":"","updated_at":""}

class UpiDetailsModel {
  UpiDetailsModel({
    this.upi,
  });

  UpiDetailsModel.fromJson(dynamic json) {
    upi = json['upi'] != null ? Upi.fromJson(json['upi']) : null;
  }
  Upi? upi;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (upi != null) {
      map['upi'] = upi?.toJson();
    }
    return map;
  }
}

/// id : 1
/// name : "Mr. Doe"
/// upiid : "doe@example.com"
/// status : 1
/// created_at : ""
/// updated_at : ""

class Upi {
  Upi({
    this.id,
    this.name,
    this.upiid,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  Upi.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    upiid = json['upiid'];
    status = json['status'];
    createdAt = json['created_at'];
    updatedAt = json['updated_at'];
  }
  num? id;
  String? name;
  String? upiid;
  num? status;
  String? createdAt;
  String? updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['upiid'] = upiid;
    map['status'] = status;
    map['created_at'] = createdAt;
    map['updated_at'] = updatedAt;
    return map;
  }
}
