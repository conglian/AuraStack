package com.thinkup.flutter;

import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.thinkup.core.api.AdError;
import com.thinkup.core.api.TUAdInfo;
import com.thinkup.flutter.banner.TUAdBannerManger;
import com.thinkup.flutter.init.TUAdInitManger;
import com.thinkup.flutter.interstitial.TUAdInterstitialManger;
import com.thinkup.flutter.nativead.TUAdNativeManger;
import com.thinkup.flutter.reward.TUAdRewardVideoManger;
import com.thinkup.flutter.splash.TUAdSplashManger;
import com.thinkup.flutter.utils.Const;
import com.thinkup.flutter.utils.FlutterPluginUtil;
import com.thinkup.flutter.utils.MsgTools;
import com.thinkup.flutter.utils.Utils;

import java.util.HashMap;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ThreadFactory;

import io.flutter.Log;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

/**
 * Singleton manager for the {@code thinkup_sdk} {@link MethodChannel}.
 * <p>
 * <b>Why a singleton</b><br>
 * Native ad helpers invoke Flutter callbacks through one shared channel. The plugin design keeps
 * a single {@link #mMethodChannel} per process rather than a map per engine.
 * <p>
 * <b>Issue 1 — detach must not break the UI engine (v1.0.12)</b><br>
 * Multiple engines can attach/detach independently. A global {@link #release()} on any detach
 * cleared the channel even when the main UI engine was still running.
 * <br>Fix: {@link #releaseForMessenger} releases only when the detaching messenger matches
 * {@link #mBinaryMessenger}. Paired with {@link ThinkupSdkPlugin#ensureMethodChannelIfNeeded}
 * on Activity re-attach to restore a null channel.
 * <p>
 * <b>Issue 2 — channel can exist on the wrong engine (Firebase)</b><br>
 * A headless engine could call {@link #init} and move {@link #mBinaryMessenger} off the UI engine.
 * {@link #isChannelAvailable} still returned true, so recovery never ran.
 * <br>Fix: {@link #isBoundTo} checks messenger identity; {@link ThinkupSdkPlugin} defers
 * {@link #init} until Activity attach so headless engines never register the handler.
 */
public class TUFlutterEventManager {

    private static TUFlutterEventManager sInstance;

    private volatile MethodChannel mMethodChannel;
    private volatile BinaryMessenger mBinaryMessenger;

    private final ExecutorService singleExecutorService;

    private TUFlutterEventManager() {
        singleExecutorService = Executors.newSingleThreadExecutor(new ThreadFactory() {
            @Override
            public Thread newThread(Runnable r) {
                Thread thread = Executors.defaultThreadFactory().newThread(r);
                thread.setName("tu_flutter_work");
                return thread;
            }
        });
    }

    public synchronized static TUFlutterEventManager getInstance() {
        if (sInstance == null) {
            sInstance = new TUFlutterEventManager();
        }
        return sInstance;
    }

