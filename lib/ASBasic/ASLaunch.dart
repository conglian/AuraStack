import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:spine_flutter/spine_widget.dart' as spine;
import '../ASMainVC/ASHome.dart';
import '../ASTool/ASLogger.dart';
import '../ASTool/ASNoticeHelp.dart';
import '../ASTool/ASTBAEventTool.dart';
import '../ASTool/ASTrackEvent.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/as_ad_manger.dart';
import '../ASTool/ASAudioUtils.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';
import '../ASTool/as_stroke_text.dart';

class ASLaunch extends StatefulWidget {
  ASLaunch({super.key});

  @override
  State<ASLaunch> createState() => ASLaunchState();
}

class ASLaunchState extends State<ASLaunch>
    with SingleTickerProviderStateMixin {
  var _daydateString = '';
  late final bool _shouldShowColdLaunchAd;
  bool _didFinishLaunch = false;

  late AnimationController _logoPulseController;

  late Animation<double> _logoPulseAnimation;

  @override
  void initState() {
    super.initState();
    // 启动瞬间取值，避免首次安装过程中 SDK 写入状态后误展示开屏广告。
    _shouldShowColdLaunchAd = ASLocalProvider.instance.as_install_status;
    if (ASLocalProvider.instance.as_bg_music) {
      ASAudioUtils().playBGM();
    }
    _logoPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _logoPulseAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1,
          end: 1.08,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 45,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.08), weight: 10),
      TweenSequenceItem(
        tween: Tween<double>(
          begin: 1.08,
          end: 1,
        ).chain(CurveTween(curve: Curves.easeInOutCubic)),
        weight: 45,
      ),
    ]).animate(_logoPulseController);
    _logoPulseController.repeat();
    _setConfigDateInfoData();
    ASNoticeHelp().setNoticeStatus();
    Future.delayed(Duration(milliseconds: 1), () {
      as_getUserCloakConfig();
    });
    as_event_fire(ASTrackEvent.launchPage, {'source_from': 'icon'});

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // PSNumberHelpers().updateBrazilianPortuguese(context);
    });
  }

  void as_getUserCloakConfig() async {
    try {
      var responseData = await ASRequestHelpers().getCloak();
      asLog.info('pigwalletspine Config Result: $responseData');
      as_event_fire("cloak_req", {});
      as_event_fire("cloak_suc", {
        "cloak_user": responseData.toString() == "freshen" ? 1 : 0,
      });
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      if (prefs.getBool('as_install_status') == null) {
        prefs.setBool('as_install_status', true);
      }
      ASLocalProvider.instance.updateBool(
        ASLocalProvider.instance.as_cloak_statusName,
        responseData.toString() == "freshen" ? true : false,
      );
    } catch (e) {
      asLog.error('pigwalletspine Request Error: $e');
      Future.delayed(Duration(seconds: 1), () {
        as_getUserCloakConfig();
      });
    }
  }

  Future<void> _setConfigDateInfoData() async {
    // text
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    _daydateString = prefs.getString('as_day_date') ?? '';
    DateTime today = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(today);
    prefs.setBool('as_old_guide', true);
    if (_daydateString == '') {
      prefs.setString('as_day_date', formattedDate);
      // 首次
      prefs.setBool('as_first_instll', true);
    } else {
      if (_daydateString != formattedDate) {
        await ASLocalProvider.instance.updateint(
          ASLocalProvider.instance.as_ad_show_indexName,
          0,
        );
        // 隔天
        prefs.setString('as_day_date', formattedDate);
        prefs.setBool('as_old_guide', false);
      }
    }
  }

  @override
  void dispose() {
    _logoPulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          ASImg(
            name: 'as_luanch_bg',
            width: 0.width(context),
            height: 0.height(context),
          ),
          Column(
            children: [
              SizedBox(height: 136.h),
              ScaleTransition(
                scale: _logoPulseAnimation,
                child: ASImg(name: 'as_luanch_logo', width: 255, height: 199),
              ),
              Spacer(),
              SizedBox(height: 12.h),
              AJGradientProgressBar(
                onCompleted: () {
                  _finishLaunch();
                },
              ),
              SizedBox(height: 12.h),
              ASStrokeText(
                text: "Loading...",
                size: 14,
                color: '#FFFFFF'.color(),
                weight: FontWeight.w900,
                skWidth: 1,
                skColor: '#4C0E0E'.color(),
              ),
              SizedBox(height: 120.h),
            ],
          ),
        ],
      ),
    );
  }

  void _finishLaunch() {
    if (_didFinishLaunch) return;
    if (!_shouldShowColdLaunchAd) {
      pushToGuide();
      return;
    }

    ASCardAds().as_showAd(
      context,
      ASTrackEvent.launchColdInterstitial,
      showDialog: false,
      onCacheResponse: (_) => pushToGuide(),
      adDidClosed: (_) => pushToGuide(),
    );
  }

  void pushToGuide() {
    if (_didFinishLaunch || !mounted) return;
    _didFinishLaunch = true;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AShome(key: homeKey)),
    );
  }
}

class AJGradientProgressBar extends StatefulWidget {
  final VoidCallback? onCompleted; // ✅ 动画完成后的回调

  const AJGradientProgressBar({super.key, this.onCompleted});

  @override
  State<AJGradientProgressBar> createState() => _AJGradientProgressBarState();
}

class _AJGradientProgressBarState extends State<AJGradientProgressBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  final double barWidth = 245;
  final double barHeight = 18;
  final double progressHeight = 14;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(seconds: kDebugMode ? 3 : 12),
      vsync: this,
    );

    _animation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // ✅ 动画完成回调
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && widget.onCompleted != null) {
        widget.onCompleted!();
      }
    });

    // 启动动画
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: barWidth,
      height: barHeight,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // 背景图片
          Positioned.fill(child: ASImg(name: 'as_luanch_pro')),
          // 进度条
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final progressWidth = barWidth * _animation.value;
              final progressPercent = (_animation.value * 100)
                  .clamp(0, 100)
                  .toInt();
              return Stack(
                alignment: Alignment.center,
                children: [
                  // 渐变进度条
                  Positioned(
                    left: 2,
                    top: 2,
                    child: Container(
                      width: max(0, progressWidth - 8),
                      height: progressHeight,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            '#FFEE38'.color(),
                            '#FFE659'.color(),
                            '#B47405'.color(),
                          ],
                        ),
                        borderRadius: BorderRadius.circular(9),
                      ),
                    ),
                  ),
                  // ✅ 居中显示百分比文字
                  Center(
                    child: Text(
                      '$progressPercent%',
                      style: TextStyle(
                        fontFamily: text_fontName,
                        color: Colors.white,
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        shadows: [
                          Shadow(
                            blurRadius: 2,
                            color: Colors.black.withOpacity(0.4),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
