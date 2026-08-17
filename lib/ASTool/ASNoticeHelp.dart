import 'package:aurastack/ASDialog/ASOther/ASOtherDialog.dart';
import 'package:aurastack/ASTool/ASLogger.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_lifecycle_detector/flutter_lifecycle_detector.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ASMainVC/ASHome.dart';
import '../main.dart';
import 'ASAudioUtils.dart';
import 'ASFKManger.dart';
import 'ASTBAEventTool.dart';
import 'ASTrackEvent.dart';
import 'as_LocalProvider.dart';
import 'as_ad_manger.dart';
import 'as_extension_help.dart';

class ASNoticeHelp {
  static final ASNoticeHelp _instance = ASNoticeHelp._internal();

  factory ASNoticeHelp() {
    return _instance;
  }

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Notification permission and delivery are disabled for Samsung devices in Korea.
  Future<bool>? _notificationBlockFuture;

  ASNoticeHelp._internal();

  static const _notificationPermissionHandledDateKey =
      'as_notification_permission_handled_date';
  static const _notificationFollowUpPendingKey =
      'as_notification_follow_up_pending';
  static const _notificationFollowUpShownDateKey =
      'as_notification_follow_up_shown_date';

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
  }

  Future<bool> _notificationPermissionHandledToday() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_notificationPermissionHandledDateKey) ==
        _todayKey();
  }

  Future<bool> _shouldDisableNotifications() {
    return _notificationBlockFuture ??= _readNotificationBlockStatus();
  }

  Future<bool> _readNotificationBlockStatus() async {
    try {
      final manufacturer = (await FlutterTbaInfo.instance.getManufacturer())
          .toLowerCase();
      final country = (await FlutterTbaInfo.instance.getOsCountry())
          .toLowerCase();
      final isSamsung = manufacturer.contains('samsung');
      final isKorea =
          country == 'kr' ||
          country == 'ko' ||
          country.contains('korea') ||
          country.contains('대한민국');
      return isSamsung && isKorea;
    } catch (error) {
      // Device metadata is optional; keep notifications enabled if it cannot be read.
      asLog.info('notification device check failed: $error');
      return false;
    }
  }

  String _notificationType(String? payload) {
    final source = (payload ?? '').toLowerCase();
    if (source.startsWith('media')) return 'media';
    if (source == 'foreground' || source == 'screenon') {
      return 'fixed';
    }
    return source;
  }

  Future<void> initNotice(BuildContext context) async {
    if (await _shouldDisableNotifications()) {
      asLog.info('notifications disabled for Samsung device in Korea');
      try {
        await flutterLocalNotificationsPlugin.cancelAll();
      } catch (error) {
        asLog.info('failed to clear disabled notifications: $error');
      }
      return;
    }
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('as_sm_log'); // Android drawable名称，不加扩展名

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        asLog.info('nf click response:${response}');
        final String? payload = response.payload;
        as_event_fire(ASTrackEvent.allNotificationClick, {
          'types': _notificationType(payload),
        });
        if (payload == null) return;
      },
    );

    NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await AndroidFlutterLocalNotificationsPlugin()
            .getNotificationAppLaunchDetails();
    asLog.info(
      '=initNotification====getNotificationAppLaunchDetails==notificationAppLaunchDetails:$notificationAppLaunchDetails=',
    );
    var didNotificationLaunchApp = false;
    if (notificationAppLaunchDetails != null) {
      NotificationResponse? notificationResponse =
          notificationAppLaunchDetails.notificationResponse;
      didNotificationLaunchApp =
          notificationAppLaunchDetails.didNotificationLaunchApp;
      if (didNotificationLaunchApp) {
        as_event_fire(ASTrackEvent.allNotificationClick, {
          'types': _notificationType(notificationResponse?.payload),
        });
      }
    }
    as_event_fire(ASTrackEvent.launchFrom, {
      'types': didNotificationLaunchApp ? 'noti' : 'app',
    });

    // The platform permission is requested once from the launch screen.
    // Home only schedules notifications and displays the in-app follow-up.
    _initLifecycleListener();
    _repeatNotification1();
    _repeatNotification2();
    _repeatNotification3();
    _repeatNotification4();
    _subscribeFcmTopic();
    _subscribeFcmTopic2();
    _showUnlockNotification();
    _showScreenOnNotification();
    showSJNotificationMediaStyle1();
    showSJNotificationMediaStyle2();
    showSJNotificationMediaStyle3();
    showSJNotificationMediaStyle4();
    _spinitNotificationCount(flutterLocalNotificationsPlugin);
  }

  Future<void> showPendingFollowUp(BuildContext context) async {
    if (!context.mounted) return;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool(_notificationFollowUpPendingKey) ?? false) ||
        (prefs.getBool('as_notification_permission_rewarded') ?? false) ||
        prefs.getString(_notificationFollowUpShownDateKey) == _todayKey()) {
      return;
    }
    await prefs.setString(_notificationFollowUpShownDateKey, _todayKey());
    if (context.mounted) await context.tipShow(ASToolDialog(type: .notice));
  }

  _spinitNotificationCount(
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin,
  ) async {
    if (await _shouldDisableNotifications()) return;
    try {
      int locals = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("noti1");
      asLog.info("==initNotificationCount==localcount:$locals==");
      if (locals > 0) {
        for (int i = 0; i < locals; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'noti1'});
        }
      }
      int locals2 = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("noti2");
      asLog.info("==initNotificationCount==localcount:$locals2==");
      if (locals2 > 0) {
        for (int i = 0; i < locals2; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'noti2'});
        }
      }
      int locals3 = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("noti3");
      asLog.info("==initNotificationCount==localcount:$locals3==");
      if (locals3 > 0) {
        for (int i = 0; i < locals3; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'noti3'});
        }
      }
      int locals4 = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("noti4");
      asLog.info("==initNotificationCount==localcount:$locals4==");
      if (locals4 > 0) {
        for (int i = 0; i < locals4; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'noti4'});
        }
      }
      int fcms = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("fcm");
      asLog.info("==initNotificationCount==localcount:$fcms==");
      if (fcms > 0) {
        for (int i = 0; i < fcms; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'fcm'});
        }
      }

      int unlocks = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("unlock");
      asLog.info("==initNotificationCount==localcount:$unlocks==");
      if (unlocks > 0) {
        for (int i = 0; i < unlocks; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {
            'types': 'unlock',
          });
        }
      }

      int screenon = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("screenon");
      asLog.info("==initNotificationCount==localcount:$screenon==");
      if (screenon > 0) {
        for (int i = 0; i < screenon; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'fixed'});
        }
      }

      int foreground = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("foreground");
      asLog.info("==initNotificationCount==localcount:$foreground==");
      if (foreground > 0) {
        for (int i = 0; i < foreground; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'fixed'});
        }
      }

      int media = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("media1");
      asLog.info("==initNotificationCount==localcount:$media==");
      if (media > 0) {
        for (int i = 0; i < media; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'media'});
        }
      }

      int media2 = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("media2");
      asLog.info("==initNotificationCount==localcount:$media2==");
      if (media2 > 0) {
        for (int i = 0; i < media2; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'media'});
        }
      }

      int media3 = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("media3");
      asLog.info("==initNotificationCount==localcount:$media3==");
      if (media3 > 0) {
        for (int i = 0; i < media3; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'media'});
        }
      }

      int media4 = await AndroidFlutterLocalNotificationsPlugin()
          .extractMessageReceivedNum("media4");
      asLog.info("==initNotificationCount==localcount:$media4==");
      if (media4 > 0) {
        for (int i = 0; i < media4; i++) {
          as_event_fire(ASTrackEvent.allNotificationTrigger, {'types': 'media'});
        }
      }
    } catch (e) {
      asLog.info("===initNotificationCount==error:$e=");
    }
  }

  Future<void> setNoticeStatus() async {
    if (await _shouldDisableNotifications()) {
      asLog.info(
        'notification permission disabled for Samsung device in Korea',
      );
      return;
    }
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    var nfPermission = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >()
        ?.requestNotificationsPermission();
    if (nfPermission ?? false) {
      as_event_fire('push_status', {});
    } else {
      asLog.info("nf no permission");
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_notificationPermissionHandledDateKey, _todayKey());
      await prefs.setBool(_notificationFollowUpPendingKey, true);
    }
  }

  // 前台服务
  Future<void> startSJForegroundService({double? balance}) async {
    if (await _shouldDisableNotifications()) return;
    //自定义通知ID
    final int id = 1801;
    final currentBalance = balance ?? ASLocalProvider.instance.as_dollar_number;
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
          'aurastackForeground',
          'aurastackForeground',
          ongoing: true,
          importance: Importance.min,
          priority: Priority.min,
          styleInformation: ForegroundStyleInformation(
            value: '${0.dolasType()}${currentBalance.toStringAsFixed(2)}',
            image: 'as_freground',
          ),
        );
    await AndroidFlutterLocalNotificationsPlugin().startForegroundService(
      id,
      '',
      '',
      notificationDetails: androidNotificationDetails,
      payload: 'foreground',
    );
  }

  // 媒体通知
  Future<void> showSJNotificationMediaStyle1() async {
    //自定义通知ID
    final int id = 9780;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'fixed',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice0',
      'aurastack0',
      styleInformation: MediaStyleInformation(
        //支持网络图片链接
        image: 'as_sm_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 40),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "Media1",
    );
  }

  Future<void> showSJNotificationMediaStyle2() async {
    //自定义通知ID
    final int id = 4588;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'fixed',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice21',
      'aurastack21',
      styleInformation: MediaStyleInformation(
        //支持网络图片链接
        image: 'as_sm_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 80),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "Media2",
    );
  }

  Future<void> showSJNotificationMediaStyle3() async {
    //自定义通知ID
    final int id = 8944;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'fixed',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice31',
      'aurastack31',
      styleInformation: MediaStyleInformation(
        //支持网络图片链接
        image: 'as_sm_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 160),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "Media3",
    );
  }

  Future<void> showSJNotificationMediaStyle4() async {
    //自定义通知ID
    final int id = 5220;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'fixed',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice41',
      'aurastack41',
      styleInformation: MediaStyleInformation(
        //支持网络图片链接
        image: 'as_sm_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 190),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "Media4",
    );
  }

  // 本地通知
  Future<void> _repeatNotification1() async {
    //自定义通知ID
    final int id = 8852;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'noti1',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice1',
      'aurastack1',
      styleInformation: BeautyStyleInformation(
        title: title,
        body: body,
        image: 'as_big_bg',
        button: 'Withdraw',
        appIcon: 'as_big_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 30),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "noti1",
    );
  }

  Future<void> _repeatNotification2() async {
    //自定义通知ID
    final int id = 1268;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'noti2',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice2',
      'aurastack2',
      styleInformation: BeautyStyleInformation(
        title: title,
        body: body,
        image: 'as_big_bg',
        button: 'Withdraw',
        appIcon: 'as_big_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 60),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "noti2",
    );
  }

  Future<void> _repeatNotification3() async {
    //自定义通知ID
    final int id = 6722;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'noti3',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice3',
      'aurastack3',
      styleInformation: BeautyStyleInformation(
        title: title,
        body: body,
        image: 'as_big_bg',
        button: 'Withdraw',
        appIcon: 'as_big_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 90),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "noti3",
    );
  }

  Future<void> _repeatNotification4() async {
    //自定义通知ID
    final int id = 1195;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'noti3',
    );
    final String title = randomMotivation.title;
    final String body = randomMotivation.body;
    AndroidNotificationDetails details = AndroidNotificationDetails(
      '170notice4',
      'aurastack4',
      styleInformation: BeautyStyleInformation(
        title: title,
        body: body,
        image: 'as_big_bg',
        button: 'Withdraw',
        appIcon: 'as_big_log',
      ),
      priority: Priority.high,
      importance: Importance.high,
      icon: 'as_sm_log',
      //“groupKey”：防止通知被系统折叠
      groupKey: "$id",
    );
    await AndroidFlutterLocalNotificationsPlugin().periodicallyShowWithDuration(
      id,
      title,
      body,
      //间隔时长根据需求设置
      const Duration(minutes: 120),
      notificationDetails: details,
      scheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      payload: "noti4",
    );
  }

  Future<void> _subscribeFcmTopic() async {
    await AndroidFlutterLocalNotificationsPlugin().subscribeToTopic(
      'c170_data_fcm',
      AndroidNotificationDetails(
        'c170_data_fcm',
        'aurastack',
        styleInformation: BeautyStyleInformation(
          title: '',
          body: '',
          image: 'as_big_bg',
          button: 'Withdraw',
          appIcon: 'as_big_log',
        ),
        priority: Priority.high,
        importance: Importance.high,
        icon: 'as_sm_log',
      ),
    );
  }

  Future<void> _subscribeFcmTopic2() async {
    await AndroidFlutterLocalNotificationsPlugin().subscribeToTopic(
      'c170_normal_fcm',
      AndroidNotificationDetails(
        'c170_normal_fcm',
        'aurastack2',
        styleInformation: BeautyStyleInformation(
          title: '',
          body: '',
          image: 'as_big_bg',
          button: 'Claim',
          appIcon: 'as_big_log',
        ),
        priority: Priority.high,
        importance: Importance.high,
        icon: 'as_sm_log',
      ),
    );
  }

  Future<void> _showUnlockNotification() async {
    //自定义通知ID
    final int ids = 9529;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'unlock',
    );
    final randomMotivation2 = randomMotivation;
    await AndroidFlutterLocalNotificationsPlugin().showBroadcastNotification(
      ids,
      randomMotivation.title,
      randomMotivation.body,
      //两次发送解锁通知的间隔，根据需求设置
      const Duration(seconds: 30),
      'android.intent.action.USER_PRESENT',
      AndroidNotificationDetails(
        '170aurastacks',
        'aurastacks',
        priority: Priority.high,
        importance: Importance.high,
        icon: 'as_sm_log',
        styleInformation: BeautyStyleInformation(
          title: randomMotivation2.title,
          body: randomMotivation2.body,
          image: 'as_big_bg',
          button: 'Withdraw',
          appIcon: 'as_big_log',
        ),
        //“groupKey”：防止通知被系统折叠
        groupKey: "$ids",
      ),
      'unlock',
    );
  }

  Future<void> _showScreenOnNotification() async {
    //自定义通知ID
    final int ids = 1929;
    final randomMotivation = ASStepMotivationManager.getRandomMotivation(
      'fixed',
    );
    final randomMotivation2 = randomMotivation;
    await AndroidFlutterLocalNotificationsPlugin().showBroadcastNotification(
      ids,
      randomMotivation.title,
      randomMotivation.body,
      //两次发送解锁通知的间隔，根据需求设置
      const Duration(seconds: 30),
      'android.intent.action.SCREEN_ON',
      AndroidNotificationDetails(
        '170aurastackscreen',
        'aurastackScreen',
        priority: Priority.high,
        importance: Importance.high,
        icon: 'as_sm_log',
        styleInformation: BeautyStyleInformation(
          title: randomMotivation2.title,
          body: randomMotivation2.body,
          image: 'as_big_bg',
          button: 'Withdraw',
          appIcon: 'as_big_log',
        ),
        //“groupKey”：防止通知被系统折叠
        groupKey: "$ids",
      ),
      'screenon',
    );
  }

  Future<void> _initLifecycleListener() async {
    FlutterLifecycleDetector().onBackgroundChange.listen((isBackground) async {
      /// `isBackground` is true => background
      /// `isBackground` is false => foreground
      asLog.info('Status background $isBackground');
      if (isBackground == true) {
        asLog.info('App进入后台');
        ASAudioUtils().pauseBGM();
        ASFKManger().as_add_tabsession_custom();
        // 执行后台逻辑
        as_session_fire();
        as_event_fire('session_back_get', {
          'pak_version': ASLocalProvider.instance.as_login_status ? 1 : 0,
        });
      } else {
        asLog.info('App进入前台');
        if (ASLocalProvider.instance.as_bg_music && !ASCardAds().someAdIsShowing()){
          ASAudioUtils().playBGM();
        }
        ASFKManger().as_add_tabsession_custom();
        as_event_fire('session_front_get', {
          'pak_version': ASLocalProvider.instance.as_login_status ? 1 : 0,
        });
        // 执行前台逻辑
        as_session_fire();
        if (!ASCardAds().is_showAd) {
          ASCardAds().as_showAd(
            homeKey.currentState!.context,
            ASTrackEvent.launchHotInterstitial,
            showDialog: false,
            onCacheResponse: (onCacheResponse) {},
            adDidClosed: (adDidClosed) {},
          );
        }
      }
    });
  }
}

