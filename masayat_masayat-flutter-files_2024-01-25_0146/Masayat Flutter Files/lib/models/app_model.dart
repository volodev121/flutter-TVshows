import 'dart:convert';
import '/providers/app_config.dart';
import '/common/apipath.dart';
import '/models/adsense_model.dart';
import '/models/config.dart';
import '/models/plans_model.dart';
import 'block.dart';
import 'blog_model.dart';
import 'package:http/http.dart' as http;

class AppModel {
  AppModel({
    this.loginImg,
    this.config,
    this.plans,
    this.blocks,
    this.adsense,
    this.appConfig,
    this.blogs,
  });
  LoginImg? loginImg;
  Config? config;
  List<Plan>? plans;
  List<Block>? blocks;
  Adsense? adsense;
  AppConfig? appConfig;
  List<Blog>? blogs;

  factory AppModel.fromJson(Map<String, dynamic> json) => AppModel(
        loginImg: LoginImg.fromJson(json["login_img"]),
        config: Config.fromJson(json["config"]),
        plans: List<Plan>.from(json["plans"].map((x) => Plan.fromJson(x))),
        blocks: List<Block>.from(json["blocks"].map((x) => Block.fromJson(x))),
        adsense: Adsense.fromJson(json["adsense"]),
        appConfig: AppConfig.fromJson(json["app_config"]),
        blogs: List<Blog>.from(json["blogs"].map((x) => Blog.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "login_img": loginImg!.toJson(),
        "config": config!.toJson(),
        "plans": List<dynamic>.from(plans!.map((x) => x.toJson())),
        "blocks": List<dynamic>.from(blocks!.map((x) => x.toJson())),
        "adsense": adsense!.toJson(),
        "app_config": appConfig!.toJson(),
        "blogs": List<dynamic>.from(blogs!.map((x) => x.toJson())),
      };
  Future<AppModel> getHomePageData() async {
    final response = await http.get(Uri.parse(APIData.homeDataApi));
    if (response.statusCode == 200) {
      return AppModel.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load data');
    }
  }
}

class LoginImg {
  LoginImg({
    this.id,
    this.image,
    this.detail,
    this.createdAt,
    this.updatedAt,
  });

  dynamic id;
  String? image;
  String? detail;
  DateTime? createdAt;
  DateTime? updatedAt;

  factory LoginImg.fromJson(Map<String, dynamic> json) => LoginImg(
        id: json["id"],
        image: json["image"],
        detail: json["detail"],
        createdAt: json["created_at"] == null
            ? null
            : DateTime.parse(json["created_at"]),
        updatedAt: json["updated_at"] == null
            ? null
            : DateTime.parse(json["updated_at"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "image": image,
        "detail": detail,
        "created_at": createdAt!.toIso8601String(),
        "updated_at": updatedAt!.toIso8601String(),
      };
}
