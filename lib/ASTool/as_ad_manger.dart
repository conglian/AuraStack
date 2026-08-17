import 'dart:convert';
import 'dart:math';
import 'package:adjust_sdk/adjust.dart';
import 'package:adjust_sdk/adjust_ad_revenue.dart';
import 'package:aurastack/ASTool/ASLogger.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:thinkup_sdk/at_interstitial.dart';
import 'package:thinkup_sdk/at_interstitial_response.dart';
import 'package:thinkup_sdk/at_listener.dart';
import 'package:thinkup_sdk/at_rewarded.dart';
import 'package:thinkup_sdk/at_rewarded_response.dart';
import '../ASDialog/ASOther/ASOtherDialog.dart';
import '../ASModel/ASAdModel.dart';
import 'ASAudioUtils.dart';
import 'ASFKManger.dart';
import 'ASTBAEventTool.dart';
import 'ASTrackEvent.dart';
import 'as_LocalProvider.dart';
import 'as_extension_help.dart';

Map<String, dynamic> as_defaultAdConfig = {
  "xjgrpkac": 100,
  "wgcmmsne": 100,
  "olstk_switch": false,
  "olstk_int": [
    {
      "ayyibgmi": "n6a69b10e0949e",
      "ckovkxxo": "topon",
      "ichurcix": "interstitial",
      "tavomvmz": 3000
    }
  ],
  "olstk_rv": [
    {
      "ayyibgmi": "n6a69b10e5fa85",
      "ckovkxxo": "topon",
      "ichurcix": "reward",
      "tavomvmz": 3000
    }
  ]
};

class ASCardAuraAdModel {
  String type;
  String source;

  double ecpm;
  String ad_identifer;
  int status;
  String networkName;
  String sdk;

  ASCardAuraAdModel({
    required this.type,
    required this.source,
    required this.ecpm,
    required this.ad_identifer,
    required this.status,
    required this.networkName,
    required this.sdk,
  });

  String getTypeToServer() {
    if (type == "reward") {
      return "rv";
    } else {
      return "int";
    }
  }
}

class ASCardAds {

  static final ASCardAds _instance = ASCardAds._internal();

  factory ASCardAds() {
    return _instance;
  }

  ASCardAds._internal();

  ASAdModel? _ASCardAuraAdModel;

  ASAdModel? as_PigAdModel = ASAdModel.fromJson(as_defaultAdConfig);

  bool _pigAdDelegateCreated = false;

  bool init_suc = false;

  String? quizAdPlaceID;

  Function(bool)? onAdClosed;
  // 保存上次播放广告时间
  DateTime? _savedTime = DateTime.now();
  // 保存上次播放到关闭广告时间
  DateTime? _savedPlayAndCloseTime;

  DateTime int_start = DateTime.now();

  DateTime read_start = DateTime.now();

  int _adShowed = 0;
  int _adClicked = 0;
  int adShowedToday = 0;
  double _adRevenues = 0.0;

  List<ASCardAuraAdModel> _ads = [];
  // 是否显示广告中
  late bool is_showAd = false;
  // 测试打开，上线关闭
  final bool skipAd = false;

  Future<void> init({ASAdModel? inputAd}) async {
    _ads = [];
    asLog.info("$runtimeType init ad json,remote value is $inputAd");
    try {
      await setAdConfigData(
        inputAdModel: inputAd ?? as_PigAdModel,
      );
      _getCacheData();

      if (!_prepareRequest()) {
        return;
      }
      _requestAd();
    } catch (error) {
      asLog.info("$runtimeType init ad error $error");
    }
  }

  void addAds(List<ASAdModellist> list) {
    for (final d in list) {
      _ads.add(
        ASCardAuraAdModel(
          type: d.ichurcix,
          source: d.ckovkxxo,
          ecpm: 0,
          ad_identifer: d.ayyibgmi,
          status: 0,
          networkName: "",
          sdk: "",
        ),
      );
    }
  }

