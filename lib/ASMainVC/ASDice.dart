import 'dart:math';
import 'package:aurastack/ASDialog/ASAward/ASAwardDialog.dart';
import 'package:aurastack/ASTool/as_stroke_text.dart';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';

class ASDice extends StatefulWidget {
  ASDice({super.key});

  @override
  State<ASDice> createState() => ASDiceState();
}

class ASDiceState extends State<ASDice> with TickerProviderStateMixin {
  int _currentIndex = ASLocalProvider.instance.as_dice_index;

  int _selectIndex = ASLocalProvider.instance.as_dice_index;

  /// 当前骰子点数
  int _diceNumber = 1;

  /// 是否显示骰子
  bool _showDice = false;

  /// 是否正在执行
  bool _rolling = false;

  /// 骰子旋转
  late AnimationController _diceRotateController;

  /// 最终中奖呼吸
  late AnimationController _scaleController;

  late Animation<double> _scaleAnimation;

  /// 奖格数据
  late List<_DiceItem> _items;

  bool _showBigWheel = false;

  late AnimationController _bigWheelController;

  late Animation<double> _bigWheelAnimation;

  @override
  void initState() {
    super.initState();

    _diceRotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1, end: 1.15).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _items = [
      _DiceItem(left: 28.w, top: 0, money: 20),

      _DiceItem(left: 110.w, top: 0, money: 20),

      _DiceItem(right: 110.w, top: 0, icon: true),

      _DiceItem(right: 28.w, top: 0, money: 20),

      _DiceItem(right: 28.w, top: 90.h, money: 20),

      _DiceItem(right: 28.w, top: 180.h, icon: true),

      _DiceItem(right: 28.w, bottom: 0, money: 20),

      _DiceItem(right: 110.w, bottom: 0, money: 20),

      _DiceItem(left: 110.w, bottom: 0, icon: true),

      _DiceItem(left: 28.w, bottom: 0, money: 20),

      _DiceItem(left: 28.w, top: 180.h, icon: true),

      _DiceItem(left: 28.w, top: 90.h, money: 20),
    ];

