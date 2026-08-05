package com.thinkup.flutter.splash;

import android.app.Activity;
import android.content.Context;
import android.graphics.Color;
import android.view.LayoutInflater;
import android.view.View;
import android.text.TextUtils;
import android.view.ViewGroup;
import android.view.ViewParent;
import android.widget.FrameLayout;

import com.thinkup.core.api.TUAdInfo;
import com.thinkup.core.api.TUAdMultipleLoadedListener;
import com.thinkup.core.api.TUAdSourceStatusListener;
import com.thinkup.core.api.TUAdStatusInfo;
import com.thinkup.core.api.TUNetworkConfirmInfo;
import com.thinkup.core.api.TURequestingInfo;
import com.thinkup.core.api.AdError;
import com.thinkup.core.api.TUShowConfig;
import com.thinkup.core.api.TUAdRequest;
import com.thinkup.flutter.TUFlutterEventManager;
import com.thinkup.flutter.utils.Const;
import com.thinkup.flutter.utils.FlutterPluginUtil;
import com.thinkup.flutter.utils.MsgTools;
import com.thinkup.flutter.commonlistener.AdRevenueListenerImpl;
import com.thinkup.flutter.utils.Utils;
import com.thinkup.flutter.utils.BridgeJsonMapUtil;
import com.thinkup.splashad.api.TUSplashAd;
import com.thinkup.splashad.api.TUSplashAdExtraInfo;
import com.thinkup.splashad.api.TUSplashExListener;

