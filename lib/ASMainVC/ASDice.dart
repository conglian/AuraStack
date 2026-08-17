import 'dart:async';
import 'dart:math';
import 'package:aurastack/ASDialog/ASAward/ASAwardDialog.dart';
import 'package:aurastack/ASDialog/ASOther/ASOtherDialog.dart';
import 'package:aurastack/ASMainVC/ASScratch.dart';
import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/as_stroke_text.dart';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/ASTBAEventTool.dart';
import '../ASTool/ASTrackEvent.dart';
import '../ASTool/ASWithdrawalFlow.dart';
import '../ASTool/ASAudioUtils.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';

class ASDice extends StatefulWidget {
  final bool fromScratch;

  const ASDice({super.key, this.fromScratch = false});

  @override
  State<ASDice> createState() => ASDiceState();
}

class ASDiceState extends State<ASDice> with TickerProviderStateMixin {
  static const List<int> _rewardPositions = <int>[0, 1, 3, 4, 6, 7, 9, 11];

  int _currentIndex = ASLocalProvider.instance.as_dice_index;

  int _selectIndex = ASLocalProvider.instance.as_dice_index;

  /// 当前骰子点数
  int _diceNumber = 1;
  int _diceFaceStepCount = 24;

  /// 是否显示骰子
  bool _showDice = false;

  /// 是否正在执行
  bool _rolling = false;

  final GlobalKey _bottomDiceKey = GlobalKey();
  final GlobalKey _wheelCenterKey = GlobalKey();
  bool _hideBottomDice = false;
  OverlayEntry? _diceFlightOverlay;

  late AnimationController _diceFlightController;
  late AnimationController _diceCenterScaleController;
  late Animation<double> _diceCenterScaleAnimation;

  /// 骰子旋转
  late AnimationController _diceRotateController;
  late Animation<double> _diceRotationAnimation;

  /// 最终中奖呼吸
  late AnimationController _scaleController;

  late Animation<double> _scaleAnimation;

  /// 奖格数据
  late List<_DiceItem> _items;

  bool _showBigWheel = false;

  late AnimationController _bigWheelController;

  late Animation<double> _bigWheelAnimation;

  late AnimationController _wheelRotationController;

  late Animation<double> _wheelRotationAnimation;

  late AnimationController _topPulseController;

  late Animation<double> _topPulseAnimation;

  List<double> awards = ASGameProgressManager().getDiceAwardValues();

