import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import '/common/apipath.dart';
import '/common/global.dart';
import '/models/coupon_model.dart';

class CouponProvider extends ChangeNotifier {
  CouponModel? couponModel;
  List<Coupon?> stripeCoupon = [];
  List<Coupon?> generalCoupon = [];

  Future<CouponModel?> getCoupons(BuildContext context) async {
    try {
      final response = await http.get(Uri.parse(APIData.getCoupons), headers: {
        "Content-Type": "application/x-www-form-urlencoded",
        HttpHeaders.authorizationHeader: "Bearer $authToken"
      });

      if (response.statusCode == 200) {
        couponModel = CouponModel.fromJson(json.decode(response.body));
        stripeCoupon =
            List<Coupon?>.generate(couponModel!.coupon!.length, (index) {
          if (couponModel!.coupon![index].inStripe == 1 ||
              "${couponModel!.coupon![index].inStripe}" == "1") {
            return Coupon(
              id: couponModel!.coupon![index].id,
              couponCode: couponModel!.coupon![index].couponCode,
              percentOff: couponModel!.coupon![index].percentOff,
              currency: couponModel!.coupon![index].currency,
              amountOff: couponModel!.coupon![index].amountOff,
              duration: couponModel!.coupon![index].duration,
              maxRedemptions: couponModel!.coupon![index].maxRedemptions,
              redeemBy: couponModel!.coupon![index].redeemBy,
              inStripe: couponModel!.coupon![index].inStripe,
              createdAt: couponModel!.coupon![index].createdAt,
              updatedAt: couponModel!.coupon![index].updatedAt,
            );
          } else {
            return null;
          }
        });
        stripeCoupon.removeWhere((element) => element == null);

        generalCoupon =
            List<Coupon?>.generate(couponModel!.coupon!.length, (index) {
          if (couponModel!.coupon![index].inStripe == 0 ||
              "${couponModel!.coupon![index].inStripe}" == "0") {
            return Coupon(
              id: couponModel!.coupon![index].id,
              couponCode: couponModel!.coupon![index].couponCode,
              percentOff: couponModel!.coupon![index].percentOff,
              currency: couponModel!.coupon![index].currency,
              amountOff: couponModel!.coupon![index].amountOff,
              duration: couponModel!.coupon![index].duration,
              maxRedemptions: couponModel!.coupon![index].maxRedemptions,
              redeemBy: couponModel!.coupon![index].redeemBy,
              inStripe: couponModel!.coupon![index].inStripe,
              createdAt: couponModel!.coupon![index].createdAt,
              updatedAt: couponModel!.coupon![index].updatedAt,
            );
          } else {
            return null;
          }
        });
        generalCoupon.removeWhere((element) => element == null);
      } else {
        throw "Can't get coupon";
      }
    } catch (error) {
      throw "Can't get coupon due to $error";
    }
    return couponModel;
  }
}
