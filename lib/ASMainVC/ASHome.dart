import 'dart:async';
import 'dart:math';
import 'package:aurastack/ASDialog/ASOther/ASOtherDialog.dart';
import 'package:aurastack/ASMainVC/ASCash.dart';
import 'package:aurastack/ASMainVC/ASScratch.dart';
import 'package:aurastack/ASMainVC/ASTask.dart';
import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/as_GradientText.dart';
import 'package:aurastack/ASTool/as_shine.dart';
import 'package:aurastack/ASTool/as_spine_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_tba_info/flutter_tba_info.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ASDialog/ASAward/ASAwardDialog.dart';
import '../ASDialog/ASCash/ASCashDialog.dart';
import '../ASTool/ASFKManger.dart';
import '../ASTool/ASLogger.dart';
import '../ASTool/ASNoticeHelp.dart';
import '../ASTool/ASTBAEventTool.dart';
import '../ASTool/ASTrackEvent.dart';
import '../ASTool/ASWithdrawalFlow.dart';
import '../ASTool/ASbubbleTool.dart';
import '../ASTool/ASAudioUtils.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/as_WebKitView.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';
import '../ASTool/as_stroke_text.dart';
import '../ASTool/as_text.dart';
import 'ASDice.dart';

final GlobalKey<AShomeState> homeKey = GlobalKey<AShomeState>();

class AShome extends StatefulWidget {
  AShome({super.key});

  @override
  State<AShome> createState() => AShomeState();
}

class AShomeState extends State<AShome> with SingleTickerProviderStateMixin {
  int shineIndex = 0;

