package com.dexterous.flutterlocalnotifications;

import android.content.Context;
import android.content.SharedPreferences;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.google.gson.Gson;
import com.google.gson.reflect.TypeToken;

import java.lang.reflect.Type;

public class FlutterForePlugin {
    public static void saveNotificationDetails(Context context, NotificationDetails details) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        SharedPreferences.Editor editor = sharedPreferences.edit();
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        editor.putString("foreNotificationDetails", gson.toJson(details));
        editor.apply();
    }

    public static NotificationDetails extractNotificationDetails(Context context) {
        SharedPreferences sharedPreferences = context.getSharedPreferences(FlutterLocalNotificationsPlugin.SHARED_PREFERENCES_KEY, Context.MODE_PRIVATE);
        String detailsJson = sharedPreferences.getString("foreNotificationDetails", "");
        Gson gson = FlutterLocalNotificationsPlugin.buildGson();
        Type type = new TypeToken<NotificationDetails>() {
        }.getType();
        return gson.fromJson(detailsJson, type);
    }
}
