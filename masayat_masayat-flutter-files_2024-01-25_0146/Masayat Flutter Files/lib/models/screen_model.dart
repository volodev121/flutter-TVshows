class ScreenModel{
  ScreenModel({
    this.screen,
  });

  Screen? screen;

  factory ScreenModel.fromJson(Map<String, dynamic> json) => ScreenModel(
    screen: Screen.fromJson(json["screen"]),
  );

  Map<String, dynamic> toJson() => {
    "screen": screen!.toJson(),
  };
}

class Screen {
  Screen({
    this.id,
    this.screen1,
    this.screen2,
    this.screen3,
    this.screen4,
    this.userId,
    this.activescreen,
    this.screen1Used,
    this.screen2Used,
    this.screen3Used,
    this.screen4Used,
    this.deviceMac1,
    this.deviceMac2,
    this.deviceMac3,
    this.deviceMac4,
    this.download1,
    this.download2,
    this.download3,
    this.download4,
    this.pkgId,
    this.createdAt,
    this.updatedAt,
  });

  dynamic  id;
  String? screen1;
  String? screen2;
  String? screen3;
  String? screen4;
  dynamic  userId;
  String? activescreen;
  String? screen1Used;
  String? screen2Used;
  String? screen3Used;
  String? screen4Used;
  String? deviceMac1;
  String? deviceMac2;
  String? deviceMac3;
  String? deviceMac4;
  dynamic download1;
  dynamic download2;
  dynamic download3;
  dynamic download4;
  dynamic  pkgId;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory Screen.fromJson(Map<String, dynamic> json) => Screen(
    id: json["id"],
    screen1: json["screen1"],
    screen2: json["screen2"],
    screen3: json["screen3"],
    screen4: json["screen4"],
    userId: json["user_id"],
    activescreen: json["activescreen"],
    screen1Used: json["screen_1_used"],
    screen2Used: json["screen_2_used"],
    screen3Used: json["screen_3_used"],
    screen4Used: json["screen_4_used"],
    deviceMac1: json["device_mac_1"],
    deviceMac2: json["device_mac_2"],
    deviceMac3: json["device_mac_3"],
    deviceMac4: json["device_mac_4"],
    download1: json["download_1"],
    download2: json["download_2"],
    download3: json["download_3"],
    download4: json["download_4"],
    pkgId: json["pkg_id"],
    createdAt: DateTime.parse(json["created_at"]),
    updatedAt: DateTime.parse(json["updated_at"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "screen1": screen1,
    "screen2": screen2,
    "screen3": screen3,
    "screen4": screen4,
    "user_id": userId,
    "activescreen": activescreen,
    "screen_1_used": screen1Used,
    "screen_2_used": screen2Used,
    "screen_3_used": screen3Used,
    "screen_4_used": screen4Used,
    "device_mac_1": deviceMac1,
    "device_mac_2": deviceMac2,
    "device_mac_3": deviceMac3,
    "device_mac_4": deviceMac4,
    "download_1": download1,
    "download_2": download2,
    "download_3": download3,
    "download_4": download4,
    "pkg_id": pkgId,
    "created_at": createdAt!.toIso8601String(),
    "updated_at": updatedAt!.toIso8601String(),
  };
}