import org.json.JSONArray;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class TUSplashHelper {

    TUSplashAd mSplashAd;
    String mPlacementId;
    ViewGroup mDecorView;
    // Template path: decorView -> mRootContainer -> [mAdContainer (ad) + mBottomTemplateView (brand area)]
    FrameLayout mRootContainer;
    // Reused across shows. Parent differs by path: decorView (normal) vs mRootContainer (template).
    ViewGroup mAdContainer;
    View mBottomTemplateView;
    // Parsed at loadSplash(), consumed at showConfigSplash(). Show APIs do not pass bottom params.
    BottomTemplateConfig mBottomTemplateConfig;

    static class BottomTemplateConfig {
        String templateName;
        Double ratio;
        Double height;
    }

    private void initSplash(final String placementId, int fetchAdTimeout) {
        Activity activity = FlutterPluginUtil.getActivity();
        if (!FlutterPluginUtil.isActivityUsable(activity)) {
            MsgTools.printMsg("initSplash: activity invalid, placementId=" + placementId);
            return;
        }
        mPlacementId = placementId;
        TUSplashExListener splashExListener = new TUSplashExListener() {
            @Override
            public void onDeeplinkCallback(TUAdInfo atAdInfo, boolean isSuccess) {
                MsgTools.printMsg("splash onDeeplinkCallback: " + mPlacementId + ", isSuccess: " + isSuccess);

                Map<String, Object> extraMap = new HashMap<>();
                extraMap.put(Const.CallbackKey.isDeeplinkSuccess, isSuccess);

                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.DeeplinkCallbackKey,
                        mPlacementId, atAdInfo.toString(), null, extraMap);
            }

            @Override
            public void onDownloadConfirm(Context context, TUAdInfo atAdInfo, TUNetworkConfirmInfo atNetworkConfirmInfo) {
                MsgTools.printMsg("splash onDownloadConfirm: " + mPlacementId);
            }

            @Override
            public void onAdLoaded(boolean isTimeout) {
                MsgTools.printMsg("onAdLoaded: " + mPlacementId + ", isTimeout: " + isTimeout);

                Map<String, Object> extraMap = new HashMap<>();
                extraMap.put(Const.CallbackKey.isTimeout, isTimeout);

                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.LoadedCallbackKey,
                        mPlacementId, null, null, extraMap);
            }

            @Override
            public void onAdLoadTimeout() {
                MsgTools.printMsg("onAdLoadTimeout: " + mPlacementId);

                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.TimeoutCallbackKey,
                        mPlacementId, null, null);
            }

            @Override
            public void onNoAdError(AdError adError) {
                MsgTools.printMsg("onNoAdError: " + mPlacementId + ", " + adError.getFullErrorInfo());

                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.LoadFailCallbackKey,
                        mPlacementId, null, adError.getFullErrorInfo());
            }

            @Override
            public void onAdShow(TUAdInfo atAdInfo) {
                MsgTools.printMsg("onAdShow: " + mPlacementId);

                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.ShowCallbackKey,
                        mPlacementId, atAdInfo.toString(), null);
            }

            @Override
            public void onAdClick(TUAdInfo atAdInfo) {
                MsgTools.printMsg("onAdClick: " + mPlacementId);

                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.ClickCallbackKey,
                        mPlacementId, atAdInfo.toString(), null);
            }

            @Override
            public void onAdDismiss(TUAdInfo atAdInfo, TUSplashAdExtraInfo atSplashAdExtraInfo) {
                MsgTools.printMsg("onAdDismiss: " + mPlacementId);
                // Must remove BOTH hierarchies: template uses mRootContainer; normal/degraded uses
                // mAdContainer on decorView directly. Missing the latter left a ghost overlay and
                // broke skip / timeout dismiss for integrations without bottomTemplate.
                cleanupSplashViews();

                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.CloseCallbackKey,
                        mPlacementId, atAdInfo.toString(), null);
            }
        };

        if (fetchAdTimeout > 0) {
            mSplashAd = new TUSplashAd(activity, placementId, splashExListener, fetchAdTimeout);
        } else {
            mSplashAd = new TUSplashAd(activity, placementId, splashExListener);
        }
        try {
            mSplashAd.setAdRevenueListener(new AdRevenueListenerImpl(placementId));
        } catch (Throwable ignore) {
        }

        mSplashAd.setAdSourceStatusListener(new TUAdSourceStatusListener() {
            @Override
            public void onAdSourceBiddingAttempt(TUAdInfo adInfo) {
                MsgTools.printMsg("onAdSourceBiddingAttempt: " + mPlacementId + ", " + (adInfo != null ? adInfo.getAdsourceId() : ""));

                TUFlutterEventManager.getInstance().sendAdSourceCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.AdSourceBiddingAttemptCallbackKey,
                        mPlacementId, adInfo, null);
            }

            @Override
            public void onAdSourceBiddingFilled(TUAdInfo adInfo) {
                MsgTools.printMsg("onAdSourceBiddingFilled: " + mPlacementId + ", " + (adInfo != null ? adInfo.getAdsourceId() : ""));

                TUFlutterEventManager.getInstance().sendAdSourceCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.AdSourceBiddingFilledCallbackKey,
                        mPlacementId, adInfo, null);
            }

            @Override
            public void onAdSourceBiddingFail(TUAdInfo adInfo, AdError adError) {
                MsgTools.printMsg("onAdSourceBiddingFail: " + mPlacementId + ", " + (adInfo != null ? adInfo.getAdsourceId() : ""));

                TUFlutterEventManager.getInstance().sendAdSourceCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.AdSourceBiddingFailCallbackKey,
                        mPlacementId, adInfo, adError);
            }

            @Override
            public void onAdSourceAttempt(TUAdInfo adInfo) {
                MsgTools.printMsg("onAdSourceAttempt: " + mPlacementId + ", " + (adInfo != null ? adInfo.getAdsourceId() : ""));

                TUFlutterEventManager.getInstance().sendAdSourceCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.AdSourceAttemptCallbackKey,
                        mPlacementId, adInfo, null);
            }

            @Override
            public void onAdSourceLoadFilled(TUAdInfo adInfo) {
                MsgTools.printMsg("onAdSourceLoadFilled: " + mPlacementId + ", " + (adInfo != null ? adInfo.getAdsourceId() : ""));

                TUFlutterEventManager.getInstance().sendAdSourceCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.AdSourceLoadFilledCallbackKey,
                        mPlacementId, adInfo, null);
            }

            @Override
            public void onAdSourceLoadFail(TUAdInfo adInfo, AdError adError) {
                MsgTools.printMsg("onAdSourceLoadFail: " + mPlacementId + ", " + (adInfo != null ? adInfo.getAdsourceId() : ""));

                TUFlutterEventManager.getInstance().sendAdSourceCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.AdSourceLoadFailCallbackKey,
                        mPlacementId, adInfo, adError);
            }
        });

        mSplashAd.setAdMultipleLoadedListener(new TUAdMultipleLoadedListener() {
            @Override
            public void onAdMultipleLoaded(TURequestingInfo atRequestingInfo) {
                MsgTools.printMsg("onAdMultipleLoaded: " + mPlacementId);

                TUFlutterEventManager.getInstance().sendCallbackToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.MultipleLoadedCallbackKey,
                        mPlacementId, Utils.getRequestingInfo(atRequestingInfo), null);
            }
        });
        
        //download
