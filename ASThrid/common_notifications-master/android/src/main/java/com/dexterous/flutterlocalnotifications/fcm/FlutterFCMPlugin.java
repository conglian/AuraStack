package com.dexterous.flutterlocalnotifications.fcm;

import android.content.Context;
import android.content.SharedPreferences;

import androidx.annotation.NonNull;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;

public class FlutterFCMPlugin {

    public static void setMessageReceivedNum(final Context context, @NonNull final String payload, int num) {
        if (context == null) return;
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        editor.putInt("message_received_num" + payload, num);
        editor.apply();
    }

    public static int getMessageReceivedNum(final Context context, @NonNull final String payload) {
        if (context == null) return 0;
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        return sharedPreferences.getInt("message_received_num" + payload, 0);
    }

    public static void saveNotificationDetails(Context context, NotificationDetails details) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        editor.putString("fcmNotificationDetails", gson.toJson(details));
        editor.apply();
    }

    public static NotificationDetails extractNotificationDetails(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        String detailsJson = sharedPreferences.getString("fcmNotificationDetails", "");
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        Type type = new TypeToken<NotificationDetails>() {
        }.getType();
        return gson.fromJson(detailsJson, type);
    }
}
