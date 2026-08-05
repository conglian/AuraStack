import 'dart:async';
import 'dart:io';
import 'package:flutter/services.dart';

import 'package:thinkup_sdk/at_index.dart';

final ATListenerManager = ATListener();

class ATListener {
  StreamController<ATInitResponse> _initEventHandlerController =
      StreamController<ATInitResponse>.broadcast();

  Stream<ATInitResponse> get initEventHandler =>
      _initEventHandlerController.stream;

  StreamController<ATBannerResponse> _bannerEventHandlerController =
      StreamController<ATBannerResponse>.broadcast();

  Stream<ATBannerResponse> get bannerEventHandler =>
      _bannerEventHandlerController.stream;

  StreamController<ATInterstitialResponse> _interstitialEventHandlerController =
      StreamController<ATInterstitialResponse>.broadcast();

  Stream<ATInterstitialResponse> get interstitialEventHandler =>
      _interstitialEventHandlerController.stream;

  StreamController<ATNativeResponse> _nativeEventHandlerController =
      StreamController<ATNativeResponse>.broadcast();

  Stream<ATNativeResponse> get nativeEventHandler =>
      _nativeEventHandlerController.stream;

  StreamController<ATRewardResponse> _rewardedVideoEventHandlerController =
      StreamController<ATRewardResponse>.broadcast();

  Stream<ATRewardResponse> get rewardedVideoEventHandler =>
      _rewardedVideoEventHandlerController.stream;

  StreamController<ATSplashResponse> _splashEventHandlerController =
      StreamController<ATSplashResponse>.broadcast();

  Stream<ATSplashResponse> get splashEventHandler =>
      _splashEventHandlerController.stream;

  StreamController<ATDownloadResponse> _downloadEventHandlerController =
      StreamController<ATDownloadResponse>.broadcast();

  Stream<ATDownloadResponse> get downloadEventHandler =>
      _downloadEventHandlerController.stream;

  StreamController<ATCommonAdResponse> _commonAdEventHandlerController =
      StreamController<ATCommonAdResponse>.broadcast();

  Stream<ATCommonAdResponse> get commonAdEventHandler =>
      _commonAdEventHandlerController.stream;

  /*Initialization*/
  ATListener() {
    AnythinkSdk.channel.setMethodCallHandler(_adMethodHandler);
  }

  /*Advertising status callback */
  Future _adMethodHandler(MethodCall methodCall) {
    try {
      if (methodCall.method == 'NativeCall') {
        var tempInterstitialResponse = ATNativeResponse.withMap(
          methodCall.arguments,
        );

        _nativeEventHandlerController.add(tempInterstitialResponse);
      } else if (methodCall.method == 'BannerCall') {
        var tempInterstitialResponse = ATBannerResponse.withMap(
          methodCall.arguments,
        );
        _bannerEventHandlerController.add(tempInterstitialResponse);
      } else if (methodCall.method == 'InterstitialCall') {
        var tempInterstitialResponse = ATInterstitialResponse.withMap(
          methodCall.arguments,
        );

        _interstitialEventHandlerController.add(tempInterstitialResponse);
      } else if (methodCall.method == 'RewardedVideoCall') {
        var tempRewardResponse = ATRewardResponse.withMap(methodCall.arguments);

        _rewardedVideoEventHandlerController.add(tempRewardResponse);
      } else if (methodCall.method == 'SplashCall') {
        var tempSplashResponse = ATSplashResponse.withMap(methodCall.arguments);

        _splashEventHandlerController.add(tempSplashResponse);
      } else if (methodCall.method == 'InitCallName') {
        var tempInitdResponse = ATInitResponse.withMap(methodCall.arguments);

        _initEventHandlerController.add(tempInitdResponse);
      } else if (methodCall.method == 'DownloadCall') {
        //Only for Android

        if (Platform.isAndroid) {
          var tempDownloadResponse = ATDownloadResponse.withMap(
            methodCall.arguments,
          );

          _downloadEventHandlerController.add(tempDownloadResponse);
        }
      } else if (methodCall.method == 'CommonADCall') {
        var tempCommonAdResponse =
            ATCommonAdResponse.withMap(methodCall.arguments);
        _commonAdEventHandlerController.add(tempCommonAdResponse);
      }
    } catch (e, stack) {
      print("ATFlutterSDK error：" + e.toString());
      print("ATFlutterSDK error stack：" + stack.toString());
    }

    return Future.value();
  }
}
