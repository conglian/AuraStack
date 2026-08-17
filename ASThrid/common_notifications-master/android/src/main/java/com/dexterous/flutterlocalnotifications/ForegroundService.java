package com.dexterous.flutterlocalnotifications;

import android.app.Service;
import android.content.Intent;
import android.os.IBinder;
import android.util.Log;

import com.dexterous.flutterlocalnotifications.models.NotificationDetails;

public class ForegroundService extends Service {
    static boolean alive = false;

    @Override
    public void onCreate() {
        super.onCreate();
        alive = true;
    }

    @Override
    public void onDestroy() {
        super.onDestroy();
        alive = false;
    }

    @Override
    public int onStartCommand(Intent intent, int flags, int startId) {
        final NotificationDetails notificationData = FlutterForePlugin.extractNotificationDetails(getApplicationContext());
        FlutterLocalNotificationsPlugin.createNotification(
                getApplicationContext(), notificationData, notification -> {
                    try {
                        startForeground(notificationData.id, notification);
                    } catch (Throwable e) {
                        Log.e("ForegroundService", "startForeground ex", e);
                        stopSelf();
                    }
                });
        return super.onStartCommand(intent, flags, startId);
    }

    @Override
    public IBinder onBind(Intent intent) {
        return null;
    }
}
