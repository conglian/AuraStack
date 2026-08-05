package com.example.AuraStack;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.pm.PackageManager;
import android.os.Build;
import android.provider.Settings;
import android.telephony.TelephonyManager;

import java.io.File;
import java.io.FileInputStream;
import java.lang.reflect.Field;
import java.net.NetworkInterface;
import java.util.Arrays;
import java.util.Collections;
import java.util.Enumeration;

//TODO:修改类名、修改所有的函数名
public class BoRiskUtils {

    public static boolean isEmulator() {
        String model = Build.MODEL;
        String product = Build.PRODUCT;
        String hardware = Build.HARDWARE;
        String device = Build.DEVICE;
        String brand = Build.BRAND;
        String board = Build.BOARD;
        String manufacture = Build.MANUFACTURER;

        if (model.contains("sdk_gphone") || model.contains("google_sdk") ||
                model.toLowerCase().contains("droid4x") ||
                model.contains("Emulator") ||
                model.contains("Android SDK built for x86") ||
                model.startsWith("iToolsAVM") ||
                manufacture.contains("Genymotion") ||
                manufacture.startsWith("iToolsAVM") ||
                hardware.equals("goldfish") ||
                hardware.equals("vbox86") ||
                hardware.toLowerCase().contains("nox") ||
                hardware.startsWith("vbox86") ||
                product.equals("sdk") ||
                product.startsWith("google_sdk") ||
                product.equals("sdk_x86") ||
                product.equals("vbox86p") ||
                product.toLowerCase().contains("nox") ||
                brand.startsWith("generic") ||
                device.startsWith("iToolsAVM") ||
                board.toLowerCase().contains("nox") ||
                Build.BOOTLOADER.toLowerCase().contains("nox") ||
                Build.SERIAL.toLowerCase().contains("nox") ||
                Build.HOST.contains("Droid4x-BuildStation")) {
            return true;
        }

        int risk = 0;
        if (Arrays.asList(
                "sdk_x86_64", "sdk_google_phone_x86", "sdk_google_phone_x86_64", "sdk_google_phone_arm64", "vbox86p"
        ).contains(product)) {
            ++risk;
        }
        if (manufacture.equals("unknown")) {
            ++risk;
        }
        if (Arrays.asList(
                "generic", "generic_arm64", "generic_x86", "generic_x86_64"
        ).contains(brand)) {
            ++risk;
        } else if (brand.equalsIgnoreCase("android")) {
            ++risk;
        }
        if (Arrays.asList(
                "generic", "generic_arm64", "generic_x86", "generic_x86_64", "vbox86p"
        ).contains(device)) {
            ++risk;
        }

        if (Arrays.asList(
                "sdk", "Android SDK built for arm64", "Android SDK built for armv7", "Android SDK built for x86", "Android SDK built for x86_64"
        ).contains(model)) {
            ++risk;
        }
        if (hardware.equals("ranchu")) {
            ++risk;
        }
        if (brand.startsWith("generic") && device.startsWith("generic")) {
            ++risk;
        }
        return risk >= 2;
    }

    public static boolean isEmulator2() {
        if (existFile(new String[]{"/dev/socket/genyd", "/dev/socket/baseband_genyd"}) ||
                existFile(new String[]{"fstab.andy", "ueventd.andy.rc"}) ||
                existFile(new String[]{"fstab.nox", "init.nox.rc", "ueventd.nox.rc"}) ||
                existFile(new String[]{"/dev/socket/qemud", "/dev/qemu_pipe"}) ||
                existFile(new String[]{"ueventd.android_x86.rc", "x86.prop", "ueventd.ttVM_x86.rc",
                        "init.ttVM_x86.rc", "fstab.ttVM_x86", "fstab.vbox86", "init.vbox86.rc", "ueventd.vbox86.rc"}
                )) {
            return true;
        }

        byte[] data;
        String[] blackString = new String[]{"goldfish"};
        File[] files = {new File("/proc/tty/drivers"), new File("/proc/cpuinfo")};
        for (File file : files) {
            if (file.exists() && file.canRead()) {
                try {
                    data = new byte[0x400];
                    FileInputStream fileInputStream0 = new FileInputStream(file);
                    int length = fileInputStream0.read(data);
                    fileInputStream0.close();
                    String s = new String(data);
                    for (String black : blackString) {
                        if (s.contains(black)) {
                            return true;
                        }
                    }
                } catch (Throwable ignore) {

                }
            }
        }
        return false;
    }