  void _getCacheData() {
    _adShowed = ASLocalProvider.instance.as_ad_show_number;
    _adClicked =  0;
    adShowedToday =  0;
    _adRevenues = 0;
  }

  void as_showAd(
      BuildContext context,
      String placeID, {
        required Function(bool) onCacheResponse,
        required Function(bool) adDidClosed,
        bool mustShow = false,
        bool showDialog = true,
      }) async {
    if (skipAd) {
      // await setTxProgress();
      onAdClosed ??= adDidClosed;
      await _finishAdCallback(true);
      return;
    }
    // 风控
    if (await ASFKManger().as_checkAllStatus()){
      asLog.error('风控不发起广告显示');
      ASDialogTool.toast(context, 'Something went wrong, please try again later.');
      as_event_fire('as_fk_un', {});
      onCacheResponse.call(false);
      resetHandler();
      return;
    }

    if (someAdIsShowing()) {
      asLog.debug("$runtimeType ad is showing,cancel this request");
      return;
    }
    onAdClosed ??= adDidClosed;
    quizAdPlaceID ??= placeID;
    String adType = placeID.contains("rv") ? "rv" : "int";
    bool defaultMode = _ASCardAuraAdModel?.olstk_switch ?? false;
    asLog.debug('$runtimeType ad service request to show [$quizAdPlaceID], ad type is $adType, use mode #$defaultMode');
    as_event_fire(ASTrackEvent.adChance, {"ad_pos_id": placeID, 'ad_format' : placeID.contains('int') ? 'int' : 'rv'});

    if (defaultMode == false) {
      _showA(adType, placeID,onCacheResponse, context: context, showDialog: showDialog);
    } else {
      _showB(adType, placeID,onCacheResponse, context: context, showDialog: showDialog);
    }
  }

  void _showA(
      String adType,
      String placeID,
      Function(bool) onCacheResponse, {
        BuildContext? context, bool showDialog = true,
      }) async {
    final isInt = adType == "int";
    final realType = isInt ? "interstitial" : "reward";

    final showIndex = _findShowIndex(realType, false);

    if (showIndex != -1) {
      final ad = _ads[showIndex];

      asLog.debug("$runtimeType prepare to show ad [A],type=$adType, id=${ad.ad_identifer}");

      final showed = await _tryShowAd(ad, showIndex, context, placeID);
      if (showed) return;

      // show 失败兜底
      onCacheResponse(false);
      resetHandler();
      ad.status = 0;
      _requestAd(defaultIndex: [showIndex]);
      return;
    } else {
      if (context != null && showDialog == true) {
        as_showfaildDiolog(context, showDialog);
      }
    }

    asLog.error("$runtimeType prepare to show ad [A],type=$adType but no caches find!!");
    as_event_fire(
      ASTrackEvent.adImpressionFail,
      {"ad_pos_id": placeID, "reason": 'notPrepared'},
    );

    onCacheResponse(false);
    resetHandler();

    final notRequestingAd = _findNotRequestingAds(realType);
    if (notRequestingAd.isNotEmpty) {
      _requestAd(defaultIndex: notRequestingAd);
      return;
    }
    asLog.error("$runtimeType onCacheResponse is not ready!!! error $quizAdPlaceID");
  }

  int _findShowIndex(String adType, bool compare) {
    int showIndex = -1;
    double bestEcpm = double.negativeInfinity;

    for (int i = 0; i < _ads.length; i++) {
      final ad = _ads[i];

      // 必须是已缓存广告
      if (ad.status != 1) continue;

      // 非 compare 模式：只选指定类型
      if (!compare && ad.type != adType) continue;

      // compare 模式下：reward 场景允许跨类型比较
      if (compare && adType != "reward" && ad.type != adType) continue;

      if (ad.ecpm > bestEcpm) {
        bestEcpm = ad.ecpm;
        showIndex = i;
      }
    }

    return showIndex;
  }

