import 'dart:async';
import 'dart:convert';

import 'package:thinkup_sdk/anythink_sdk.dart';

final ATInitManger = ATInit();

class ATInit {
  /*Set log switch */
  Future<bool> setLogEnabled({
    bool logEnabled = false,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setLogEnabled", {
      "logEnabled": logEnabled,
    });
  }

  /*Set up channels */
  Future<String> setChannelStr({
    String? channelStr
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setChannelStr", {
      "channelStr": channelStr,
    });
  }

  /*Set up sub-channels */
  Future<String> setSubChannelStr({
    String? subchannelStr
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setSubchannelStr", {
      "subchannelStr": subchannelStr,
    });
  }

  /*Set up custom rules*/
  Future<Map> setCustomDataMap({
    Map<String, Object>? customDataMap,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setCustomDataDic", {
      "customDataDic": customDataMap,
    });
  }

/*Set up exclusion cross-promotion list */
  Future<List> setExludeBundleIDArray({
    List<String>? exludeBundleIDList,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setExludeBundleIDArray", {
      "exludeBundleIDArray": exludeBundleIDList,
    });
  }

/*Set to limit the reporting of these private data */
  Future<List> deniedUploadDeviceInfo({
    List<String>? deniedUploadDeviceInfoList,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("deniedUploadDeviceInfo", {
      "deniedUploadInfoArray": deniedUploadDeviceInfoList,
    });
  }

  /*System version number */
  String aVersionNameKey() {
    return 'os_vn';
  }

  /*System version number */
  String aVersionCodeKey() {
    return 'os_vc';
  }

  /*Application package name */
  String aPackageNameKey() {
    return 'package_name';
  }

  /*Application version name */
  String aAppVersionNameKey() {
    return 'app_vn';
  }

  /*App version number */
  String aAppVersionCodeKey() {
    return 'app_vc';
  }

  /*Equipment Brand */
  String aBrandKey() {
    return 'brand';
  }

  /*Device model */
  String aModelKey() {
    return 'model';
  }

  /*Screen Resolution */
  String aScreenKey() {
    return 'screen';
  }

  /*Network Type */
  String aNetworkTypeKey() {
    return 'network_type';
  }

  /*Mobile network code */
  String aMNCKey() {
    return 'mnc';
  }

  /*Mobile country code */
  String aMCCKey() {
    return 'mcc';
  }

  /*System language */
  String aLanguageKey() {
    return 'language';
  }

  /*Time zone */
  String aTimeZoneKey() {
    return 'timezone';
  }

  /*User Agent*/
  String aUserAgentKey() {
    return 'ua';
  }

  /*Screen orientation */
  String aOrientKey() {
    return 'orient';
  }

  /*idfa*/
  String aIDFAKey() {
    return 'idfa';
  }

/*idfv*/
  String aIDFVKey() {
    return 'idfv';
  }

/*Android ID*/
  String aANDROID() {
    return 'android_id';
  }

  /*Google Ad ID*/
  String aGAID() {
    return 'gaid';
  }

  /*App install source*/
  String aINSTALLER() {
    return 'it_src';
  }

  /*MAC address*/
  String aMAC() {
    return 'mac';
  }

/*International Mobile Equipment Identity*/
  String aIMEI() {
    return 'imei';
  }

  /*OAID*/
  String aOAID() {
    return 'oaid';
  }

/*Set Placement rules*/
  Future<String> setPlacementCustomData({
    Map<String, Object>? placementCustomDataMap,
    String? placementIDStr,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setPlacementCustomData", {
      "placementCustomDataDic": placementCustomDataMap,
      "placementIDStr": placementIDStr,
    });
  }

  /*Get GDPR grade*/
  Future<String> getGDPRLevel() async {
    return await AnythinkSdk.channel.invokeMethod("getGDPRLevel", {});
  }

  /*Get user location*/
  Future<String> getUserLocation() async {
    return await AnythinkSdk.channel.invokeMethod("getUserLocation", {});
  }

  /*Show the GDPR authorization interface*/
  Future<String> showGDPRAuth() async {
    return await AnythinkSdk.channel.invokeMethod("showGDPRAuth", {});
  }

  /*Show the GDPR authorization interface(with UMP). Returns dismiss map on Android (infoMsg, dismissType).*/
  Future<dynamic> showGDPRConsentDialog({String? appId}) async {
    print("showGDPRConsentDialog: $appId");
    return await AnythinkSdk.channel.invokeMethod("showGDPRConsentDialog", {
      if (appId != null) "appId": appId,
    });
  }

  /*Show the GDPR second consent interface(with UMP). Returns dismiss map on Android (infoMsg, dismissType).*/
  Future<dynamic> showGDPRConsentSecondDialog({String? appId}) async {
    print("showGDPRConsentSecondDialog: $appId");
    return await AnythinkSdk.channel.invokeMethod("showGDPRConsentSecondDialog", {
      if (appId != null) "appId": appId,
    });
  }

  /*Check whether the user is in EU traffic(with appId)*/
  Future<bool> checkIsEuTraffic({String? appId}) async {
    print("checkIsEuTraffic: $appId");
    final bool? result = await AnythinkSdk.channel.invokeMethod("checkIsEuTraffic", {
      if (appId != null) "appId": appId,
    });
    return result ?? false;
  }