    public static boolean isDevModel(Context context) {
        try {
            return Settings.Secure.getInt(context.getContentResolver(), Settings.Global.DEVELOPMENT_SETTINGS_ENABLED, 0) != 0;
        } catch (Throwable ignore) {
        }
        return false;
    }

    public static boolean isDebug(Context context) {
        try {
            return Settings.Secure.getInt(context.getContentResolver(), Settings.Global.ADB_ENABLED, 0) != 0;
        } catch (Throwable ignore) {
        }
        return false;
    }

    public static boolean isXposed() {
        try {
            Field field0 = ClassLoader.getSystemClassLoader().loadClass("de.robv.android.xposed.XposedBridge").getDeclaredField("disableHooks");
            field0.setAccessible(true);
            field0.set(null, Boolean.TRUE);
            return true;
        } catch (Throwable ignore) {

        }
        return false;
    }

    public static boolean isAbnormalEnv() {
        if ("0".equals(getProperty("ro.secure", "1"))) {
            return true;
        }
        for (String file : new String[]{"/su", "/su/bin/su", "/sbin/su", "/system/bin/su", "/system/xbin/su",
                "/data/local/xbin/su", "/data/local/bin/su", "/system/sd/xbin/su",
                "/system/bin/failsafe/su", "/data/local/su", "/system/bin/cufsdosck", "/system/xbin/cufsdosck",
                "/system/bin/cufsmgr", "/system/xbin/cufsmgr", "/system/bin/cufaevdd", "/system/xbin/cufaevdd",
                "/system/bin/conbb", "/system/xbin/conbb"}) {
            if (new File(file).exists()) {
                return true;
            }
        }
        return Build.TAGS != null && Build.TAGS.contains("test-keys");
    }

    public static boolean isVpn() {
        try {
            Enumeration<NetworkInterface> e = NetworkInterface.getNetworkInterfaces();
            if (e != null) {
                for (NetworkInterface net : Collections.list(e)) {
                    if (net.isUp() && !net.getInterfaceAddresses().isEmpty() && ("tun0".equals(net.getName()) || "ppp0".equals(net.getName()))) {
                        return true;
                    }
                }
            }
        } catch (Throwable ignore) {
        }
        return false;
    }

    public static boolean isSim(Context context) {
        try {
            final int state = ((TelephonyManager) (context.getSystemService(Activity.TELEPHONY_SERVICE))).getSimState();
            return TelephonyManager.SIM_STATE_ABSENT != state && state != TelephonyManager.SIM_STATE_UNKNOWN;
        } catch (Throwable e) {
            //
        }
        return true;
    }

    public static String getInstaller(Context context) {
        String installer = "";
        try {
            final PackageManager packageManager = context.getPackageManager();
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                installer = packageManager.getInstallSourceInfo(context.getPackageName()).getInstallingPackageName();
            } else {
                installer = packageManager.getInstallerPackageName(context.getPackageName());
            }
        } catch (Throwable e) {
            //
        }
        return installer != null ? installer : "";
    }

    private static boolean existFile(String[] files) {
        for (String file : files) {
            if (new File(file).exists()) {
                return true;
            }
        }
        return false;
    }

    @SuppressLint("PrivateApi")
    private static String getProperty(String key, String defaultValue) {
        try {
            return (String) Class.forName("android.os.SystemProperties").getMethod("get", String.class).invoke(null, key);
        } catch (Throwable ignore) {
        }
        return defaultValue;
    }

}
