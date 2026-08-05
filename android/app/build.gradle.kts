plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.example.aurastack"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "28.2.13676358"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // 启用核心库脱糖
//        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = "17"  // 明确指定JVM目标版本为17
    }

    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId = "com.auraascratch.lccstack"
        // You can update the following values to match your application needs.
        // For more information, see: https://flutter.dev/to/review-gradle-config.
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        minSdkVersion(27)
        targetSdkVersion(36)
    }

//    signingConfigs {
//        create("release") {
//            storeFile = file("/Users/scracthjoy/Desktop/pigwalletssigns.jks")
//            storePassword = "123456"
//            keyAlias = "pigwalletssigns"
//            keyPassword = "123456"
//        }
//    }

//    buildTypes {
//        getByName("release") {
//            signingConfig = signingConfigs.getByName("release")
//            isMinifyEnabled = true
//            isShrinkResources = true
//            proguardFiles(
//                getDefaultProguardFile("proguard-android-optimize.txt"),
//                "proguard-rules.pro"
//            )
//        }
//    }
}


flutter {
    source = "../.."
}

dependencies {
    // facebook
    implementation ("com.facebook.android:facebook-android-sdk:latest.release")
    // When using the BoM, you don't specify versions in Firebase library dependencies
    implementation("com.google.firebase:firebase-crashlytics-ndk")
    implementation("com.google.firebase:firebase-analytics")
    implementation(platform("com.google.firebase:firebase-bom:34.4.0"))

    // 添加核心库脱糖依赖 通知需要
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.1.5")

    implementation ("com.adjust.sdk:adjust-android:4.38.0")

    api("io.github.alex-only:max_adapter_tu:1.2.5")

    implementation ("com.google.gms:google-services:4.3.15")



    // TU (Necessary)
    api("com.thinkup.sdk:core-tpn:6.5.73.2")

    // AndroidX (Necessary)
    api("androidx.appcompat:appcompat:1.6.1")
    api("androidx.browser:browser:1.4.0")

    // Moloco
    api("com.thinkup.sdk:adapter-tpn-moloco:4.8.1.1.0")
    api("com.moloco.sdk:moloco-sdk:4.8.1")

    // Vungle
    api("com.thinkup.sdk:adapter-tpn-vungle:7.7.3.1.0")
    api("com.vungle:vungle-ads:7.7.3")
    api("com.google.android.gms:play-services-basement:18.1.0")
    api("com.google.android.gms:play-services-ads-identifier:18.0.1")

    // UnityAds
    api("com.thinkup.sdk:adapter-tpn-unityads:4.17.0.1.1")
    api("com.unity3d.ads:unity-ads:4.17.0")

    // Ironsource
    api("com.thinkup.sdk:adapter-tpn-ironsource:9.2.0.1.1")
    api("com.unity3d.ads-mediation:mediation-sdk:9.2.0")
    api("com.google.android.gms:play-services-appset:16.0.2")
    api("com.google.android.gms:play-services-ads-identifier:18.0.1")
    api("com.google.android.gms:play-services-basement:18.1.0")

    // Bigo
    api("com.thinkup.sdk:adapter-tpn-bigo:5.7.1.1.1")
    api("com.bigossp:bigo-ads:5.7.1")

    // Pangle
    api("com.thinkup.sdk:adapter-tpn-pangle:7.9.1.0.1.0")
    api("com.pangle.global:pag-sdk:7.9.1.0")
    api("com.google.android.gms:play-services-ads-identifier:18.2.0")

    // Kwai
    api("com.thinkup.sdk:adapter-tpn-kwai:1.2.21.1.0")
    api("io.github.kwainetwork:adApi:1.2.21")
    api("io.github.kwainetwork:adImpl:1.2.21")
    api("androidx.media3:media3-exoplayer:1.0.0-alpha01")
    api("androidx.appcompat:appcompat:1.6.1")
    api("com.google.android.material:material:1.2.1")
    api("androidx.annotation:annotation:1.2.0")
    api("org.jetbrains.kotlin:kotlin-stdlib-jdk7:1.4.10")
    api("com.google.android.gms:play-services-ads-identifier:18.0.1")

    // Facebook
    api("com.thinkup.sdk:adapter-tpn-facebook:6.21.0.1.1")
    api("com.facebook.android:audience-network-sdk:6.21.0")
    api("androidx.annotation:annotation:1.0.0")

    // Admob
    api("com.thinkup.sdk:adapter-tpn-admob:25.0.0.1.0")
    api("com.google.android.gms:play-services-ads:25.0.0")

    // Inmobi
    api("com.thinkup.sdk:adapter-tpn-inmobi:11.1.1.1.1")
    api("com.inmobi.monetization:inmobi-ads-kotlin:11.1.1")

    // TU Adx SDK (Necessary)
    api("com.thinkup.sdk:adapter-tpn-sdm:6.5.68.1.0")
    api("com.smartdigimkttech.sdk:smartdigimkttech-sdk:6.5.68")

    // AppLovin
    api("com.thinkup.sdk:adapter-tpn-applovin:13.6.0.1.1")
    api("com.applovin:applovin-sdk:13.6.0")

    // Mintegral
    api("com.thinkup.sdk:adapter-tpn-mintegral:17.0.91.1.0")
    api("com.mbridge.msdk.oversea:mbridge_android_sdk:17.0.91")
    api("androidx.recyclerview:recyclerview:1.1.0")

    // Bidmachine
    api("com.thinkup.sdk:adapter-tpn-bidmachine:3.7.0.1.0")
    api("io.bidmachine:ads:3.7.0")

    // Chartboost
    api("com.thinkup.sdk:adapter-tpn-chartboost:9.12.0.1.0")
    api("com.chartboost:chartboost-sdk:9.12.0")
    api("com.chartboost:chartboost-mediation-sdk:5.3.0")
    api("com.chartboost:chartboost-core-sdk:1.1.0")
    api("com.chartboost:chartboost-mediation-adapter-chartboost:5.9.11.0.0")
    api("androidx.media3:media3-exoplayer:1.4.1")
    api("androidx.media3:media3-ui:1.4.1")
    api("com.jakewharton.retrofit:retrofit2-kotlinx-serialization-converter:1.0.0")
    api("com.squareup.okhttp3:logging-interceptor:4.11.0")
    api("com.squareup.okhttp3:okhttp:4.12.0")
    api("com.squareup.retrofit2:converter-scalars:2.9.0")
    api("com.squareup.retrofit2:retrofit:2.9.0")
    api("org.jetbrains.kotlinx:kotlinx-coroutines-android:1.7.3")
    api("org.jetbrains.kotlinx:kotlinx-serialization-json:1.5.1")

    // Fyber
    api("com.thinkup.sdk:adapter-tpn-fyber:8.4.2.1.1")
    api("com.fyber:marketplace-sdk:8.4.2")
    api("com.google.android.gms:play-services-basement:18.9.0")
    api("com.google.android.gms:play-services-ads-identifier:18.0.1")

    // Tramini
    api("com.thinkup.sdk:tramini-plugin-tpn:6.5.73")


}