/*Set GDPR level*/
  Future<String> setDataConsentSet({
    required String gdprLevel,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setDataConsentSet", {
      "gdprLevel": gdprLevel,
    });
  }

  String dataConsentSetNonpersonalized() {
    return 'ATDataConsentSetNonpersonalized';
  }

  String dataConsentSetPersonalized() {
    return 'ATDataConsentSetPersonalized';
  }

  String dataConsentSetUnknown() {
    return 'ATDataConsentSetUnknown';
  }

  /*Initialize SDK*/
  Future<String> initSDK({
    required String appidStr,
    required String appidkeyStr,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("initSDK", {
      "appIdStr": appidStr,
      "appKeyStr": appidkeyStr,
    });
  }

  /*preset placement strategy*/
  Future<String> setPresetPlacementConfigPath({
    required String pathStr,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("setPresetPlacementConfigPath", {
      "pathStr": pathStr,
    });
  }

  /*Open DebugUI*/
  Future<String> showDebuggerUI({
    required String debugKey,
  }) async {
    return await AnythinkSdk.channel.invokeMethod("showDebuggerUI", {
      "debugKey": debugKey,
    });
  }

  /// Native SDK version string (empty if unavailable).
  Future<String> getSDKVersionName() async {
    final String? version = await AnythinkSdk.channel.invokeMethod("getSDKVersionName", {});
    return version ?? "";
  }

  /// Call after [initSDK] when your integration requires an explicit start.
  Future<String> start() async {
    return await AnythinkSdk.channel.invokeMethod("start", {});
  }

  /// Ad-network privacy/device policy (camelCase keys; nested maps allowed).
  Future<String> setAdSourcePrivacyPolicy({
    required Map<String, Object?> policy,
  }) async {
    final String policyJson = jsonEncode(policy);
    print("setAdSourcePrivacyPolicy: $policyJson");
    return await AnythinkSdk.channel.invokeMethod("setAdSourcePrivacyPolicy", {
      "policyJson": policyJson,
    });
  }

  /// Waterfall load filter: native `putFilter`. Root key `groups`; AND inside each group, OR across groups.
  Future<String> putFilter({
    required String placementID,
    required Map<String, Object?> filterSpec,
  }) async {
    print("putFilter: placementID=$placementID filterJson=${jsonEncode(filterSpec)}");
    return await AnythinkSdk.channel.invokeMethod("putFilter", {
      "placementID": placementID,
      "extraDic": filterSpec,
    });
  }

  Future<String> removeFilters() async {
    print("removeFilters");
    return await AnythinkSdk.channel.invokeMethod("removeFilters", {});
  }

  Future<String> removeFilterWithPlacementId({
    required String placementID,
  }) async {
    print("removeFilterWithPlacementId: placementID=$placementID");
    return await AnythinkSdk.channel.invokeMethod("removeFilterWithPlacementId", {
      "placementID": placementID,
    });
  }

  /// Shared placement local extras per format (`rewardVideoLocalExtra`, etc.).
  Future<String> setSharedPlacementConfig({
    required Map<String, Object?> config,
  }) async {
    print("setSharedPlacementConfig: config=${jsonEncode(config)}");
    return await AnythinkSdk.channel.invokeMethod("setSharedPlacementConfig", {
      "extraDic": config,
    });
  }
}
