package com.dexterous.flutterlocalnotifications.broadcast;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.Nullable;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;
import java.util.Objects;

public class FlutterBroadcastNotificationPlugin {
    public static void saveNotificationDetails(Context context, NotificationDetails details, String broadcast) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        editor.putString("broadcastNotificationDetails" + Objects.hashCode(broadcast), gson.toJson(details));
        editor.apply();
    }

    @Nullable
    public static NotificationDetails extractNotificationDetails(Context context, String broadcast) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        String detailsJson = sharedPreferences.getString("broadcastNotificationDetails" + Objects.hashCode(broadcast), "");
        if (StringUtils.isNullOrEmpty(detailsJson)) return null;
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        Type type = new TypeToken<NotificationDetails>() {
        }.getType();
        return gson.fromJson(detailsJson, type);
    }

    public static void saveInterval(Context context, int interval, String broadcast) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt("broadcastNotificationInterval" + Objects.hashCode(broadcast), interval);
        editor.apply();
    }

    public static int extractInterval(Context context, String broadcast) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        return sharedPreferences.getInt("broadcastNotificationInterval" + Objects.hashCode(broadcast), -1);
    }

    public static void saveWhen(Context context, long when, String broadcast) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putLong("broadcastNotificationWhen" + Objects.hashCode(broadcast), when);
        editor.apply();
    }

    public static long extractWhen(Context context, String broadcast) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        return sharedPreferences.getLong("broadcastNotificationWhen" + Objects.hashCode(broadcast), -1L);
    }
}
