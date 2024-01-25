/// manualPayment : [{"id":1,"payment_name":"Method-1","description":"Testing Method-1","thumbnail":"mp_61c0668276b50.png","status":1,"created_at":"2021-12-20T11:18:26.000000Z","updated_at":"2021-12-20T11:18:26.000000Z"}]

class ManualPaymentModel {
  ManualPaymentModel({
    List<ManualPayment>? manualPayment,
  }) {
    _manualPayment = manualPayment;
  }

  ManualPaymentModel.fromJson(dynamic json) {
    if (json['manualPayment'] != null) {
      _manualPayment = [];
      json['manualPayment'].forEach((v) {
        _manualPayment?.add(ManualPayment.fromJson(v));
      });
    }
  }
  List<ManualPayment>? _manualPayment;

  List<ManualPayment>? get manualPayment => _manualPayment;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (_manualPayment != null) {
      map['manualPayment'] = _manualPayment?.map((v) => v.toJson()).toList();
    }
    return map;
  }
}

/// id : 1
/// payment_name : "Method-1"
/// description : "Testing Method-1"
/// thumbnail : "mp_61c0668276b50.png"
/// status : 1
/// created_at : "2021-12-20T11:18:26.000000Z"
/// updated_at : "2021-12-20T11:18:26.000000Z"

class ManualPayment {
  ManualPayment({
    int? id,
    String? paymentName,
    String? description,
    String? thumbnail,
    int? status,
    String? thumbPath,
    String? createdAt,
    String? updatedAt,
  }) {
    _id = id;
    _paymentName = paymentName;
    _description = description;
    _thumbnail = thumbnail;
    _status = status;
    _thumbPath = thumbPath;
    _createdAt = createdAt;
    _updatedAt = updatedAt;
  }

  ManualPayment.fromJson(dynamic json) {
    _id = json['id'];
    _paymentName = json['payment_name'];
    _description = json['description'];
    _thumbnail = json['thumbnail'];
    _status = json['status'];
    _thumbPath = json['thumb_path'];
    _createdAt = json['created_at'];
    _updatedAt = json['updated_at'];
  }
  int? _id;
  String? _paymentName;
  String? _description;
  String? _thumbnail;
  int? _status;
  String? _thumbPath;
  String? _createdAt;
  String? _updatedAt;

  int? get id => _id;
  String? get paymentName => _paymentName;
  String? get description => _description;
  String? get thumbnail => _thumbnail;
  int? get status => _status;
  String? get thumbPath => _thumbPath;
  String? get createdAt => _createdAt;
  String? get updatedAt => _updatedAt;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = _id;
    map['payment_name'] = _paymentName;
    map['description'] = _description;
    map['thumbnail'] = _thumbnail;
    map['status'] = _status;
    map['thumb_path'] = _thumbPath;
    map['created_at'] = _createdAt;
    map['updated_at'] = _updatedAt;
    return map;
  }
}
