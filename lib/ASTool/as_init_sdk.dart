import 'dart:convert';

// import 'package:anythink_sdk/at_init.dart';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:adjust_sdk/adjust_attribution.dart';
import 'package:adjust_sdk/adjust_config.dart';
import 'package:applovin_max/applovin_max.dart';
import 'package:aurastack/ASModel/ASAdModel.dart';
import 'package:aurastack/ASModel/ASGameProgressModel.dart';
import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/ASLogger.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:thinkup_sdk/at_init.dart';
import '../ASModel/ASFKModel.dart';
import 'as_ad_manger.dart';
import 'as_extension_help.dart';
import 'ASFKManger.dart';
import 'ASTBAEventTool.dart';
import 'as_LocalProvider.dart';

String decsgerew(String st) => utf8.decode(base64Decode(st));

class ASSDKHelpers {
  static final ASSDKHelpers _instance = ASSDKHelpers._internal();

  factory ASSDKHelpers() {
    return _instance;
  }

  ASSDKHelpers._internal();

  DateTime sj_max_start = DateTime.now();

  DateTime sj_topon_start = DateTime.now();

  int sj_remoteConfigTryCount = 0;

  bool is_ad_suc = false;

  Future<void> initSDK() async {
    _initAdjustSDk();
    _initTopon();
    // _asinitloadFireBase();
  }