    /**
     * Register {@code thinkup_sdk} on {@code binaryMessenger}. Switches handler if messenger changes.
     * Must be called from the UI engine only — {@link ThinkupSdkPlugin} enforces this via Activity attach.
     */
    public void init(BinaryMessenger binaryMessenger) {
        if (binaryMessenger == null) {
            return;
        }
        if (mMethodChannel != null && mBinaryMessenger == binaryMessenger) {
            return;
        }
        if (mMethodChannel != null) {
            mMethodChannel.setMethodCallHandler(null);
        }

        mBinaryMessenger = binaryMessenger;
        mMethodChannel = new MethodChannel(binaryMessenger, "thinkup_sdk");
        mMethodChannel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall methodCall, @NonNull MethodChannel.Result result) {
                try {
                    if (Utils.checkMethodInArray(Const.initMethodNames, methodCall.method)) {
                        TUAdInitManger.getInstance().handleMethodCall(methodCall, result);
                    } else if (Utils.checkMethodInArray(Const.rewardVideoMethodNames, methodCall.method)) {
                        TUAdRewardVideoManger.getInstance().handleMethodCall(methodCall, result);
                    } else if (Utils.checkMethodInArray(Const.interstitialMethodNames, methodCall.method)) {
                        TUAdInterstitialManger.getInstance().handleMethodCall(methodCall, result);
                    } else if (Utils.checkMethodInArray(Const.bannerMethodNames, methodCall.method)) {
                        TUAdBannerManger.getInstance().handleMethodCall(methodCall, result);
                    } else if (Utils.checkMethodInArray(Const.nativeMethodNames, methodCall.method)) {
                        TUAdNativeManger.getInstance().handleMethodCall(methodCall, result);
                    } else if (Utils.checkMethodInArray(Const.splashMethodNames, methodCall.method)) {
                        TUAdSplashManger.getInstance().handleMethodCall(methodCall, result);
                    }

                } catch (Throwable e) {
                    MsgTools.printMsg("method call error: " + methodCall + ", " + e.getMessage());
                    e.printStackTrace();
                }
            }
        });
    }

    /**
     * Whether a channel object exists. Not sufficient for readiness checks: after Issue 2 the
     * channel may be registered on a background engine while the UI engine has no handler.
     */
    public boolean isChannelAvailable() {
        return mMethodChannel != null;
    }

    /**
     * Whether the channel handler is registered on {@code messenger}. Used by
     * {@link ThinkupSdkPlugin#ensureMethodChannelIfNeeded} instead of {@link #isChannelAvailable}.
     */
    public boolean isBoundTo(@Nullable BinaryMessenger messenger) {
        return mMethodChannel != null && mBinaryMessenger == messenger;
    }

    public void sendDownloadMsgToFlutter(final String callName, String callbackName, String placementId, String atAdInfoString,
                                         long totalBytes, long currBytes, String fileName, String appName) {

        try {
            final Map<String, Object> paramsMap = new HashMap<>(10);
            paramsMap.put("callbackName", callbackName);
            paramsMap.put("placementID", placementId);

            if (atAdInfoString != null) {
                paramsMap.put("extraDic", Utils.jsonStrToMap(atAdInfoString));
            }

            if (totalBytes > 0) {
                paramsMap.put("totalBytes", totalBytes);
            }
            if (currBytes > 0) {
                paramsMap.put("currBytes", currBytes);
            }
            if (fileName != null) {
                paramsMap.put("fileName", fileName);
            }
            if (appName != null) {
                paramsMap.put("appName", appName);
            }

            FlutterPluginUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (mMethodChannel != null) {
                            mMethodChannel.invokeMethod(callName, paramsMap);
                        }
                    } catch (Throwable e) {
                        Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter invokeMethod error: " + callName + ", " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            });

        } catch (Throwable e) {
            Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter error: " + callbackName + ", " + e.getMessage());
            e.printStackTrace();
        }
    }


    public void sendCallbackMsgToFlutter(final String callName, String callbackName, String placementId, Object infoObj, String errorMsg, Map<String, Object> extra) {

        try {
            final Map<String, Object> paramsMap = new HashMap<>(8);
            paramsMap.put(Const.CallbackKey.callbackName, callbackName);
            paramsMap.put(Const.CallbackKey.placementID, placementId);

            if (infoObj instanceof String) {
                paramsMap.put(Const.CallbackKey.extraDic, Utils.jsonStrToMap(((String) infoObj)));
            } else if (infoObj instanceof Map) {
                paramsMap.put(Const.CallbackKey.extraDic, infoObj);
            }

            if (errorMsg != null) {
                paramsMap.put(Const.CallbackKey.requestMessage, errorMsg);
            } else {
                paramsMap.put(Const.CallbackKey.requestMessage, "");
            }

            try {
                if (extra != null) {
                    Set<Map.Entry<String, Object>> entries = extra.entrySet();
                    for (Map.Entry<String, Object> entry : entries) {
                        String key = entry.getKey();
                        Object value = entry.getValue();

                        if (value instanceof Boolean) {
                            if (TextUtils.equals(key, Const.CallbackKey.isDeeplinkSuccess) || TextUtils.equals(key, Const.CallbackKey.isTimeout)) {
                                paramsMap.put(key, ((Boolean) value));
                            }
                        }
                    }
                }
            } catch (Throwable e) {
                e.printStackTrace();
            }

            FlutterPluginUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (mMethodChannel != null) {
                            mMethodChannel.invokeMethod(callName, paramsMap);
                        }
                    } catch (Throwable e) {
                        Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter invokeMethod error: " + callName + ", " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            });

        } catch (Throwable e) {
            Log.e(MsgTools.TAG, "sendCallbackMsgToFlutter error: " + callbackName + ", " + e.getMessage());
            e.printStackTrace();
        }
    }


    /**
     * send message to flutter
     */
    public void sendCallbackMsgToFlutter(String callName, String callbackName, String placementId, String atAdInfoString, String errorMsg) {
        this.sendCallbackMsgToFlutter(callName, callbackName, placementId, atAdInfoString, errorMsg, null);
    }
    public void sendCallbackToFlutter(String callName, String callbackName, String placementId, Map<String, Object> infoMap, String errorMsg) {
        this.sendCallbackMsgToFlutter(callName, callbackName, placementId, infoMap, errorMsg, null);
    }

    public void sendAdSourceCallbackMsgToFlutter(String callName, String callbackName, String placementId, TUAdInfo adInfo, AdError adError) {
        if (singleExecutorService != null) {
            singleExecutorService.execute(new Runnable() {
                @Override
                public void run() {
                    sendCallbackMsgToFlutter(callName, callbackName, placementId, adInfo != null ? adInfo.toString() : null,
                            adError != null ? adError.getFullErrorInfo() : null, null);
                }
            });
        }
    }


    /**
     * send message to flutter
     */
    public void sendMsgToFlutter(final String callName, String key, Object extra) {
        try {
            final Map<String, Object> paramsMap = new HashMap<>(4);
            paramsMap.put(key, extra);


            FlutterPluginUtil.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    try {
                        if (mMethodChannel != null) {
                            mMethodChannel.invokeMethod(callName, paramsMap);
                        }
                    } catch (Throwable e) {
                        Log.e(MsgTools.TAG, "sendMsgToFlutter invokeMethod error: " + key + ", " + e.getMessage());
                        e.printStackTrace();
                    }
                }
            });
        } catch (Throwable e) {
            Log.e(MsgTools.TAG, "sendMsgToFlutter error: " + key + ", " + e.getMessage());
            e.printStackTrace();
        }
    }

    public void release() {
        if (mMethodChannel != null) {
            mMethodChannel.setMethodCallHandler(null);
            mMethodChannel = null;
        }
        mBinaryMessenger = null;
    }

    /**
     * Release channel when an engine detaches. Only clears if {@code messenger} owns the current
     * binding — prevents Issue 1 where destroying a secondary engine broke the UI channel.
     */
    public void releaseForMessenger(@Nullable BinaryMessenger messenger) {
        if (messenger != null && mBinaryMessenger == messenger) {
            release();
        }
    }

}