  List<int> _findNotRequestingAds(String adType) {
    final result = <int>[];
    for (int i = 0; i < _ads.length; i++) {
      if (_ads[i].status == 0 && _ads[i].type == adType) {
        result.add(i);
      }
    }
    return result;
  }

  Future<bool> _tryShowAd(
      ASCardAuraAdModel ad,
      int index,
      BuildContext? context,
      String placeID
      ) async {
    if (ad.source == "max") {
      if (ad.type == "reward") {
        // final ready =
            // await AppLovinMAX.isRewardedAdReady(ad.ad_identifer) ?? false;
        // if (!ready) return false;
        is_showAd = true;
        // AppLovinMAX.showRewardedAd(ad.ad_identifer);
      } else {
        is_showAd = true;
        // AppLovinMAX.showInterstitial(ad.ad_identifer);
      }
    } else {
      if (ad.type == "reward") {
        final ready = await ATRewardedManager.rewardedVideoReady(
          placementID: ad.ad_identifer,
        );
        if (!ready) {
          as_event_fire(
            ASTrackEvent.adImpressionFail,
            {"ad_pos_id": placeID, "reason": 'notPrepared'},
          );
          return false;
        }
        is_showAd = true;
        ATRewardedManager.showRewardedVideo(placementID: ad.ad_identifer);
      } else {
        final ready = await ATInterstitialManager.hasInterstitialAdReady(
          placementID: ad.ad_identifer,
        );
        if (!ready){
          as_event_fire(
            ASTrackEvent.adImpressionFail,
            {"ad_pos_id": placeID, "reason": 'notPrepared'},
          );
          return false;
        }
        is_showAd = true;
        ATInterstitialManager.showInterstitialAd(placementID: ad.ad_identifer);
      }
    }

    ad.status = 2;

    return true;
  }

  void _showB(
      String adType, String placeID,
      Function(bool) onCacheResponse, {
        BuildContext? context,
        bool showDialog = true,
      }) async {
    final isInt = adType == "int";
    final realType = isInt ? "interstitial" : "reward";

    final showIndex = _findShowIndex(realType, true);

    if (showIndex != -1) {
      final ad = _ads[showIndex];

      asLog.debug("$runtimeType prepare to show ad [B],type=$adType, id=${ad.ad_identifer}");
      final showed = await _tryShowAd(ad, showIndex, context, placeID);
      if (showed) return;

      // show 失败兜底
      onCacheResponse(false);
      resetHandler();
      ad.status = 0;
      _requestAd(defaultIndex: [showIndex]);
      return;
    } else {
      if (context != null && showDialog == true) {
        as_showfaildDiolog(context, showDialog);
      }
    }
    asLog.debug("$runtimeType prepare to show ad [B],type=$adType but no caches find!!");
    as_event_fire(
      ASTrackEvent.adImpressionFail,
      {"ad_pos_id": placeID, "reason": 'notPrepared'},
    );

    onCacheResponse(false);
    resetHandler();

    final notRequestingAd = _findNotRequestingAds(realType);
    if (notRequestingAd.isNotEmpty) {
      _requestAd(defaultIndex: notRequestingAd);
      return;
    }
    asLog.debug("$runtimeType onCacheResponse is not ready!!! error $quizAdPlaceID");
  }

  void adImpression(Map extMap) async {
    double ecpms = extMap['publisher_revenue'] ?? 0.0;
    String adunit_format = extMap['adunit_format'] ?? '';
    as_ad_fire({
      "ss": ecpms * 1000000,
      "chute": extMap["network_name"],
      "motive": 'topon_sdk',
      "citywide": extMap['adunit_id'],
      "schnabel": quizAdPlaceID,
      "canaan": adunit_format.contains('Rewarded') ? 'rv' : 'int',
    });
    adRevenues(ecpms);
    // to sdk
    AdjustAdRevenue adjustAdRevenue = AdjustAdRevenue('topon_sdk');
    adjustAdRevenue.adRevenueNetwork = extMap["network_name"];
    adjustAdRevenue.setRevenue(ecpms, "USD");
    adjustAdRevenue.adRevenuePlacement = quizAdPlaceID;
    adjustAdRevenue.adRevenueUnit = extMap['adunit_id'];
    Adjust.trackAdRevenue(adjustAdRevenue);
    // PSFacebookAnalytics.logPurchase(ecpms, "USD");

  }

