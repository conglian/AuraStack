// import 'package:flutter/cupertino.dart';
// import 'package:flutter_lifecycle_detector/flutter_lifecycle_detector.dart';
// import '../main.dart';
// import 'ASFKManger.dart';
// import 'ASTBAEventTool.dart';
// import 'as_extension_help.dart';
//
//
// class ASNoticeHelp {
//
//   static final ASNoticeHelp _instance = ASNoticeHelp._internal();
//
//   factory ASNoticeHelp() {
//     return _instance;
//   }
//
//   FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//
//   ASNoticeHelp._internal();
//
//   Future<void> initNotice(BuildContext context) async {
//
//     const AndroidInitializationSettings initializationSettingsAndroid =
//     AndroidInitializationSettings('cs_logo'); // 不加 .png
//
//     const InitializationSettings initializationSettings = InitializationSettings(
//       android: initializationSettingsAndroid,
//     );
//
//     await flutterLocalNotificationsPlugin.initialize(
//       initializationSettings,
//       onDidReceiveNotificationResponse: (response) {
//         'nf click response:${response}'.log();
//         final String? payload = response.payload;
//         cs_event_fire('inform_c', {'infrom_from': payload ?? ''});
//         if(payload == null)return;
//       },
//     );
//
//
//     NotificationAppLaunchDetails? notificationAppLaunchDetails =
//     await AndroidFlutterLocalNotificationsPlugin()
//         .getNotificationAppLaunchDetails();
//     '=initNotification====getNotificationAppLaunchDetails==notificationAppLaunchDetails:$notificationAppLaunchDetails='.log();
//
//     if (notificationAppLaunchDetails != null) {
//       NotificationResponse? notificationResponse =
//           notificationAppLaunchDetails.notificationResponse;
//       bool didNotificationLaunchApp =
//           notificationAppLaunchDetails.didNotificationLaunchApp ?? false;
//       if (didNotificationLaunchApp) {
//         cs_event_fire('inform_c', {'infrom_from': notificationResponse?.payload ?? ''});
//       }
//     }
//
//     var nfPermission = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
//     if(nfPermission??false){
//       cs_event_fire('push_status', {});
//     }else{
//       "nf no permission".log();
//       context.tipShow(CSNoticeOpenDialog());
//     }
//     "nf has permission".log();
//     _initLifecycleListener();
//     _repeatNotification1();
//     _repeatNotification2();
//     _repeatNotification3();
//     _repeatNotification4();
//     _subscribeFcmTopic();
//     _subscribeFcmTopic2();
//     _showUnlockNotification();
//     _showScreenOnNotification();
//     showSJNotificationMediaStyle1();
//     showSJNotificationMediaStyle2();
//     showSJNotificationMediaStyle3();
//     showSJNotificationMediaStyle4();
//     _spinitNotificationCount(flutterLocalNotificationsPlugin);
//   }
//
//   _spinitNotificationCount(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//     try {
//       int locals = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti1");
//       "==initNotificationCount==localcount:$locals==".log();
//       if (locals > 0) {
//         for (int i = 0; i < locals; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "noti1"});
//         }
//       }
//       int locals2 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti2");
//       "==initNotificationCount==localcount:$locals2==".log();
//       if (locals2 > 0) {
//         for (int i = 0; i < locals2; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "noti2"});
//         }
//       }
//       int locals3 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti3");
//       "==initNotificationCount==localcount:$locals3==".log();
//       if (locals3 > 0) {
//         for (int i = 0; i < locals3; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "noti3"});
//         }
//       }
//       int locals4 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("noti4");
//       "==initNotificationCount==localcount:$locals4==".log();
//       if (locals4 > 0) {
//         for (int i = 0; i < locals4; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "noti4"});
//         }
//       }
//       int fcms = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("fcm");
//       "==initNotificationCount==localcount:$fcms==".log();
//       if (fcms > 0) {
//         for (int i = 0; i < fcms; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "fcm"});
//         }
//       }
//
//       int unlocks = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("unlock");
//       "==initNotificationCount==localcount:$unlocks==".log();
//       if (unlocks > 0) {
//         for (int i = 0; i < unlocks; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "unlock"});
//         }
//       }
//
//       int screenon = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("screenon");
//       "==initNotificationCount==localcount:$screenon==".log();
//       if (screenon > 0) {
//         for (int i = 0; i < screenon; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "screenon"});
//         }
//       }
//
//       int foreground = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("foreground");
//       "==initNotificationCount==localcount:$foreground==".log();
//       if (foreground > 0) {
//         for (int i = 0; i < foreground; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "foreground"});
//         }
//       }
//
//       int media = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media1");
//       "==initNotificationCount==localcount:$media==".log();
//       if (media > 0) {
//         for (int i = 0; i < media; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "media"});
//         }
//       }
//
//       int media2 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media2");
//       "==initNotificationCount==localcount:$media==".log();
//       if (media2 > 0) {
//         for (int i = 0; i < media2; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "media"});
//         }
//       }
//
//       int media3 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media3");
//       "==initNotificationCount==localcount:$media==".log();
//       if (media3 > 0) {
//         for (int i = 0; i < media3; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "media"});
//         }
//       }
//
//       int media4 = await AndroidFlutterLocalNotificationsPlugin()
//           .extractMessageReceivedNum("media4");
//       "==initNotificationCount==localcount:$media==".log();
//       if (media4 > 0) {
//         for (int i = 0; i < media4; i++) {
//           cs_event_fire('inform_p', {'infrom_from' : "media"});
//         }
//       }
//
//     } catch (e) {
//       "===initNotificationCount==error:$e=".log();
//     }
//   }
//
//   Future<void> setNoticeStatus() async {
//
//     FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
//     var nfPermission = await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.requestNotificationsPermission();
//     if(nfPermission??false){
//       cs_event_fire('push_status', {});
//     }else{
//       "nf no permission".log();
//     }
//
//   }
//
//   // 前台服务
//   Future<void> startSJForegroundService() async {
//     //自定义通知ID
//     final int id = 1201;
//     AndroidNotificationDetails androidNotificationDetails = AndroidNotificationDetails(
//         'pigwalletForeground',
//         'pigwalletForeground',
//         ongoing: true,
//         importance: Importance.min,
//         priority: Priority.min,
//         styleInformation: ForegroundStyleInformation(value: '${0.dolasType()}${CSLocalProvider.instance.cs_dollar_number.toStringAsFixed(2)}', image:'cs_freground')
//     );
//     await AndroidFlutterLocalNotificationsPlugin().startForegroundService(id, '', '',
//         notificationDetails: androidNotificationDetails, payload: 'foreground');
//   }
//
//   // 媒体通知
//   Future<void> showSJNotificationMediaStyle1() async {
//     //自定义通知ID
//     final int id = 4780;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice0',
//       'cashscatchgo0',
//       styleInformation:MediaStyleInformation(
//         //支持网络图片链接
//         image:'cs_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 40),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "Media1"
//     );
//   }
//
//   Future<void> showSJNotificationMediaStyle2() async {
//     //自定义通知ID
//     final int id = 2588;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice21',
//       'cashscatchgo21',
//       styleInformation:MediaStyleInformation(
//         //支持网络图片链接
//         image:'cs_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 80),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "Media2"
//     );
//   }
//
//   Future<void> showSJNotificationMediaStyle3() async {
//     //自定义通知ID
//     final int id = 2964;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice31',
//       'cashscatchgo31',
//       styleInformation:MediaStyleInformation(
//         //支持网络图片链接
//         image:'cs_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 160),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "Media3"
//     );
//   }
//
//   Future<void> showSJNotificationMediaStyle4() async {
//     //自定义通知ID
//     final int id = 1720;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice41',
//       'cashscatchgo41',
//       styleInformation:MediaStyleInformation(
//         //支持网络图片链接
//         image:'cs_sm_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 190),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "Media4"
//     );
//   }
//
//   // Future<void> _tapMediasNotice(FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin) async {
//   //
//   //   await flutterLocalNotificationsPlugin.cancel(3744);
//   //
//   //   final NotificationDetails media = NotificationDetails(
//   //     android: AndroidNotificationDetails(
//   //       'scratchjoy Media',
//   //       'scratchjoy',
//   //       styleInformation: MediaStyleInformation(image: 'cs_sm_logo'),
//   //     ),
//   //   );
//   //
//   //   final int id = 3744;
//   //   final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//   //   final String title = randomMotivation.title;
//   //   final String body = randomMotivation.body;
//   //   await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//   //       id,
//   //       title,
//   //       body,
//   //       //间隔时长根据需求设置
//   //       Duration(minutes: 30),
//   //       notificationDetails: media.android,
//   //       scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//   //       payload: "media"
//   //   );
//   // }
//
//   // 本地通知
//   Future<void> _repeatNotification1() async {
//     //自定义通知ID
//     final int id = 7290;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice1',
//       'cashscatchgo1',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image:'cs_notice_big',
//         button:'Withdraw',
//         appIcon:'cs_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 30),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "noti1"
//     );
//   }
//
//   Future<void> _repeatNotification2() async {
//     //自定义通知ID
//     final int id = 2568;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice2',
//       'cashscatchgo2',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image:'cs_notice_big',
//         button:'Withdraw',
//         appIcon:'cs_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 60),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "noti2"
//     );
//   }
//
//   Future<void> _repeatNotification3() async {
//     //自定义通知ID
//     final int id = 2722;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice3',
//       'cashscatchgo3',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image:'cs_notice_big',
//         button:'Withdraw',
//         appIcon:'cs_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 90),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "noti3"
//     );
//   }
//
//   Future<void> _repeatNotification4() async {
//     //自定义通知ID
//     final int id = 7195;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     final String title = randomMotivation.title;
//     final String body = randomMotivation.body;
//     AndroidNotificationDetails details = AndroidNotificationDetails(
//       '168notice4',
//       'cashscatchgo4',
//       styleInformation: BeautyStyleInformation(
//         title: title,
//         body: body,
//         image:'cs_notice_big',
//         button:'Withdraw',
//         appIcon:'cs_logo',
//       ),
//       priority: Priority.high,
//       importance: Importance.high,
//       icon: 'cs_sm_logo',
//       //“groupKey”：防止通知被系统折叠
//       groupKey: "$id",
//     );
//     await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
//         id,
//         title,
//         body,
//         //间隔时长根据需求设置
//         const Duration(minutes: 120),
//         notificationDetails: details,
//         scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//         payload: "noti4"
//     );
//   }
//
//   Future<void> _subscribeFcmTopic() async {
//     await AndroidFlutterLocalNotificationsPlugin().subscribeToTopic(
//       'c168card_fcm_one',
//       AndroidNotificationDetails(
//         'c168card_fcm_one',
//         'cashscatchgo',
//         styleInformation: BeautyStyleInformation(
//           title: '',
//           body: '',
//           image:'',
//           button:'Withdraw',
//           appIcon:'cs_logo',
//         ),
//         priority: Priority.high,
//         importance: Importance.high,
//         icon: 'cs_sm_logo',
//       ),
//     );
//   }
//
//   Future<void> _subscribeFcmTopic2() async {
//     await AndroidFlutterLocalNotificationsPlugin().subscribeToTopic(
//       'c168card_fcm_two',
//       AndroidNotificationDetails(
//         'c168card_fcm_two',
//         'cashscatchgo2',
//         styleInformation: BeautyStyleInformation(
//           title: '',
//           body: '',
//           image:'',
//           button:'Claim',
//           appIcon:'cs_logo',
//         ),
//         priority: Priority.high,
//         importance: Importance.high,
//         icon: 'cs_sm_logo',
//       ),
//     );
//   }
//
//   Future<void> _showUnlockNotification() async {
//     //自定义通知ID
//     final int ids = 2829;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     ASStepMotivation randomMotivation2 = ASStepMotivationManager.getRandomMotivation();;
//     await AndroidFlutterLocalNotificationsPlugin().showBroadcastNotification(
//       ids,
//       randomMotivation.title,
//       randomMotivation.body,
//       //两次发送解锁通知的间隔，根据需求设置
//       const Duration(seconds: 30),
//       'android.intent.action.USER_PRESENT',
//       AndroidNotificationDetails(
//         '168cashscatchgos',
//         'cashscatchgos',
//         priority: Priority.high,
//         importance: Importance.high,
//         icon: 'cs_sm_logo',
//         styleInformation: BeautyStyleInformation(
//           title: randomMotivation2.title,
//           body: randomMotivation2.body,
//           image:'cs_notice_big',
//           button:'Withdraw',
//           appIcon:'cs_logo',
//         ),
//         //“groupKey”：防止通知被系统折叠
//         groupKey: "$ids",
//       ),
//       'unlock',
//     );
//   }
//
//   Future<void> _showScreenOnNotification() async {
//     //自定义通知ID
//     final int ids = 1029;
//     final randomMotivation = ASStepMotivationManager.getRandomMotivation();
//     ASStepMotivation randomMotivation2 = ASStepMotivationManager.getRandomMotivation();;
//     await AndroidFlutterLocalNotificationsPlugin().showBroadcastNotification(
//       ids,
//       randomMotivation.title,
//       randomMotivation.body,
//       //两次发送解锁通知的间隔，根据需求设置
//       const Duration(seconds: 30),
//       'android.intent.action.SCREEN_ON',
//       AndroidNotificationDetails(
//         '168cashscatchgoscreen',
//         'cashscatchgoScreen',
//         priority: Priority.high,
//         importance: Importance.high,
//         icon: 'cs_sm_logo',
//         styleInformation: BeautyStyleInformation(
//           title: randomMotivation2.title,
//           body: randomMotivation2.body,
//           image:'cs_notice_big',
//           button:'Withdraw',
//           appIcon:'cs_logo',
//         ),
//         //“groupKey”：防止通知被系统折叠
//         groupKey: "$ids",
//       ),
//       'screenon',
//     );
//   }
//
//
//   Future<void> _initLifecycleListener() async {
//
//     FlutterLifecycleDetector().onBackgroundChange.listen((isBackground) async {
//       /// `isBackground` is true => background
//       /// `isBackground` is false => foreground
//       print('Status background $isBackground');
//       if (isBackground == true) {
//         print('App进入后台');
//         // SJAudioUtils().pauseBGM();
//         CSFKManger().cs_add_tabsession_custom();
//         // 执行后台逻辑
//         cs_session_fire();
//         cs_event_fire('session_back_get', {'"pak_version' : CSLocalProvider.instance.cs_login_status ? 1 : 0});
//       } else {
//         print('App进入前台');
//         // if (PSLocalProvider.instance.ps_bg_music && !SJJoyAds().someAdIsShowing()){
//         //   SJAudioUtils().playBGM();
//         // }
//         CSFKManger().cs_add_tabsession_custom();
//         cs_event_fire('session_front_get', {'"pak_version' : CSLocalProvider.instance.cs_login_status ? 1 : 0});
//         // 执行前台逻辑
//         cs_session_fire();
//         if (!CSCardAds().is_showAd){
//           CSCardAds().cs_showAd(homeKey.currentState!.context, 'rakwt_launch_hot',showDialog: false, onCacheResponse: (onCacheResponse){
//           }, adDidClosed: (adDidClosed){
//           });
//         }
//       }
//     });
//   }
//
// }
// /// 步行激励文案数据模型
// class ASStepMotivation {
//   final String title;
//   final String body;
//
//   ASStepMotivation({
//     required this.title,
//     required this.body,
//   });
// }
//
// /// 步行激励文案工具类
// class ASStepMotivationManager {
//   // 文案数据列表
//   static final List<ASStepMotivation> _motivations = [
//     ASStepMotivation(
//       title: "Payout Update",
//       body: 'You’ve moved up in the cash queue. Keep scratching to reach payout.',
//     ),
//     ASStepMotivation(
//       title: "Cash Money Verified",
//       body: "Your scratch reward is approved. Finish a task to release cash.",
//     ),
//     ASStepMotivation(
//       title: "Bonus Ending Soon",
//       body: "Your LuckyCard bonus expires soon. Scratch now to keep your cash.",
//     ),
//     ASStepMotivation(
//       title: "Hurry! Cash Drop",
//       body: "A surprise scratch bonus just landed. Don’t miss this payout chance.",
//     ),
//     ASStepMotivation(
//       title: "Cash Window Open",
//       body: "Limited-time withdrawal chance unlocked. Scratch to secure it.",
//     ),
//   ];
//
//   /// 随机获取一条激励文案
//   static ASStepMotivation getRandomMotivation() {
//     final random = DateTime.now().microsecond % _motivations.length;
//     return _motivations[random];
//   }
//
// }