//        try {
//            if (TUSDK.isCnSDK()) {
//                mSplashAd.setAdDownloadListener(new ATAppDownloadListener() {
//                    @Override
//                    public void onDownloadStart(TUAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadStart: " + mPlacementId + ", " + totalBytes + ", " + currBytes + ", " + fileName + ", " + appName);
//
//                        TUFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadStartKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadUpdate(TUAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadUpdate: " + mPlacementId);
//
//                        TUFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadUpdateKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadPause(TUAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadPause: " + mPlacementId);
//
//                        TUFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadPauseKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadFinish(TUAdInfo atAdInfo, long totalBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadFinish: " + mPlacementId + ", " + totalBytes  + ", " + fileName + ", " + appName);
//
//                        TUFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadFinishedKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, -1, fileName, appName);
//                    }
//
//                    @Override
//                    public void onDownloadFail(TUAdInfo atAdInfo, long totalBytes, long currBytes, String fileName, String appName) {
//                        MsgTools.printMsg("splash onDownloadFail: " + mPlacementId + ", " + totalBytes + ", " + currBytes + ", " + fileName + ", " + appName);
//
//                        TUFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadFailedKey,
//                                mPlacementId, atAdInfo.toString(), totalBytes, currBytes, fileName, appName);
//                    }
//
//                    @Override
//                    public void onInstalled(TUAdInfo atAdInfo, String fileName, String appName) {
//                        MsgTools.printMsg("splash onInstalled: " + mPlacementId + ", " + fileName + ", " + appName);
//
//                        TUFlutterEventManager.getInstance().sendDownloadMsgToFlutter(Const.CallbackMethodCall.DownloadCall, Const.DownloadCallCallback.DownloadInstalledKey,
//                                mPlacementId, atAdInfo.toString(), -1, -1, fileName, appName);
//                    }
//                });
//            }
//        } catch (Throwable e) {
//        }

    }

    public void loadSplash(final String placementId, final Map<String, Object> settings) {
        MsgTools.printMsg("loadSplash: " + placementId + ", settings: " + settings);

        // Cache bottom config here; show only reads mBottomTemplateConfig (not show-time extras).
        mBottomTemplateConfig = parseBottomTemplateConfig(settings);

        int fetchAdTimeout = -1;
        if (settings != null) {
            try {
                Object timeObj = settings.get(Const.Splash.tolerateTimeout);
                if (timeObj != null) {
                    fetchAdTimeout = Integer.parseInt(timeObj.toString());
                }
            } catch (Throwable e) {
//                e.printStackTrace();
            }
        }

        if (mSplashAd == null) {
            initSplash(placementId, fetchAdTimeout);
        }
        if (mSplashAd == null) {
            MsgTools.printMsg("loadSplash: mSplashAd null after init, placementId=" + placementId);
            return;
        }


        //todo
//        int adViewWidth;
//        int adViewHeight;
//        if (settings != null) {
//            try {
//                Map<String, Object> nativeAdSize = (Map<String, Object>) settings.get(Const.SIZE);
//
//                adViewWidth = Utils.dip2px(mActivity, (double) nativeAdSize.get(Const.WIDTH));
//                adViewHeight = Utils.dip2px(mActivity, (double) nativeAdSize.get(Const.HEIGHT));
//
//                MsgTools.printMsg("loadSplash: " + placementId + ", width: " + adViewWidth + ", height: " + adViewHeight);
//
//                settings.put(TUAdConst.KEY.AD_WIDTH, adViewWidth);
//                settings.put(TUAdConst.KEY.AD_HEIGHT, adViewHeight);
//            } catch (Throwable e) {
//                e.printStackTrace();
//            }
//        }

        mSplashAd.setLocalExtra(settings);
        TUAdRequest atAdRequest = null;
        try {
            atAdRequest = BridgeJsonMapUtil.atAdRequestFromLoadExtraDic(settings);
            if (settings != null && settings.containsKey("atAdRequest")) {
                settings.remove("atAdRequest");
            }
        } catch (Throwable ignore) {
        }
        if (atAdRequest != null) {
            mSplashAd.loadAd(atAdRequest);
        } else {
            mSplashAd.loadAd();
        }
    }

    public void showSplash(final String scenario) {
        MsgTools.printMsg("showSplash: " + mPlacementId + ", scenario: " + scenario);
        showConfigSplash(scenario, null, null);
    }

    public void showConfigSplash(final String scenario, final String showCustomExt, final Object atCustomContentResultArg) {
        MsgTools.printMsg("showConfigSplash: " + mPlacementId + ", scenario: " + scenario+ ", showCustomExt: " + showCustomExt);

        if (mSplashAd != null) {
            try {
                Activity activity = FlutterPluginUtil.getActivity();
                if (!FlutterPluginUtil.isActivityUsable(activity)) {
                    MsgTools.printMsg("showConfigSplash: activity invalid, skip show");
                    return;
                }

                mDecorView = activity.findViewById(android.R.id.content);

                // --- Normal splash (no bottomTemplate, or legacy integration) ---
                if (mBottomTemplateConfig == null) {
                    attachAdContainerForNormalSplash(activity);
                    TUShowConfig.Builder builder = new TUShowConfig.Builder();
                    builder.scenarioId(scenario);
                    builder.showCustomExt(showCustomExt);
                    BridgeJsonMapUtil.applyAtCustomContentToShowConfigBuilder(builder, atCustomContentResultArg);
                    mSplashAd.show(activity, mAdContainer, null, builder.build());
                    return;
                }

                ensureContainer(activity);
                int bottomHeightPx = resolveBottomHeightPx(activity, mBottomTemplateConfig);
                mBottomTemplateView = createBottomTemplateView(activity, mBottomTemplateConfig);
                boolean hasBottomTemplate = mBottomTemplateView != null && bottomHeightPx > 0;
                // Degrade when layout missing, inflate fails, or height invalid — no reserved bottom gap.
                if (!hasBottomTemplate) {
                    MsgTools.printMsg("splash bottom template degrade to normal splash: bottom view unavailable");
                    attachAdContainerForNormalSplash(activity);
                    TUShowConfig.Builder builder = new TUShowConfig.Builder();
                    builder.scenarioId(scenario);
                    builder.showCustomExt(showCustomExt);
                    BridgeJsonMapUtil.applyAtCustomContentToShowConfigBuilder(builder, atCustomContentResultArg);
                    mSplashAd.show(activity, mAdContainer, null, builder.build());
                    return;
                }

                // --- Template splash: ad area above, host layout pinned to bottom ---
                FrameLayout.LayoutParams adLayoutParams = new FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                );
                adLayoutParams.bottomMargin = bottomHeightPx;
                mAdContainer.setLayoutParams(adLayoutParams);
                mAdContainer.removeAllViews();

                mRootContainer.removeAllViews();
                // mAdContainer may still be on decorView from a prior normal show (or undismissed show).
                // Reparenting without detach causes: IllegalStateException: child already has a parent.
                detachViewFromParent(mAdContainer);
                mRootContainer.addView(mAdContainer);
                mRootContainer.setBackgroundColor(Color.WHITE);
                FrameLayout.LayoutParams bottomLayoutParams = new FrameLayout.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        bottomHeightPx
                );
                bottomLayoutParams.gravity = android.view.Gravity.BOTTOM;
                mRootContainer.addView(mBottomTemplateView, bottomLayoutParams);

                if (mDecorView != null) {
                    detachViewFromParent(mRootContainer);
                    mDecorView.addView(mRootContainer);
                }
                TUShowConfig.Builder builder = new TUShowConfig.Builder();
                builder.scenarioId(scenario);
                builder.showCustomExt(showCustomExt);
                BridgeJsonMapUtil.applyAtCustomContentToShowConfigBuilder(builder, atCustomContentResultArg);
                mSplashAd.show(activity, mAdContainer, null, builder.build());
            } catch (Exception e) {
                MsgTools.printMsg("Splash showAd failed: " + e.getMessage());
                TUFlutterEventManager.getInstance().sendCallbackMsgToFlutter(
                        Const.CallbackMethodCall.SplashCall, Const.SplashCallback.ShowFailedCallbackKey,
                        mPlacementId, null, e.getMessage());
            }
        }
    }

    /**
     * Full-screen splash: attach mAdContainer directly to decorView.
     * Resets layout params (clears stale bottomMargin from a previous template show) and removes
     * any leftover mRootContainer from a prior template show on the same helper instance.
     */
    private void attachAdContainerForNormalSplash(Activity activity) {
        mBottomTemplateView = null;
        if (mAdContainer == null) {
            mAdContainer = new FrameLayout(activity);
        }
        mAdContainer.setLayoutParams(new ViewGroup.LayoutParams(
                ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT
        ));
        mAdContainer.removeAllViews();
        if (mDecorView != null && mRootContainer != null) {
            detachViewFromParent(mRootContainer);
        }
        if (mDecorView != null) {
            detachViewFromParent(mAdContainer);
            mDecorView.addView(mAdContainer);
        }
    }

    /**
     * Tear down splash overlay views. Template and normal paths use different parent chains;
     * use detachViewFromParent (not decorView.removeView directly) so template dismiss does not
     * throw when mAdContainer sits under mRootContainer instead of decorView.
     */
    private void cleanupSplashViews() {
        mBottomTemplateView = null;
        if (mAdContainer != null) {
            mAdContainer.removeAllViews();
            detachViewFromParent(mAdContainer);
        }
        if (mRootContainer != null) {
            mRootContainer.removeAllViews();
            detachViewFromParent(mRootContainer);
        }
    }

    /** Safe reparent helper: mAdContainer is reused and may sit under decorView or mRootContainer. */
    private void detachViewFromParent(View view) {
        if (view == null) {
            return;
        }
        ViewParent parent = view.getParent();
        if (parent instanceof ViewGroup) {
            ((ViewGroup) parent).removeView(view);
        }
    }

    private void ensureContainer(Activity activity) {
        if (mRootContainer == null) {
            mRootContainer = new FrameLayout(activity);
            mRootContainer.setLayoutParams(new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
            ));
        }
        if (mAdContainer == null) {
            mAdContainer = new FrameLayout(activity);
            mAdContainer.setLayoutParams(new ViewGroup.LayoutParams(
                    ViewGroup.LayoutParams.MATCH_PARENT,
                    ViewGroup.LayoutParams.MATCH_PARENT
            ));
        }
    }

    private BottomTemplateConfig parseBottomTemplateConfig(Map<String, Object> settings) {
        if (settings == null) {
            return null;
        }
        Object templateObj = settings.get(Const.Splash.bottomTemplate);
        String templateName = templateObj != null ? String.valueOf(templateObj).trim() : "";
        if (TextUtils.isEmpty(templateName)) {
            MsgTools.printMsg("splash bottom template disabled: bottomTemplate empty");
            return null;
        }
        BottomTemplateConfig config = new BottomTemplateConfig();
        config.templateName = templateName;
        Object ratioObj = settings.get(Const.Splash.bottomRatio);
        if (ratioObj != null) {
            try {
                config.ratio = Double.parseDouble(String.valueOf(ratioObj));
            } catch (Throwable ignored) {
            }
        }
        Object heightObj = settings.get(Const.Splash.bottomHeight);
        if (heightObj != null) {
            try {
                config.height = Double.parseDouble(String.valueOf(heightObj));
            } catch (Throwable ignored) {
            }
        }
        return config;
    }

    private int resolveBottomHeightPx(Activity activity, BottomTemplateConfig config) {
        if (config == null) {
            return 0;
        }
        // bottomRatio takes priority over bottomHeight. Ratio uses decorView height when laid out,
        // else screen heightPixels (may differ slightly before first layout — acceptable).
        if (config.ratio != null && config.ratio > 0 && config.ratio < 1) {
            int baseHeight = 0;
            if (mDecorView != null && mDecorView.getHeight() > 0) {
                baseHeight = mDecorView.getHeight();
            }
            if (baseHeight <= 0) {
                baseHeight = activity.getResources().getDisplayMetrics().heightPixels;
            }
            int ratioHeight = (int) Math.round(baseHeight * config.ratio);
            MsgTools.printMsg("splash bottom height from ratio: " + config.ratio + " -> " + ratioHeight + "px");
            return Math.max(ratioHeight, 0);
        }
        if (config.height != null && config.height > 0) {
            int fixedHeight = Utils.dip2px(activity, config.height);
            MsgTools.printMsg("splash bottom height from bottomHeight: " + config.height + " -> " + fixedHeight + "px");
            return Math.max(fixedHeight, 0);
        }
        MsgTools.printMsg("splash bottom template exists but height invalid, degrade to normal splash");
        return 0;
    }

    /** Inflates host-app layout by name (res/layout/{templateName}.xml). Returns null on failure → degrade. */
    private View createBottomTemplateView(Activity activity, BottomTemplateConfig config) {
        if (config == null || TextUtils.isEmpty(config.templateName)) {
            return null;
        }
        int layoutId = activity.getResources().getIdentifier(config.templateName, "layout", activity.getPackageName());
        if (layoutId == 0) {
            MsgTools.printMsg("splash bottom template inflate failed: layout not found, template=" + config.templateName);
            return null;
        }
        try {
            View view = LayoutInflater.from(activity).inflate(layoutId, mRootContainer, false);
            MsgTools.printMsg("splash bottom template inflate success: " + config.templateName);
            return view;
        } catch (Throwable throwable) {
            MsgTools.printMsg("splash bottom template inflate failed: " + throwable.getMessage());
            return null;
        }
    }

    public boolean isAdReady() {
        MsgTools.printMsg("splash isAdReady: " + mPlacementId);

        boolean isReady = false;
        if (mSplashAd != null) {
            isReady = mSplashAd.isAdReady();
        }

        MsgTools.printMsg("splash isAdReady: " + mPlacementId + ", " + isReady);
        return isReady;
    }

    public Map<String, Object> checkAdStatus() {
        MsgTools.printMsg("splash checkAdStatus: " + mPlacementId);

        Map<String, Object> map = new HashMap<>(5);

        if (mSplashAd != null) {
            TUAdStatusInfo atAdStatusInfo = mSplashAd.checkAdStatus();
            boolean loading = atAdStatusInfo.isLoading();
            boolean ready = atAdStatusInfo.isReady();
            TUAdInfo atTopAdInfo = atAdStatusInfo.getTUTopAdInfo();

            map.put("isLoading", loading);
            map.put("isReady", ready);

            if (atTopAdInfo != null) {
                map.put("adInfo", atTopAdInfo.toString());
            }

            return map;
        }

        map.put("isLoading", false);
        map.put("isReady", false);

        return map;
    }

    public String checkValidAdCaches() {
        MsgTools.printMsg("splash checkValidAdCaches: " + mPlacementId);

        if (mSplashAd != null) {
            List<TUAdInfo> vaildAds = mSplashAd.checkValidAdCaches();
            if (vaildAds == null) {
                return "";
            }

            JSONArray jsonArray = new JSONArray();

            int size = vaildAds.size();
            for (int i = 0; i < size; i++) {
                try {
                    jsonArray.put(new JSONObject(vaildAds.get(i).toString()));
                } catch (Throwable e) {
                    e.printStackTrace();
                }
            }
            return jsonArray.toString();
        }
        return "";
    }

    public void entryScenario(final String placementId,final String sceneID) {
        MsgTools.printMsg("entrySplashScenario: " + mPlacementId + "sceneID: " + sceneID);
        TUSplashAd.entryAdScenario(placementId, sceneID);
    }
}