  final GlobalKey _firstScratchCardKey = GlobalKey();
  Timer? _shineTimer;
  Timer? _scratchRecoveryTimer;
  OverlayEntry? _firstHomeGuideOverlay;
  bool _isRestoringScratchCount = false;
  bool _isOpeningFirstScratchGuide = false;
  bool _isHandlingExit = false;
  bool _didShowWithdrawalTaskOnLaunch = false;
  Future<void>? _noticeInitFuture;
  int _scratchRecoverySeconds = 60;

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.homePage, {});
    if (ASLocalProvider.instance.as_bg_music) {
      ASAudioUtils().playBGM();
    }
    ASAudioUtils().prepareScratchAudio();
    ASAudioUtils().prepareDolasAudio();
    ASFKManger().initFK();
    _noticeInitFuture = ASNoticeHelp().initNotice(context).catchError((
      error,
      stackTrace,
    ) {
      asLog.error(
        'Notification initialization failed',
        tag: 'ASHome',
        error: error,
        stackTrace: stackTrace,
      );
    });
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ASLocalProvider.instance.init();
      if (!mounted) return;
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedFirstHomeGuide =
          prefs.getBool(ASLocalProvider.instance.as_first_show_homeName) ??
          false;

      // 老用户每日宝箱优先，关闭后再恢复未完成的提现任务。
      if (hasCompletedFirstHomeGuide) {
        await _showOldUserBoxOnceToday(prefs);
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
      }

      final taskIndex = ASLocalProvider.instance.as_tx_task_index;
      if (taskIndex > 0 && !_didShowWithdrawalTaskOnLaunch) {
        _didShowWithdrawalTaskOnLaunch = true;
        await ASWithdrawalFlow.instance.showTask(context, taskIndex);
        await Future.delayed(const Duration(milliseconds: 300));
        if (!mounted) return;
      }

      if (!hasCompletedFirstHomeGuide) {
        await _showFirstHomeGuide();
      } else {
        await ASNoticeHelp().showPendingFollowUp(context);
      }
    });

    _shineTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted) return;

      setState(() {
        shineIndex++;

        if (shineIndex >= 6) {
          shineIndex = 0;
        }
      });
    });

    _startScratchRecoveryTimer();
  }

  List<int> _scratchUsedCounts() {
    final provider = ASLocalProvider.instance;
    return [
      provider.as_scrach_end_number_0,
      provider.as_scrach_end_number_1,
      provider.as_scrach_end_number_2,
      provider.as_scrach_end_number_3,
      provider.as_scrach_end_number_4,
      provider.as_scrach_end_number_5,
    ];
  }

  List<String> _scratchUsedCountKeys() {
    final provider = ASLocalProvider.instance;
    return [
      provider.as_scrach_end_number_0Name,
      provider.as_scrach_end_number_1Name,
      provider.as_scrach_end_number_2Name,
      provider.as_scrach_end_number_3Name,
      provider.as_scrach_end_number_4Name,
      provider.as_scrach_end_number_5Name,
    ];
  }

  void _startScratchRecoveryTimer() {
    if (_scratchUsedCounts().every((count) => count <= 0)) {
      _scratchRecoveryTimer?.cancel();
      _scratchRecoveryTimer = null;
      return;
    }
    if (_scratchRecoveryTimer?.isActive == true) return;

    _scratchRecoverySeconds = 60;
    _scratchRecoveryTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => _handleScratchRecoveryTick(),
    );
  }

  Future<void> _handleScratchRecoveryTick() async {
    if (_isRestoringScratchCount) return;
    if (_scratchRecoverySeconds > 1) {
      if (!mounted) return;
      setState(() {
        _scratchRecoverySeconds--;
      });
      return;
    }

    _scratchRecoverySeconds = 60;
    await _restoreScratchCounts();
    if (mounted) setState(() {});
  }

  Future<void> _restoreScratchCounts() async {
    if (_isRestoringScratchCount) return;
    _isRestoringScratchCount = true;

    try {
      final counts = _scratchUsedCounts();
      final keys = _scratchUsedCountKeys();
      final prefs = await SharedPreferences.getInstance();
      for (var index = 0; index < counts.length; index++) {
        if (counts[index] > 0) {
          counts[index]--;
          await prefs.setInt(keys[index], counts[index]);
        }
      }
      await ASLocalProvider.instance.init();

      if (counts.every((count) => count <= 0)) {
        _scratchRecoveryTimer?.cancel();
        _scratchRecoveryTimer = null;
      }
    } finally {
      _isRestoringScratchCount = false;
    }
  }

  Future<void> _openScratch(int type) async {
    if (_scratchUsedCounts()[type] >= 10) {
      await context.tipShow(ASScratchChanceDialog(type: type));
      if (mounted) _startScratchRecoveryTimer();
      return;
    }

    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ASScratch(type: type)),
    );
    if (!mounted) return;
    _startScratchRecoveryTimer();
  }

  Future<void> _handleHomeExit() async {
    if (_isHandlingExit || !mounted) return;
    _isHandlingExit = true;
    try {
      final prefs = await SharedPreferences.getInstance();
      final now = DateTime.now();
      final today =
          '${now.year.toString().padLeft(4, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-'
          '${now.day.toString().padLeft(2, '0')}';
      const shownDateKey = 'as_exit_retention_shown_date';

      if (prefs.getString(shownDateKey) == today) {
        await SystemNavigator.pop();
        return;
      }

      // 展示即计入当天次数，避免连续返回叠加多个挽留弹窗。
      await prefs.setString(shownDateKey, today);
      if (!mounted) return;
      final result = await context.tipShow(const ASWaitDialog());
      if (!mounted) return;
      if (result == 1) {
        await SystemNavigator.pop();
        return;
      }

      final availableTypes = <int>[];
      final usedCounts = _scratchUsedCounts();
      for (var type = 0; type < usedCounts.length; type++) {
        if (usedCounts[type] < 10) availableTypes.add(type);
      }
      if (availableTypes.isEmpty) {
        ASDialogTool.toast(context, 'No scratch cards available right now.');
        return;
      }
      final type = availableTypes[Random().nextInt(availableTypes.length)];
      await _openScratch(type);
    } finally {
      _isHandlingExit = false;
    }
  }

  String get _scratchRecoveryText {
    final hours = _scratchRecoverySeconds ~/ 3600;
    final minutes = (_scratchRecoverySeconds % 3600) ~/ 60;
    final seconds = _scratchRecoverySeconds % 60;
    return '${hours.toString().padLeft(2, '0')}:'
        '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  Widget _scratchCardWithCountdown({
    Key? key,
    required Widget child,
    required int usedCount,
    required int type,
  }) {
    return SizedBox(
      key: key,
      width: 121.w,
      height: 205.h,
      child: Stack(
        fit: StackFit.expand,
        children: [
          child,
          if (usedCount >= 10)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _openScratch(type),
              child: Container(
                color: '#000000'.color(opacity: 0.5),
                alignment: Alignment.center,
                child: Container(
                  width: 102,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(image: ASDImg('as_dao_bgs')),
                  child: ASStrokeText(
                    text: _scratchRecoveryText,
                    size: 12,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w900,
                    skWidth: 1,
                    skColor: '#000000'.color(),
                  ),
                ),
              ),
            ),
          Positioned(
            left: 0,
            bottom: 12.h,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                context.tipShow2(ASScratchChanceDialog(type: type));
              },
              child: Container(
                width: 102.w,
                height: 36.h,
                color: Colors.transparent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showFirstHomeGuide() async {
    if (_firstHomeGuideOverlay != null || _isOpeningFirstScratchGuide) return;

    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool(ASLocalProvider.instance.as_first_show_homeName) ??
        false) {
      await _showOldUserBoxOnceToday(prefs);
      return;
    }

    if (!mounted) return;
    final cardBox =
        _firstScratchCardKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (cardBox == null || overlayBox == null || !cardBox.hasSize) return;

    final cardTopLeft = overlayBox.globalToLocal(
      cardBox.localToGlobal(Offset.zero),
    );
    final usedCount = ASLocalProvider.instance.as_scrach_end_number_0;

    _firstHomeGuideOverlay = OverlayEntry(
      builder: (_) => Material(
        color: Colors.transparent,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: _openFirstScratchFromGuide,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Container(color: '#000000'.color(opacity: 0.72)),
              Positioned(
                left: cardTopLeft.dx,
                top: cardTopLeft.dy,
                child: IgnorePointer(
                  child: Container(
                    width: 121.w,
                    height: 205.h,
                    decoration: BoxDecoration(
                      image: ASDImg('as_home_list_bg_0'),
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          bottom: 21.h,
                          child: SizedBox(
                            width: 102.w,
                            height: 17.h,
                            child: Row(
                              children: [
                                SizedBox(width: 50.w),
                                ASStrokeText(
                                  text: 'X${10 - usedCount}',
                                  size: 12,
                                  color: '#FFFFFF'.color(),
                                  weight: FontWeight.w900,
                                  skWidth: 1,
                                  skColor: '#000000'.color(),
                                ),
                                const Spacer(),
                                ASImg(
                                  name: 'as_add_s_icon',
                                  width: 17,
                                  height: 17,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                left: cardTopLeft.dx + 58.w,
                top: cardTopLeft.dy + 100.h,
                child: IgnorePointer(
                  child: ASTapGuide(width: 80.w, height: 80.h),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    overlay.insert(_firstHomeGuideOverlay!);
  }

  Future<void> _showOldUserBoxOnceToday(SharedPreferences prefs) async {
    if (!mounted) return;
    final now = DateTime.now();
    final today =
        '${now.year.toString().padLeft(4, '0')}-'
        '${now.month.toString().padLeft(2, '0')}-'
        '${now.day.toString().padLeft(2, '0')}';
    const shownDateKey = 'as_box_old_shown_date';
    if (prefs.getString(shownDateKey) == today) return;

    await prefs.setString(shownDateKey, today);
    if (!mounted) return;
    await context.tipShow(ASBoxOldDiaologWidget());
  }

  Future<void> _openFirstScratchFromGuide() async {
    if (_isOpeningFirstScratchGuide) return;
    _isOpeningFirstScratchGuide = true;
    _firstHomeGuideOverlay?.remove();
    _firstHomeGuideOverlay = null;

    await _noticeInitFuture;
    await ASNoticeHelp().showPendingFollowUp(context);

    await ASLocalProvider.instance.updateBool(
      ASLocalProvider.instance.as_first_show_homeName,
      true,
    );
    if (!mounted) return;
    await _openScratch(0);
  }

  @override
  void dispose() {
    _shineTimer?.cancel();
    _scratchRecoveryTimer?.cancel();
    _firstHomeGuideOverlay?.remove();
    _firstHomeGuideOverlay = null;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleHomeExit();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Consumer<ASLocalProvider>(
          builder: (context, provider, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ASImg(
                  name: 'as_luanch_bg',
                  width: 0.width(context),
                  height: 0.height(context),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 0.height(context)),
                  child: Column(
                    children: [
                      SizedBox(height: 40.h),
                      Row(
                        children: [
                          SizedBox(width: 18.w),
                          Container(
                            width: 298.w,
                            height: 51.h,
                            decoration: BoxDecoration(
                              image: ASDImg('as_top_bg'),
                            ),
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
                                  top: 6.h,
                                  child: ParticleButton(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ASCash(),
                                        ),
                                      );
                                    },
                                    child: ASImg(
                                      name:
                                          'as_pp_${ASLocalProvider.instance.as_tx_task_index > 0 ? ASLocalProvider.instance.as_tx_pending_account : ASLocalProvider.instance.as_tx_ing_account}',
                                      width: 82,
                                      height: 32,
                                    ),
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
                                              '\$${0.to2Double(provider.as_dollar_number)}',
                                        ),
                                        TextSpan(
                                          text: '/\$1000',
                                          style: TextStyle(
                                            color: '#0A8A33'.color(),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 53.w,
                                  bottom: 14.h,
                                  child: Container(
                                    width: 138.w,
                                    height: 11,
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_pro_1'),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width:
                                              138.w *
                                              (provider.as_dollar_number /
                                                          1000 >=
                                                      1
                                                  ? 1
                                                  : provider.as_dollar_number /
                                                        1000),
                                          height: 11,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5.5,
                                            ),
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
                          Spacer(),
                          ParticleButton(
                            child: ASImg(
                              name: 'as_setting_icon',
                              width: 32,
                              height: 32,
                            ),
                            onTap: () {
                              context.tipShow(ASPopSettingDialog());
                            },
                          ),
                          SizedBox(width: 18.w),
                        ],
                      ),
                      SizedBox(height: 11.h),
                      ParticleButton(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ASTask()),
                          );
                        },
                        child: Container(
                          width: 352.w,
                          height: 106.h,
                          decoration: BoxDecoration(
                            image: ASDImg('as_top_pot_bg'),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: (352.w - 180) * 0.5,
                                bottom: 22,
                                child: Container(
                                  width: 180,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    image: ASDImg('as_home_pro_0'),
                                  ),
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width:
                                                180 *
                                                (provider.as_task_pig_progress /
                                                    9),
                                            height: 18,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(9),
                                              color: '#FFEE38'.color(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 180,
                                        height: 18,
                                        child: Center(
                                          child: ASStrokeText(
                                            text:
                                                '${provider.as_task_pig_progress}/9',
                                            size: 14,
                                            color: '#FFFFFF'.color(),
                                            weight: FontWeight.w900,
                                            skWidth: 1,
                                            skColor: '#000000'.color(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 29.w,
                                child: ASImg(
                                  name: 'as_jackpot_icon',
                                  width: 58,
                                  height: 52,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 11.h),
                      Row(
                        children: [
                          SizedBox(width: 12.w),
                          ASStrokeText(
                            text: 'Prize',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          SizedBox(width: 8.w),
                          ASImg(name: 'as_dollar_icon', width: 24, height: 24),
                          ASGradientStrokeText(
                            text: '\$80',
                            gradientColors: [
                              '#FFE600'.color(),
                              '#FFFFFF'.color(),
                            ],
                            width: 70,
                            height: 24,
                            fontSize: 20,
                            strokeWidth: 1,
                            strokeColor: '#2A0FA6'.color(),
                          ),
                          Spacer(),
                          ASStrokeText(
                            text: 'Win Chance',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          SizedBox(width: 8.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          ParticleButton(
                            child: _scratchCardWithCountdown(
                              key: _firstScratchCardKey,
                              usedCount: provider.as_scrach_end_number_0,
                              type: 0,
                              child: shineIndex == 0
                                  ? ASShine(
                                      width: 121.w,
                                      height: 205.h,
                                      child: Container(
                                        width: 121.w,
                                        height: 205.h,
                                        decoration: BoxDecoration(
                                          image: ASDImg('as_home_list_bg_0'),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 21.h,
                                              child: SizedBox(
                                                width: 102.w,
                                                height: 17.h,
                                                child: ParticleButton(
                                                  onTap: () {
                                                    context.tipShow2(
                                                      ASScratchChanceDialog(
                                                        type: 0,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 50.w),
                                                      ASStrokeText(
                                                        text:
                                                            'X${10 - provider.as_scrach_end_number_0}',
                                                        size: 12,
                                                        color: '#FFFFFF'
                                                            .color(),
                                                        weight: FontWeight.w900,
                                                        skWidth: 1,
                                                        skColor: '#000000'
                                                            .color(),
                                                      ),
                                                      Spacer(),
                                                      ASImg(
                                                        name: 'as_add_s_icon',
                                                        width: 17,
                                                        height: 17,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_0'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: ParticleButton(
                                                onTap: () {
                                                  context.tipShow2(
                                                    ASScratchChanceDialog(
                                                      type: 0,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 50.w),
                                                    ASStrokeText(
                                                      text:
                                                          'X${10 - provider.as_scrach_end_number_0}',
                                                      size: 12,
                                                      color: '#FFFFFF'.color(),
                                                      weight: FontWeight.w900,
                                                      skWidth: 1,
                                                      skColor: '#000000'
                                                          .color(),
                                                    ),
                                                    Spacer(),
                                                    ASImg(
                                                      name: 'as_add_s_icon',
                                                      width: 17,
                                                      height: 17,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            onTap: () {
                              _openScratch(0);
                            },
                          ),

                          ParticleButton(
                            child: _scratchCardWithCountdown(
                              usedCount: provider.as_scrach_end_number_1,
                              type: 1,
                              child: shineIndex == 1
                                  ? ASShine(
                                      width: 121.w,
                                      height: 205.h,
                                      child: Container(
                                        width: 121.w,
                                        height: 205.h,
                                        decoration: BoxDecoration(
                                          image: ASDImg('as_home_list_bg_1'),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 21.h,
                                              child: SizedBox(
                                                width: 102.w,
                                                height: 17.h,
                                                child: ParticleButton(
                                                  onTap: () {
                                                    context.tipShow2(
                                                      ASScratchChanceDialog(
                                                        type: 1,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 50.w),
                                                      ASStrokeText(
                                                        text:
                                                            'X${10 - provider.as_scrach_end_number_1}',
                                                        size: 12,
                                                        color: '#FFFFFF'
                                                            .color(),
                                                        weight: FontWeight.w900,
                                                        skWidth: 1,
                                                        skColor: '#000000'
                                                            .color(),
                                                      ),
                                                      Spacer(),
                                                      ASImg(
                                                        name: 'as_add_s_icon',
                                                        width: 17,
                                                        height: 17,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_1'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: ParticleButton(
                                                onTap: () {
                                                  context.tipShow2(
                                                    ASScratchChanceDialog(
                                                      type: 1,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 50.w),
                                                    ASStrokeText(
                                                      text:
                                                          'X${10 - provider.as_scrach_end_number_1}',
                                                      size: 12,
                                                      color: '#FFFFFF'.color(),
                                                      weight: FontWeight.w900,
                                                      skWidth: 1,
                                                      skColor: '#000000'
                                                          .color(),
                                                    ),
                                                    Spacer(),
                                                    ASImg(
                                                      name: 'as_add_s_icon',
                                                      width: 17,
                                                      height: 17,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            onTap: () {
                              _openScratch(1);
                            },
                          ),
                          ParticleButton(
                            child: _scratchCardWithCountdown(
                              usedCount: provider.as_scrach_end_number_2,
                              type: 2,
                              child: shineIndex == 2
                                  ? ASShine(
                                      width: 121.w,
                                      height: 205.h,
                                      child: Container(
                                        width: 121.w,
                                        height: 205.h,
                                        decoration: BoxDecoration(
                                          image: ASDImg('as_home_list_bg_2'),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 21.h,
                                              child: SizedBox(
                                                width: 102.w,
                                                height: 17.h,
                                                child: ParticleButton(
                                                  onTap: () {
                                                    context.tipShow2(
                                                      ASScratchChanceDialog(
                                                        type: 2,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 50.w),
                                                      ASStrokeText(
                                                        text:
                                                            'X${10 - provider.as_scrach_end_number_2}',
                                                        size: 12,
                                                        color: '#FFFFFF'
                                                            .color(),
                                                        weight: FontWeight.w900,
                                                        skWidth: 1,
                                                        skColor: '#000000'
                                                            .color(),
                                                      ),
                                                      Spacer(),
                                                      ASImg(
                                                        name: 'as_add_s_icon',
                                                        width: 17,
                                                        height: 17,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_2'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: ParticleButton(
                                                onTap: () {
                                                  context.tipShow2(
                                                    ASScratchChanceDialog(
                                                      type: 2,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 50.w),
                                                    ASStrokeText(
                                                      text:
                                                          'X${10 - provider.as_scrach_end_number_2}',
                                                      size: 12,
                                                      color: '#FFFFFF'.color(),
                                                      weight: FontWeight.w900,
                                                      skWidth: 1,
                                                      skColor: '#000000'
                                                          .color(),
                                                    ),
                                                    Spacer(),
                                                    ASImg(
                                                      name: 'as_add_s_icon',
                                                      width: 17,
                                                      height: 17,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            onTap: () {
                              _openScratch(2);
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 14.h),
                      Row(
                        children: [
                          SizedBox(width: 12.w),
                          ASStrokeText(
                            text: 'Prize',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          SizedBox(width: 8.w),
                          ASImg(name: 'as_dollar_icon', width: 24, height: 24),
                          ASGradientStrokeText(
                            text: '\$100',
                            gradientColors: [
                              '#FFE600'.color(),
                              '#FFFFFF'.color(),
                            ],
                            width: 70,
                            height: 24,
                            fontSize: 20,
                            strokeWidth: 1,
                            strokeColor: '#2A0FA6'.color(),
                          ),
                          Spacer(),
                          ASStrokeText(
                            text: 'Win Chance  ',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_n', width: 24, height: 24),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          ParticleButton(
                            child: _scratchCardWithCountdown(
                              usedCount: provider.as_scrach_end_number_3,
                              type: 3,
                              child: shineIndex == 3
                                  ? ASShine(
                                      width: 121.w,
                                      height: 205.h,
                                      child: Container(
                                        width: 121.w,
                                        height: 205.h,
                                        decoration: BoxDecoration(
                                          image: ASDImg('as_home_list_bg_3'),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 21.h,
                                              child: SizedBox(
                                                width: 102.w,
                                                height: 17.h,
                                                child: ParticleButton(
                                                  onTap: () {
                                                    context.tipShow2(
                                                      ASScratchChanceDialog(
                                                        type: 3,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 50.w),
                                                      ASStrokeText(
                                                        text:
                                                            'X${10 - provider.as_scrach_end_number_3}',
                                                        size: 12,
                                                        color: '#FFFFFF'
                                                            .color(),
                                                        weight: FontWeight.w900,
                                                        skWidth: 1,
                                                        skColor: '#000000'
                                                            .color(),
                                                      ),
                                                      Spacer(),
                                                      ASImg(
                                                        name: 'as_add_s_icon',
                                                        width: 17,
                                                        height: 17,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_3'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: ParticleButton(
                                                onTap: () {
                                                  context.tipShow2(
                                                    ASScratchChanceDialog(
                                                      type: 3,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 50.w),
                                                    ASStrokeText(
                                                      text:
                                                          'X${10 - provider.as_scrach_end_number_3}',
                                                      size: 12,
                                                      color: '#FFFFFF'.color(),
                                                      weight: FontWeight.w900,
                                                      skWidth: 1,
                                                      skColor: '#000000'
                                                          .color(),
                                                    ),
                                                    Spacer(),
                                                    ASImg(
                                                      name: 'as_add_s_icon',
                                                      width: 17,
                                                      height: 17,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            onTap: () {
                              _openScratch(3);
                            },
                          ),

                          ParticleButton(
                            child: _scratchCardWithCountdown(
                              usedCount: provider.as_scrach_end_number_4,
                              type: 4,
                              child: shineIndex == 4
                                  ? ASShine(
                                      width: 121.w,
                                      height: 205.h,
                                      child: Container(
                                        width: 121.w,
                                        height: 205.h,
                                        decoration: BoxDecoration(
                                          image: ASDImg('as_home_list_bg_4'),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 21.h,
                                              child: SizedBox(
                                                width: 102.w,
                                                height: 17.h,
                                                child: ParticleButton(
                                                  onTap: () {
                                                    context.tipShow2(
                                                      ASScratchChanceDialog(
                                                        type: 4,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 50.w),
                                                      ASStrokeText(
                                                        text:
                                                            'X${10 - provider.as_scrach_end_number_4}',
                                                        size: 12,
                                                        color: '#FFFFFF'
                                                            .color(),
                                                        weight: FontWeight.w900,
                                                        skWidth: 1,
                                                        skColor: '#000000'
                                                            .color(),
                                                      ),
                                                      Spacer(),
                                                      ASImg(
                                                        name: 'as_add_s_icon',
                                                        width: 17,
                                                        height: 17,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_4'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: ParticleButton(
                                                onTap: () {
                                                  context.tipShow2(
                                                    ASScratchChanceDialog(
                                                      type: 4,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 50.w),
                                                    ASStrokeText(
                                                      text:
                                                          'X${10 - provider.as_scrach_end_number_4}',
                                                      size: 12,
                                                      color: '#FFFFFF'.color(),
                                                      weight: FontWeight.w900,
                                                      skWidth: 1,
                                                      skColor: '#000000'
                                                          .color(),
                                                    ),
                                                    Spacer(),
                                                    ASImg(
                                                      name: 'as_add_s_icon',
                                                      width: 17,
                                                      height: 17,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            onTap: () {
                              _openScratch(4);
                            },
                          ),

                          ParticleButton(
                            child: _scratchCardWithCountdown(
                              usedCount: provider.as_scrach_end_number_5,
                              type: 5,
                              child: shineIndex == 5
                                  ? ASShine(
                                      width: 121.w,
                                      height: 205.h,
                                      child: Container(
                                        width: 121.w,
                                        height: 205.h,
                                        decoration: BoxDecoration(
                                          image: ASDImg('as_home_list_bg_5'),
                                        ),
                                        child: Stack(
                                          children: [
                                            Positioned(
                                              bottom: 21.h,
                                              child: SizedBox(
                                                width: 102.w,
                                                height: 17.h,
                                                child: ParticleButton(
                                                  onTap: () {
                                                    context.tipShow2(
                                                      ASScratchChanceDialog(
                                                        type: 5,
                                                      ),
                                                    );
                                                  },
                                                  child: Row(
                                                    children: [
                                                      SizedBox(width: 50.w),
                                                      ASStrokeText(
                                                        text:
                                                            'X${10 - provider.as_scrach_end_number_5}',
                                                        size: 12,
                                                        color: '#FFFFFF'
                                                            .color(),
                                                        weight: FontWeight.w900,
                                                        skWidth: 1,
                                                        skColor: '#000000'
                                                            .color(),
                                                      ),
                                                      Spacer(),
                                                      ASImg(
                                                        name: 'as_add_s_icon',
                                                        width: 17,
                                                        height: 17,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  : Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_5'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: ParticleButton(
                                                onTap: () {
                                                  context.tipShow2(
                                                    ASScratchChanceDialog(
                                                      type: 5,
                                                    ),
                                                  );
                                                },
                                                child: Row(
                                                  children: [
                                                    SizedBox(width: 50.w),
                                                    ASStrokeText(
                                                      text:
                                                          'X${10 - provider.as_scrach_end_number_5}',
                                                      size: 12,
                                                      color: '#FFFFFF'.color(),
                                                      weight: FontWeight.w900,
                                                      skWidth: 1,
                                                      skColor: '#000000'
                                                          .color(),
                                                    ),
                                                    Spacer(),
                                                    ASImg(
                                                      name: 'as_add_s_icon',
                                                      width: 17,
                                                      height: 17,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                            ),
                            onTap: () {
                              _openScratch(5);
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: 8.h,
                  child: SizedBox(
                    width: 0.width(context),
                    height: 100,
                    child: Stack(
                      children: [
                        Positioned(
                          left: 10.w,
                          bottom: 0,
                          child: ParticleButton(
                            child: SizedBox(
                              width: 75,
                              height: 80,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ASSpine(
                                    path: 'treasure'.spinepaths(),
                                    width: 75,
                                    height: 80,
                                  ),
                                  Positioned(
                                    left: 0,
                                    top: 0,
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      decoration: BoxDecoration(
                                        color: '#1C1F77'.color(),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(2),
                                            child: CircularProgressIndicator(
                                              value:
                                                  provider.as_box_index /
                                                  ASGameProgressManager()
                                                      .gameProgressModel
                                                      .boxInterval,
                                              strokeWidth: 2,
                                              strokeCap: StrokeCap.round,
                                              color: '#9AFF51'.color(),
                                              backgroundColor:
                                                  Colors.transparent,
                                            ),
                                          ),
                                          ASText(
                                            text:
                                                '${provider.as_box_index}/${ASGameProgressManager().gameProgressModel.boxInterval}',
                                            size: 8,
                                            color: Colors.white,
                                            weight: FontWeight.w900,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              if (ASLocalProvider.instance.as_box_index >=
                                  ASGameProgressManager()
                                      .gameProgressModel
                                      .boxInterval) {
                                context.tipShow(ASBoxOpenDiaologWidget());
                              } else {
                                ASDialogTool.toast(
                                  context,
                                  'Insufficient treasure chest attempts, scratch card attempts',
                                );
                              }
                            },
                          ),
                        ),
                        Positioned(
                          bottom: 10,
                          left: ((0.width(context) - 135) * 0.5) + 8.w,
                          child: ParticleButton(
                            child: ASSpine(
                              path: 'cash'.spinepaths(),
                              width: 135,
                              height: 88,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASCash()),
                              );
                            },
                          ),
                        ),
                        Positioned(
                          right: 10.w,
                          bottom: 0,
                          child: ParticleButton(
                            child: SizedBox(
                              width: 57,
                              height: 80,
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  ASSpine(
                                    path: 'dice'.spinepaths(),
                                    width: 57,
                                    height: 80,
                                  ),
                                  Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      width: 25,
                                      height: 25,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: '#1C1F77'.color(),
                                        shape: BoxShape.circle,
                                      ),
                                      child: ASText(
                                        text: '${provider.as_dice_number}',
                                        size: 10,
                                        color: Colors.white,
                                        weight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onTap: () {
                              context.tipShow(ASDice());
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  right: 18.w,
                  top: 88.h,
                  child: ParticleButton(
                    onTap: () async {
                      as_event_fire('h5_c', {});
                      as_event_fire('h5_page', {});
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (builder) {
                            as_event_fire('link_page', {});
                            return ASWebkitview(
                              url: "https://tinyurl.com/bdd6mwh9",
                              title: 'GamePlay',
                            );
                          },
                        ),
                      );
                    },
                    child: Container(
                      width: 59,
                      height: 40,
                      decoration: BoxDecoration(image: ASDImg('as_h5_icon')),
                    ),
                  ),
                ),
                Positioned.fill(child: ASBubbleButton()),
              ],
            );
          },
        ),
      ),
    );
  }
}