/// 步行激励文案数据模型
class ASStepMotivation {
  final String title;
  final String body;

  ASStepMotivation({required this.title, required this.body});
}

/// 步行激励文案工具类
class ASStepMotivationManager {
  static final Map<String, List<ASStepMotivation>> _motivations = {
    'noti1': [
      ASStepMotivation(
        title: 'Your Next Card Holds A Surprise',
        body: 'Scratch across and see what you get',
      ),
      ASStepMotivation(
        title: 'Ready For A Lucky Reveal?',
        body: 'Scratch your way to a cash reward',
      ),
      ASStepMotivation(
        title: "What’s Under The Card?",
        body: 'There’s only one way to find out',
      ),
      ASStepMotivation(
        title: 'Your Lucky Reveal Starts Now',
        body: 'Scratch the card and uncover your reward',
      ),
    ],
    'noti2': [
      ASStepMotivation(
        title: 'Your Cash Total Is Growing',
        body: 'Keep scratching to build more rewards',
      ),
      ASStepMotivation(
        title: 'Your Latest Cash Reward Is In',
        body: 'Check your updated earnings',
      ),
      ASStepMotivation(
        title: 'Cash Rewards Are Adding Up',
        body: 'Come back and continue your streak',
      ),
      ASStepMotivation(
        title: 'Your Earnings Just Got A Boost',
        body: 'Keep scratching for more cash',
      ),
    ],
    'noti3': [
      ASStepMotivation(
        title: 'You’ve Unlocked An Extra Reward',
        body: 'Open the app to claim it',
      ),
      ASStepMotivation(
        title: 'Your Lucky Bonus Just Landed',
        body: 'Take a look at your reward',
      ),
      ASStepMotivation(
        title: 'An Extra Cash Chance Is Yours',
        body: 'Use it while it’s available',
      ),
      ASStepMotivation(
        title: 'A Special Reward Was Added For You',
        body: 'Check it before you continue',
      ),
    ],
    // 解锁通知
    'unlock': [
      ASStepMotivation(
        title: 'Your Reward Opportunity Won’t Last',
        body: 'Open now while it’s active',
      ),
      ASStepMotivation(
        title: 'The Clock Is Running On Today’s Bonus',
        body: 'Claim your reward before it ends',
      ),
      ASStepMotivation(
        title: 'Your Special Scratch Chance Ends Soon',
        body: 'Don’t miss today’s opportunity',
      ),
      ASStepMotivation(
        title: 'Your Bonus Window Is Almost Closed',
        body: 'Come back before time runs out',
      ),
    ],
    // 固定通知
    'fixed': [
      ASStepMotivation(
        title: 'Your Cashout Progress Is Moving',
        body: 'Keep earning toward your next withdrawal',
      ),
      ASStepMotivation(
        title: 'Your Lucky Chance Has Changed',
        body: 'Try another card for a surprise',
      ),
      ASStepMotivation(
        title: 'Today’s Scratch Mission Is Live',
        body: 'Complete the challenge for extra rewards',
      ),
      ASStepMotivation(
        title: 'Your Cashout Goal Is Within Reach',
        body: 'Keep earning to get closer',
      ),
    ],
  };

  /// 随机获取一条激励文案
  static ASStepMotivation getRandomMotivation(String type) {
    final motivations = _motivations[type] ?? _motivations['noti3']!;
    final random = DateTime.now().microsecond % motivations.length;
    return motivations[random];
  }
}