  // 显示失败弹框
  as_showfaildDiolog(BuildContext context, bool isShow) async {
    // 无网络
    bool isConnected = await NetworkUtils.isConnected();
    if (isShow == true){
      if (isConnected) {
        asLog.debug("有网加载失败");
        context.tipShow(ASToolDialog(type: .loadfaild));
      } else {
        asLog.debug("设备无网络连接");
        context.tipShow(ASToolDialog(type: .nowifi));
      }
    }
  }

  void adShowed() async {
    _adShowed += 1;
    asLog.debug("$runtimeType ad show times $_adShowed");
    ASLocalProvider.instance.updateint(
      ASLocalProvider.instance.as_ad_show_numberName,
      _adShowed,
    );
    ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_ad_all_numberName, ASLocalProvider.instance.as_ad_all_number + 1);
    if (_adShowed % 5 == 0) {
      as_event_fire(
        ASTrackEvent.adLifetime,
        {
          "ad": _adShowed,
        },
      );
    }

    update();
  }

  void adClicked() async {
    _adClicked += 1;

    update();
  }

  int getAdShowCount() {
    return _adShowed;
  }

  void adRevenues(double revenue) {
    _adRevenues += revenue;
    update();
  }

  update() async {

  }
}

extension AdServiceExtension on ASCardAds {
  Future<void> setAdConfigData({ASAdModel? inputAdModel}) async {
    _ASCardAuraAdModel = inputAdModel;
  }

  void _requestAd({List<int>? defaultIndex}) async {
    for (int i = 0; i < _ads.length; i++) {
      if (defaultIndex != null && !defaultIndex.contains(i)) {
        continue;
      }
      ASCardAuraAdModel ad = _ads[i];
      int status = ad.status;
      String type = ad.type;
      String source = ad.source;
      String adID = ad.ad_identifer;

      if (status == 0) {
        if (type == "interstitial") {
          if (source == "max") {
            // AppLovinMAX.loadInterstitial(adID);
          } else if (source == "topon") {
            ATInterstitialManager.loadInterstitialAd(
              placementID: adID,
              extraMap: {},
            );
          }
        } else if (type == "reward") {
          if (source == "max") {
            // AppLovinMAX.loadRewardedAd(adID);
          } else {
            ATRewardedManager.loadRewardedVideo(
              placementID: adID,
              extraMap: {},
            );
          }
        }
        asLog.debug("$runtimeType ad requesting [start],status = $status, type is $type, source is $source, id is $adID");
      } else if (status == 1) {
        asLog.debug("$runtimeType ad requesting [requesting] status = $status, type is $type, source is $source, id is $adID");
      } else {
        asLog.debug("$runtimeType ad requesting [requested] status = $status, type is $type, source is $source, id is $adID");
      }
      as_event_fire(
        ASTrackEvent.adRequest,
        {
          "ad_code_id": adID,
          "ad_format": type,
          "ad_source_client": source,
        },
      );
    }
  }

  bool _prepareRequest() {
    if (_ASCardAuraAdModel == null) {
      asLog.error("$runtimeType request ad start,but ad model empty...");
      return false;
    }

    addAds(_ASCardAuraAdModel!.olstk_int);
    addAds(_ASCardAuraAdModel!.olstk_rv);
    if (_ads.isEmpty) {
      asLog.error("$runtimeType request ad start,but datasource model empty...");
      return false;
    }

    if (!_pigAdDelegateCreated) {
      _createListener();
    }
    return true;
  }

  void _createListener() {
    _maxIntListener();
    _maxRvListener();
    _pigAdDelegateCreated = true;
  }

