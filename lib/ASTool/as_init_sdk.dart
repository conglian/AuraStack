// import 'dart:convert';
//
// // import 'package:anythink_sdk/at_init.dart';
// import 'package:adjust_sdk/adjust.dart';
// import 'package:adjust_sdk/adjust_ad_revenue.dart';
// import 'package:adjust_sdk/adjust_attribution.dart';
// import 'package:adjust_sdk/adjust_config.dart';
// import 'package:applovin_max/applovin_max.dart';
// import 'package:firebase_remote_config/firebase_remote_config.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_tba_info/flutter_tba_info.dart';
// import 'as_extension_help.dart';
// import 'ASFKManger.dart';
// import 'ASTBAEventTool.dart';
// import 'as_LocalProvider.dart';
//
// String decsgerew(String st) => utf8.decode(base64Decode(st));
//
// class ASSDKHelpers {
//   static final ASSDKHelpers _instance = ASSDKHelpers._internal();
//
//   factory ASSDKHelpers() {
//     return _instance;
//   }
//
//   ASSDKHelpers._internal();
//
//   DateTime sj_max_start = DateTime.now();
//
//   DateTime sj_topon_start = DateTime.now();
//
//   int sj_remoteConfigTryCount = 0;
//
//   bool is_ad_suc = false;
//
//   Future<void> initSDK() async {
//     _initAdjustSDk();
//     _initTopon();
//     _csinitloadFireBase();
//   }
//
//   void _initTopon() async {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       // 这里保证在主线程
//       sj_topon_start = DateTime.now();
//       ATInitManger.initThinkUpSDK(
//             appidStr: 'h6a0c1323b2da9',
//             appidkeyStr: 'a9756a18ca5e9098c24597266d345a53a',
//           )
//           .then((value) {
//             cs_event_fire('ad_initsuc', {
//               'ad_source_client': 'topon',
//               'ad_init_time': DateTime.now()
//                   .difference(sj_topon_start)
//                   .inMilliseconds,
//             });
//             'topon init Success'.log();
//             CSCardAds().init();
//             CSCardAds().init_suc = true;
//             cs_session_fire();
//             if (CSLocalProvider.instance.cs_install_status == false) {
//               cs_install_fire();
//               CSLocalProvider.instance.updateBool(
//                 CSLocalProvider.instance.cs_install_statusName,
//                 true,
//               );
//             }
//           })
//           .catchError((error) {
//             'topon init error=$error'.log();
//             Future.delayed(Duration(seconds: 1), () {
//               _initTopon();
//             });
//           });
//       // 打开SDK的Debug log，强烈建议在测试阶段打开，方便排查问题。
//       ATInitManger
//           .setLogEnabled(
//         logEnabled: kDebugMode ? true : false,
//       );
//     });
//   }
//
//   _initAdjustSDk() async {
//     const String appToken1 = 'vnci7e1gq7sw'; // relsease
//     var disId = await FlutterTbaInfo.instance.getDistinctId();
//     'disId=$disId'.log();
//     Adjust.addGlobalCallbackParameter('customer_user_id', disId);
//     final config = AdjustConfig(appToken1, AdjustEnvironment.production);
//     config.logLevel = AdjustLogLevel.verbose;
//     // 归因信息
//     config.attributionCallback = (AdjustAttribution attributionChangedData) {
//       print('[Adjust]: Attribution changed!');
//       if (attributionChangedData.trackerToken != null) {
//         print(
//           '[Adjust]: Tracker token: ${attributionChangedData.trackerToken}',
//         );
//       }
//       if (attributionChangedData.trackerName != null) {
//         as_event_fire('adjust_suc', {
//           'adjust_user': attributionChangedData.trackerName == 'Organic'
//               ? 0
//               : 1,
//         });
//         print('[Adjust]: Tracker name: ${attributionChangedData.trackerName}');
//         if (attributionChangedData.trackerName != 'Organic') {
//           as_event_fire('organic_to_buy', {});
//           // _toHome();
//         }
//       }
//       if (attributionChangedData.campaign != null) {
//         print('[Adjust]: Campaign: ${attributionChangedData.campaign}');
//       }
//       if (attributionChangedData.network != null) {
//         print('[Adjust]: Network: ${attributionChangedData.network}');
//       }
//       if (attributionChangedData.creative != null) {
//         print('[Adjust]: Creative: ${attributionChangedData.creative}');
//       }
//       if (attributionChangedData.adgroup != null) {
//         print('[Adjust]: Adgroup: ${attributionChangedData.adgroup}');
//       }
//       if (attributionChangedData.clickLabel != null) {
//         print('[Adjust]: Click label: ${attributionChangedData.clickLabel}');
//       }
//       if (attributionChangedData.fbInstallReferrer != null) {
//         print(
//           '[Adjust]: facebook install referrer: ${attributionChangedData.fbInstallReferrer}',
//         );
//       }
//       if (attributionChangedData.jsonResponse != null) {
//         print(
//           '[Adjust]: JSON Response: ${attributionChangedData.jsonResponse}',
//         );
//       }
//     };
//     Adjust.initSdk(config);
//     as_event_fire('adjust_req', {});
//   }
//
//   void _csinitloadFireBase() async {
//     final remoteConfig = FirebaseRemoteConfig.instance;
//     await remoteConfig.setConfigSettings(
//       RemoteConfigSettings(
//         fetchTimeout: const Duration(seconds: 10),
//         minimumFetchInterval: const Duration(hours: 1),
//       ),
//     );
//     "app firebase init".log();
//     "app firebase loading".log();
//     try {
//       await remoteConfig.fetchAndActivate();
//
//       final playcard_number = remoteConfig.getValue('playcard_number').asString();
//       if (playcard_number != ''){
//         try {
//           Map<String, dynamic> jsonMap = json.decode(playcard_number);
//           var intModel = GameConfig.fromJson(jsonMap);
//           CSNumberHelpers().gameModel = intModel;
//           "app firebase remoteconfig playcard_number data $jsonMap".log();
//         } catch (error) {
//           print("app firebase remoteconfig playcard_number error ${error}");
//         }
//       }
//
//       final nwkls_ad_config = remoteConfig.getValue('nwkls_ad_config').asString();
//       if (nwkls_ad_config != ''){
//         try {
//           Map<String, dynamic> jsonMap = json.decode(nwkls_ad_config);
//
//           CSCardAds().cs_PigAdModel = CSAdModel.fromJson(jsonMap);
//           if (CSCardAds().init_suc == true){
//             CSCardAds().init(inputAd: CSCardAds().cs_PigAdModel);
//           }
//           "app firebase remoteconfig nwkls_ad_config data $jsonMap".log();
//         } catch (error) {
//           print("app firebase remoteconfig nwkls_ad_config error ${error}");
//         }
//       }
//
//       //  'c152pig_android_fb=默认'.log();
//       //  PSFacebookAnalytics.init(appId: '3083467831849635', clientToken: '7d8a9303f209a20ddf9213b726a897af', appName: 'C152GP');
//
//       // final c152pig_android_fb =
//       // remoteConfig.getValue("c152pig_android_fb").asString();
//       // // facebook_init
//       // if (c152pig_android_fb != ''){
//       //   "app firebase remoteconfig c152pig_android_fb data $c152pig_android_fb".log();
//       //   Map<String, dynamic> jsonMap = json.decode(c152pig_android_fb);
//       //   PSFacebookAnalytics.init(appId: jsonMap['app_id'], clientToken: jsonMap['client_token'], appName: jsonMap['app_name']);
//       // } else {
//       //   'c152pig_android_fb=默认'.log();
//       //   PSFacebookAnalytics.init(appId: '3083467831849635', clientToken: '7d8a9303f209a20ddf9213b726a897af', appName: 'C152GP');
//       // }
//
//
//       final risk_control = remoteConfig.getValue('risk_control').asString();
//       if (risk_control != ''){
//         try {
//           Map<String, dynamic> jsonMap = json.decode(risk_control);
//           var fkModel = ASFkModel.fromJson(jsonMap);
//           ASFKManger().fkModel = fkModel;
//           "app firebase remoteconfig risk_control data $jsonMap".log();
//         } catch (error) {
//           print("app firebase remoteconfig risk_control error ${error}");
//         }
//       }
//
//       // 新用户流程中的ad开关
//       // 给默认值，确保不存在 Key 时不会报错
//       await remoteConfig.setDefaults(<String, dynamic>{
//         'card_push_number': 5, // 默认值
//       });
//       int card_push_number = remoteConfig.getValue('card_push_number').asInt();
//       if (card_push_number != null) {
//         ASLocalProvider.instance.updateint(
//           ASLocalProvider.instance.card_push_numberName,
//           card_push_number,
//         );
//         "app firebase remoteconfig card_push_number data $card_push_number".log();
//       }
//     } catch (e, s) {
//       print("RemoteConfig fetch error: $e");
//       sj_remoteConfigTryCount += 1;
//       if (sj_remoteConfigTryCount <= 60) {
//         Future.delayed(Duration(seconds: 1), () {
//           _csinitloadFireBase();
//         });
//       } else {
//         // CSPigAds().init();
//       }
//     }
//   }
//
//   // 上报收入
//   cs_sendAdToSdk(MaxAd max) async {
//     try {
//       AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('applovin_max_sdk');
//       adjustAdRevenue.setRevenue(max.revenue, 'USD');
//       adjustAdRevenue.adRevenueNetwork = max.networkPlacement;
//       adjustAdRevenue.adRevenuePlacement = max.placement;
//       Adjust.trackAdRevenue(adjustAdRevenue);
//       await CSFacebookAnalytics.logPurchase(max.revenue, 'USD');
//       "af logs:: af revenue success ${max.revenue}".log();
//     } catch (e) {
//       "af logs:: af revenue error $e".log();
//     }
//   }
//
//   // 上报收入
//   cs_sendintTopOnAdToSdk(Map extraMap) async {
//     final revenue = extraMap["publisher_revenue"] ?? 0;
//     final network = extraMap["network_name"];
//     final currency = extraMap["currency"] ?? "";
//     try {
//       AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('topon_sdk');
//       adjustAdRevenue.setRevenue(revenue, 'USD');
//       adjustAdRevenue.adRevenueNetwork = network;
//       Adjust.trackAdRevenue(adjustAdRevenue);
//       await CSFacebookAnalytics.logPurchase(revenue, 'USD');
//       "af logs:: af revenue success ${revenue}".log();
//     } catch (e) {
//       "af logs:: af revenue error $e".log();
//     }
//   }
// }
//
// class CSFacebookAnalytics {
//   static final _channel = MethodChannel("com.example.cashscratchgo/facebook");
//
//   /// 初始化 Facebook SDK（动态传入 appId、clientToken、appName）
//   static Future<void> init({
//     required String appId,
//     required String clientToken,
//     required String appName,
//   }) async {
//     'initFacebook1'.log();
//     await _channel.invokeMethod("initFacebook", {
//       "app_id": appId,
//       "client_token": clientToken,
//       "app_name": appName,
//     });
//     'initFacebook2'.log();
//   }
//
//   /// 购买打点（无参数）
//   static Future<void> logPurchase(double amount, String currency) async {
//     await _channel.invokeMethod("logPurchase", {
//       "amount": amount,
//       "currency": currency,
//     });
//   }
// }
