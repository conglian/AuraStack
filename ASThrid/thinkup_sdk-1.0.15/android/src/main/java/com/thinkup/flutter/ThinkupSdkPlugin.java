package com.thinkup.flutter;

import androidx.annotation.NonNull;

import com.thinkup.flutter.utils.FlutterPluginUtil;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;

/**
 * Ad SDK Flutter plugin — entry point for Flutter ↔ Native MethodChannel communication.
 * <p>
 * <b>Background</b><br>
 * {@link TUFlutterEventManager} is a process-wide singleton: only one {@code thinkup_sdk} channel exists.
 * In production, an app may host more than one {@link io.flutter.embedding.engine.FlutterEngine}
 * (e.g. system recycles engines after long background, or Firebase {@code onBackgroundMessage}
 * starts a headless engine). All plugin instances share the same channel manager.
 * <p>
 * <b>Issue 1 — channel cleared after long background (v1.0.12)</b><br>
 * When any engine called {@code onDetachedFromEngine}, the old code released the global channel.
 * If a secondary engine was destroyed while the main UI engine was still alive, the UI lost its
 * channel; returning to foreground caused Dart calls to fail until the process restarted.
 * <br>Fix: {@link #onDetachedFromEngine} calls {@link TUFlutterEventManager#releaseForMessenger}
 * so only the detaching engine's messenger is released. {@link #onAttachedToActivity} and
 * {@link #onReattachedToActivityForConfigChanges} call {@link #ensureMethodChannelIfNeeded} to
 * re-bind when the channel was cleared but the main engine is still attached.
 * <p>
 * <b>Issue 2 — background engine steals channel (Firebase multi-engine)</b><br>
 * {@code FirebaseMessaging.onBackgroundMessage} registers a second engine without Activity.
 * The old code called {@link TUFlutterEventManager#init} in {@link #onAttachedToEngine} for every
 * engine, so the headless engine bound the singleton channel first; the UI isolate then got
 * {@code MissingPluginException}. {@link TUFlutterEventManager#isChannelAvailable} stayed true
 * while the handler lived on the wrong messenger, so the recovery logic in Issue 1 did not run.
 * <br>Fix: do not init channel or PlatformView in {@link #onAttachedToEngine} — only save
 * {@link #pluginBinding}. Init runs in {@link #onAttachedToActivity} (main UI engine only).
 * {@link #ensureMethodChannelIfNeeded} uses {@link TUFlutterEventManager#isBoundTo} to detect
 * wrong-messenger binding and re-init on the UI engine.
 */
public class ThinkupSdkPlugin implements FlutterPlugin, ActivityAware {

    private FlutterPlugin.FlutterPluginBinding pluginBinding;
    private boolean platformViewRegistered;

    @Override
    public void onAttachedToEngine(@NonNull FlutterPlugin.FlutterPluginBinding flutterPluginBinding) {
        this.pluginBinding = flutterPluginBinding;
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPlugin.FlutterPluginBinding binding) {
        TUFlutterEventManager.getInstance().releaseForMessenger(binding.getBinaryMessenger());
        this.pluginBinding = null;
        this.platformViewRegistered = false;
    }

    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding activityPluginBinding) {
        FlutterPluginUtil.setActivity(activityPluginBinding.getActivity());
        ensureMethodChannelIfNeeded();
        ensurePlatformViewIfNeeded();
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {

    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding activityPluginBinding) {
        FlutterPluginUtil.setActivity(activityPluginBinding.getActivity());
        ensureMethodChannelIfNeeded();
        ensurePlatformViewIfNeeded();
    }

    @Override
    public void onDetachedFromActivity() {

    }

    /**
     * Restore or correct channel binding for this plugin instance's engine.
     * <ul>
     *   <li>Channel null after detach / long background → call {@link TUFlutterEventManager#init}</li>
     *   <li>Channel bound to another engine's messenger → re-init on this engine</li>
     *   <li>Already bound to this messenger → no-op</li>
     * </ul>
     */
    private void ensureMethodChannelIfNeeded() {
        if (pluginBinding == null) {
            return;
        }
        final io.flutter.plugin.common.BinaryMessenger messenger = pluginBinding.getBinaryMessenger();
        if (TUFlutterEventManager.getInstance().isBoundTo(messenger)) {
            return;
        }
        TUFlutterEventManager.getInstance().init(messenger);
    }

    /**
     * Register Banner {@link io.flutter.plugin.platform.PlatformView} factory on the UI engine only.
     * <p>
     * Same rationale as {@link #ensureMethodChannelIfNeeded}: {@link TUPlatformViewManager#init}
     * must not run in {@link #onAttachedToEngine}, or a headless engine (e.g. Firebase background
     * handler) would register the view factory on the wrong engine and Banner ads would not render
     * on the main isolate.
     * <p>
     * {@link #platformViewRegistered} avoids calling {@code registerViewFactory} twice on the same
     * engine when {@link #onReattachedToActivityForConfigChanges} fires; it is reset in
     * {@link #onDetachedFromEngine} so a later engine attach can register again.
     */
    private void ensurePlatformViewIfNeeded() {
        if (pluginBinding == null || platformViewRegistered) {
            return;
        }
        TUPlatformViewManager.getInstance().init(pluginBinding);
        platformViewRegistered = true;
    }
}
