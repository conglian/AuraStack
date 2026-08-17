package com.dexterous.flutterlocalnotifications.broadcast;

import android.annotation.SuppressLint;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;

import androidx.core.app.NotificationManagerCompat;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;

import java.util.HashMap;
import java.util.Map;

public class BroadcastNotificationReceiver extends BroadcastReceiver {
    private static final Map<String, BroadcastNotificationReceiver> sInstances = new HashMap<>();

    public static void add(Context context, String broadcast) {
        if (sInstances.containsKey(broadcast)) return;
        BroadcastNotificationReceiver receiver = new BroadcastNotificationReceiver();
        receiver.broadcast = broadcast;
        IntentFilter intentFilter = new IntentFilter();
        intentFilter.addAction(broadcast);
        context.registerReceiver(receiver, intentFilter);
        sInstances.put(broadcast, receiver);
    }

    public static void removeAll(Context context) {
        sInstances.values().forEach(context::unregisterReceiver);
        sInstances.clear();
    }

    public String broadcast;

    @SuppressLint("UnsafeProtectedBroadcastReceiver")
    @Override
    public void onReceive(Context context, Intent intent) {
        final String broadcast = this.broadcast;
        if (StringUtils.isNullOrEmpty(broadcast)) return;
        if (!broadcast.equals(intent.getAction())) return;
        if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return;
        final NotificationDetails notificationDetails = FlutterBroadcastNotificationPlugin.extractNotificationDetails(context, broadcast);
        if (notificationDetails == null) return;
        final int interval = FlutterBroadcastNotificationPlugin.extractInterval(context, broadcast);
        final long when = FlutterBroadcastNotificationPlugin.extractWhen(context, broadcast);
        if (when >= 0 && (System.currentTimeMillis() - when) <= interval * 1000L) return;
        FlutterBroadcastNotificationPlugin.saveWhen(context, System.currentTimeMillis(), broadcast);
        FlutterLocalNotificationsPlugin.showNotification(context, notificationDetails);
    }
}
