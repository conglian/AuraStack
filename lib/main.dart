import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:AuraStackFK/AuraStackFK.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'ASBasic/ASLaunch.dart';
import 'ASTool/ASLogger.dart';
import 'ASTool/as_LocalProvider.dart';
import 'ASTool/ASFKManger.dart';
import 'ASTool/ASGameProgressManager.dart';
import 'package:spine_flutter/spine_flutter.dart';

import 'ASTool/as_extension_help.dart';
import 'ASTool/as_init_sdk.dart';

Future<void> main() async {
  // 初始化Flutter绑定（确保async操作在runApp前执行）
  WidgetsFlutterBinding.ensureInitialized();
  // 只允许竖屏
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // 状态栏背景透明
      statusBarIconBrightness: Brightness.dark, // 安卓图标白色
      statusBarBrightness: Brightness.light, // iOS 用
    ),
  );

  // await Firebase.initializeApp();
  //
  // FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // // 捕获 Flutter 框架错误
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  // // 捕获 async / isolate 全局错误
  // PlatformDispatcher.instance.onError = (error, stack) {
  //   bool isFatal = false;
  //   // 严重错误：fatal
  //   if (error is OutOfMemoryError ||
  //       error is StackOverflowError ||
  //       error is FlutterError ||
  //       error is AssertionError) {
  //     isFatal = true;
  //   }
  //   // 上报到 Crashlytics
  //   FirebaseCrashlytics.instance.recordError(error, stack, fatal: isFatal);
  //   return true;
  // };

  // asLog.info(BoomUniqueStringUtil.decrypt('5+zd3e778+DhxfDjwtzJ5Ov77+jo++vu+d3r3fnr4Ojr5/PGnuHJ0MjS+/PJ+OnlzfnimsbQ+N7M3+OFwMzM8uXy2uL/8vj8x5np+MPT5Oae55//mvzTmdvpgeLlnJ6Fy5vw8Jjs7Mnh5u2ck8Xl3P/B6d/n2Jrp693v6+v7l5c=', 170));
  await AuraStackFK.instance.as_initNumberUnit(apiKey: BoomUniqueStringUtil.decrypt('5+zd3e778+DhxfDjwtzJ5Ov77+jo++vu+d3r3fnr4Ojr5/PGnuHJ0MjS+/PJ+OnlzfnimsbQ+N7M3+OFwMzM8uXy2uL/8vj8x5np+MPT5Oae55//mvzTmdvpgeLlnJ6Fy5vw8Jjs7Mnh5u2ck8Xl3P/B6d/n2Jrp693v6+v7l5c=', 170));

  await initSpineFlutter(enableMemoryDebugging: false);
  // 1. 创建LocalStorageProvider实例并初始化（加载本地数据）
  final localStorageProvider = ASLocalProvider.instance;
  await localStorageProvider.init();
  await trigger.init();
  await ASFKManger().initFKJson();
  await ASGameProgressManager.instance.initGameProgressJson();
  // 模拟排队完成
  // PSLocalProvider.instance.updateint(PSLocalProvider.instance.ps_quiz_all_numName, 0);
  // PSLocalProvider.instance.updatedouble(PSLocalProvider.instance.ps_pig_level_indexName, 0);
  /*
  String jsonString = await rootBundle.loadString("quiz".jsons());

  final encrypted = AESHelper.encryptString(jsonString);

  printLongString(encrypted);
  // 解密
  final decrypted = AESHelper.decryptString(encrypted);
  print(decrypted); // 👈 复制这个
  */
  // 2. 注入Provider，包裹MyApp
  runApp(
    ChangeNotifierProvider(
      create: (context) => localStorageProvider, // 传入已初始化的实例
      child: const MyApp(),
    ),
  );
}

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale? _locale;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    ASSDKHelpers().initSDK();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      // 字体自动适配
      splitScreenMode: true,
      // 支持平板分屏
      builder: (context, child) {
        return MaterialApp(
          navigatorObservers: [routeObserver],
          theme: ThemeData(
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
            hoverColor: Colors.transparent,
            focusColor: Colors.transparent,
            splashFactory: NoSplash.splashFactory, // 彻底取消水波纹
          ),
          debugShowCheckedModeBanner: false,
          builder: (context, widget) {
            // 防止系统字体缩放影响
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
              child: widget!,
            );
          },
          home: child,
        );
      },
      child: ASLaunch(),
    );
  }
}
