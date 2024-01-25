import 'package:flutter/material.dart';
import 'package:facebook_audience_network/facebook_audience_network.dart';

String interstitialPlacementID = "IMG_16_9_APP_INSTALL#ENTER_PLACEMENT_ID_HERE";

String rewardedVideoPlacementID =
    "IMG_16_9_APP_INSTALL#ENTER_PLACEMENT_ID_HERE";

String bannerPlacementID = "IMG_16_9_APP_INSTALL#ENTER_PLACEMENT_ID_HERE";

String nativeBannerPlacementID = "IMG_16_9_APP_INSTALL#ENTER_PLACEMENT_ID_HERE";

String nativePlacementID = "IMG_16_9_APP_INSTALL#ENTER_PLACEMENT_ID_HERE";

bool isFANEnabled = false;

void initializeFBAd() {
  /// please add your own device testingId
  /// (testingId will print in console if you don't provide)
  if (isFANEnabled) {
    FacebookAudienceNetwork.init(
      testingId: "a77955ee-3304-4635-be65-81029b0f5201", // Optional
      iOSAdvertiserTrackingEnabled: true,
    );
  }
}

bool isInterstitialAdLoaded = false;
bool isRewardedAdLoaded = false;

Future<void> loadInterstitialAd() async {
  if (isFANEnabled) {
    await FacebookInterstitialAd.loadInterstitialAd(
      placementId: interstitialPlacementID,
      listener: (result, value) {
        print("Interstitial Ad: $result --> $value");
        if (result == InterstitialAdResult.LOADED)
          isInterstitialAdLoaded = true;

        /// Once an Interstitial Ad has been dismissed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == InterstitialAdResult.DISMISSED &&
            value["invalidated"] == true) {
          isInterstitialAdLoaded = false;
          loadInterstitialAd();
        }
      },
    );
  }
}

showInterstitialAd_() {
  if (isFANEnabled) {
    if (isInterstitialAdLoaded == true)
      FacebookInterstitialAd.showInterstitialAd();
    else
      print("Interstitial Ad not yet loaded!");
  }
}

Future<void> loadRewardedVideoAd() async {
  if (isFANEnabled) {
    await FacebookRewardedVideoAd.loadRewardedVideoAd(
      placementId: rewardedVideoPlacementID,
      listener: (result, value) {
        print("Rewarded Ad: $result --> $value");
        if (result == RewardedVideoAdResult.LOADED) isRewardedAdLoaded = true;
        if (result == RewardedVideoAdResult.VIDEO_COMPLETE)

        /// Once a Rewarded Ad has been closed and becomes invalidated,
        /// load a fresh Ad by calling this function.
        if (result == RewardedVideoAdResult.VIDEO_CLOSED &&
            (value == true || value["invalidated"] == true)) {
          isRewardedAdLoaded = false;
          loadRewardedVideoAd();
        }
      },
    );
  }
}

showRewardedAd_() {
  if (isFANEnabled) {
    if (isRewardedAdLoaded == true)
      FacebookRewardedVideoAd.showRewardedVideoAd();
    else
      print("Rewarded Ad not yet loaded!");
  }
}

Widget showBannerAd_() {
  return isFANEnabled
      ? FacebookBannerAd(
          placementId: bannerPlacementID,
          bannerSize: BannerSize.STANDARD,
          listener: (result, value) {
            print("Banner Ad: $result -->  $value");
          },
        )
      : SizedBox.shrink();
}

Widget showNativeBannerAd_() {
  return isFANEnabled
      ? FacebookNativeAd(
          placementId: nativeBannerPlacementID,
          adType: NativeAdType.NATIVE_BANNER_AD,
          bannerAdSize: NativeBannerAdSize.HEIGHT_100,
          width: double.infinity,
          backgroundColor: Colors.blue,
          titleColor: Colors.white,
          descriptionColor: Colors.white,
          buttonColor: Colors.deepPurple,
          buttonTitleColor: Colors.white,
          buttonBorderColor: Colors.white,
          listener: (result, value) {
            print("Native Banner Ad: $result --> $value");
          },
        )
      : SizedBox.shrink();
}

Widget showNativeAd_() {
  return isFANEnabled
      ? FacebookNativeAd(
          placementId: nativePlacementID,
          adType: NativeAdType.NATIVE_AD_VERTICAL,
          width: double.infinity,
          height: 300,
          backgroundColor: Colors.blue,
          titleColor: Colors.white,
          descriptionColor: Colors.white,
          buttonColor: Colors.deepPurple,
          buttonTitleColor: Colors.white,
          buttonBorderColor: Colors.white,
          listener: (result, value) {
            print("Native Ad: $result --> $value");
          },
          keepExpandedWhileLoading: true,
          expandAnimationDuraion: 1000,
        )
      : SizedBox.shrink();
}
