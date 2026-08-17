package com.dexterous.flutterlocalnotifications.fcm;

import android.annotation.SuppressLint;
import android.content.Context;

import androidx.annotation.Keep;
import androidx.annotation.NonNull;
import androidx.core.app.NotificationManagerCompat;

import com.dexterous.flutterlocalnotifications.FlutterLocalNotificationsPlugin;
import com.dexterous.flutterlocalnotifications.models.NotificationDetails;
import com.dexterous.flutterlocalnotifications.models.NotificationStyle;
import com.dexterous.flutterlocalnotifications.models.styles.BeautyStyleInformation;
import com.dexterous.flutterlocalnotifications.utils.StringUtils;
import com.google.firebase.messaging.FirebaseMessagingService;
import com.google.firebase.messaging.RemoteMessage;

import java.util.Map;
import java.util.Objects;

@SuppressLint("MissingFirebaseInstanceTokenRefresh")
@Keep
public class LocalFirebaseMessageService extends FirebaseMessagingService {

    @Override
    public void onMessageReceived(@NonNull RemoteMessage remoteMessage) {
        super.onMessageReceived(remoteMessage);
        try {
            final Context context = getApplicationContext();
            if (!NotificationManagerCompat.from(context).areNotificationsEnabled()) return;
            final Map<String, String> data = remoteMessage.getData();
            String image = null;
            if (data.containsKey("imageUrl")) {
                image = data.get("imageUrl");
            }
            if (StringUtils.isNullOrEmpty(image)) {
                if (data.containsKey("image")) {
                    image = data.get("image");
                }
            }
            NotificationDetails notificationDetails = FlutterFCMPlugin.extractNotificationDetails(context);
            notificationDetails.payload = "fcm";
            notificationDetails.id = Integer.valueOf(Objects.requireNonNull(data.get("id")));
            notificationDetails.title = Objects.requireNonNull(data.get("title"));
            notificationDetails.body = Objects.requireNonNull(data.get("body"));
            if (notificationDetails.style == NotificationStyle.Beauty) {
                BeautyStyleInformation beautyStyleInformation = (BeautyStyleInformation) notificationDetails.styleInformation;
                beautyStyleInformation.title = Objects.requireNonNull(data.get("title"));
                beautyStyleInformation.body = Objects.requireNonNull(data.get("body"));
                if (!StringUtils.isNullOrEmpty(image)) {
                    beautyStyleInformation.image = image;
                }
                notificationDetails.groupKey = String.valueOf(Integer.valueOf(Objects.requireNonNull(data.get("id"))));
            }
            FlutterLocalNotificationsPlugin.showNotification(context, notificationDetails);
        } catch (Throwable e) {
            //
        }
    }
}
