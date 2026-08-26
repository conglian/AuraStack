import 'dart:async';
import 'dart:math';

import 'package:app_settings/app_settings.dart';
import 'package:aurastack/ASTool/as_LocalProvider.dart';
import 'package:aurastack/ASTool/as_ad_manger.dart';
import 'package:aurastack/ASTool/as_extension_help.dart';
import 'package:aurastack/ASTool/as_img.dart';
import 'package:aurastack/ASTool/as_shine.dart';
import 'package:aurastack/ASTool/as_spine_tool.dart';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:fl_toast/fl_toast.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../ASTool/ASAudioUtils.dart';
import '../../ASTool/ASTBAEventTool.dart';
import '../../ASTool/ASTrackEvent.dart';
import '../../ASTool/as_WebKitView.dart';
import '../../ASTool/as_stroke_text.dart';

enum ToolType { notice, nowifi, loadfaild, limted }

class ASDialogTool {
  // tosat
  static void toast(BuildContext buildContext, String text) async {
    await showAndroidToast(
      padding: 0.0.all(16),
      margin: 0.0.all(32),
      alignment: Alignment.center,
      backgroundColor: '#000000'.color(opacity: 0.8),
      duration: Duration(seconds: 2),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.white,
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      context: buildContext,
    );
  }

  static void toastRanking(BuildContext buildContext, int num) async {
    await showAndroidToast(
      padding: 0.0.all(0),
      margin: 0.0.all(0),
      backgroundColor: Colors.transparent,
      alignment: Alignment.center,
      duration: Duration(seconds: 3),
      child: Container(
        width: 205,
        height: 50.5,
        decoration: BoxDecoration(
          color: '#000000'.color(opacity: 0.8),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: const TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
              children: <TextSpan>[
                TextSpan(
                  text: 'Your Current rank: ',
                  style: TextStyle(color: Colors.white),
                ),
                TextSpan(
                  text: '$num',
                  style: TextStyle(color: '#16FF16'.color(), fontSize: 14),
                ),
              ],
            ),
          ),
        ),
      ),
      context: buildContext,
    );
  }
}

// 广告上线/无网/加载失败/通知
class ASToolDialog extends StatefulWidget {
  final ToolType type;

  const ASToolDialog({super.key, required this.type});

  @override
  State<ASToolDialog> createState() => ASToolDialogState();
}

