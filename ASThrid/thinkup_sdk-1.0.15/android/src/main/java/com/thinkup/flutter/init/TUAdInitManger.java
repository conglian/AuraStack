package com.thinkup.flutter.init;

import androidx.annotation.NonNull;

import android.text.TextUtils;

import com.thinkup.flutter.TUFlutterEventManager;
import com.thinkup.flutter.HandleThinkUpMethod;
import com.thinkup.flutter.utils.BridgeJsonMapUtil;
import com.thinkup.flutter.utils.Const;
import com.thinkup.flutter.utils.FlutterPluginUtil;
import com.thinkup.flutter.utils.MsgTools;
import com.thinkup.flutter.utils.Utils;
import com.thinkup.core.api.TUGDPRAuthCallback;
import com.thinkup.core.api.TUGDPRConsentDismissListener;
import com.thinkup.core.api.TUGDPRConsentDismissListener.ConsentDismissInfo;
import com.thinkup.core.api.TUSDK;
import com.thinkup.core.api.TUSharedPlacementConfig;
import com.thinkup.core.api.TUWaterfallFilter;
import com.thinkup.core.api.NetTrafficeCallback;
import com.thinkup.debug.api.TUDebuggerUITest;

import android.app.Activity;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

public class TUAdInitManger implements HandleThinkUpMethod {

    private static class SingletonClassInstance {
        private static final TUAdInitManger instance = new TUAdInitManger();
    }

    public static TUAdInitManger getInstance() {
        return SingletonClassInstance.instance;
    }

    private TUAdInitManger() {
    }

    /** Maps {@link ConsentDismissInfo} to Flutter {@code InitCallName} payload (keys: infoMsg, dismissType). */
    private static Map<String, Object> consentDismissToMap(ConsentDismissInfo info) {
        Map<String, Object> map = new HashMap<>(4);
        if (info != null) {
            map.put("infoMsg", info.getInfoMsg() != null ? info.getInfoMsg() : "");
            map.put("dismissType", info.getDismissType());
        }
        return map;
    }