  void _maxIntListener() {
    /*
    AppLovinMAX.setInterstitialListener(
      InterstitialListener(
        onAdLoadedCallback: (ad) async {
          _adDidFinishLoad(maxAd: ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _adDidLoadFailed(adUnitId, error.message, 'max');
        },
        onAdDisplayedCallback: (ad) {
          _adDidDisplayed(adID: ad.adUnitId, ad_network: ad.networkName);
        },
        onAdHiddenCallback: (ad) {
          _adDidHidden(adId: ad.adUnitId);
        },
        onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
          _adDidDisplayedError(ad.adUnitId, error.message);
        },
        onAdClickedCallback: (MaxAd ad) {},
        onAdRevenuePaidCallback: (MaxAd ad) {},
      ),
    );
    */

    ATListenerManager.interstitialEventHandler.listen((value) {
      switch (value.interstatus) {
        case InterstitialStatus.interstitialAdFailToLoadAD:
          _adDidLoadFailed(value.placementID, value.requestMessage, 'topon');
          break;
      // interstitial load finish
        case InterstitialStatus.interstitialAdDidFinishLoading:
          _adDidFinishLoad(toponInt: value);
          break;
      // interstitial play start, some AD platforms have this callback.
        case InterstitialStatus.interstitialAdDidStartPlaying:
          break;
      // interstitial play end, some AD platforms have this callback.
        case InterstitialStatus.interstitialAdDidEndPlaying:
          break;
      // interstitial play fail, some AD platforms have this callback.
        case InterstitialStatus.interstitialDidFailToPlayVideo:
          _adDidDisplayedError(value.placementID, value.requestMessage);
          break;
      // interstitial show succeed
        case InterstitialStatus.interstitialDidShowSucceed:
          adImpression(value.extraMap);
          _adDidDisplayed(adID: value.placementID, ad_network: value.extraMap['network_name']);
          break;
      // interstitial show fail
        case InterstitialStatus.interstitialFailedToShow:
          break;
      // interstitial clicked
        case InterstitialStatus.interstitialAdDidClick:
          adClicked();
          break;
      // Deeplink
        case InterstitialStatus.interstitialAdDidDeepLink:
          break;
      // interstitial closed
        case InterstitialStatus.interstitialAdDidClose:
          _adDidHidden(adId: value.placementID);
          break;

        case InterstitialStatus.interstitialUnknown:
          break;
        case InterstitialStatus.interstitialAdDidMultipleLoaded:
        case InterstitialStatus.interstitialAdDidAdSourceBiddingAttempt:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceBiddingFilled:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceBiddingFail:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceAttempt:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceLoadFilled:
          break;
        case InterstitialStatus.interstitialAdDidAdSourceLoadFail:
          break;
      }
    });
  }

