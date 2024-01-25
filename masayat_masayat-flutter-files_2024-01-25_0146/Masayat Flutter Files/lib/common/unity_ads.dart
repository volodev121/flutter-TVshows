import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class AdManager {
  static bool get showUnityAds {
    return false;
  }

  static bool get showAdsInTestMode {
    return false;
  }

  static String get gameId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'ENTER_ANDROID_GAME_ID_HERE';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'ENTER_IOS_GAME_ID_HERE';
    }
    return '';
  }

  static String get bannerAdPlacementId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Banner_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Banner_iOS';
    }
    return '';
  }

  static String get interstitialVideoAdPlacementId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Interstitial_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Interstitial_iOS';
    }
    return '';
  }

  static String get rewardedVideoAdPlacementId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'Rewarded_Android';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return 'Rewarded_iOS';
    }
    return '';
  }
}

Future<void> _initializeUnityAds() async {
  if (await UnityAds.isInitialized() == false) {
    await UnityAds.init(
      gameId: AdManager.gameId,
      testMode: AdManager.showAdsInTestMode,
      onComplete: () => print('Unity Initialization Complete'),
      onFailed: (error, message) =>
          print('Unity Initialization Failed: $error $message'),
    );
  }
}

Widget showBannerAds() {
  if (AdManager.showUnityAds) {
    _initializeUnityAds();
    return UnityBannerAd(
        placementId: AdManager.bannerAdPlacementId,
        onLoad: (placementId) => print('Unity Banner loaded: $placementId'),
        onClick: (placementId) => print('Unity Banner clicked: $placementId'),
        onFailed: (placementId, error, message) {
          print('Unity Banner Ad $placementId failed: $error $message');
          _loadAd(AdManager.bannerAdPlacementId);
        });
  } else {
    return SizedBox.shrink();
  }
}

void showRewardedVideoAds() {
  _showAd(AdManager.rewardedVideoAdPlacementId);
}

void showInterstitialVideoAds() {
  _showAd(AdManager.interstitialVideoAdPlacementId);
}

void _loadAd(String placementId) {
  UnityAds.load(
    placementId: placementId,
    onComplete: (placementId) {
      print('Unity ads Load Complete $placementId');
    },
    onFailed: (placementId, error, message) =>
        print('Unity ads Load Failed $placementId: $error $message'),
  );
}

void _showAd(String placementId) {
  if (AdManager.showUnityAds) {
    _initializeUnityAds();
    UnityAds.showVideoAd(
      placementId: placementId,
      onComplete: (placementId) {
        print('Unity Video Ad $placementId completed');
        _loadAd(placementId);
      },
      onFailed: (placementId, error, message) {
        print('Unity Video Ad $placementId failed: $error $message');
        _loadAd(placementId);
      },
      onStart: (placementId) => print('Unity Video Ad $placementId started'),
      onClick: (placementId) => print('Unity Video Ad $placementId click'),
      onSkipped: (placementId) {
        print('Unity Video Ad $placementId skipped');
        _loadAd(placementId);
      },
    );
  }
}