    @Override
    public boolean handleMethodCall(@NonNull MethodCall methodCall, @NonNull final MethodChannel.Result result) throws Exception {

        switch (methodCall.method) {
            case "initSDK":
                String appID = methodCall.argument(Const.Init.APP_ID_STR);
                String appKey = methodCall.argument(Const.Init.APP_KEY_STR);

                MsgTools.printMsg("initSDK: " + appID + ", " + appKey);
                TUSDK.init(FlutterPluginUtil.getApplicationContext(), appID, appKey);
                result.success("");
                break;
            case "setLogEnabled":
                Boolean logEnable = methodCall.argument(Const.Init.LOG_ENABLE);

                MsgTools.setLogDebug(logEnable);
                MsgTools.printMsg("setLogEnabled: " + logEnable);
                TUSDK.setNetworkLogDebug(logEnable);
                break;
            case "setChannelStr":
                String channelStr = methodCall.argument(Const.Init.CHANNEL_STR);

                MsgTools.printMsg("setChannelStr: " + channelStr);
                TUSDK.setChannel(channelStr);
                break;
            case "setSubchannelStr":
                String subchannelStr = methodCall.argument(Const.Init.SUB_CHANNEL_STR);

                MsgTools.printMsg("setSubchannelStr: " + subchannelStr);
                TUSDK.setSubChannel(subchannelStr);
                break;
            case "setCustomDataDic":
                Map<String, Object> argument = methodCall.argument(Const.Init.CUSTOM_DTUA_DIC);
                if (argument != null) {
                    MsgTools.printMsg("setCustomDataDic: " + argument);
                    TUSDK.initCustomMap(argument);
                }
                break;
            case "setExludeBundleIDArray":
                MsgTools.printMsg("setExludeBundleIDArray");
                List<String> bundleIdList = methodCall.argument(Const.Init.EXLUDE_BUNDLE_ID_ARRAY);

                if (bundleIdList != null) {

                    int size = bundleIdList.size();
                    for (int i = 0; i < size; i++) {
                        MsgTools.printMsg("setExludeBundleIDArray: " + bundleIdList.get(i));
                    }

//                    TUSDK.setExcludeMyOfferPkgList(bundleIdList);
                    TUSDK.setExcludePackageList(bundleIdList);
                }
                break;
            case "deniedUploadDeviceInfo":
                MsgTools.printMsg("deniedUploadDeviceInfo");
                List<String> deniedUploadDeviceInfoList = methodCall.argument(Const.Init.DENIED_UPLOAD_INFO_ARRAY);

                if (deniedUploadDeviceInfoList != null) {

                    int size = deniedUploadDeviceInfoList.size();
                    if (size > 0) {
                        String[] deniedArray = new String[size];
                        String info;
                        for (int i = 0; i < size; i++) {
                            info = deniedUploadDeviceInfoList.get(i);
                            deniedArray[i] = info;
                            MsgTools.printMsg("deniedUploadDeviceInfo: " + info);
                        }

                        TUSDK.deniedUploadDeviceInfo(deniedArray);
                        break;
                    }
                }

                try {
                    MsgTools.printMsg("deniedUploadDeviceInfo: empty string");
                    TUSDK.deniedUploadDeviceInfo("");
                } catch (Throwable e) {
                    e.printStackTrace();
                }

                break;
            case "setPlacementCustomData":
                String placementIDStr = methodCall.argument(Const.Init.PLACEMENT_ID_STR);
                Map<String, Object> placementCustomDataMap = methodCall.argument(Const.Init.PLACEMENT_CUSTOM_DTUA_DIC);

                MsgTools.printMsg("setPlacementCustomData: " + placementIDStr + ", " + placementCustomDataMap);
                TUSDK.initPlacementCustomMap(placementIDStr, placementCustomDataMap);
                break;
            case "getGDPRLevel":
                int gdprDataLevel = TUSDK.getGDPRDataLevel(FlutterPluginUtil.getApplicationContext());

                MsgTools.printMsg("getGDPRLevel: " + gdprDataLevel);

                String levelString;
                switch (gdprDataLevel) {
                    case TUSDK.PERSONALIZED:
                        levelString = "TUDataConsentSetPersonalized";
                        break;
                    case TUSDK.NONPERSONALIZED:
                        levelString = "TUDataConsentSetNonpersonalized";
                        break;
                    default:
                        levelString = "TUDataConsentSetUnknown";
                        break;
                }
                MsgTools.printMsg("getGDPRLevel: callback to flutter: " + levelString);
                result.success(levelString);
                break;
            case "getUserLocation":
                MsgTools.printMsg("getUserLocation");
                TUSDK.checkIsEuTraffic(FlutterPluginUtil.getApplicationContext(), new NetTrafficeCallback() {
                    @Override
                    public void onResultCallback(boolean b) {
                        MsgTools.printMsg("getUserLocation: onResultCallback: " + b);

                        final String result = b ? "1" : "2";
                        MsgTools.printMsg("getUserLocation: callback to flutter: result: " + result);
                        TUFlutterEventManager.getInstance().sendMsgToFlutter(Const.CallbackMethodCall.InitCallName, Const.InitCallback.locationCallbackKey, result);
                    }

                    @Override
                    public void onErrorCallback(String s) {
                        MsgTools.printMsg("getUserLocation: onErrorCallback: " + s);

                        TUFlutterEventManager.getInstance().sendMsgToFlutter(Const.CallbackMethodCall.InitCallName, Const.InitCallback.locationCallbackKey, "0");//unknown
                    }
                });
                break;
            case "setDataConsentSet":
                String uploadDataLevel = methodCall.argument(Const.Init.GDPR_UPLOAD_DTUA_LEVEL);

                MsgTools.printMsg("setDataConsentSet: " + uploadDataLevel);

                int level;
                switch (uploadDataLevel) {
                    case "TUDataConsentSetPersonalized":
                        level = TUSDK.PERSONALIZED;
                        break;
                    case "TUDataConsentSetNonpersonalized":
                        level = TUSDK.NONPERSONALIZED;
                        break;
                    default:
                        level = TUSDK.UNKNOWN;
                        break;
                }

                TUSDK.setGDPRUploadDataLevel(FlutterPluginUtil.getApplicationContext(), level);
                break;
            case "showGDPRAuth":
                MsgTools.printMsg("showGDPRAuth");

                FlutterPluginUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        TUSDK.showGdprAuth(FlutterPluginUtil.getApplicationContext(), new TUGDPRAuthCallback() {
                            @Override
                            public void onAuthResult(int i) {
                                MsgTools.printMsg("showGDPRAuth: onAuthResult: " + i);

                                String result;
                                switch (i) {
                                    case TUSDK.PERSONALIZED:
                                        result = "1";
                                        break;
                                    case TUSDK.NONPERSONALIZED:
                                        result = "2";
                                        break;
                                    default:
                                        result = "0";//unknown
                                        break;
                                }
                                MsgTools.printMsg("showGDPRAuth: onAuthResult: callback to flutter: result: " + result);
                                TUFlutterEventManager.getInstance().sendMsgToFlutter(Const.CallbackMethodCall.InitCallName, Const.InitCallback.consentSetCallbackKey, result);
                            }

                            @Override
                            public void onPageLoadFail() {
                                MsgTools.printMsg("showGDPRAuth: onPageLoadFail");

                                TUFlutterEventManager.getInstance().sendMsgToFlutter(Const.CallbackMethodCall.InitCallName, Const.InitCallback.consentSetCallbackKey, "0");//unknown
                            }
                        });
                    }
                });
                break;

            case "showGDPRConsentDialog":
                final String consentAppId = methodCall.argument(Const.Init.APP_ID);
                MsgTools.printMsg("showGDPRConsentDialog: appId=" + consentAppId);

                FlutterPluginUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Activity activity = FlutterPluginUtil.getActivity();
                        if (!FlutterPluginUtil.isActivityUsable(activity)) {
                            MsgTools.printMsg("showGDPRConsentDialog: activity invalid, abort");
                            Map<String, Object> dismissMap = new HashMap<>(4);
                            dismissMap.put("infoMsg", "activity is null!");
                            dismissMap.put("dismissType", -1);
                            TUFlutterEventManager.getInstance().sendMsgToFlutter(
                                    Const.CallbackMethodCall.InitCallName,
                                    Const.InitCallback.consentDismissCallbackKey,
                                    dismissMap);
                            try {
                                result.success(dismissMap);
                            } catch (Throwable ignored) {
                            }
                            return;
                        }
                        TUGDPRConsentDismissListener listener = new TUGDPRConsentDismissListener() {
                            @Override
                            public void onDismiss(ConsentDismissInfo consentDismissInfo) {
                                MsgTools.printMsg("showGDPRConsentDialog: onDismiss: " + consentDismissInfo);
                                final Map<String, Object> dismissMap = consentDismissToMap(consentDismissInfo);
                                TUFlutterEventManager.getInstance().sendMsgToFlutter(
                                        Const.CallbackMethodCall.InitCallName,
                                        Const.InitCallback.consentDismissCallbackKey,
                                        dismissMap);
                                try {
                                    result.success(dismissMap);
                                } catch (Throwable ignored) {
                                }
                            }
                        };
                        if (consentAppId != null && consentAppId.length() > 0) {
                            TUSDK.showGDPRConsentDialog(activity, listener, consentAppId);
                        } else {
                            TUSDK.showGDPRConsentDialog(activity, listener);
                        }
                    }
                });
                break;

            case "showGDPRConsentSecondDialog":
                final String secondAppId = methodCall.argument(Const.Init.APP_ID);
                MsgTools.printMsg("showGDPRConsentSecondDialog: appId=" + secondAppId);

                FlutterPluginUtil.runOnUiThread(new Runnable() {
                    @Override
                    public void run() {
                        Activity activity = FlutterPluginUtil.getActivity();
                        if (!FlutterPluginUtil.isActivityUsable(activity)) {
                            MsgTools.printMsg("showGDPRConsentSecondDialog: activity invalid, abort");
                            Map<String, Object> dismissMap = new HashMap<>(4);
                            dismissMap.put("infoMsg", "activity is null!");
                            dismissMap.put("dismissType", -1);
                            TUFlutterEventManager.getInstance().sendMsgToFlutter(
                                    Const.CallbackMethodCall.InitCallName,
                                    Const.InitCallback.consentDismissCallbackKey,
                                    dismissMap);
                            try {
                                result.success(dismissMap);
                            } catch (Throwable ignored) {
                            }
                            return;
                        }
                        TUGDPRConsentDismissListener listener = new TUGDPRConsentDismissListener() {
                            @Override
                            public void onDismiss(ConsentDismissInfo consentDismissInfo) {
                                MsgTools.printMsg("showGDPRConsentSecondDialog: onDismiss: " + consentDismissInfo);
                                final Map<String, Object> dismissMap = consentDismissToMap(consentDismissInfo);
                                TUFlutterEventManager.getInstance().sendMsgToFlutter(
                                        Const.CallbackMethodCall.InitCallName,
                                        Const.InitCallback.consentDismissCallbackKey,
                                        dismissMap);
                                try {
                                    result.success(dismissMap);
                                } catch (Throwable ignored) {
                                }
                            }
                        };
                        if (secondAppId != null && secondAppId.length() > 0) {
                            TUSDK.showGDPRConsentSecondDialog(activity, listener, secondAppId);
                        } else {
                            TUSDK.showGDPRConsentSecondDialog(activity, listener, "");
                        }
                    }
                });
                break;

            case "checkIsEuTraffic":
                final String euAppId = methodCall.argument(Const.Init.APP_ID);
                MsgTools.printMsg("checkIsEuTraffic: appId=" + euAppId);
                TUSDK.checkIsEuTraffic(FlutterPluginUtil.getApplicationContext(), new NetTrafficeCallback() {
                    @Override
                    public void onResultCallback(boolean b) {
                        MsgTools.printMsg("checkIsEuTraffic: onResultCallback: " + b);
                        try {
                            result.success(b);
                        } catch (Throwable ignored) {
                        }
                    }

                    @Override
                    public void onErrorCallback(String s) {
                        MsgTools.printMsg("checkIsEuTraffic: onErrorCallback: " + s);
                        try {
                            result.success(false);
                        } catch (Throwable ignored) {
                        }
                    }
                }, euAppId);
                break;

            case "setPresetPlacementConfigPath":
                String path = methodCall.argument(Const.Init.PTUH_STR);

                MsgTools.printMsg("setPresetPlacementConfigPath: " + path);
                TUSDK.setLocalStrategyAssetPath(FlutterPluginUtil.getApplicationContext(), path);
                break;

            case "getSDKVersionName":
                try {
                    String v = TUSDK.getSDKVersionName();
                    result.success(v);
                } catch (Throwable e) {
                    result.success("");
                }
                break;

            case "start":
                try {
                    TUSDK.start();
                    result.success("");
                } catch (Throwable e) {
                    result.success("");
                }
                break;

            case "putFilter": {
                String placementId = methodCall.argument(Const.PLACEMENT_ID);
                Map<String, Object> filterSpec = methodCall.argument(Const.EXTRA_DIC);
                MsgTools.printMsg("putFilter: placementId=" + placementId + ", spec=" + (filterSpec != null ? filterSpec.toString() : ""));
                try {
                    if (!TextUtils.isEmpty(placementId) && filterSpec != null) {
                        String json = Utils.flutterMapToJsonString(filterSpec);
                        TUWaterfallFilter filter = BridgeJsonMapUtil.waterfallFilterFromGroupsJson(json);
                        if (filter != null) {
                            TUSDK.putFilter(placementId, filter);
                        }
                    }
                } catch (Throwable t) {
                    MsgTools.printMsg("putFilter error: " + t.getMessage());
                }
                result.success("");
                break;
            }

            case "removeFilterWithPlacementId": {
                String placementId = methodCall.argument(Const.PLACEMENT_ID);
                MsgTools.printMsg("removeFilterWithPlacementId: placementId=" + placementId);
                try {
                    TUSDK.removeFilterWithPlacementId(placementId);
                } catch (Throwable ignored) {
                }
                result.success("");
                break;
            }

            case "removeFilters":
                MsgTools.printMsg("removeFilters");
                try {
                    TUSDK.removeFilters();
                } catch (Throwable ignored) {
                }
                result.success("");
                break;

            case "setSharedPlacementConfig": {
                Map<String, Object> cfg = methodCall.argument(Const.EXTRA_DIC);
                MsgTools.printMsg("setSharedPlacementConfig: " + (cfg != null ? cfg.toString() : ""));
                try {
                    if (cfg != null) {
                        String json = Utils.flutterMapToJsonString(cfg);
                        TUSharedPlacementConfig config = BridgeJsonMapUtil.sharedPlacementConfigFromJson(json);
                        if (config != null) {
                            TUSDK.setSharedPlacementConfig(config);
                        }
                    }
                } catch (Throwable t) {
                    MsgTools.printMsg("setSharedPlacementConfig error: " + t.getMessage());
                }
                result.success("");
                break;
            }

            case "setAdSourcePrivacyPolicy": {
                String policyJson = methodCall.argument(Const.Init.POLICY_JSON);
                MsgTools.printMsg("setAdSourcePrivacyPolicy: "
                        + (policyJson == null ? "null" : ("len=" + policyJson.length())));
                if (TextUtils.isEmpty(policyJson)) {
                    AdSourcePrivacyPolicyStore.setPolicyJson(null);
                } else {
                    AdSourcePrivacyPolicyStore.setPolicyJson(policyJson);
                }
                result.success("");
                break;
            }

            case "showDebuggerUI":
                String debugKey = methodCall.argument(Const.DEBUGKEY);
                try {
                    TUDebuggerUITest.showDebuggerUI(FlutterPluginUtil.getApplicationContext(), debugKey);
                } catch (Error e) {
                    MsgTools.printMsg("showDebuggerUI: " + e.toString());
                }
                break;

        }
        return true;
    }
}