class ASToolDialogState extends State<ASToolDialog>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;
  Completer<void>? _settingsReturnCompleter;
  bool _waitingForNotificationSettings = false;

  Future<void> _openNotificationSettings() async {
    _waitingForNotificationSettings = true;
    _settingsReturnCompleter = Completer<void>();
    try {
      await AppSettings.openAppSettings(type: AppSettingsType.notification);
      await _settingsReturnCompleter!.future;
      as_event_fire(ASTrackEvent.notificationConfirmSuccess, {});
      final notificationsEnabled =
          await AndroidFlutterLocalNotificationsPlugin()
              .areNotificationsEnabled();
      if (notificationsEnabled == true) {
        final prefs = await SharedPreferences.getInstance();
        if (!(prefs.getBool('as_notification_permission_rewarded') ?? false)) {
          await ASLocalProvider.instance.updatedouble(
            ASLocalProvider.instance.as_dollar_numberName,
            10,
          );
          await prefs.setBool('as_notification_permission_rewarded', true);
        }
      }
    } catch (_) {
      as_event_fire(ASTrackEvent.notificationConfirmFail, {});
    } finally {
      _waitingForNotificationSettings = false;
      _settingsReturnCompleter = null;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _waitingForNotificationSettings &&
        !(_settingsReturnCompleter?.isCompleted ?? true)) {
      _settingsReturnCompleter!.complete();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    switch (widget.type) {
      case ToolType.loadfaild:
        as_event_fire(ASTrackEvent.adRetry, {});
        ASAudioUtils().playErrorCommonAudio();
      case ToolType.nowifi:
        as_event_fire(ASTrackEvent.networkNo, {});
        ASAudioUtils().playErrorCommonAudio();
      case ToolType.notice:
        as_event_fire(ASTrackEvent.notificationConfirmPopup, {});
      case ToolType.limted:
        as_event_fire(ASTrackEvent.seeYouTomorrow, {});
        ASAudioUtils().playErrorCommonAudio();
    }

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (!(_settingsReturnCompleter?.isCompleted ?? true)) {
      _settingsReturnCompleter!.complete();
    }
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    if (widget.type == .notice) {
                      as_event_fire(ASTrackEvent.notificationConfirmSkip, {});
                    }
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 347,
              height: 308,
              decoration: BoxDecoration(image: ASDImg('as_tool_bg')),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  ASText(
                    text: gettitleName(),
                    size: 20,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: 26),
                  SizedBox(
                    width: 155,
                    height: 140,
                    child: Center(child: ASImg(name: getIconName())),
                  ),
                  SizedBox(height: 18),
                  SizedBox(
                    width: 248,
                    height: 40,
                    child: Center(
                      child: ASText(
                        text: getTripsName(),
                        size: 16,
                        color: '#4A474B'.color(),
                        weight: FontWeight.w600,
                        maxLines: 2,
                        align: .center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            SizedBox(
              width: 287,
              height: 55,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned.fill(
                    child: ParticleButton(
                      onTap: () async {
                        if (widget.type == .loadfaild) {
                          as_event_fire(ASTrackEvent.adRetryClick, {});
                        } else if (widget.type == .nowifi) {
                          as_event_fire(ASTrackEvent.networkNoClick, {});
                        } else if (widget.type == .notice) {
                          as_event_fire(
                            ASTrackEvent.notificationConfirmAllow,
                            {},
                          );
                          await _openNotificationSettings();
                        }
                        if (!context.mounted) return;
                        Navigator.pop(context, 0);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          image: ASDImg('as_yellow_btn_bg'),
                        ),
                        child: Center(
                          child: ASText(
                            text: getBtnName(),
                            size: 24,
                            color: '#5C300E'.color(),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (widget.type != .limted)
                    Positioned(
                      right: -8,
                      top: 16,
                      child: IgnorePointer(
                        child: ScaleTransition(
                          scale: _scaleAnimation,
                          child: ASImg(
                            name: 'cs_tap_icon',
                            width: 93,
                            height: 98,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Visibility(
              visible: widget.type == .notice,
              child: SizedBox(height: 12.h),
            ),
            Visibility(
              visible: widget.type == .notice,
              child: ASUnderlineTextButton(
                text: 'Later On',
                textColor: '#CEC4D5'.color(),
                underlineColor: '#CEC4D5'.color(),
                fontSize: 16,
                onPressed: () {
                  as_event_fire(ASTrackEvent.notificationConfirmSkip, {});
                  Navigator.pop(context, 0);
                },
              ),
            ),
            SizedBox(height: 88.h),
          ],
        ),
      ],
    );
  }

  String gettitleName() {
    String name = 'Ad Limit Reached';
    if (widget.type == .limted) {
      name = 'Ad Limit Reached';
    } else if (widget.type == .loadfaild) {
      name = 'Quick Break - Back Soon!';
    } else if (widget.type == .nowifi) {
      name = 'No Network Currently';
    } else if (widget.type == .notice) {
      name = 'Unlock More Rewards';
    }
    return name;
  }

  String getIconName() {
    String name = 'as_limteds_icon';
    if (widget.type == .limted) {
      name = 'as_limteds_icon';
    } else if (widget.type == .loadfaild) {
      name = 'as_loadfaild_icon';
    } else if (widget.type == .nowifi) {
      name = 'as_wifi_icon';
    } else if (widget.type == .notice) {
      name = 'as_notice_icon';
    }
    return name;
  }

  String getTripsName() {
    String name = 'You’re all set for today! Come back tomorrow for more ads.';
    if (widget.type == .limted) {
      name = 'You’re all set for today! Come back tomorrow for more ads.';
    } else if (widget.type == .loadfaild) {
      name = 'More Cash Coming!';
    } else if (widget.type == .nowifi) {
      name = 'Large rewards were interrupted';
    } else if (widget.type == .notice) {
      name = 'Enable notifications to get more reward opportunities.';
    }
    return name;
  }

  String getBtnName() {
    String name = 'Ok';
    if (widget.type == .limted) {
      name = 'Ok';
    } else if (widget.type == .loadfaild) {
      name = 'Try Again';
    } else if (widget.type == .nowifi) {
      name = 'Try Again';
    } else if (widget.type == .notice) {
      name = 'Allow & Get \$10';
    }
    return name;
  }
}

// 退出挽留
class ASWaitDialog extends StatefulWidget {
  const ASWaitDialog({super.key});

  @override
  State<ASWaitDialog> createState() => ASWaitDialogState();
}

class ASWaitDialogState extends State<ASWaitDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.exitPopup, {});
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Spacer(),
            Container(
              width: 0.width(context),
              height: 311.h,
              decoration: BoxDecoration(image: ASDImg('as_wait_bg')),
              child: Column(
                children: [
                  SizedBox(height: 46.h),
                  Row(
                    children: [
                      SizedBox(width: 25.w),
                      ASText(
                        text: 'Wait!',
                        size: 48,
                        color: '#451F80'.color(),
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      SizedBox(width: 25.w),
                      ASText(
                        text: 'You next surprise is almost ready!',
                        size: 16,
                        color: '#451F80'.color(),
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      SizedBox(width: 25.w),
                      SizedBox(
                        width: 331,
                        height: 40,
                        child: ASText(
                          text:
                              'leave now and you‘ll miss today’s bouns spin.would you like to stay and check it out?',
                          size: 14,
                          color: '#4A474B'.color(),
                          weight: FontWeight.w600,
                          maxLines: 2,
                          align: .left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  ParticleButton(
                    onTap: () {
                      as_event_fire(ASTrackEvent.exitPopupClick, {
                        'types': 'keep',
                      });
                      Navigator.pop(context, 0);
                    },
                    child: Container(
                      width: 339.w,
                      height: 55.h,
                      decoration: BoxDecoration(image: ASDImg('as_zi_btn_bg')),
                      child: Center(
                        child: ASText(
                          text: 'Keep Playing',
                          size: 24,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ASUnderlineTextButton(
                    text: 'Exit Anyway',
                    fontSize: 16,
                    textColor: '#65576F'.color(),
                    underlineColor: '#65576F'.color(),
                    onPressed: () {
                      as_event_fire(ASTrackEvent.exitPopupClick, {
                        'types': 'exit',
                      });
                      Navigator.pop(context, 1);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          bottom: 200.h,
          child: ASImg(name: 'as_wait_icon', width: 227, height: 232),
        ),
      ],
    );
  }
}

// 首次获得奖励
class ASFristAwardDialog extends StatefulWidget {
  const ASFristAwardDialog({super.key});

  @override
  State<ASFristAwardDialog> createState() => ASFristAwardDialogState();
}

class ASFristAwardDialogState extends State<ASFristAwardDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context, 1);
      },
      child: SizedBox(
        width: 0.width(context),
        height: 0.height(context),
        child: Stack(
          children: [
            Positioned(
              left: 16.w,
              top: 48.h,
              child: Container(
                width: 298.w,
                height: 51.h,
                decoration: BoxDecoration(image: ASDImg('as_top_bg')),
                child: Stack(
                  children: [
                    Positioned(
                      left: 13.w,
                      top: 10,
                      child: ASImg(
                        name: 'as_dollar_icon',
                        width: 38,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      right: 10.w,
                      top: 9.h,
                      child: ASImg(
                        name:
                            'as_pp_${ASLocalProvider.instance.as_tx_ing_account}',
                        width: 82,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      left: 50.w,
                      top: 9.h,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: text_fontName,
                            color: '#733A1B'.color(),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  '\$${ASLocalProvider.instance.as_dollar_number}',
                            ),
                            TextSpan(
                              text: '/\$1000',
                              style: TextStyle(color: '#0A8A33'.color()),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      left: 53.w,
                      bottom: 12.h,
                      child: Container(
                        width: 138,
                        height: 11,
                        decoration: BoxDecoration(
                          image: ASDImg('as_home_pro_1'),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 138 * 0.5,
                              height: 11,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5.5),
                                color: '#FFEE38'.color(),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 56.w,
              top: 110.h,
              child: Container(
                width: 265,
                height: 89,
                decoration: BoxDecoration(image: ASDImg('as_doaller_bgs')),
                child: Stack(
                  children: [
                    Positioned(
                      left: 24.w,
                      top: 50,
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 18.0,
                            fontWeight: FontWeight.w900,
                            fontFamily: text_fontName,
                            color: '#DC2918'.color(),
                          ),
                          children: <TextSpan>[
                            TextSpan(
                              text:
                                  '\$${ASLocalProvider.instance.as_dollar_number}',
                            ),
                            TextSpan(
                              text: ' Stored In Account. ',
                              style: TextStyle(color: '#240B4F'.color()),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// 运营1
class ASYunying1Dialog extends StatefulWidget {
  const ASYunying1Dialog({super.key});

  @override
  State<ASYunying1Dialog> createState() => ASYunying1DialogState();
}

class ASYunying1DialogState extends State<ASYunying1Dialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _leftAnimation;
  late final Animation<Offset> _rightAnimation;
  late Route<dynamic> _route;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _leftAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _rightAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // 精确移除当前弹窗路由，避免被其他弹窗覆盖时永久留在路由栈中。
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      if (_route.isActive) {
        Navigator.of(context).removeRoute(_route, 1);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context)!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 392.h,
          child: SlideTransition(
            position: _rightAnimation,
            child: ASImg(name: 'as_right_icons', width: 363, height: 110),
          ),
        ),
        Positioned(
          left: 0,
          top: 254.h,
          child: SlideTransition(
            position: _leftAnimation,
            child: ASImg(name: 'as_left_icons', width: 362, height: 158),
          ),
        ),
      ],
    );
  }
}

// 运营2
class ASyunying2Dialog extends StatefulWidget {
  const ASyunying2Dialog({super.key});

  @override
  State<ASyunying2Dialog> createState() => ASyunying2DialogState();
}

class ASyunying2DialogState extends State<ASyunying2Dialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            ASImg(name: 'as_yunying2_top', width: 358, height: 62),
            SizedBox(height: 22.h),
            Row(
              children: [
                Spacer(),
                ASImg(name: 'as_yunying2_center', width: 265, height: 101),
                SizedBox(width: 30.w),
              ],
            ),
            SizedBox(height: 3.5.h),
            ASSpine(width: 169, height: 165, path: 'securemoney'.spinepaths()),
            SizedBox(height: 15.h),
            SizedBox(
              width: 309,
              height: 72,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Your game was a success! To send your '),
                    TextSpan(
                      text:
                          '\$${0.to2Double(ASLocalProvider.instance.as_dollar_number)} ',
                      style: TextStyle(color: '#FFE100'.color()),
                    ),
                    TextSpan(
                      text: 'in earnings, we just need your payout info.. ',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 36.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 1);
              },
              child: Container(
                width: 339,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Secure My Winnings',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            ASUnderlineTextButton(
              text: 'Later On',
              fontSize: 16,
              textColor: '#CEC4D5'.color(),
              underlineColor: '#CEC4D5'.color(),
              onPressed: () {
                Navigator.pop(context, 0);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// 运营5-提现信息填写
class ASyunying3Dialog extends StatefulWidget {
  const ASyunying3Dialog({super.key});

  @override
  State<ASyunying3Dialog> createState() => ASyunying3DialogState();
}

class ASyunying3DialogState extends State<ASyunying3Dialog> {
  final TextEditingController _accountController = TextEditingController();
  int _selectedPlatform = 0;
  bool _isSubmitting = false;

  bool get _canConfirm =>
      _accountController.text.trim().isNotEmpty && !_isSubmitting;

  String get _accountLabel => _selectedPlatform == 0 ? 'Account' : 'Phone';

  String get _accountHint => _selectedPlatform == 0
      ? 'Please enter your PayPal email'
      : 'Please enter your 10-digit phone number';

  String get _paymentTip => _selectedPlatform == 0
      ? 'Direct To Your Paypal Instant Payment'
      : 'Direct To Your Cash Instant Payment';

  @override
  void initState() {
    super.initState();
    _accountController.addListener(_refreshConfirmButton);
  }

  @override
  void dispose() {
    _accountController
      ..removeListener(_refreshConfirmButton)
      ..dispose();
    super.dispose();
  }

  void _refreshConfirmButton() {
    if (mounted) setState(() {});
  }

  void _selectPlatform(int platform) {
    if (_selectedPlatform == platform) return;
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() {
      _selectedPlatform = platform;
      _accountController.clear();
    });
  }

  bool _isValidAccount(String value) {
    if (_selectedPlatform == 1) {
      return RegExp(r'^\d{10}$').hasMatch(value);
    }
    return RegExp(
      r"^[A-Za-z0-9.!#$%&'*+/=?^_`{|}~-]+@[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?(?:\.[A-Za-z0-9](?:[A-Za-z0-9-]{0,61}[A-Za-z0-9])?)+$",
    ).hasMatch(value);
  }

  Future<void> _confirm() async {
    if (!_canConfirm) return;
    final account = _accountController.text.trim();
    if (!_isValidAccount(account)) {
      _accountController.clear();
      ASDialogTool.toast(context, 'The format you entered is incorrect.');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });
    final provider = ASLocalProvider.instance;
    await provider.updateint(provider.as_tx_ing_accountName, _selectedPlatform);
    await provider.updateint(
      provider.as_account_seled_indexName,
      _selectedPlatform,
    );
    await provider.updateString(provider.as_account_idName, account);
    as_event_fire(ASTrackEvent.withdrawalInformation, {});
    if (!context.mounted) return;
    Navigator.pop(context, 1);
  }

  @override
  Widget build(BuildContext context) {
    final isPhone = _selectedPlatform == 1;
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    const Spacer(),
                    ParticleButton(
                      onTap: () => Navigator.pop(context, 0),
                      child: SizedBox(
                        width: 40,
                        height: 40,
                        child: Center(
                          child: ASImg(
                            name: 'as_close_w',
                            width: 18,
                            height: 18,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 32.w),
                  ],
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 347,
                  height: 430,
                  decoration: BoxDecoration(image: ASDImg('as_tx_fa_bg')),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      ASText(
                        text: 'Payment Information',
                        size: 20,
                        color: '#FFFFFF'.color(),
                        weight: FontWeight.w700,
                      ),
                      const SizedBox(height: 45),
                      ParticleButton(
                        onTap: () => _selectPlatform(0),
                        child: ASImg(
                          name:
                              'as_act_0_${_selectedPlatform == 0 ? 's' : 'n'}',
                          width: 253,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 15),
                      ParticleButton(
                        onTap: () => _selectPlatform(1),
                        child: ASImg(
                          name:
                              'as_act_1_${_selectedPlatform == 1 ? 's' : 'n'}',
                          width: 253,
                          height: 60,
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 287,
                        child: ASText(
                          text: _accountLabel,
                          size: 14,
                          color: '#000000'.color(),
                          weight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: 287,
                        height: 48,
                        decoration: BoxDecoration(
                          color: '#E3E3E3'.color(),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: TextField(
                          key: ValueKey(
                            'withdrawal-account-$_selectedPlatform',
                          ),
                          controller: _accountController,
                          keyboardType: isPhone
                              ? TextInputType.phone
                              : TextInputType.emailAddress,
                          inputFormatters: isPhone
                              ? [
                                  FilteringTextInputFormatter.digitsOnly,
                                  LengthLimitingTextInputFormatter(10),
                                ]
                              : null,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF000000),
                            fontSize: 14,
                          ),
                          decoration: InputDecoration(
                            hintText: _accountHint,
                            hintStyle: TextStyle(
                              color: '#ACACAC'.color(),
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 14,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: 287,
                        child: ASText(
                          text: _paymentTip,
                          size: 12,
                          color: '#4A474B'.color(),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 27.h),
                GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: _canConfirm ? _confirm : null,
                  child: Container(
                    width: 287,
                    height: 55,
                    alignment: Alignment.center,
                    decoration: _canConfirm
                        ? BoxDecoration(image: ASDImg('as_yellow_btn_bg'))
                        : BoxDecoration(
                            color: '#9B9B9B'.color(),
                            borderRadius: BorderRadius.circular(28),
                          ),
                    child: ASText(
                      text: 'Confirm',
                      size: 24,
                      color: _canConfirm
                          ? '#5C300E'.color()
                          : '#D8D8D8'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(height: 50.h),
              ],
            ),
          ),
        );
      },
    );
  }
}

// 运营6-阶段收益
class ASyunying3ProgressDialog extends StatefulWidget {
  const ASyunying3ProgressDialog({super.key});

  @override
  State<ASyunying3ProgressDialog> createState() =>
      ASyunying3ProgressDialogState();
}

class ASyunying3ProgressDialogState extends State<ASyunying3ProgressDialog>
    with TickerProviderStateMixin {
  late AnimationController _noticeController;

  late AnimationController _noticeController1;

  late Animation<double> _noticeAnimation;

  late Animation<double> _noticeAnimation1;

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.remindPopup, {});

    _noticeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _noticeController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _noticeAnimation = Tween<double>(
      begin: 1.2,
      end: -1.2,
    ).animate(CurvedAnimation(parent: _noticeController, curve: Curves.linear));

    _noticeAnimation1 = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _noticeController1, curve: Curves.linear),
    );

    _noticeController.repeat();

    _noticeController1.repeat();
  }

  @override
  void dispose() {
    _noticeController.dispose();

    _noticeController1.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            SizedBox(
              width: 0.width(context),
              height: 76.h,

              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _noticeAnimation,

                    builder: (_, child) {
                      return Positioned(
                        left: _noticeAnimation.value * 300.w,
                        top: 0,
                        child: child!,
                      );
                    },
                    child: Container(
                      width: 277.w,
                      height: 32.h,
                      decoration: BoxDecoration(image: ASDImg('as_yunying3_0')),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 38.w,
                            top: 5.h,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: text_fontName,
                                  color: '#262933'.color(),
                                ),
                                children: <TextSpan>[
                                  const TextSpan(text: 'Congrats, '),
                                  TextSpan(
                                    text: '1****${Random().nextInt(900) + 99} ',
                                    style: TextStyle(color: '#3844B2'.color()),
                                  ),
                                  const TextSpan(text: 'withdrew '),
                                  TextSpan(
                                    text: '\$1000',
                                    style: TextStyle(color: '#1E7C2D'.color()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AnimatedBuilder(
                    animation: _noticeAnimation1,

                    builder: (_, child) {
                      return Positioned(
                        left: _noticeAnimation1.value * 300.w - 50.w,
                        top: 31.h,
                        child: child!,
                      );
                    },

                    child: Container(
                      width: 277.w,
                      height: 32.h,
                      decoration: BoxDecoration(image: ASDImg('as_yunying3_1')),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 38.w,
                            top: 5.h,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: text_fontName,
                                  color: '#262933'.color(),
                                ),
                                children: <TextSpan>[
                                  const TextSpan(text: 'Congrats, '),
                                  TextSpan(
                                    text: '1****${Random().nextInt(900) + 99} ',
                                    style: TextStyle(color: '#3844B2'.color()),
                                  ),
                                  const TextSpan(text: 'withdrew '),
                                  TextSpan(
                                    text: '\$1000',
                                    style: TextStyle(color: '#1E7C2D'.color()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            ASImg(name: 'as_yunying3_top', width: 223, height: 38),
            SizedBox(height: 10.h),
            SizedBox(
              width: 312,
              height: 42,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w900,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Your withdrawal progress is ahead of '),
                    TextSpan(
                      text: '92% ',
                      style: TextStyle(color: '#FFEA00'.color()),
                    ),
                    TextSpan(text: 'of users! '),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: 317,
              height: 351,
              decoration: BoxDecoration(image: ASDImg('as_yunying3_center')),
              child: Stack(
                children: [
                  Positioned(
                    left: 37,
                    top: 62,
                    child: ASText(
                      text:
                          '\$${0.to2Double(ASLocalProvider.instance.as_dollar_number)}',
                      size: 48,
                      color: '#FFFFFF'.color(),
                      weight: FontWeight.w700,
                    ),
                  ),
                  Positioned(
                    left: 34,
                    top: 160,
                    child: ASImg(
                      name: 'as_yunying3_line',
                      width: 18,
                      height: 96,
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 200,
                    child: ASText(
                      text:
                          'Just \$${0.to2Double(1000 - ASLocalProvider.instance.as_dollar_number)} away from payout!',
                      size: 14,
                      color: '#B11212'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 160,
                    child: ASText(
                      text: 'Submit payment information',
                      size: 14,
                      color: '#312E2D'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 60,
                    top: 238,
                    child: ASText(
                      text: 'Revenue received',
                      size: 14,
                      color: '#8E8779'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 15,
                    bottom: 20,
                    child: ParticleButton(
                      onTap: () {
                        as_event_fire(ASTrackEvent.remindPopupClick, {});
                        Navigator.pop(context, 1);
                      },
                      child: Container(
                        width: 287,
                        height: 55,
                        decoration: BoxDecoration(
                          image: ASDImg('as_yellow_btn_bg'),
                        ),
                        child: Center(
                          child: ASText(
                            text: 'Play Game',
                            size: 24,
                            color: '#5C300E'.color(),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 34.h),
            Visibility(
              visible: false,
              child: Container(
                width: 339.w,
                height: 120.h,
                decoration: BoxDecoration(image: ASDImg('as_yunying3_bottom')),
                child: Stack(
                  children: [
                    Column(
                      children: [
                        SizedBox(height: 15.h),
                        Row(
                          children: [
                            SizedBox(width: 14.w),
                            ASText(
                              text: '\$ 1000',
                              size: 32,
                              color: '#1C4779'.color(),
                              weight: FontWeight.w600,
                            ),
                            Spacer(),
                            ParticleButton(
                              child: Container(
                                width: 119,
                                height: 33,
                                decoration: BoxDecoration(
                                  image: ASDImg('as_zi_s_btn'),
                                ),
                                child: Center(
                                  child: ASText(
                                    text: 'Cash Out',
                                    size: 16,
                                    color: '#FFFFFF'.color(),
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              onTap: () {},
                            ),
                            SizedBox(width: 14.w),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Container(
                          width: 304.w,
                          height: 16.h,
                          decoration: BoxDecoration(
                            color: '#C0BFCA'.color(),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 2.w,
                                top: 2.h,
                                child: Container(
                                  width:
                                      300.w *
                                      (ASLocalProvider
                                              .instance
                                              .as_dollar_number /
                                          1000),
                                  height: 12.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(6.h),
                                    color: '#4045D8'.color(),
                                  ),
                                ),
                              ),
                              Center(
                                child: ASStrokeText(
                                  text:
                                      '${((ASLocalProvider.instance.as_dollar_number / 1000) * 100).toInt()}%',
                                  size: 12,
                                  color: '#FFD000'.color(),
                                  weight: FontWeight.w600,
                                  skWidth: 1,
                                  skColor: '#000000'.color(),
                                ),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            SizedBox(width: 20.w),
                            ASText(
                              text: 'Accumulate \$1000 to cash out.',
                              size: 12,
                              color: '#4A474B'.color(),
                              weight: FontWeight.w200,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 提现申请
class ASyunying4Dialog extends StatefulWidget {
  const ASyunying4Dialog({super.key});

  @override
  State<ASyunying4Dialog> createState() => ASyunying4DialogState();
}

class ASyunying4DialogState extends State<ASyunying4Dialog>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController;
  late final AnimationController _progressController;
  bool _isLoadingAd = false;
  bool _progressCompleted = false;
  bool _isTransitioning = false;

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.paymentApplication, {});

    // 无限旋转
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // 25秒进度
    _progressController =
        AnimationController(vsync: this, duration: const Duration(seconds: 25))
          ..addStatusListener((status) {
            if (status != AnimationStatus.completed) return;
            _progressCompleted = true;
            if (!_isLoadingAd) {
              _enterNextDialog();
            }
          })
          ..forward();
  }

  Future<void> _enterNextDialog() async {
    if (_isTransitioning || !mounted) return;
    _isTransitioning = true;
    final navigator = Navigator.of(context);
    navigator.pop(1);
  }

  void _skipWithRewardAd() {
    if (_isLoadingAd || _isTransitioning) return;
    setState(() {
      _isLoadingAd = true;
    });
    as_event_fire(ASTrackEvent.paymentApplicationClick, {});
    ASCardAds().as_showAd(
      context,
      ASTrackEvent.withdrawalApplyRewarded,
      onCacheResponse: (_) {
        if (!mounted) return;
        setState(() {
          _isLoadingAd = false;
        });
        if (_progressCompleted) {
          _enterNextDialog();
        }
      },
      adDidClosed: (success) async {
        if (!mounted) return;
        if (success) {
          await _enterNextDialog();
          return;
        }
        setState(() {
          _isLoadingAd = false;
        });
        if (_progressCompleted) {
          await _enterNextDialog();
        }
      },
    );
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Row(
            //   children: [
            //     const Spacer(),
            //     ParticleButton(
            //       child: SizedBox(
            //         width: 40,
            //         height: 40,
            //         child: Center(
            //           child: ASImg(name: 'as_close_w', width: 18, height: 18),
            //         ),
            //       ),
            //       onTap: () {
            //         Navigator.pop(context, 0);
            //       },
            //     ),
            //     SizedBox(width: 32.w),
            //   ],
            // ),
            SizedBox(height: 41.h),

            /// 无限旋转
            RotationTransition(
              turns: _rotateController,
              child: ASImg(name: 'as_loading_icon', width: 108, height: 108),
            ),

            SizedBox(height: 51.h),

            /// 25秒进度条
            Container(
              width: 217,
              height: 16,
              decoration: BoxDecoration(
                color: '#FFFFFF'.color(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (_, __) {
                  return Stack(
                    children: [
                      Positioned(
                        left: 1,
                        top: 1,
                        child: Container(
                          width: 215 * _progressController.value,
                          height: 14,
                          decoration: BoxDecoration(
                            color: '#E8800A'.color(),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 31.h),

            SizedBox(
              width: 287,
              height: 48,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: const <TextSpan>[
                    TextSpan(
                      text:
                          'Due to a high number of requests, processing may take a bit longer.',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 57.h),

            ParticleButton(
              onTap: _skipWithRewardAd,
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_s_bg')),
                child: Center(
                  child: ASText(
                    text: _isLoadingAd ? 'Loading...' : 'Skip Now',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        Positioned(
          right: 38.w,
          bottom: 225.h,
          child: ASImg(name: 'as_ads_icon', width: 47, height: 47),
        ),
      ],
    );
  }
}

// 申请成功
class ASyunying5Dialog extends StatefulWidget {
  const ASyunying5Dialog({super.key});

  @override
  State<ASyunying5Dialog> createState() => ASyunying5DialogState();
}

class ASyunying5DialogState extends State<ASyunying5Dialog>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 11.h),
            ASImg(name: 'as_duis_icons', width: 143, height: 151),
            SizedBox(height: 37.h),
            Container(
              width: 217,
              height: 16,
              decoration: BoxDecoration(
                color: '#FFFFFF'.color(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 1,
                    top: 1,
                    child: Container(
                      width: 215 * 1.0,
                      height: 14,
                      decoration: BoxDecoration(
                        color: '#E8800A'.color(),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 31.h),

            SizedBox(
              width: 287,
              height: 48,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: const <TextSpan>[
                    TextSpan(
                      text:
                          'Due to a high number of requests, processing may take a bit longer.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 翻卡
class ASyunying6Dialog extends StatefulWidget {
  const ASyunying6Dialog({super.key});

  @override
  State<ASyunying6Dialog> createState() => ASyunying6DialogState();
}

class ASyunying6DialogState extends State<ASyunying6Dialog>
    with TickerProviderStateMixin {
  /// 当前是否正在翻牌
  bool _isOpening = false;

  /// 三张牌是否已经全部翻开
  bool _allOpened = false;

  /// 首次点击的中奖牌位置
  int? _winningCardIndex;

  final List<String> _resultImages = List<String>.filled(3, 'as_yunying6_bg');

  /// 三张牌翻牌控制器
  late AnimationController _centerFlipController;
  late AnimationController _leftFlipController;
  late AnimationController _rightFlipController;

  /// 翻牌动画
  late Animation<double> _centerFlipAnimation;
  late Animation<double> _leftFlipAnimation;
  late Animation<double> _rightFlipAnimation;

  /// 光效呼吸
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.withdrawalCard, {});

    _centerFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _leftFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _rightFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _centerFlipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _centerFlipController, curve: Curves.easeInOut),
    );

    _leftFlipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _leftFlipController, curve: Curves.easeInOut),
    );

    _rightFlipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _rightFlipController, curve: Curves.easeInOut),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _centerFlipController.dispose();

    _leftFlipController.dispose();

    _rightFlipController.dispose();

    _breathController.dispose();

    super.dispose();
  }

  AnimationController _controllerFor(int index) {
    if (index == 0) return _leftFlipController;
    if (index == 1) return _centerFlipController;
    return _rightFlipController;
  }

  /// 点击任意牌后先翻出中奖牌，再依次翻开其余两张牌。
  Future<void> _openCard(int selectedIndex) async {
    if (_isOpening || _winningCardIndex != null) return;
    final otherIndexes = [
      0,
      1,
      2,
    ].where((index) => index != selectedIndex).toList();

    setState(() {
      _isOpening = true;
      _winningCardIndex = selectedIndex;
      _resultImages[selectedIndex] = 'as_yunying6_0';
      _resultImages[otherIndexes[0]] = 'as_yunying6_1';
      _resultImages[otherIndexes[1]] = 'as_yunying6_2';
    });

    await _controllerFor(selectedIndex).forward();
    _breathController.repeat(reverse: true);

    for (final index in otherIndexes) {
      await Future.delayed(const Duration(milliseconds: 200));
      if (!mounted) return;
      await _controllerFor(index).forward();
    }

    if (!mounted) return;
    setState(() {
      _isOpening = false;
      _allOpened = true;
    });
  }

  Widget _buildCard(int index) {
    Widget card = Container(
      width: 123,
      height: 164,

      decoration: BoxDecoration(
        image: index == _winningCardIndex ? ASDImg('as_yunying6_guang') : null,
      ),

      child: Stack(
        children: [
          Positioned(
            left: 2.5,

            top: 5.5,

            child: ASImg(name: 'as_yunying6_bg', width: 117, height: 158),
          ),
        ],
      ),
    );

    Animation<double> animation;

    if (index == 0) {
      animation = _leftFlipAnimation;
    } else if (index == 1) {
      animation = _centerFlipAnimation;
    } else {
      animation = _rightFlipAnimation;
    }

    return ParticleButton(
      onTap: () => _openCard(index),
      child: AnimatedBuilder(
        animation: animation,

        builder: (_, child) {
          final angle = animation.value;

          return Transform(
            alignment: Alignment.center,

            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.0015)
              ..rotateY(angle),

            child: angle > pi / 2
                ? Transform(
                    alignment: Alignment.center,

                    transform: Matrix4.identity()..rotateY(pi),

                    child: index == _winningCardIndex
                        ? ScaleTransition(
                            scale: _breathAnimation,

                            child: _resultCard(index),
                          )
                        : _resultCard(index),
                  )
                : child,
          );
        },

        child: card,
      ),
    );
  }

  Widget _resultCard(int index) {
    final imageName = _resultImages[index];

    return Container(
      width: 123,

      height: 164,

      decoration: BoxDecoration(
        image: index == _winningCardIndex ? ASDImg('as_yunying6_guang') : null,
      ),

      child: Stack(
        children: [
          Positioned(
            left: 2.5,

            top: 5.5,

            child: ASImg(name: imageName, width: 117, height: 158),
          ),
        ],
      ),
    );
  }

  Widget _buildCards() {
    return SizedBox(
      width: 1.sw,

      height: 164,

      child: Stack(
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: SizedBox(
              width: 369,
              height: 164,
              child: Row(
                children: [_buildCard(0), _buildCard(1), _buildCard(2)],
              ),
            ),
          ),
          if (_winningCardIndex == null)
            Positioned(
              left: (1.sw - 70.w) * 0.5 + 28.w,
              top: 76.h,
              child: IgnorePointer(
                child: ASTapGuide(width: 70.w, height: 70.h),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            // Row(
            //   children: [
            //     const Spacer(),
            //
            //     ParticleButton(
            //       child: SizedBox(
            //         width: 40,
            //
            //         height: 40,
            //
            //         child: Center(
            //           child: ASImg(name: 'as_close_w', width: 18, height: 18),
            //         ),
            //       ),
            //
            //       onTap: () {
            //         Navigator.pop(context, 0);
            //       },
            //     ),
            //
            //     SizedBox(width: 32.w),
            //   ],
            // ),
            SizedBox(height: 21.h),

            ASImg(name: 'as_yunying6_top', width: 345, height: 69),

            SizedBox(height: 31.h),

            _buildCards(),

            SizedBox(height: 31.h),

            SizedBox(
              height: 55,
              child: _allOpened
                  ? ParticleButton(
                      onTap: () => Navigator.pop(context, 1),
                      child: Container(
                        width: 339,
                        height: 55,
                        decoration: BoxDecoration(
                          image: ASDImg('as_yellow_btn_bg'),
                        ),
                        child: Center(
                          child: ASText(
                            text: 'Next',
                            size: 24,
                            color: '#5C300E'.color(),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    )
                  : null,
            ),

            SizedBox(height: 50.h),
          ],
        ),
      ],
    );
  }
}

// 骰子次数不足
class ASDiceNotEnoughDialog extends StatelessWidget {
  const ASDiceNotEnoughDialog({super.key});

  int _availableScratchType() {
    final provider = ASLocalProvider.instance;
    final usedCounts = [
      provider.as_scrach_end_number_0,
      provider.as_scrach_end_number_1,
      provider.as_scrach_end_number_2,
      provider.as_scrach_end_number_3,
      provider.as_scrach_end_number_4,
      provider.as_scrach_end_number_5,
    ];
    return usedCounts.indexWhere((usedCount) => usedCount < 10);
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 347,
            height: 308,
            decoration: BoxDecoration(image: ASDImg('as_dice_tip_bg')),
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 17,
                  child: Center(
                    child: ASText(
                      text: 'Not Enough Dice To Roll',
                      size: 17,
                      color: '#FFFFFF'.color(),
                      weight: FontWeight.w900,
                    ),
                  ),
                ),
                Positioned(
                  top: 6,
                  right: 7,
                  child: ParticleButton(
                    onTap: () => Navigator.pop(context, -1),
                    child: SizedBox(
                      width: 42,
                      height: 42,
                      child: Center(
                        child: ASImg(name: 'as_close_x', width: 28, height: 28),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  top: 108,
                  child: Center(
                    child: ASImg(
                      name: 'as_dice_not_icon',
                      width: 142,
                      height: 133,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 18.h),
          ParticleButton(
            onTap: () {
              final type = _availableScratchType();
              if (type < 0) return;
              Navigator.pop(context, type);
            },
            child: Container(
              width: 287,
              height: 55,
              alignment: Alignment.center,
              decoration: BoxDecoration(image: ASDImg('as_yellow_s_bg')),
              child: ASText(
                text: 'Find It',
                size: 22,
                color: '#5C300E'.color(),
                weight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 刮卡次数不足
class ASScratchChanceDialog extends StatefulWidget {
  final int type;

  const ASScratchChanceDialog({super.key, required this.type});

  @override
  State<ASScratchChanceDialog> createState() => ASScratchChanceDialogState();
}

class ASScratchChanceDialogState extends State<ASScratchChanceDialog> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.sheetNumberPopup, {});
  }

  int get _usedCount {
    final provider = ASLocalProvider.instance;
    switch (widget.type) {
      case 0:
        return provider.as_scrach_end_number_0;
      case 1:
        return provider.as_scrach_end_number_1;
      case 2:
        return provider.as_scrach_end_number_2;
      case 3:
        return provider.as_scrach_end_number_3;
      case 4:
        return provider.as_scrach_end_number_4;
      case 5:
        return provider.as_scrach_end_number_5;
      default:
        return 0;
    }
  }

  String get _usedCountKey {
    final provider = ASLocalProvider.instance;
    switch (widget.type) {
      case 0:
        return provider.as_scrach_end_number_0Name;
      case 1:
        return provider.as_scrach_end_number_1Name;
      case 2:
        return provider.as_scrach_end_number_2Name;
      case 3:
        return provider.as_scrach_end_number_3Name;
      case 4:
        return provider.as_scrach_end_number_4Name;
      case 5:
        return provider.as_scrach_end_number_5Name;
      default:
        return provider.as_scrach_end_number_0Name;
    }
  }

  Future<void> _addFiveScratchChances() async {
    // 弹窗固定 +5，但保留负值以允许单个刮卡累计超过 10 次。
    await ASLocalProvider.instance.updateint(_usedCountKey, _usedCount - 5);
  }

  void _getScratchChances() {
    if (_isLoading) return;
    as_event_fire(ASTrackEvent.sheetNumberClick, {});
    setState(() {
      _isLoading = true;
    });

    ASCardAds().as_showAd(
      context,
      ASTrackEvent.getCardRewarded,
      onCacheResponse: (_) {
        if (!mounted) return;
        setState(() {
          _isLoading = false;
        });
      },
      adDidClosed: (_) async {
        await _addFiveScratchChances();
        if (!mounted) return;
        Navigator.pop(context, 1);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontFamily: text_fontName,
                fontSize: 26,
                fontWeight: FontWeight.w900,
                color: '#FFFFFF'.color(),
                shadows: [
                  Shadow(
                    color: '#6B00BE'.color(),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              children: [
                const TextSpan(text: 'Wealth '),
                TextSpan(
                  text: '+5',
                  style: TextStyle(color: '#FFF600'.color(), fontSize: 38),
                ),
                const TextSpan(text: ' Chances'),
              ],
            ),
          ),
          SizedBox(height: 32.h),
          ASImg(
            name: 'as_get_iocn_${widget.type.clamp(0, 5)}',
            width: 190,
            height: 200,
          ),
          SizedBox(height: 32.h),
          Transform.translate(
            offset: const Offset(0, -6),
            child: ASStrokeText(
              text: '+5',
              size: 48,
              color: '#FFF600'.color(),
              weight: FontWeight.w900,
              skWidth: 2,
              skColor: '#6412A8'.color(),
            ),
          ),
          SizedBox(height: 26.h),
          ParticleButton(
            onTap: _getScratchChances,
            child: Container(
              width: 262,
              height: 84,
              decoration: BoxDecoration(image: ASDImg('as_green_btn')),
              child: Stack(
                children: [
                  Center(
                    child: ASStrokeText(
                      text: _isLoading ? 'Loading...' : 'Get',
                      size: 28,
                      color: '#FFFFFF'.color(),
                      weight: FontWeight.w900,
                      skWidth: 2,
                      skColor: '#41740A'.color(),
                    ),
                  ),
                  Positioned(
                    right: 0,
                    top: 0,
                    child: ASImg(name: 'as_ads_icon', width: 42, height: 42),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// 设置
class ASPopSettingDialog extends StatefulWidget {
  ASPopSettingDialog({super.key});
  @override
  State<ASPopSettingDialog> createState() => ASPopSettingDialogState();
}

class ASPopSettingDialogState extends State<ASPopSettingDialog> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 340,
            height: 382,
            decoration: BoxDecoration(image: ASDImg('as_set_bg')),
            child: Column(
              children: [
                SizedBox(height: 15.h),
                ASStrokeText(
                  text: 'Settings',
                  size: 24,
                  color: '#FFFFFF'.color(),
                  weight: FontWeight.w900,
                  skWidth: 1,
                  skColor: '#000000'.color(),
                ),
                SizedBox(height: 32.0.h),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () async {
                          if (ASLocalProvider.instance.as_sound_music) {
                            await ASLocalProvider.instance.updateBool(
                              ASLocalProvider.instance.as_sound_musicName,
                              false,
                            );
                          } else {
                            await ASLocalProvider.instance.updateBool(
                              ASLocalProvider.instance.as_sound_musicName,
                              true,
                            );
                          }
                          setState(() {});
                        },
                        child: Center(
                          child: ASImg(
                            name: ASLocalProvider.instance.as_sound_music
                                ? 'as_sound_s'
                                : 'as_sound_n',
                            width: 88,
                            height: 88,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 28.w),
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: InkWell(
                        splashColor: Colors.transparent,
                        highlightColor: Colors.transparent,
                        hoverColor: Colors.transparent,
                        focusColor: Colors.transparent,
                        onTap: () async {
                          if (ASLocalProvider.instance.as_bg_music) {
                            ASLocalProvider.instance.as_bg_music = false;
                            await ASAudioUtils().pauseBGM();
                            await ASLocalProvider.instance.updateBool(
                              ASLocalProvider.instance.as_bg_musicName,
                              false,
                            );
                          } else {
                            ASLocalProvider.instance.as_bg_music = true;
                            await ASLocalProvider.instance.updateBool(
                              ASLocalProvider.instance.as_bg_musicName,
                              true,
                            );
                            await ASAudioUtils().playBGM();
                          }
                          setState(() {});
                        },
                        child: Center(
                          child: ASImg(
                            name: ASLocalProvider.instance.as_bg_music
                                ? 'as_bgmusic_s'
                                : 'as_bgmusic_n',
                            width: 88,
                            height: 88,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.12.h),
                Container(
                  width: 246,
                  height: 65,
                  decoration: BoxDecoration(image: ASDImg('as_user_btn')),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (builder) {
                            return ASWebkitview(
                              url:
                                  "https://sites.google.com/view/170terms-of-use/home",
                              title: 'User Agreement',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 10.12.h),
                Container(
                  width: 246,
                  height: 65,
                  decoration: BoxDecoration(image: ASDImg('as_priacy_btn')),
                  child: InkWell(
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onTap: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (builder) {
                            return ASWebkitview(
                              url:
                                  "https://sites.google.com/view/170privacypolicy/home",
                              title: 'Privacy Policy',
                            );
                          },
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: 18.w,
            top: (0.height(context) - 362.h) * 0.35,
            width: 48,
            height: 48,
            child: ParticleButton(
              child: SizedBox(
                width: 48,
                height: 48,
                child: Center(
                  child: ASImg(name: 'as_close_x', width: 30, height: 30),
                ),
              ),
              onTap: () {
                Navigator.pop(context, 0);
              },
            ),
          ),
          Positioned(
            right: (0.width(context) - 338) * 0.5,
            bottom: 90.h,
            width: 338,
            height: 60,
            child: ASImg(name: 'as_set_bottom'),
          ),
        ],
      ),
    );
  }
}
