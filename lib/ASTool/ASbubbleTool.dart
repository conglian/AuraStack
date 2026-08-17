import 'dart:async';

import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/as_ad_manger.dart';
import 'package:flutter/cupertino.dart';

import 'ASAudioUtils.dart';
import 'ASTBAEventTool.dart';
import 'ASTrackEvent.dart';
import 'as_LocalProvider.dart';
import 'as_extension_help.dart';
import 'as_img.dart';
import 'as_stroke_text.dart';


// 气泡
class ASBubbleButton extends StatefulWidget {
  const ASBubbleButton({super.key});

  @override
  _ASBubbleButtonState createState() => _ASBubbleButtonState();
}

class _ASBubbleButtonState extends State<ASBubbleButton>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  double _top = 100;
  double _left = 100;
  double _dx = 50; // 每秒移动多少 px
  double _dy = 80;

  static const double _iconSize = 65;

  bool _showPop = true;
  double _pptReward = ASGameProgressManager().getBubbleRewardValue();

  late int _lastTime; // 用来计算 deltaTime

  late double screenWidth;

  late double screenHeight;
  Timer? _showTimer;
  bool _isOpening = false;

  @override
  void initState() {
    super.initState();

    _lastTime = DateTime.now().millisecondsSinceEpoch;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(days: 10),
    )..addListener(_onTick);

    _controller.repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
  }


  @override
  void dispose() {
    _showTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onTick() {
    if (!mounted) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final dt = (now - _lastTime) / 1000.0; // dt 秒
    _lastTime = now;

    final maxW = screenWidth - _iconSize;
    final maxH = screenHeight - _iconSize - 100;

    // 按时间移动，而不是按帧
    _left += _dx * dt;
    _top += _dy * dt;

    if (_left <= 0) {
      _left = 0;
      _dx = -_dx;
    } else if (_left >= maxW) {
      _left = maxW;
      _dx = -_dx;
    }

    if (_top <= 0) {
      _top = 0;
      _dy = -_dy;
    } else if (_top >= maxH) {
      _top = maxH;
      _dy = -_dy;
    }

  }

  @override
  Widget build(BuildContext context) {
    if (!_showPop) return SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      child: RepaintBoundary(
        child: GestureDetector(
          onTap: _openPopPT,
          child: Container(
            width: _iconSize,
            height: _iconSize,
            decoration: BoxDecoration(image: ASDImg('as_bubble_icon')),
            alignment: Alignment.bottomCenter,
            child: ASStrokeText(
              text: '\$${_pptReward.toStringAsFixed(2)}',
              size: 16,
              color: '#FFFFFF'.color(),
              weight: FontWeight.w400,
              skWidth: 1.5,
              skColor: '#0B5C0E'.color(),
            ),
          ),
        ),
      ),
      builder: (context, child) {
        return Stack(
          fit: StackFit.expand,
          children: [
            Positioned(left: _left, top: _top, child: child!),
          ],
        );
      },
    );
  }

  void _openPopPT() {
    if (_isOpening) return;
    _isOpening = true;
    as_event_fire(ASTrackEvent.bubbleClick, {});
    ASCardAds().as_showAd(context, ASTrackEvent.bubbleRewarded, onCacheResponse: (onCacheResponse){
      _isOpening = false;
      _hidePoPT();
    }, adDidClosed: (adDidClosed) async {
      _isOpening = false;
      if (adDidClosed) {
        await ASLocalProvider.instance.updatedouble(
            ASLocalProvider.instance.as_dollar_numberName, _pptReward
        );
        playAwardmp3();
      }
      _hidePoPT();
    });
  }

  void playAwardmp3(){
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // await ASAudioUtils().playDolasAudio();
      // Future.delayed(Duration(milliseconds: 1300), () async {
      //   await SJAudioUtils().stopAllTempAudio();
      //   if (ASLocalProvider.instance.sj_bg_music){
      //     await SJAudioUtils().playBGM();
      //   }
      // });
    });
  }

  void _hidePoPT() {
    if (!_showPop) return;
    _controller.stop();
    _pptReward = ASGameProgressManager().getBubbleRewardValue();
    if (mounted) {
      setState(() {
        _showPop = false;
      });
    }
    _showTimer?.cancel();
    _showTimer = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        _lastTime = DateTime.now().millisecondsSinceEpoch;
        setState(() {
          _showPop = true;
        });
        _controller.repeat();
      }
    });
  }
}