  List<double> wheelAwards = ASGameProgressManager().getWheelAwardValues();

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.dicePage, {});

    _diceRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _diceRotationAnimation = Tween<double>(begin: 0, end: pi * 10).animate(
      CurvedAnimation(
        parent: _diceRotateController,
        curve: Curves.easeOutQuart,
      ),
    );

    _diceFlightController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _diceCenterScaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _diceCenterScaleAnimation = Tween<double>(begin: 1, end: 1.5).animate(
      CurvedAnimation(
        parent: _diceCenterScaleController,
        curve: Curves.easeOutBack,
      ),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _items = List<_DiceItem>.generate(
      12,
      (index) => _DiceItem(icon: const {2, 5, 8, 10}.contains(index)),
    );

    _bigWheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bigWheelAnimation = Tween<double>(begin: 1, end: 2.1).animate(
      CurvedAnimation(parent: _bigWheelController, curve: Curves.easeOut),
    );

    _wheelRotationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _wheelRotationAnimation = const AlwaysStoppedAnimation<double>(0);

    _topPulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _topPulseAnimation = TweenSequence<double>([
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
    ]).animate(_topPulseController);
    _topPulseController.repeat();
  }

  @override
  void dispose() {
    _removeDiceFlightOverlay();
    _diceFlightController.dispose();
    _diceCenterScaleController.dispose();
    _diceRotateController.dispose();

    _bigWheelController.dispose();

    _wheelRotationController.dispose();

    _topPulseController.dispose();

    _scaleController.dispose();

    super.dispose();
  }

  /// 点击按钮开始
  Future<void> _startRoll() async {
    _scaleController.stop();
    _scaleController.reset();

    _diceNumber = 6;
    await ASAudioUtils().playShaiziAudio();
    setState(() {
      _hideBottomDice = true;
    });

    await _flyDice(toCenter: true);
    if (!mounted) return;

    setState(() {
      _showDice = true;
    });
    await _diceCenterScaleController.forward(from: 0);
    if (!mounted) return;

    _diceNumber = Random().nextInt(6) + 1;
    final targetFaceIndex = _diceNumber - 1;
    _diceFaceStepCount = 24 + (targetFaceIndex - 5 + 6) % 6;
    _diceRotateController.reset();
    await _diceRotateController.forward();
    if (!mounted) return;
    setState(() {});

    final diceReturned = Completer<void>();
    final moveFuture = _moveStep(
      _diceNumber,
      beforeSettlement: diceReturned.future,
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) {
      diceReturned.complete();
      return;
    }
    setState(() {
      _showDice = false;
    });

    await _flyDice(toCenter: false);
    if (mounted) {
      setState(() {
        _hideBottomDice = false;
      });
    }
    diceReturned.complete();
    await moveFuture;
  }

  Future<void> _handleThrow() async {
    if (_rolling) return;
    if (ASLocalProvider.instance.as_dice_number <= 0) {
      final type = await context.tipShow2(const ASDiceNotEnoughDialog());
      if (!mounted || type is! int || type < 0) return;
      if (widget.fromScratch) {
        Navigator.pop(context, 0);
      } else {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ASScratch(type: type)),
        );
      }
      return;
    }

    // 在任何异步操作前先锁定，防止快速连点重复扣次数。
    _rolling = true;
    as_event_fire(ASTrackEvent.diceThrow, {});
    try {
      await ASLocalProvider.instance.updateint(
        ASLocalProvider.instance.as_dice_numberName,
        ASLocalProvider.instance.as_dice_number - 1,
      );
      if (!mounted) return;
      await _startRoll();
      if (!mounted) return;
    } finally {
      _rolling = false;
    }
    await ASWithdrawalFlow.instance.record('dice', context);
  }

  Future<void> _flyDice({required bool toCenter}) async {
    final bottomBox =
        _bottomDiceKey.currentContext?.findRenderObject() as RenderBox?;
    final centerBox =
        _wheelCenterKey.currentContext?.findRenderObject() as RenderBox?;
    final overlay = Overlay.of(context);
    final overlayBox = overlay.context.findRenderObject() as RenderBox?;
    if (bottomBox == null || centerBox == null || overlayBox == null) return;

    final bottomCenter = overlayBox.globalToLocal(
      bottomBox.localToGlobal(bottomBox.size.center(Offset.zero)),
    );
    final center = overlayBox.globalToLocal(
      centerBox.localToGlobal(centerBox.size.center(Offset.zero)),
    );
    final start = toCenter ? bottomCenter : center;
    final end = toCenter ? center : bottomCenter;
    final startSize = toCenter ? bottomBox.size : const Size(87, 87);
    final endSize = toCenter ? centerBox.size : bottomBox.size;

    _removeDiceFlightOverlay();
    _diceFlightController.duration = Duration(
      milliseconds: toCenter ? 500 : 280,
    );
    _diceFlightOverlay = OverlayEntry(
      builder: (context) {
        return AnimatedBuilder(
          animation: _diceFlightController,
          builder: (context, child) {
            final progress = Curves.easeInOutCubic.transform(
              _diceFlightController.value,
            );
            final control = Offset(
              (start.dx + end.dx) / 2 + (toCenter ? 24.w : -18.w),
              min(start.dy, end.dy) - 42.h,
            );
            final position = _quadraticBezier(start, control, end, progress);
            final width =
                startSize.width + (endSize.width - startSize.width) * progress;
            final height =
                startSize.height +
                (endSize.height - startSize.height) * progress;
            final rotation = progress * pi * (toCenter ? 2 : -1.5);

            return Positioned(
              left: position.dx - width / 2,
              top: position.dy - height / 2,
              child: IgnorePointer(
                child: Transform.rotate(
                  angle: rotation,
                  child: ASImg(
                    name: toCenter ? 'dice_6' : 'dice_$_diceNumber',
                    width: width,
                    height: height,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
    overlay.insert(_diceFlightOverlay!);
    await _diceFlightController.forward(from: 0);
    _removeDiceFlightOverlay();
  }

  Offset _quadraticBezier(
    Offset start,
    Offset control,
    Offset end,
    double progress,
  ) {
    final inverse = 1 - progress;
    return start * (inverse * inverse) +
        control * (2 * inverse * progress) +
        end * (progress * progress);
  }

  void _removeDiceFlightOverlay() {
    _diceFlightOverlay?.remove();
    _diceFlightOverlay = null;
  }

  /// 根据骰子点数移动
  Future<void> _moveStep(int step, {Future<void>? beforeSettlement}) async {
    for (int i = 0; i < step; i++) {
      if (_selectIndex >= 0) {
        if (!mounted) return;
        setState(() {});
      }

      _currentIndex++;

      if (_currentIndex >= _items.length) {
        _currentIndex = 0;
      }

      _selectIndex = _currentIndex;
      await ASAudioUtils().playDiceStepAudio();

      if (mounted) {
        setState(() {});
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    if (beforeSettlement != null) {
      await beforeSettlement;
    }

    // 保存当前位置
    ASLocalProvider.instance.updateint(
      ASLocalProvider.instance.as_dice_indexName,
      _currentIndex,
    );
    await ASLocalProvider.instance.incrementTaskProgress(8);

    /// 停止后开始呼吸动画
    _scaleController.repeat(reverse: true);

    if (_isRewardPosition(_currentIndex)) {
      final rewardIndex = _rewardPositions.indexOf(_currentIndex);
      if (rewardIndex >= awards.length) {
        throw StateError('骰子奖励数量不足。');
      }
      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      await showBigWheel(awards[rewardIndex]);
    } else {
      final nextWheelCount = ASLocalProvider.instance.as_dice_shou_index + 1;
      await ASLocalProvider.instance.updateint(
        ASLocalProvider.instance.as_dice_shou_indexName,
        nextWheelCount >= 3 ? 0 : nextWheelCount,
      );
      if (nextWheelCount >= 3) {
        wheelAwards = ASGameProgressManager().getWheelAwardValues();
        if (wheelAwards.length < 6) {
          throw StateError('转盘奖励数量不足。');
        }

        final winningIndex = Random().nextInt(6);
        final targetOffset = (pi * 2 - winningIndex * pi / 3) % (pi * 2);
        _wheelRotationController.reset();
        _wheelRotationAnimation =
            Tween<double>(begin: 0, end: pi * 16 + targetOffset).animate(
              CurvedAnimation(
                parent: _wheelRotationController,
                curve: Curves.easeOutQuart,
              ),
            );

        setState(() {
          _showBigWheel = true;
        });
        await ASAudioUtils().playWheelAudio();
        as_event_fire(ASTrackEvent.spinPage, {});

        await _bigWheelController.forward();

        if (!mounted) return;
        await _wheelRotationController.forward(from: 0);

        if (!mounted) return;
        await onWheelStopped(winningIndex, wheelAwards[winningIndex]);
      }
    }
  }

  bool _isRewardPosition(int index) {
    return _rewardPositions.contains(index);
  }

  Future<void> showBigWheel(double award) async {
    final navigator = Navigator.of(context, rootNavigator: true);
    final overlayContext = navigator.overlay?.context;
    if (overlayContext == null) {
      await context.tipShow(
        ASYouWinDialog(award: award, isWheel: true, rewardType: 'dice'),
      );
      return;
    }

    if (!overlayContext.mounted) return;
    final fromScratch = widget.fromScratch;
    navigator.pop();
    unawaited(_showDiceRewardAndReopen(overlayContext, award, fromScratch));
  }

  /// 转盘停止后的奖励处理，奖励弹窗可以添加在这里。
  Future<void> onWheelStopped(int index, double award) async {
    await ASLocalProvider.instance.incrementTaskProgress(6);
    if (!mounted) return;
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;

    final navigator = Navigator.of(context, rootNavigator: true);
    final overlayContext = navigator.overlay?.context;
    if (overlayContext == null) {
      int code = await context.tipShow(
        ASYouWinDialog(award: award, isWheel: true, rewardType: 'spins'),
      );
      if (code < 0 || !mounted) return;

      await _bigWheelController.reverse();
      if (!mounted) return;

      _wheelRotationController.reset();
      _scaleController.stop();
      setState(() {
        _showBigWheel = false;
        awards = ASGameProgressManager().getDiceAwardValues();
        wheelAwards = ASGameProgressManager().getWheelAwardValues();
      });
      await ASWithdrawalFlow.instance.record('spins', context);
      return;
    }

    if (!overlayContext.mounted) return;
    final fromScratch = widget.fromScratch;
    navigator.pop();
    unawaited(
      _showDiceRewardAndReopen(
        overlayContext,
        award,
        fromScratch,
        rewardType: 'spins',
      ),
    );
  }

  // 12个item
  Widget _buildDiceItem(
    int index, {
    required double left,
    required double top,
    required double size,
  }) {
    final item = _items[index];
    final rewardIndex = _rewardPositions.indexOf(index);
    final scale = size / 76;

    bool active = _selectIndex == index;

    Widget content = Container(
      width: size,

      height: size,

      decoration: BoxDecoration(
        image: ASDImg(active ? 'as_dice_s' : 'as_dice_n'),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          if (item.icon)
            ASImg(name: 'as_wheel_s', width: 45 * scale, height: 46 * scale)
          else ...[
            ASImg(
              name: 'as_doaller_wheel',
              width: 36 * scale,
              height: 36 * scale,
            ),

            ASText(
              text: '\$${_formatAwardValue(awards[rewardIndex])}',

              size: 20 * scale,

              color: '#4559B2'.color(),

              weight: FontWeight.w900,
            ),
          ],
        ],
      ),
    );

    /// 中奖位置放大呼吸
    if (active) {
      content = ScaleTransition(scale: _scaleAnimation, child: content);
    }

    return Positioned(left: left, top: top, child: content);
  }

  Widget _buildProgress(ASLocalProvider provider) {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 300),
      opacity: _showBigWheel ? 0 : 1,
      child: Container(
        width: 114,

        height: 25,

        decoration: BoxDecoration(
          color: '#666E8E'.color(),

          borderRadius: BorderRadius.circular(13),
        ),

        child: Stack(
          children: [
            Positioned(
              left: 1,

              top: 1,

              child: Container(
                width: 112 * (provider.as_dice_shou_index / 3),

                height: 23,

                decoration: BoxDecoration(
                  color: '#FFEE38'.color(),

                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            Center(
              child: ASStrokeText(
                text: '${provider.as_dice_shou_index}/3',

                size: 20,

                color: '#FFFFFF'.color(),

                weight: FontWeight.w900,

                skWidth: 1,

                skColor: '#000000'.color(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWheel() {
    if (wheelAwards.length < 6) {
      throw StateError('转盘奖励数量不足。');
    }

    final wheelWidth = 163.w;
    final wheelHeight = 163.w;
    final centerX = wheelWidth / 2;
    final centerY = wheelHeight / 2;
    final radius = 31.w;
    final labelWidth = 50.w;
    final labelHeight = 20.w;
    // The upper labels stay unchanged. The lower labels are oriented so their
    // text becomes upright when each segment rotates into the top pointer.
    const labelRotations = <double>[
      0,
      pi / 3,
      2 * pi / 3,
      pi,
      -2 * pi / 3,
      -pi / 3,
    ];

    return SizedBox(
      width: wheelWidth,
      height: wheelHeight,
      child: Stack(
        children: [
          ASImg(name: 'as_wheel_bg', width: wheelWidth, height: wheelHeight),
          ...List.generate(6, (index) {
            final angle = -pi / 2 + index * pi / 3;
            return Positioned(
              left: centerX + cos(angle) * radius - labelWidth / 2,
              top: centerY + sin(angle) * radius - labelHeight / 2,
              child: SizedBox(
                width: labelWidth,
                height: labelHeight,
                child: Transform.rotate(
                  angle: labelRotations[index],
                  child: ASStrokeText(
                    text: '\$${_formatAwardValue(wheelAwards[index])}',
                    size: 10,
                    color: Colors.white,
                    weight: FontWeight.w900,
                    skWidth: 1.5,
                    skColor: Colors.black,
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ASLocalProvider>(
        builder: (context, provider, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              Column(
                mainAxisAlignment: .center,
                crossAxisAlignment: .center,
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      ParticleButton(
                        child: SizedBox(
                          width: 40,
                          height: 40,
                          child: Center(
                            child: ASImg(
                              name: 'as_close_x',
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                        onTap: () {
                          Navigator.pop(context, 0);
                        },
                      ),
                      SizedBox(width: 32.w),
                    ],
                  ),
                  SizedBox(height: 21.h),
                  ScaleTransition(
                    scale: _topPulseAnimation,
                    child: ASImg(name: 'as_dice_top', width: 256, height: 71),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: 0.width(context),

                    height: 330.h,

                    child: Stack(
                      children: [
                        Center(
                          child: IgnorePointer(
                            child: SizedBox(
                              key: _wheelCenterKey,
                              width: 58,
                              height: 58,
                            ),
                          ),
                        ),
                        Center(
                          child: AnimatedBuilder(
                            animation: _bigWheelAnimation,

                            builder: (context, child) {
                              return Transform.scale(
                                scale: _bigWheelAnimation.value,

                                child: child,
                              );
                            },

                            child: SizedBox(
                              width: 163.w,
                              height: 170.w,
                              child: Stack(
                                alignment: Alignment.center,
                                clipBehavior: Clip.none,
                                children: [
                                  AnimatedBuilder(
                                    animation: _wheelRotationAnimation,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _wheelRotationAnimation.value,
                                        child: child,
                                      );
                                    },
                                    child: _buildWheel(),
                                  ),
                                  Positioned(
                                    top: 10.w,
                                    child: ASImg(
                                      name: 'as_wheel_top',
                                      width: 22.w,
                                      height: 20.w,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        /// 周围12个格子
                        AnimatedOpacity(
                          duration: const Duration(milliseconds: 500),

                          opacity: _showBigWheel ? 0 : 1,

                          child: AnimatedScale(
                            duration: const Duration(milliseconds: 500),

                            scale: _showBigWheel ? 0 : 1,

                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                const columns = <int>[
                                  0,
                                  1,
                                  2,
                                  3,
                                  3,
                                  3,
                                  3,
                                  2,
                                  1,
                                  0,
                                  0,
                                  0,
                                ];
                                const rows = <int>[
                                  0,
                                  0,
                                  0,
                                  0,
                                  1,
                                  2,
                                  3,
                                  3,
                                  3,
                                  3,
                                  2,
                                  1,
                                ];
                                final itemSize = min(
                                  76.0,
                                  min(
                                    (constraints.maxWidth - 40) / 4,
                                    (constraints.maxHeight - 24) / 4,
                                  ),
                                ).clamp(56.0, 76.0).toDouble();
                                final horizontalGap =
                                    (constraints.maxWidth - itemSize * 4) / 5;
                                final verticalGap =
                                    (constraints.maxHeight - itemSize * 4) / 3;

                                return Stack(
                                  children: List.generate(_items.length, (
                                    index,
                                  ) {
                                    return _buildDiceItem(
                                      index,
                                      left:
                                          horizontalGap +
                                          columns[index] *
                                              (itemSize + horizontalGap),
                                      top:
                                          rows[index] *
                                          (itemSize + verticalGap),
                                      size: itemSize,
                                    );
                                  }),
                                );
                              },
                            ),
                          ),
                        ),

                        /// 中间骰子
                        if (_showDice)
                          Center(
                            child: ScaleTransition(
                              scale: _diceCenterScaleAnimation,
                              child: AnimatedBuilder(
                                animation: _diceRotateController,
                                builder: (_, _) {
                                  final faceProgress = Curves.easeOutCubic
                                      .transform(_diceRotateController.value);
                                  final faceStep =
                                      (faceProgress * (_diceFaceStepCount + 1))
                                          .floor()
                                          .clamp(0, _diceFaceStepCount);
                                  final face = (5 + faceStep) % 6 + 1;
                                  return Transform.rotate(
                                    angle: _diceRotationAnimation.value,
                                    child: ASImg(
                                      name: 'dice_$face',
                                      width: 58,
                                      height: 58,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),

                        /// 进度条保持
                        Positioned(
                          bottom: 88.h,

                          left: (0.width(context) - 114) * 0.5,

                          child: _buildProgress(provider),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showBigWheel ? 0 : 1,
                    child: SizedBox(
                      width: 130,
                      height: 32,
                      child: Stack(
                        children: [
                          Positioned(
                            left: 4,
                            child: Container(
                              width: 126,
                              height: 32,
                              decoration: BoxDecoration(
                                color: '#FFFFFF'.color(),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Center(
                                child: ASText(
                                  text: '${provider.as_dice_number}',
                                  size: 20,
                                  color: '#4559B2'.color(),
                                  weight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          Opacity(
                            opacity: _hideBottomDice ? 0 : 1,
                            child: SizedBox(
                              key: _bottomDiceKey,
                              width: 34,
                              height: 32,
                              child: ASImg(
                                name: 'dice_6',
                                width: 34,
                                height: 32,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showBigWheel ? 0 : 1,
                    child: SizedBox(height: 40.h),
                  ),
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: _showBigWheel ? 0 : 1,
                    child: ParticleButton(
                      child: ASImg(
                        name: 'as_throw_btn',
                        width: 262,
                        height: 76,
                      ),

                      onTap: _handleThrow,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatAwardValue(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

Future<void> _showDiceRewardAndReopen(
  BuildContext overlayContext,
  double award,
  bool fromScratch, {
  String rewardType = 'dice',
}) async {
  await Future.delayed(const Duration(milliseconds: 50));
  if (!overlayContext.mounted) return;

  await overlayContext.tipShow(
    ASYouWinDialog(award: award, isWheel: true, rewardType: rewardType),
  );

  if (!overlayContext.mounted) return;
  await ASWithdrawalFlow.instance.record(rewardType, overlayContext);
  if (!overlayContext.mounted) return;

  await Future.delayed(const Duration(milliseconds: 1200));
  if (!overlayContext.mounted) return;

  await overlayContext.tipShow(ASDice(fromScratch: fromScratch));
}

class _DiceItem {
  final bool icon;

  const _DiceItem({this.icon = false});
}
