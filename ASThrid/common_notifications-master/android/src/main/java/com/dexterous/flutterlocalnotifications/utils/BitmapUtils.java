package com.dexterous.flutterlocalnotifications.utils;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.Canvas;
import android.graphics.PixelFormat;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.text.TextUtils;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.bumptech.glide.Glide;

public class BitmapUtils {
    public interface NetworkImageBuildListener {
        void complete(@Nullable Bitmap bitmap);
    }

    public static void createFromNetwork(@NonNull Context context, @NonNull String url, @NonNull NetworkImageBuildListener listener) {
        if (TextUtils.isEmpty(url)) {
            listener.complete(null);
            return;
        }
        new Thread(() -> {
            Bitmap bitmap = null;
            try {
                bitmap = Glide.with(context)
                        .asBitmap()
                        .skipMemoryCache(true)
                        .load(url)
                        .submit()
                        .get();
            } catch (Throwable e) {
                //
            } finally {
                listener.complete(bitmap);
            }
        }).start();
    }

    @Nullable
    public static Bitmap createFromResource(@NonNull Context context, int resId) {
        Drawable drawable = context.getDrawable(resId);
        if (drawable == null) return null;
        if (drawable instanceof BitmapDrawable) {
            BitmapDrawable bitmapDrawable = (BitmapDrawable) drawable;
            if (bitmapDrawable.getBitmap() != null) {
                return bitmapDrawable.getBitmap();
            }
        }
        Bitmap bitmap;
        if (drawable.getIntrinsicWidth() <= 0 || drawable.getIntrinsicHeight() <= 0) {
            bitmap = Bitmap.createBitmap(1, 1,
                    drawable.getOpacity() != PixelFormat.OPAQUE
                            ? Bitmap.Config.ARGB_8888
                            : Bitmap.Config.RGB_565);
        } else {
            bitmap = Bitmap.createBitmap(drawable.getIntrinsicWidth(),
                    drawable.getIntrinsicHeight(),
                    drawable.getOpacity() != PixelFormat.OPAQUE
                            ? Bitmap.Config.ARGB_8888
                            : Bitmap.Config.RGB_565);
        }
        Canvas canvas = new Canvas(bitmap);
        drawable.setBounds(0, 0, canvas.getWidth(), canvas.getHeight());
        drawable.draw(canvas);
        return bitmap;
    }
}
