// import 'dart:convert';
// import 'dart:math';
// import 'package:flutter/material.dart';
// import 'as_extension_help.dart';
//
// Map<String, dynamic> as_defaultAdConfig = {
//   "bxkghizv": 100,
//   "nwboczqr": 100,
//   "nwkls_switch": false,
//   "nwkls_int": [
//     {
//       "prnospnz": "n1hc77c1997skd",
//       "bamussgh": "topon",
//       "cspsfdfm": "interstitial",
//       "gbhayrnf": 3000
//     }
//   ],
//   "nwkls_rv": [
//     {
//       "prnospnz": "n1hc77c19984sv",
//       "bamussgh": "topon",
//       "cspsfdfm": "reward",
//       "gbhayrnf": 3000
//     }
//   ]
// };
//
// class ASPigAdModel {
//   String type;
//   String source;
//
//   double ecpm;
//   String ad_identifer;
//   int status;
//   String networkName;
//   String sdk;
//
//   ASPigAdModel({
//     required this.type,
//     required this.source,
//     required this.ecpm,
//     required this.ad_identifer,
//     required this.status,
//     required this.networkName,
//     required this.sdk,
//   });
//
//   String getTypeToServer() {
//     if (type == "reward") {
//       return "rv";
//     } else {
//       return "int";
//     }
//   }
// }
//
// class ASCardAds {
//
//   static final ASCardAds _instance = ASCardAds._internal();
//
//   factory ASCardAds() {
//     return _instance;
//   }
//
//   ASCardAds._internal();
//
//   CSAdModel? _ASPigAdModel;
//
//   CSAdModel? cs_PigAdModel = CSAdModel.fromJson(cs_defaultAdConfig);
//
//   bool _pigAdDelegateCreated = false;
//
//   bool init_suc = false;
//
//   String? quizAdPlaceID;
//
//   Function(bool)? onAdClosed;
//   // 保存上次播放广告时间
//   DateTime? _savedTime = DateTime.now();
//   // 保存上次播放到关闭广告时间
//   DateTime? _savedPlayAndCloseTime;
//
//   DateTime int_start = DateTime.now();
//
//   DateTime read_start = DateTime.now();
//
//   int _adShowed = 0;
//   int _adClicked = 0;
//   int adShowedToday = 0;
//   double _adRevenues = 0.0;
//
//   List<ASPigAdModel> _ads = [];
//   // 是否显示广告中
//   late bool is_showAd = false;
//   // 测试打开，上线关闭
//   final bool skipAd = false;
//
//   Future<void> init({CSAdModel? inputAd}) async {
//     _ads = [];
//     "$runtimeType init ad json,remote value is $inputAd".log();
//     try {
//       await setAdConfigData(
//         inputAdModel: inputAd ?? cs_PigAdModel,
//       );
//       _getCacheData();
//
//       if (!_prepareRequest()) {
//         return;
//       }
//       _requestAd();
//     } catch (error) {
//       "$runtimeType init ad error $error".log();
//     }
//   }
//
//   void addAds(List<CSAdModellist> list) {
//     for (final d in list) {
//       _ads.add(
//         ASPigAdModel(
//           type: d.cspsfdfm,
//           source: d.bamussgh,
//           ecpm: 0,
//           ad_identifer: d.prnospnz,
//           status: 0,
//           networkName: "",
//           sdk: "",
//         ),
//       );
//     }
//   }
//
//   void _getCacheData() {
//     _adShowed = CSLocalProvider.instance.cs_ad_show_number;
//     _adClicked =  0;
//     adShowedToday =  0;
//     _adRevenues = 0;
//   }
//
//   void cs_showAd(
//       BuildContext context,
//       String placeID, {
//         required Function(bool) onCacheResponse,
//         required Function(bool) adDidClosed,
//         bool mustShow = false,
//         bool showDialog = true,
//       }) async {
//     if (skipAd) {
//       await setTxProgress();
//       adDidClosed.call(true);
//       resetHandler();
//       return;
//     }
//     // 展示上限
//     if (CSLocalProvider.instance.cs_ad_show_index > CSFKManger().fkModel.behavior.ad_daily_show && CSFKManger().fkModel.ui.behavior == 1){
//       context.tipShow(CSAdLimitDialog());
//       onCacheResponse.call(false);
//       resetHandler();
//       return;
//     }
//     // 风控
//     if (await CSFKManger().cs_checkAllStatus()){
//       '风控不发起广告显示'.log();
//       CSDialogTool.toast(context, 'Something went wrong, please try again later.');
//       cs_event_fire('cs_fk_un', {});
//       onCacheResponse.call(false);
//       resetHandler();
//       return;
//     }
//
//     if (someAdIsShowing()) {
//       "$runtimeType ad is showing,cancel this request".log();
//       return;
//     }
//     onAdClosed ??= adDidClosed;
//     quizAdPlaceID ??= placeID;
//     String adType = placeID.contains("rv") ? "rv" : "int";
//     bool defaultMode = _ASPigAdModel!.nwkls_switch;
//     "$runtimeType ad service request to show [$quizAdPlaceID], ad type is $adType, use mode #$defaultMode"
//         .log();
//     cs_event_fire('ad_chance', {"ad_pos_id": placeID, 'ad_format' : placeID.contains('int') ? 'int' : 'rv'});
//
//     if (defaultMode == false) {
//       _showA(adType, placeID,onCacheResponse, context: context, showDialog: showDialog);
//     } else {
//       _showB(adType, placeID,onCacheResponse, context: context, showDialog: showDialog);
//     }
//   }
//
//   void _showA(
//       String adType,
//       String placeID,
//       Function(bool) onCacheResponse, {
//         BuildContext? context, bool showDialog = true,
//       }) async {
//     final isInt = adType == "int";
//     final realType = isInt ? "interstitial" : "reward";
//
//     final showIndex = _findShowIndex(realType, false);
//
//     if (showIndex != -1) {
//       final ad = _ads[showIndex];
//
//       "$runtimeType prepare to show ad [A],type=$adType, id=${ad.ad_identifer}"
//           .log();
//
//       final showed = await _tryShowAd(ad, showIndex, context, placeID);
//       if (showed) return;
//
//       // show 失败兜底
//       onCacheResponse(false);
//       resetHandler();
//       ad.status = 0;
//       _requestAd(defaultIndex: [showIndex]);
//       return;
//     } else {
//       if (context != null && showDialog == true) {
//         showfaildDiolog(context);
//       }
//     }
//
//     "$runtimeType prepare to show ad [A],type=$adType but no caches find!!".log();
//     cs_event_fire(
//       "ad_impression_fail",
//       {"ad_pos_id": placeID, "reason": 'notPrepared'},
//     );
//
//     onCacheResponse(false);
//     resetHandler();
//
//     final notRequestingAd = _findNotRequestingAds(realType);
//     if (notRequestingAd.isNotEmpty) {
//       _requestAd(defaultIndex: notRequestingAd);
//       return;
//     }
//
//     "$runtimeType onCacheResponse is not ready!!! error $quizAdPlaceID".log();
//   }
//
//   int _findShowIndex(String adType, bool compare) {
//     int showIndex = -1;
//     double bestEcpm = double.negativeInfinity;
//
//     for (int i = 0; i < _ads.length; i++) {
//       final ad = _ads[i];
//
//       // 必须是已缓存广告
//       if (ad.status != 1) continue;
//
//       // 非 compare 模式：只选指定类型
//       if (!compare && ad.type != adType) continue;
//
//       // compare 模式下：reward 场景允许跨类型比较
//       if (compare && adType != "reward" && ad.type != adType) continue;
//
//       if (ad.ecpm > bestEcpm) {
//         bestEcpm = ad.ecpm;
//         showIndex = i;
//       }
//     }
//
//     return showIndex;
//   }
//
//   List<int> _findNotRequestingAds(String adType) {
//     final result = <int>[];
//     for (int i = 0; i < _ads.length; i++) {
//       if (_ads[i].status == 0 && _ads[i].type == adType) {
//         result.add(i);
//       }
//     }
//     return result;
//   }
//
//   Future<bool> _tryShowAd(
//       ASPigAdModel ad,
//       int index,
//       BuildContext? context,
//       String placeID
//       ) async {
//     if (ad.source == "max") {
//       if (ad.type == "reward") {
//         final ready =
//             await AppLovinMAX.isRewardedAdReady(ad.ad_identifer) ?? false;
//         if (!ready) return false;
//         is_showAd = true;
//         AppLovinMAX.showRewardedAd(ad.ad_identifer);
//       } else {
//         is_showAd = true;
//         AppLovinMAX.showInterstitial(ad.ad_identifer);
//       }
//     } else {
//       if (ad.type == "reward") {
//         final ready = await ATRewardedManager.rewardedVideoReady(
//           placementID: ad.ad_identifer,
//         );
//         if (!ready) {
//           cs_event_fire(
//             "nskdh_ad_impression_fail",
//             {"ad_pos_id": placeID, "reason": 'notPrepared'},
//           );
//           return false;
//         }
//         is_showAd = true;
//         ATRewardedManager.showRewardedVideo(placementID: ad.ad_identifer);
//       } else {
//         final ready = await ATInterstitialManager.hasInterstitialAdReady(
//           placementID: ad.ad_identifer,
//         );
//         if (!ready){
//           cs_event_fire(
//             "nskdh_ad_impression_fail",
//             {"ad_pos_id": placeID, "reason": 'notPrepared'},
//           );
//           return false;
//         }
//         is_showAd = true;
//         ATInterstitialManager.showInterstitialAd(placementID: ad.ad_identifer);
//       }
//     }
//
//     ad.status = 2;
//
//     return true;
//   }
//
//   void _showB(
//       String adType, String placeID,
//       Function(bool) onCacheResponse, {
//         BuildContext? context,
//         bool showDialog = false,
//       }) async {
//     final isInt = adType == "int";
//     final realType = isInt ? "interstitial" : "reward";
//
//     final showIndex = _findShowIndex(realType, true);
//
//     if (showIndex != -1) {
//       final ad = _ads[showIndex];
//
//       "$runtimeType prepare to show ad [B],type=$adType, id=${ad.ad_identifer}"
//           .log();
//
//       final showed = await _tryShowAd(ad, showIndex, context, placeID);
//       if (showed) return;
//
//       // show 失败兜底
//       onCacheResponse(false);
//       resetHandler();
//       ad.status = 0;
//       _requestAd(defaultIndex: [showIndex]);
//       return;
//     } else {
//       if (context != null && showDialog == true) {
//         showfaildDiolog(context);
//       }
//     }
//
//     "$runtimeType prepare to show ad [B],type=$adType but no caches find!!".log();
//     cs_event_fire(
//       "nskdh_ad_impression_fail",
//       {"ad_pos_id": placeID, "reason": 'notPrepared'},
//     );
//
//     onCacheResponse(false);
//     resetHandler();
//
//     final notRequestingAd = _findNotRequestingAds(realType);
//     if (notRequestingAd.isNotEmpty) {
//       _requestAd(defaultIndex: notRequestingAd);
//       return;
//     }
//
//     "$runtimeType onCacheResponse is not ready!!! error $quizAdPlaceID".log();
//   }
//
//   void adImpression(Map extMap) async {
//     'extMap1=$extMap'.log();
//     double ecpms = extMap['publisher_revenue'] ?? 0.0;
//     String adunit_format = extMap['adunit_format'] ?? '';
//     cs_ad_fire({
//       "vaduz": ecpms * 1000000,
//       "guru": extMap["network_name"],
//       "phenyl": 'topon_sdk',
//       "nauseate": extMap['adunit_id'],
//       "ambition": quizAdPlaceID,
//       "canister": adunit_format.contains('Rewarded') ? 'rv' : 'int',
//     });
//     adRevenues(ecpms);
//     // to sdk
//     AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('topon_sdk');
//     adjustAdRevenue.adRevenueNetwork = extMap["network_name"];
//     adjustAdRevenue.setRevenue(ecpms, "USD");
//     adjustAdRevenue.adRevenuePlacement = quizAdPlaceID;
//     adjustAdRevenue.adRevenueUnit = extMap['adunit_id'];
//     Adjust.trackAdRevenue(adjustAdRevenue);
//     // PSFacebookAnalytics.logPurchase(ecpms, "USD");
//
//   }
//
//   // 显示失败弹框
//   showfaildDiolog(BuildContext context) async {
//     // 无网络
//     bool isConnected = await NetworkUtils.isConnected();
//     if (CSLocalProvider.instance.cs_new_guide_end == true){
//       if (isConnected) {
//         print("有网加载失败");
//         context.tipShow(CSAdLoadingDialog());
//       } else {
//         context.tipShow(CSNotWifiDialog());
//         print("设备无网络连接");
//       }
//     }
//   }
//
//   void adShowed() async {
//     _adShowed += 1;
//
//     "$runtimeType ad show times $_adShowed".log();
//     CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_show_numberName, CSLocalProvider.instance.cs_ad_show_number + 1);
//     CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_all_numberName, CSLocalProvider.instance.cs_ad_all_number + 1);
//     if (CSLocalProvider.instance.cs_ad_show_number % 5 == 0 && CSLocalProvider.instance.cs_ad_show_number > 0) {
//       cs_event_fire(
//         "cash_ad_detail",
//         {
//           "ad": CSLocalProvider.instance.cs_ad_show_number ?? "",
//         },
//       );
//     }
//
//     update();
//   }
//
//   void adClicked() async {
//     _adClicked += 1;
//
//     update();
//   }
//
//   int getAdShowCount() {
//     return _adShowed;
//   }
//
//   void adRevenues(double revenue) {
//     _adRevenues += revenue;
//     update();
//   }
//
//   update() async {
//
//   }
// }
//
// extension AdServiceExtension on ASCardAds {
//   Future<void> setAdConfigData({CSAdModel? inputAdModel}) async {
//     _ASPigAdModel = inputAdModel;
//   }
//
//   void _requestAd({List<int>? defaultIndex}) async {
//     for (int i = 0; i < _ads.length; i++) {
//       if (defaultIndex != null && !defaultIndex.contains(i)) {
//         continue;
//       }
//       ASPigAdModel ad = _ads[i];
//       int status = ad.status;
//       String type = ad.type;
//       String source = ad.source;
//       String adID = ad.ad_identifer;
//
//       if (status == 0) {
//         if (type == "interstitial") {
//           if (source == "max") {
//             AppLovinMAX.loadInterstitial(adID);
//           } else if (source == "topon") {
//             ATInterstitialManager.loadInterstitialAd(
//               placementID: adID,
//               extraMap: {},
//             );
//           }
//         } else if (type == "reward") {
//           if (source == "max") {
//             AppLovinMAX.loadRewardedAd(adID);
//           } else {
//             ATRewardedManager.loadRewardedVideo(
//               placementID: adID,
//               extraMap: {},
//             );
//           }
//         }
//         "$runtimeType ad requesting [start],status = $status, type is $type, source is $source, id is $adID"
//             .log();
//       } else if (status == 1) {
//         "$runtimeType ad requesting [requesting] status = $status, type is $type, source is $source, id is $adID"
//             .log();
//       } else {
//         "$runtimeType ad requesting [requested] status = $status, type is $type, source is $source, id is $adID"
//             .log();
//       }
//       cs_event_fire(
//         "ad_request",
//         {
//           "ad_code_id": adID,
//           "ad_format": type,
//           "ad_source_client": source,
//         },
//       );
//     }
//   }
//
//   bool _prepareRequest() {
//     if (_ASPigAdModel == null) {
//       "$runtimeType request ad start,but ad model empty...".log();
//       return false;
//     }
//
//     addAds(_ASPigAdModel!.nwkls_int);
//     addAds(_ASPigAdModel!.nwkls_rv);
//     if (_ads.isEmpty) {
//       "$runtimeType request ad start,but datasource model empty...".log();
//       return false;
//     }
//
//     if (!_pigAdDelegateCreated) {
//       _createListener();
//     }
//     return true;
//   }
//
//   void _createListener() {
//     _maxIntListener();
//     _maxRvListener();
//     _pigAdDelegateCreated = true;
//   }
//
//   void _maxIntListener() {
//     AppLovinMAX.setInterstitialListener(
//       InterstitialListener(
//         onAdLoadedCallback: (ad) async {
//           _adDidFinishLoad(maxAd: ad);
//         },
//         onAdLoadFailedCallback: (adUnitId, error) {
//           _adDidLoadFailed(adUnitId, error.message, 'max');
//         },
//         onAdDisplayedCallback: (ad) {
//           _adDidDisplayed(adID: ad.adUnitId, ad_network: ad.networkName);
//         },
//         onAdHiddenCallback: (ad) {
//           _adDidHidden(adId: ad.adUnitId);
//         },
//         onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
//           _adDidDisplayedError(ad.adUnitId, error.message);
//         },
//         onAdClickedCallback: (MaxAd ad) {},
//         onAdRevenuePaidCallback: (MaxAd ad) {},
//       ),
//     );
//
//     ATListenerManager.interstitialEventHandler.listen((value) {
//       switch (value.interstatus) {
//         case InterstitialStatus.interstitialAdFailToLoadAD:
//           _adDidLoadFailed(value.placementID, value.requestMessage, 'topon');
//           break;
//       // interstitial load finish
//         case InterstitialStatus.interstitialAdDidFinishLoading:
//           _adDidFinishLoad(toponInt: value);
//           break;
//       // interstitial play start, some AD platforms have this callback.
//         case InterstitialStatus.interstitialAdDidStartPlaying:
//           break;
//       // interstitial play end, some AD platforms have this callback.
//         case InterstitialStatus.interstitialAdDidEndPlaying:
//           break;
//       // interstitial play fail, some AD platforms have this callback.
//         case InterstitialStatus.interstitialDidFailToPlayVideo:
//           _adDidDisplayedError(value.placementID, value.requestMessage);
//           break;
//       // interstitial show succeed
//         case InterstitialStatus.interstitialDidShowSucceed:
//           adImpression(value.extraMap);
//           _adDidDisplayed(adID: value.placementID, ad_network: value.extraMap['network_name']);
//           break;
//       // interstitial show fail
//         case InterstitialStatus.interstitialFailedToShow:
//           break;
//       // interstitial clicked
//         case InterstitialStatus.interstitialAdDidClick:
//           adClicked();
//           break;
//       // Deeplink
//         case InterstitialStatus.interstitialAdDidDeepLink:
//           break;
//       // interstitial closed
//         case InterstitialStatus.interstitialAdDidClose:
//           _adDidHidden(adId: value.placementID);
//           break;
//
//         case InterstitialStatus.interstitialUnknown:
//           break;
//         case InterstitialStatus.interstitialAdDidMultipleLoaded:
//         case InterstitialStatus.interstitialAdDidAdSourceBiddingAttempt:
//           break;
//         case InterstitialStatus.interstitialAdDidAdSourceBiddingFilled:
//           break;
//         case InterstitialStatus.interstitialAdDidAdSourceBiddingFail:
//           break;
//         case InterstitialStatus.interstitialAdDidAdSourceAttempt:
//           break;
//         case InterstitialStatus.interstitialAdDidAdSourceLoadFilled:
//           break;
//         case InterstitialStatus.interstitialAdDidAdSourceLoadFail:
//           break;
//       }
//     });
//   }
//
//   void _maxRvListener() async {
//     AppLovinMAX.setRewardedAdListener(
//       RewardedAdListener(
//         onAdLoadedCallback: (ad) {
//           _adDidFinishLoad(maxAd: ad);
//         },
//         onAdLoadFailedCallback: (adUnitId, error) {
//           _adDidLoadFailed(adUnitId, error.message, 'max');
//         },
//         onAdDisplayedCallback: (ad) {
//           _adDidDisplayed(adID: ad.adUnitId, ad_network: ad.networkName);
//           setTxProgress();
//         },
//         onAdHiddenCallback: (ad) {
//           _adDidHidden(adId: ad.adUnitId);
//         },
//         onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
//           _adDidDisplayedError(ad.adUnitId, error.message);
//         },
//         onAdClickedCallback: (MaxAd ad) {},
//         onAdRevenuePaidCallback: (MaxAd ad) {},
//         onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {},
//       ),
//     );
//
//     ATListenerManager.rewardedVideoEventHandler.listen((value) {
//       switch (value.rewardStatus) {
//       // ad load fail
//         case RewardedStatus.rewardedVideoDidFailToLoad:
//           _adDidLoadFailed(value.placementID, value.requestMessage, 'topon');
//           break;
//       // ad load finish
//         case RewardedStatus.rewardedVideoDidFinishLoading:
//           _adDidFinishLoad(toponReward: value);
//           break;
//       // ad video start play
//         case RewardedStatus.rewardedVideoDidStartPlaying:
//           adImpression(value.extraMap);
//           _adDidDisplayed(adID: value.placementID, ad_network: value.extraMap['network_name']);
//           CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_qunm_ad_indexName, CSLocalProvider.instance.cs_qunm_ad_index + 1);
//           setTxProgress();
//           break;
//       // ad video start end
//         case RewardedStatus.rewardedVideoDidEndPlaying:
//           break;
//       // ad video fail to play
//         case RewardedStatus.rewardedVideoDidFailToPlay:
//           _adDidDisplayedError(value.placementID, value.requestMessage);
//           break;
//       // The rewarded is successful, it is recommended to issue the reward in this callback
//         case RewardedStatus.rewardedVideoDidRewardSuccess:
//           break;
//       // ad video clicked
//         case RewardedStatus.rewardedVideoDidClick:
//           adClicked();
//           break;
//       //Deeplink
//         case RewardedStatus.rewardedVideoDidDeepLink:
//           break;
//         case RewardedStatus.rewardedVideoDidClose:
//           _adDidHidden(adId: value.placementID);
//           break;
//         case RewardedStatus.rewardedVideoDidAgainStartPlaying:
//           break;
//       // ad video again play end(only TT)
//         case RewardedStatus.rewardedVideoDidAgainEndPlaying:
//           break;
//       // ad video again fail to play(only TT)
//         case RewardedStatus.rewardedVideoDidAgainFailToPlay:
//           break;
//       // ad video again rewarded success(only TT)
//         case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
//           break;
//       // ad video again clicked(only TT)
//         case RewardedStatus.rewardedVideoDidAgainClick:
//         case RewardedStatus.rewardedVideoUnknown:
//           break;
//         case RewardedStatus.rewardedVideoDidMultipleLoaded:
//           break;
//         case RewardedStatus.rewardedVideoDidAdSourceBiddingAttempt:
//           break;
//         case RewardedStatus.rewardedVideoDidAdSourceBiddingFilled:
//           break;
//         case RewardedStatus.rewardedVideoDidAdSourceBiddingFail:
//           break;
//         case RewardedStatus.rewardedVideoDidAdSourceAttempt:
//           break;
//         case RewardedStatus.rewardedVideoDidAdSourceLoadFilled:
//           break;
//         case RewardedStatus.rewardedVideoDidAdSourceLoadFail:
//           break;
//       }
//     });
//   }
//
//   void _adDidFinishLoad({
//     MaxAd? maxAd,
//     ATInterstitialResponse? toponInt,
//     ATRewardResponse? toponReward,
//   }) async {
//     String adID = "";
//     double revenue = 0;
//     String networkName = "";
//     String sdk = "";
//     if (maxAd != null) {
//       adID = maxAd.adUnitId;
//       revenue = maxAd.revenue;
//       networkName = "max";
//       sdk = "applovin_max_sdk";
//     }
//     if (toponInt != null) {
//       sdk = "topon_sdk";
//       adID = toponInt.placementID;
//       revenue = toponInt.extraMap["publisher_revenue"] ?? 0;
//       networkName = "topon";
//       String intInfo = await ATInterstitialManager.getInterstitialValidAds(
//         placementID: adID,
//       );
//       try {
//         List<dynamic> infoMap = json.decode(intInfo);
//         if (infoMap.isNotEmpty) {
//           Map<String, dynamic> d = infoMap.first;
//           revenue = d["publisher_revenue"] ?? 0;
//         }
//       } catch (error) {
//         "$runtimeType decode topon int info error $error".log();
//       }
//     }
//     if (toponReward != null) {
//       sdk = "topon_sdk";
//       adID = toponReward.placementID;
//       networkName = "topon";
//       String intInfo = await ATRewardedManager.getRewardedVideoValidAds(
//         placementID: adID,
//       );
//       try {
//         List<dynamic> infoMap = json.decode(intInfo);
//         if (infoMap.isNotEmpty) {
//           Map<String, dynamic> d = infoMap.first;
//           revenue = d["publisher_revenue"] ?? 0;
//         }
//       } catch (error) {
//         "$runtimeType decode topon int info error $error".log();
//       }
//     }
//
//     if (adID.isEmpty) {
//       "$runtimeType ad did loaded but id is empty id = $adID".log();
//       return;
//     }
//
//     int index = _ads.indexWhere((test) => test.ad_identifer == adID);
//     if (index == -1) {
//       "$runtimeType ad did loaded but cant find in ads data from id = $adID"
//           .log();
//       return;
//     }
//
//     _ads[index].status = 1;
//     _ads[index].ecpm = revenue;
//     _ads[index].networkName = networkName;
//     _ads[index].sdk = sdk;
//     "$runtimeType ad did load success [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer} ecpm = ${_ads[index].ecpm} network = ${_ads[index].networkName}"
//         .log();
//     cs_event_fire(
//       "ad_return",
//       {
//         "ad_code_id": _ads[index].ad_identifer,
//         "ad_format": _ads[index].type == "reward" ? "rv" : "int",
//         "ad_source_client": _ads[index].networkName,
//         "nskdh_ad_request_time": Random().nextInt(4),
//       },
//     );
//   }
//
//   void _adDidLoadFailed(String adID, String reason, String type) {
//     int index = _ads.indexWhere((test) => test.ad_identifer == adID);
//     if (index == -1) {
//       "$runtimeType ad did load failed but cant find in ads data from id = $adID"
//           .log();
//       return;
//     }
//     cs_event_fire(
//       "ad_return_fail",
//       {
//         "ad_code_id": quizAdPlaceID ?? "",
//         "ad_format": _ads[index].getTypeToServer(),
//         "ad_source_client": type,
//         "reason": reason,
//       },
//     );
//     // 延迟1s请求下一条避免出现请求频繁报错
//     Future.delayed(Duration(seconds: 2),(){
//       _requestAd(defaultIndex: [index]);
//     });
//   }
//
//   Future<void>
//   _adDidDisplayed({required String adID,required String ad_network}) async {
//     if (CSLocalProvider.instance.cs_bg_music){
//       CSAudioUtils().pauseBGM();
//     }
//     int index = _ads.indexWhere((test) => test.ad_identifer == adID);
//     if (index == -1) {
//       "$runtimeType ad did display but cant find in ads data from id = $adID"
//           .log();
//       cs_event_fire('nskdh_ad_show_suc_not_impression', {});
//       return;
//     }
//     _ads[index].status = 2;
//
//     _savedPlayAndCloseTime = DateTime.now();
//     CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_show_indexName, CSLocalProvider.instance.cs_ad_show_index + 1);
//     CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_all_numberName, CSLocalProvider.instance.cs_ad_all_number + 1);
//     // 广告显示
//     CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_show_numberName, CSLocalProvider.instance.cs_ad_show_number + 1);
//
//     if (_ads[index].getTypeToServer() == "rv") {
//       CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_reawrd_all_numberName, CSLocalProvider.instance.cs_ad_reawrd_all_number + 1);
//       // 判断两次播放间隔小于30s
//       int secondsDiff = DateTime.now().difference(_savedTime!).inSeconds;
//       if (secondsDiff < CSFKManger().fkModel.behavior.ad_short_show.duration && _savedTime != null){
//         // 添加次数
//         CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_short_show_numberName, CSLocalProvider.instance.cs_ad_short_show_number + 1);
//         // 大于等于次数被风控
//         'CSFKManger().fkModel.behavior.ad_short_show.value=${CSFKManger().fkModel.behavior.ad_short_show.value}'.log();
//         'WUUserHelpers().wu_ad_short_show_number=${CSLocalProvider.instance.cs_ad_short_show_number}'.log();
//         if (CSFKManger().fkModel.behavior.ad_short_show.value <= CSLocalProvider.instance.cs_ad_short_show_number){
//           cs_event_fire('risk_chance', {'risk_from' : 'ad_short_show'});
//           CSLocalProvider.instance.updateBool(CSLocalProvider.instance.cs_fk_ad_short_showName, true);
//         }
//       }
//     }
//
//     "$runtimeType ad did display success [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer}"
//         .log();
//
//     adShowed();
//   }
//
//   Future<void> setTxProgress() async {
//     // if (CSLocalProvider.instance.cs_tx_task_index == 2 || CSLocalProvider.instance.cs_tx_task_index == 5 || CSLocalProvider.instance.cs_tx_task_index == 8){
//     //   await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_bubble_indexName, CSLocalProvider.instance.cs_tx_bubble_index + 1);
//     //   Future.delayed(Duration(milliseconds: 50), () async {
//     //     // PSPigCashNotificationService.sendToQuizProgressNotification(0);
//     //     'CSLocalProvider.instance.cs_tx_bubble_index=${CSLocalProvider.instance.cs_tx_bubble_index}'.log();
//     //     'CSLocalProvider.instance.cs_tx_task_index=${CSLocalProvider.instance.cs_tx_task_index}'.log();
//     //     if (CSLocalProvider.instance.cs_tx_bubble_index >= PSNumberHelpers().intModel!.tixianTask[CSLocalProvider.instance.cs_tx_task_index].data) {
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_quiz_indexName, 0);
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_wheel_indexName, 0);
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_bubble_indexName, 0);
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_task_indexName, CSLocalProvider.instance.cs_tx_task_index + 1);
//     //       Future.delayed(Duration(milliseconds: 50), () async {
//     //         // PSPigCashNotificationService.sendToQuizProgressNotification(0);
//     //       });
//     //     }
//     //   });
//     //   // 重置任务
//     //   Future.delayed(Duration(milliseconds: 100), () async {
//     //     if (CSLocalProvider.instance.cs_tx_task_index + 1 >= PSNumberHelpers().intModel!.tixianTask.length){
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_quiz_indexName, 0);
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_wheel_indexName, 0);
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_bubble_indexName, 0);
//     //       await CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_tx_task_indexName, 0);
//     //       Future.delayed(Duration(milliseconds: 50), () async {
//     //         // PSPigCashNotificationService.sendToQuizProgressNotification(0);
//     //       });
//     //     }
//     //   });
//     // };
//   }
//
//   Future<void> _adDidHidden({required String adId}) async {
//     if (CSLocalProvider.instance.cs_bg_music){
//       CSAudioUtils().playBGM();
//     }
//     is_showAd = false;
//     // 保存上次关闭广告时间仅限激励
//     _savedTime = DateTime.now();
//     int index = _ads.indexWhere((test) => test.ad_identifer == adId);
//     if (index == -1) {
//       "$runtimeType ad did hidden but cant find in ads data from id = $adId"
//           .log();
//       return;
//     }
//     "$runtimeType ad did hidden success id = $adId".log();
//     _ads[index].status = 0;
//     cs_event_fire(
//       "ad_close",
//       {
//         "ad_pos_id": quizAdPlaceID ?? "none",
//         "ad_source_client": _ads[index].source,
//         "ad_format": _ads[index].getTypeToServer(),
//         "ad_code_id": _ads[index].ad_identifer,
//       },
//     );
//
//     if (_ads[index].getTypeToServer() == "rv") {
//       // 判断播发到关闭播放间隔小于20s
//       int secondsDiff = DateTime.now().difference(_savedPlayAndCloseTime!).inSeconds;
//       if (secondsDiff < CSFKManger().fkModel.behavior.ad_short_close.duration && _savedPlayAndCloseTime != null){
//         // 添加次数
//         CSLocalProvider.instance.updateint(CSLocalProvider.instance.cs_ad_short_close_numberName, CSLocalProvider.instance.cs_ad_short_close_number + 1);
//         // 大于等于次数被风控
//         if (CSFKManger().fkModel.behavior.ad_short_close.value <= CSLocalProvider.instance.cs_ad_short_close_number){
//           cs_event_fire('risk_chance', {'risk_from' : 'ad_short_close'});
//           CSLocalProvider.instance.updateBool(CSLocalProvider.instance.cs_fk_ad_short_closeName, true);
//         }
//       }
//     }
//
//     onAdClosed?.call(true);
//     resetHandler();
//
//     _requestAd(defaultIndex: [index]);
//   }
//
//   Future<void> _adDidDisplayedError(String adID, String errorString) async {
//
//     int index = _ads.indexWhere((test) => test.ad_identifer == adID);
//
//     if (index == -1) {
//       "$runtimeType ad did display error but cant find in ads data from id = $adID"
//           .log();
//       return;
//     }
//     _ads[index].status = 0;
//     "$runtimeType ad did display error [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer}"
//         .log();
//
//     cs_event_fire(
//       "nskdh_ad_impression_fail",
//       {"ad_pos_id": quizAdPlaceID ?? "", "reason": errorString},
//     );
//
//     onAdClosed?.call(false);
//     resetHandler();
//
//     _requestAd(defaultIndex: [index]);
//   }
//
//   bool findTag(List<CSAdModellist> data, String adID) {
//     bool finded = false;
//     for (int i = 0; i < data.length; i++) {
//       if (data[i].prnospnz == adID) {
//         finded = true;
//         break;
//       }
//     }
//     return finded;
//   }
//
//   void resetHandler() {
//     if (onAdClosed != null) {
//       onAdClosed = null;
//     }
//     if (quizAdPlaceID != null) {
//       quizAdPlaceID = null;
//     }
//   }
//
//   bool someAdIsShowing() {
//     return _ads.any((e) => e.status == 2);
//   }
// }
//
// class NetworkUtils {
//   /// 检查当前是否有网络连接（移动数据或Wi-Fi）
//   static Future<bool> isConnected() async {
//     // 获取当前网络状态
//     final connectivityResult = await (Connectivity().checkConnectivity());
//
//     // 判断是否有网络连接
//     if (connectivityResult == ConnectivityResult.mobile ||
//         connectivityResult == ConnectivityResult.wifi) {
//       return true; // 有移动数据或Wi-Fi连接
//     }
//
//     return false; // 无网络连接
//   }
//
//   /// 监听网络状态变化
//   static Stream<ConnectivityResult> getNetworkChanges() {
//     return Connectivity().onConnectivityChanged;
//   }
// }