    _bigWheelController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _bigWheelAnimation = Tween<double>(begin: 1, end: 2.1).animate(
      CurvedAnimation(parent: _bigWheelController, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _diceRotateController.dispose();

    _bigWheelController.dispose();

    _scaleController.dispose();

    super.dispose();
  }

  /// 点击按钮开始
  Future<void> _startRoll() async {
    if (_rolling) return;

    _rolling = true;

    _scaleController.stop();
    _scaleController.reset();

    setState(() {
      _showDice = true;
    });

    /// 骰子开始旋转
    _diceRotateController.repeat();

    /// 转1.5秒
    await Future.delayed(const Duration(milliseconds: 1500));

    /// 随机点数
    _diceNumber = Random().nextInt(6) + 1;

    /// 停止旋转
    _diceRotateController.stop();

    if (mounted) {
      setState(() {});
    }

    /// 停留1秒
    await Future.delayed(const Duration(seconds: 1));

    /// 骰子隐藏
    if (mounted) {
      setState(() {
        _showDice = false;
      });
    }

    /// 开始走格子
    await _moveStep(_diceNumber);

    _rolling = false;
  }

  /// 根据骰子点数移动
  Future<void> _moveStep(int step) async {
    for (int i = 0; i < step; i++) {
      if (_selectIndex >= 0) {
        setState(() {});
      }

      _currentIndex++;

      if (_currentIndex >= _items.length) {
        _currentIndex = 0;
      }

      _selectIndex = _currentIndex;

      if (mounted) {
        setState(() {});
      }

      await Future.delayed(const Duration(milliseconds: 300));
    }

    // 保存当前位置
    ASLocalProvider.instance.updateint(
      ASLocalProvider.instance.as_dice_indexName,
      _currentIndex,
    );

    /// 停止后开始呼吸动画
    _scaleController.repeat(reverse: true);

    if (_isRewardPosition(_currentIndex)) {
      await showBigWheel();
    } else {
      setState(() {
        _showBigWheel = true;
      });

      await _bigWheelController.forward();
    }
  }

  bool _isRewardPosition(int index) {
    // index 从 0 开始
    // 对应格子:
    // 1,2,4,5,7,8,10,12

    return [
      0, // 第1格
      1, // 第2格
      3, // 第4格
      4, // 第5格
      6, // 第7格
      7, // 第8格
      9, // 第10格
      11, // 第12格
    ].contains(index);
  }

  Future<void> showBigWheel() async {
    /// 这里调用你的奖励弹窗

    context.tipShow(ASYouWinDialog(award: 10.0, isWheel: true));
  }

  Future<void> restoreWheel() async {
    // 开始恢复动画
    await _bigWheelController.reverse();

    if (mounted) {
      setState(() {
        // 恢复正常状态
        _showBigWheel = false;
      });
    }

    // 停止中奖格子的呼吸动画
    _scaleController.stop();
  }

  // 12个item
  Widget _buildDiceItem(int index) {
    final item = _items[index];

    bool active = _selectIndex == index;

    Widget content = Container(
      width: 76,

      height: 76,

      decoration: BoxDecoration(
        image: ASDImg(active ? 'as_dice_s' : 'as_dice_n'),
      ),

      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,

        children: [
          if (item.icon)
            ASImg(name: 'as_wheel_s', width: 45, height: 46)
          else ...[
            ASImg(name: 'as_doaller_wheel', width: 36, height: 36),

            ASText(
              text: '${item.money}',

              size: active ? 20 : 10,

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

    return Positioned(
      left: item.left,

      right: item.right,

      top: item.top,

      bottom: item.bottom,

      child: content,
    );
  }

  Widget _buildProgress() {
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
                width: 112 * 0.3,

                height: 23,

                decoration: BoxDecoration(
                  color: '#FFEE38'.color(),

                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),

            Center(
              child: ASStrokeText(
                text: '1/3',

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
                  ASImg(name: 'as_dice_top', width: 256, height: 71),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: 0.width(context),

                    height: 330.h,

                    child: Stack(
                      children: [
                        Center(
                          child: ParticleButton(
                            onTap: (){
                              restoreWheel();
                            },
                            child: AnimatedBuilder(
                              animation: _bigWheelAnimation,

                              builder: (context, child) {
                                return Transform.scale(
                                  scale: _bigWheelAnimation.value,

                                  child: child,
                                );
                              },

                              child: ASImg(
                                name: 'as_wheel_s',

                                width: 163.w,

                                height: 170.w,
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

                            child: Stack(
                              children: [
                                ...List.generate(_items.length, (index) {
                                  return _buildDiceItem(index);
                                }),
                              ],
                            ),
                          ),
                        ),

                        /// 中间骰子
                        if (_showDice)
                          Center(
                            child: AnimatedBuilder(
                              animation: _diceRotateController,

                              builder: (_, child) {
                                return Transform.rotate(
                                  angle:
                                      _diceRotateController.value * pi * 2 * 2,

                                  child: child,
                                );
                              },

                              child: ASImg(
                                name: 'dice_$_diceNumber',

                                width: 87,

                                height: 87,
                              ),
                            ),
                          ),

                        /// 进度条保持
                        Positioned(
                          bottom: 88.h,

                          left: (0.width(context) - 114) * 0.5,

                          child: _buildProgress(),
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
                                  text: '${provider.as_wheel_number}',
                                  size: 20,
                                  color: '#4559B2'.color(),
                                  weight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                          ASImg(name: 'as_dice_bottom', width: 34, height: 32),
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

                      onTap: () {
                        _startRoll();
                      },
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
}

class _DiceItem {
  final double? left;
  final double? right;
  final double? top;
  final double? bottom;

  final bool icon;

  final int money;

  const _DiceItem({
    this.left,

    this.right,

    this.top,

    this.bottom,

    this.icon = false,

    this.money = 0,
  });
}