  void _initTopon() async {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 这里保证在主线程
      sj_topon_start = DateTime.now();
      ATInitManger.initSDK(
            appidStr: 'h6a69b0ff34eb9',
            appidkeyStr: 'ac29096fc124ea560c685e0d632afbd56',
          )
          .then((value) {
            as_event_fire('ad_initsuc', {
              'ad_source_client': 'topon',
              'ad_init_time': DateTime.now()
                  .difference(sj_topon_start)
                  .inMilliseconds,
            });
            asLog.success('topon init Success');
            ASCardAds().init();
            ASCardAds().init_suc = true;
            as_session_fire();
            if (ASLocalProvider.instance.as_install_status == false) {
              as_install_fire();
              ASLocalProvider.instance.updateBool(
                ASLocalProvider.instance.as_install_statusName,
                true,
              );
            }
          })
          .catchError((error) {
           asLog.error('topon init error=$error');
            Future.delayed(Duration(seconds: 1), () {
              _initTopon();
            });
          });
      // 打开SDK的Debug log，强烈建议在测试阶段打开，方便排查问题。
      ATInitManger
          .setLogEnabled(
        logEnabled: kDebugMode ? true : false,
      );
    });
  }

  _initAdjustSDk() async {
    const String appToken1 = 'h78noxn52scg'; // relsease
    var disId = await FlutterTbaInfo.instance.getDistinctId();
    asLog.debug('disId=$disId');
    Adjust.addGlobalCallbackParameter('customer_user_id', disId);
    final config = AdjustConfig(appToken1, AdjustEnvironment.production);
    config.logLevel = AdjustLogLevel.verbose;
    // 归因信息
    config.attributionCallback = (AdjustAttribution attributionChangedData) {
      print('[Adjust]: Attribution changed!');
      if (attributionChangedData.trackerToken != null) {
        print(
          '[Adjust]: Tracker token: ${attributionChangedData.trackerToken}',
        );
      }
      if (attributionChangedData.trackerName != null) {
        as_event_fire('adjust_suc', {
          'adjust_user': attributionChangedData.trackerName == 'Organic'
              ? 0
              : 1,
        });
        print('[Adjust]: Tracker name: ${attributionChangedData.trackerName}');
        if (attributionChangedData.trackerName != 'Organic') {
          as_event_fire('organic_to_buy', {});
          // _toHome();
        }
      }
      if (attributionChangedData.campaign != null) {
        print('[Adjust]: Campaign: ${attributionChangedData.campaign}');
      }
      if (attributionChangedData.network != null) {
        print('[Adjust]: Network: ${attributionChangedData.network}');
      }
      if (attributionChangedData.creative != null) {
        print('[Adjust]: Creative: ${attributionChangedData.creative}');
      }
      if (attributionChangedData.adgroup != null) {
        print('[Adjust]: Adgroup: ${attributionChangedData.adgroup}');
      }
      if (attributionChangedData.clickLabel != null) {
        print('[Adjust]: Click label: ${attributionChangedData.clickLabel}');
      }
      if (attributionChangedData.fbInstallReferrer != null) {
        print(
          '[Adjust]: facebook install referrer: ${attributionChangedData.fbInstallReferrer}',
        );
      }
      if (attributionChangedData.jsonResponse != null) {
        print(
          '[Adjust]: JSON Response: ${attributionChangedData.jsonResponse}',
        );
      }
    };
    Adjust.initSdk(config);
    as_event_fire('adjust_req', {});
  }

  void _asinitloadFireBase() async {
    final remoteConfig = FirebaseRemoteConfig.instance;
    await remoteConfig.setConfigSettings(
      RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(hours: 1),
      ),
    );
    asLog.debug("app firebase init");
    asLog.debug("app firebase loading");
    try {
      await remoteConfig.fetchAndActivate();

      final game_progress = remoteConfig.getValue('game_progress').asString();
      if (game_progress != ''){
        try {
          Map<String, dynamic> jsonMap = json.decode(game_progress);
          var intModel = ASGameProgressModel.fromJson(jsonMap);
          ASGameProgressManager.instance.gameProgressModel = intModel;
          asLog.success("app firebase remoteconfig game_progress data $jsonMap");
        } catch (error) {
          asLog.error("app firebase remoteconfig game_progress error ${error}");
        }
      }

      final olstk_ad_config = remoteConfig.getValue('olstk_ad_config').asString();
      if (olstk_ad_config != ''){
        try {
          Map<String, dynamic> jsonMap = json.decode(olstk_ad_config);

          ASCardAds().as_PigAdModel = ASAdModel.fromJson(jsonMap);
          if (ASCardAds().init_suc == true){
            ASCardAds().init(inputAd: ASCardAds().as_PigAdModel);
          }
          asLog.success("app firebase remoteconfig olstk_ad_config data $jsonMap");
        } catch (error) {
          asLog.error("app firebase remoteconfig olstk_ad_config error ${error}");
        }
      }

      //  'c152pig_android_fb=默认'.log();
      //  PSFacebookAnalytics.init(appId: '3083467831849635', clientToken: '7d8a9303f209a20ddf9213b726a897af', appName: 'C152GP');

      // final c152pig_android_fb =
      // remoteConfig.getValue("c152pig_android_fb").asString();
      // // facebook_init
      // if (c152pig_android_fb != ''){
      //   "app firebase remoteconfig c152pig_android_fb data $c152pig_android_fb".log();
      //   Map<String, dynamic> jsonMap = json.decode(c152pig_android_fb);
      //   PSFacebookAnalytics.init(appId: jsonMap['app_id'], clientToken: jsonMap['client_token'], appName: jsonMap['app_name']);
      // } else {
      //   'c152pig_android_fb=默认'.log();
      //   PSFacebookAnalytics.init(appId: '3083467831849635', clientToken: '7d8a9303f209a20ddf9213b726a897af', appName: 'C152GP');
      // }


      final c153_risk_control = remoteConfig.getValue('c153_risk_control').asString();
      if (c153_risk_control != ''){
        try {
          Map<String, dynamic> jsonMap = json.decode(c153_risk_control);
          var fkModel = ASFkModel.fromJson(jsonMap);
          ASFKManger().fkModel = fkModel;
          asLog.success("app firebase remoteconfig c153_risk_control data $jsonMap");
        } catch (error) {
          asLog.error("app firebase remoteconfig c153_risk_control error ${error}");
        }
      }

    } catch (e, s) {
      print("RemoteConfig fetch error: $e");
      sj_remoteConfigTryCount += 1;
      if (sj_remoteConfigTryCount <= 60) {
        Future.delayed(Duration(seconds: 1), () {
          _asinitloadFireBase();
        });
      } else {
      }
    }
  }

  // 上报收入
  cs_sendAdToSdk(MaxAd max) async {
    try {
      AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('applovin_max_sdk');
      adjustAdRevenue.setRevenue(max.revenue, 'USD');
      adjustAdRevenue.adRevenueNetwork = max.networkPlacement;
      adjustAdRevenue.adRevenuePlacement = max.placement;
      Adjust.trackAdRevenue(adjustAdRevenue);
      await ASFacebookAnalytics.logPurchase(max.revenue, 'USD');
      asLog.error("af logs:: af revenue success ${max.revenue}");
    } catch (e) {
      asLog.error("af logs:: af revenue error $e");
    }
  }

  // 上报收入
  cs_sendintTopOnAdToSdk(Map extraMap) async {
    final revenue = extraMap["publisher_revenue"] ?? 0;
    final network = extraMap["network_name"];
    final currency = extraMap["currency"] ?? "";
    try {
      AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('topon_sdk');
      adjustAdRevenue.setRevenue(revenue, 'USD');
      adjustAdRevenue.adRevenueNetwork = network;
      Adjust.trackAdRevenue(adjustAdRevenue);
      await ASFacebookAnalytics.logPurchase(revenue, 'USD');
      asLog.error("af logs:: af revenue success $revenue");
    } catch (e) {
      asLog.error("af logs:: af revenue error $e");
    }
  }
}

class ASFacebookAnalytics {
  static final _channel = MethodChannel("com.example.aurastack/facebook");

  /// 初始化 Facebook SDK（动态传入 appId、clientToken、appName）
  static Future<void> init({
    required String appId,
    required String clientToken,
    required String appName,
  }) async {
    asLog.debug('initFacebook1');
    await _channel.invokeMethod("initFacebook", {
      "app_id": appId,
      "client_token": clientToken,
      "app_name": appName,
    });
    asLog.debug('initFacebook2');
  }

  /// 购买打点（无参数）
  static Future<void> logPurchase(double amount, String currency) async {
    await _channel.invokeMethod("logPurchase", {
      "amount": amount,
      "currency": currency,
    });
  }
}
