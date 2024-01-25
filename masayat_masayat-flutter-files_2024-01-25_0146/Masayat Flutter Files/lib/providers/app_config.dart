import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '/models/plans-feature.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/app_model.dart';
import '/models/block.dart';
import '/models/plans_model.dart';
import '../common/route_paths.dart';

class AppConfig with ChangeNotifier {
  AppConfig({
    this.id,
    this.logo,
    this.title,
    this.stripePayment,
    this.paypalPayment,
    this.razorpayPayment,
    this.brainetreePayment,
    this.paystackPayment,
    this.bankdetails,
    this.fbCheck,
    this.googleLogin,
    this.amazonlogin,
    this.amazonLabCheck,
    this.gitLabCheck,
    this.admobAppKey,
    this.bannerAdmob,
    this.bannerId,
    this.interstitialAdmob,
    this.interstitialId,
    this.rewardedAdmob,
    this.rewardedId,
    this.nativeAdmob,
    this.nativeId,
    this.createdAt,
    this.updatedAt,
    this.inappPayment,
    this.pushKey,
    this.removeAds,
    this.paytmPayment,
    this.instamojoPayment,
  });

  dynamic id;
  String? logo;
  String? title;
  dynamic stripePayment;
  dynamic paypalPayment;
  dynamic razorpayPayment;
  dynamic brainetreePayment;
  dynamic paystackPayment;
  dynamic bankdetails;
  dynamic fbCheck;
  dynamic googleLogin;
  dynamic amazonlogin;
  dynamic amazonLabCheck;
  dynamic gitLabCheck;
  dynamic admobAppKey;
  dynamic bannerAdmob;
  dynamic bannerId;
  dynamic interstitialAdmob;
  dynamic interstitialId;
  dynamic rewardedAdmob;
  dynamic rewardedId;
  dynamic nativeAdmob;
  dynamic nativeId;
  dynamic createdAt;
  DateTime? updatedAt;
  dynamic inappPayment;
  dynamic pushKey;
  dynamic removeAds;
  dynamic paytmPayment;
  dynamic instamojoPayment;

  factory AppConfig.fromJson(Map<String, dynamic> json) => AppConfig(
        id: json["id"],
        logo: json["logo"],
        title: json["title"],
        stripePayment: json["stripe_payment"],
        paypalPayment: json["paypal_payment"],
        razorpayPayment: json["razorpay_payment"],
        brainetreePayment: json["brainetree_payment"],
        paystackPayment: json["paystack_payment"],
        bankdetails: json["bankdetails"],
        fbCheck: json["fb_check"],
        googleLogin: json["google_login"],
        amazonlogin: json["amazon_login"],
        amazonLabCheck: json["amazon_lab_check"],
        gitLabCheck: json["git_lab_check"],
        admobAppKey: json["ADMOB_APP_KEY"],
        bannerAdmob: json["banner_admob"],
        bannerId: json["banner_id"],
        interstitialAdmob: json["interstitial_admob"],
        interstitialId: json["interstitial_id"],
        rewardedAdmob: json["rewarded_admob"],
        rewardedId: json["rewarded_id"],
        nativeAdmob: json["native_admob"],
        nativeId: json["native_id"],
        createdAt: json["created_at"],
        updatedAt: DateTime.parse(json["updated_at"]),
        inappPayment: json["inapp_payment"],
        pushKey: json["push_key"],
        removeAds: json["remove_ads"],
        paytmPayment: json["paytm_payment"],
        instamojoPayment: json["instamojo_payment"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "logo": logo,
        "title": title,
        "stripe_payment": stripePayment,
        "paypal_payment": paypalPayment,
        "razorpay_payment": razorpayPayment,
        "brainetree_payment": brainetreePayment,
        "paystack_payment": paystackPayment,
        "bankdetails": bankdetails,
        "fb_check": fbCheck,
        "google_login": googleLogin,
        "amazon_login": amazonlogin,
        "amazon_lab_check": amazonLabCheck,
        "git_lab_check": gitLabCheck,
        "ADMOB_APP_KEY": admobAppKey,
        "banner_admob": bannerAdmob,
        "banner_id": bannerId,
        "interstitial_admob": interstitialAdmob,
        "interstitial_id": interstitialId,
        "rewarded_admob": rewardedAdmob,
        "rewarded_id": rewardedId,
        "native_admob": nativeAdmob,
        "native_id": nativeId,
        "created_at": createdAt,
        "updated_at": updatedAt,
        "inapp_payment": inappPayment,
        "push_key": pushKey,
        "remove_ads": removeAds,
        "paytm_payment": paytmPayment,
        "instamojo_payment": instamojoPayment,
      };
  AppModel? appModel;
  AppConfig? appConfig;
  List<Block> slides = [];
  List<Plan> planList = [];
  List<PlansFeature> plansFeatures = [];

  Future<AppModel?> getHomeData(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(APIData.homeDataApi), headers: {
        "Accept": "application/json",
        "Content-Type": "application/x-www-form-urlencoded"
      });
      print("Home API Status Code :-> ${response.statusCode}");
      if (response.statusCode == 200) {
        appModel = AppModel.fromJson(json.decode(response.body));
        slides = List.generate(
            appModel!.blocks!.length,
            (index) => Block(
                  id: appModel!.blocks![index].id,
                  image: appModel!.blocks![index].image,
                  heading: appModel!.blocks![index].heading,
                  detail: appModel!.blocks![index].detail,
                  position: appModel!.blocks![index].position,
                  buttonText: appModel!.blocks![index].buttonText,
                ));
        planList = List.generate(
            appModel!.plans!.length,
            (index) => Plan(
                id: appModel!.plans![index].id,
                name: appModel!.plans![index].name,
                currency: appModel!.plans![index].currency,
                currencySymbol: appModel!.plans![index].currencySymbol,
                amount: appModel!.plans![index].amount,
                interval: appModel!.plans![index].interval,
                intervalCount: appModel!.plans![index].intervalCount,
                trialPeriodDays: appModel!.plans![index].trialPeriodDays,
                status: appModel!.plans![index].status,
                screens: appModel!.plans![index].screens,
                deleteStatus: appModel!.plans![index].deleteStatus,
                download: appModel!.plans![index].download,
                downloadlimit: appModel!.plans![index].downloadlimit,
                updatedAt: appModel!.plans![index].updatedAt,
                createdAt: appModel!.plans![index].createdAt,
                planId: appModel!.plans![index].planId,
                free: appModel!.plans![index].free,
                adsInApp: appModel!.plans![index].adsInApp,
                pricingTexts: appModel!.plans![index].pricingTexts,
                feature: appModel!.plans![index].feature));
        planList.removeWhere(
            (element) => element.status == 0 || element.status == "0");
      } else if (response.statusCode == 404) {
        storage.deleteAll();
        throw "Invalid Secret Key";
      } else if (response.statusCode == 401) {
        storage.deleteAll();
        throw "Secret Key is required";
      } else {
        storage.deleteAll();
        throw "Can't get home data";
      }
      notifyListeners();
      return appModel;
    } catch (error) {
      storage.deleteAll();
      Navigator.pushNamed(context, RoutePaths.login);
      throw error;
    }
  }

  @override
  void dispose() {
    super.dispose();
  }
}