  void _maxRvListener() async {
    /*
    AppLovinMAX.setRewardedAdListener(
      RewardedAdListener(
        onAdLoadedCallback: (ad) {
          _adDidFinishLoad(maxAd: ad);
        },
        onAdLoadFailedCallback: (adUnitId, error) {
          _adDidLoadFailed(adUnitId, error.message, 'max');
        },
        onAdDisplayedCallback: (ad) {
          _adDidDisplayed(adID: ad.adUnitId, ad_network: ad.networkName);
          setTxProgress();
        },
        onAdHiddenCallback: (ad) {
          _adDidHidden(adId: ad.adUnitId);
        },
        onAdDisplayFailedCallback: (MaxAd ad, MaxError error) {
          _adDidDisplayedError(ad.adUnitId, error.message);
        },
        onAdClickedCallback: (MaxAd ad) {},
        onAdRevenuePaidCallback: (MaxAd ad) {},
        onAdReceivedRewardCallback: (MaxAd ad, MaxReward reward) {},
      ),
    );
    */

    ATListenerManager.rewardedVideoEventHandler.listen((value) {
      switch (value.rewardStatus) {
      // ad load fail
        case RewardedStatus.rewardedVideoDidFailToLoad:
          _adDidLoadFailed(value.placementID, value.requestMessage, 'topon');
          break;
      // ad load finish
        case RewardedStatus.rewardedVideoDidFinishLoading:
          _adDidFinishLoad(toponReward: value);
          break;
      // ad video start play
        case RewardedStatus.rewardedVideoDidStartPlaying:
          adImpression(value.extraMap);
          _adDidDisplayed(adID: value.placementID, ad_network: value.extraMap['network_name']);
          ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_qunm_ad_indexName, ASLocalProvider.instance.as_qunm_ad_index + 1);
          // setTxProgress();
          break;
      // ad video start end
        case RewardedStatus.rewardedVideoDidEndPlaying:
          break;
      // ad video fail to play
        case RewardedStatus.rewardedVideoDidFailToPlay:
          _adDidDisplayedError(value.placementID, value.requestMessage);
          break;
      // The rewarded is successful, it is recommended to issue the reward in this callback
        case RewardedStatus.rewardedVideoDidRewardSuccess:
          break;
      // ad video clicked
        case RewardedStatus.rewardedVideoDidClick:
          adClicked();
          break;
      //Deeplink
        case RewardedStatus.rewardedVideoDidDeepLink:
          break;
        case RewardedStatus.rewardedVideoDidClose:
          _adDidHidden(adId: value.placementID);
          break;
        case RewardedStatus.rewardedVideoDidAgainStartPlaying:
          break;
      // ad video again play end(only TT)
        case RewardedStatus.rewardedVideoDidAgainEndPlaying:
          break;
      // ad video again fail to play(only TT)
        case RewardedStatus.rewardedVideoDidAgainFailToPlay:
          break;
      // ad video again rewarded success(only TT)
        case RewardedStatus.rewardedVideoDidAgainRewardSuccess:
          break;
      // ad video again clicked(only TT)
        case RewardedStatus.rewardedVideoDidAgainClick:
        case RewardedStatus.rewardedVideoUnknown:
          break;
        case RewardedStatus.rewardedVideoDidMultipleLoaded:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceBiddingAttempt:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceBiddingFilled:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceBiddingFail:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceAttempt:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceLoadFilled:
          break;
        case RewardedStatus.rewardedVideoDidAdSourceLoadFail:
          break;
      }
    });
  }

  void _adDidFinishLoad({
    ATInterstitialResponse? toponInt,
    ATRewardResponse? toponReward,
  }) async {
    String adID = "";
    double revenue = 0;
    String networkName = "";
    String sdk = "";
    // if (maxAd != null) {
    //   adID = maxAd.adUnitId;
    //   revenue = maxAd.revenue;
    //   networkName = "max";
    //   sdk = "applovin_max_sdk";
    // }
    if (toponInt != null) {
      sdk = "topon_sdk";
      adID = toponInt.placementID;
      revenue = toponInt.extraMap["publisher_revenue"] ?? 0;
      networkName = "topon";
      String intInfo = await ATInterstitialManager.getInterstitialValidAds(
        placementID: adID,
      );
      try {
        List<dynamic> infoMap = json.decode(intInfo);
        if (infoMap.isNotEmpty) {
          Map<String, dynamic> d = infoMap.first;
          revenue = d["publisher_revenue"] ?? 0;
        }
      } catch (error) {
        asLog.error("$runtimeType decode topon int info error $error");
      }
    }
    if (toponReward != null) {
      sdk = "topon_sdk";
      adID = toponReward.placementID;
      networkName = "topon";
      String intInfo = await ATRewardedManager.getRewardedVideoValidAds(
        placementID: adID,
      );
      try {
        List<dynamic> infoMap = json.decode(intInfo);
        if (infoMap.isNotEmpty) {
          Map<String, dynamic> d = infoMap.first;
          revenue = d["publisher_revenue"] ?? 0;
        }
      } catch (error) {
        asLog.error("$runtimeType decode topon int info error $error");
      }
    }

    if (adID.isEmpty) {
      asLog.error("$runtimeType ad did loaded but id is empty id = $adID");
      return;
    }

    int index = _ads.indexWhere((test) => test.ad_identifer == adID);
    if (index == -1) {
      asLog.error("$runtimeType ad did loaded but cant find in ads data from id = $adID");
      return;
    }

    _ads[index].status = 1;
    _ads[index].ecpm = revenue;
    _ads[index].networkName = networkName;
    _ads[index].sdk = sdk;
    asLog.success("$runtimeType ad did load success [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer} ecpm = ${_ads[index].ecpm} network = ${_ads[index].networkName}");
    as_event_fire(
      ASTrackEvent.adReturn,
      {
        "ad_code_id": _ads[index].ad_identifer,
        "ad_format": _ads[index].type == "reward" ? "rv" : "int",
        "ad_source_client": _ads[index].networkName,
        "olstk_ad_request_time": Random().nextInt(4),
      },
    );
  }

  void _adDidLoadFailed(String adID, String reason, String type) {
    int index = _ads.indexWhere((test) => test.ad_identifer == adID);
    if (index == -1) {
      asLog.error("$runtimeType ad did load failed but cant find in ads data from id = $adID");
      return;
    }
    as_event_fire(
      ASTrackEvent.adReturnFail,
      {
        "ad_code_id": quizAdPlaceID ?? "",
        "ad_format": _ads[index].getTypeToServer(),
        "ad_source_client": type,
        "reason": reason,
      },
    );
    // 延迟1s请求下一条避免出现请求频繁报错
    Future.delayed(Duration(seconds: 2),(){
      _requestAd(defaultIndex: [index]);
    });
  }

  Future<void>
  _adDidDisplayed({required String adID,required String ad_network}) async {
    if (ASLocalProvider.instance.as_bg_music){
      ASAudioUtils().pauseBGM();
    }
    int index = _ads.indexWhere((test) => test.ad_identifer == adID);
    if (index == -1) {
      asLog.success("$runtimeType ad did display but cant find in ads data from id = $adID");
      as_event_fire('olstk_ad_show_suc_not_impression', {});
      return;
    }
    _ads[index].status = 2;

    _savedPlayAndCloseTime = DateTime.now();
    ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_ad_show_indexName, ASLocalProvider.instance.as_ad_show_index + 1);
    // if (_ads[index].getTypeToServer() == "rv") {
    //   ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_ad_reawrd_all_numberName, ASLocalProvider.instance.as_ad_reawrd_all_number + 1);
    //   // 判断两次播放间隔小于30s
    //   int secondsDiff = DateTime.now().difference(_savedTime!).inSeconds;
    //   if (secondsDiff < ASFKManger().fkModel.behavior.ad_short_show.duration && _savedTime != null){
    //     // 添加次数
    //     ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_ad_short_show_numberName, ASLocalProvider.instance.as_ad_short_show_number + 1);
    //     // 大于等于次数被风控
    //     'CSFKManger().fkModel.behavior.ad_short_show.value=${CSFKManger().fkModel.behavior.ad_short_show.value}'.log();
    //     'WUUserHelpers().wu_ad_short_show_number=${ASLocalProvider.instance.as_ad_short_show_number}'.log();
    //     if (CSFKManger().fkModel.behavior.ad_short_show.value <= ASLocalProvider.instance.as_ad_short_show_number){
    //       as_event_fire(ASTrackEvent.riskChance, {'risk_from' : 'ad_short_show'});
    //       ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_ad_short_showName, true);
    //     }
    //   }
    // }

    asLog.success("$runtimeType ad did display success [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer}");

    adShowed();
  }

  Future<void> _adDidHidden({required String adId}) async {
    if (ASLocalProvider.instance.as_bg_music){
      ASAudioUtils().playBGM();
    }
    is_showAd = false;
    // 保存上次关闭广告时间仅限激励
    _savedTime = DateTime.now();
    int index = _ads.indexWhere((test) => test.ad_identifer == adId);
    if (index == -1) {
      asLog.debug("$runtimeType ad did hidden but cant find in ads data from id = $adId");
      return;
    }
    asLog.success("$runtimeType ad did hidden success id = $adId");
    _ads[index].status = 0;
    as_event_fire(
      ASTrackEvent.adClose,
      {
        "ad_pos_id": quizAdPlaceID ?? "none",
        "ad_source_client": _ads[index].source,
        "ad_format": _ads[index].getTypeToServer(),
        "ad_code_id": _ads[index].ad_identifer,
      },
    );

    // if (_ads[index].getTypeToServer() == "rv") {
    //   // 判断播发到关闭播放间隔小于20s
    //   int secondsDiff = DateTime.now().difference(_savedPlayAndCloseTime!).inSeconds;
    //   if (secondsDiff < ASFKManger().fkModel.behavior.ad_short_close.duration && _savedPlayAndCloseTime != null){
    //     // 添加次数
    //     ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_ad_short_close_numberName, ASLocalProvider.instance.as_ad_short_close_number + 1);
    //     // 大于等于次数被风控
    //     if (ASFKManger().fkModel.behavior.ad_short_close.value <= ASLocalProvider.instance.as_ad_short_close_number){
    //       as_event_fire(ASTrackEvent.riskChance, {'risk_from' : 'ad_short_close'});
    //       ASLocalProvider.instance.updateBool(ASLocalProvider.instance.as_fk_ad_short_closeName, true);
    //     }
    //   }
    // }

    await _finishAdCallback(true);

    _requestAd(defaultIndex: [index]);
  }

  Future<void> _adDidDisplayedError(String adID, String errorString) async {

    int index = _ads.indexWhere((test) => test.ad_identifer == adID);

    if (index == -1) {
      asLog.error("$runtimeType ad did display error but cant find in ads data from id = $adID");
      return;
    }
    _ads[index].status = 0;
    asLog.error("$runtimeType ad did display error [${_ads[index].source}] type = ${_ads[index].type} id = ${_ads[index].ad_identifer}");
    as_event_fire(
      ASTrackEvent.adImpressionFail,
      {"ad_pos_id": quizAdPlaceID ?? "", "reason": errorString},
    );

    await _finishAdCallback(false);

    _requestAd(defaultIndex: [index]);
  }

  bool findTag(List<ASAdModellist> data, String adID) {
    bool finded = false;
    for (int i = 0; i < data.length; i++) {
      if (data[i].ayyibgmi == adID) {
        finded = true;
        break;
      }
    }
    return finded;
  }

  void resetHandler() {
    if (onAdClosed != null) {
      onAdClosed = null;
    }
    if (quizAdPlaceID != null) {
      quizAdPlaceID = null;
    }
  }

  Future<void> _finishAdCallback(bool didClose) async {
    try {
      final callbackResult = onAdClosed?.call(didClose);
      if (callbackResult is Future) {
        await callbackResult;
      }
      if (didClose) {
        await ASLocalProvider.instance.showRevenueMilestoneFlowAfterAd();
      }
    } finally {
      resetHandler();
    }
  }

  bool someAdIsShowing() {
    return _ads.any((e) => e.status == 2);
  }
}

class NetworkUtils {
  /// 检查当前是否有网络连接（移动数据或Wi-Fi）
  static Future<bool> isConnected() async {
    // 获取当前网络状态
    final connectivityResult = await (Connectivity().checkConnectivity());

    // 判断是否有网络连接
    if (connectivityResult == ConnectivityResult.mobile ||
        connectivityResult == ConnectivityResult.wifi) {
      return true; // 有移动数据或Wi-Fi连接
    }

    return false; // 无网络连接
  }

  /// 监听网络状态变化
  static Stream<ConnectivityResult> getNetworkChanges() {
    return Connectivity().onConnectivityChanged;
  }
}
