import 'dart:math';
import 'package:aurastack/ASTool/as_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 定义单个飘落图标的数据模型
class FallingIconData {
  final IconData icon;
  final String imagePath;
  final double startX; // 屏幕上的水平起始位置比例 (0.0 - 1.0)
  final double initialDelay; // 初始进度偏移，防止所有图标同时开始掉落
  final double fallSpeed; // 下落速度
  final double swayAmount; // 左右摇晃的幅度（像素）
  final double swaySpeed; // 摇晃的频率
  final bool isForeground; // 是否为前景
  final double size; // 图标尺寸

  FallingIconData({
    required this.icon,
    required this.imagePath,
    required this.startX,
    required this.initialDelay,
    required this.fallSpeed,
    required this.swayAmount,
    required this.swaySpeed,
    required this.isForeground,
    required this.size,
  });
}

/// 飘落动画背景组件
class FallingIconsBackground extends StatefulWidget {
  final Widget child; // 背景上方的内容
  final double speed;
  final int minCount;
  final bool isBigWin;

  const FallingIconsBackground({
    super.key,
    required this.child,
    this.speed = 0.3,
    this.minCount = 20,
    this.isBigWin = false,
  });

  @override
  State<FallingIconsBackground> createState() => _FallingIconsBackgroundState();
}

class _FallingIconsBackgroundState extends State<FallingIconsBackground>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  // 使用 ValueNotifier 记录从动画开始经过的真实秒数（无限增长，不会中途归零）
  final ValueNotifier<double> _timeNotifier = ValueNotifier(0.0);

  final List<FallingIconData> _icons = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateIcons();

    // 使用 Ticker 替代 AnimationController，获取无限增长的经过时间
    _ticker = createTicker((elapsed) {
      // 将时间转换为精确的秒数
      _timeNotifier.value = elapsed.inMicroseconds / 1000000.0;
    });
    _ticker.start();
  }

  void _generateIcons() {
    final iconTypes = [Icons.money, Icons.ice_skating, Icons.light];
    final images = ['as_dollar_icon', 'as_dollars_icons', 'as_dollar_icon'];

    for (int i = 0; i < 3; i++) {
      final icon = iconTypes[i];
      final image = images[i];
      // 每种 icon 随机取 3-5 个
      int count = _random.nextInt(3) + widget.minCount;

      for (int i = 0; i < count; i++) {
        // 随机决定是前景还是后景
        // bool isFore = _random.nextBool();
        final bigWinStartX = _random.nextBool()
            ? _random.nextDouble() * 0.2
            : 0.7 + _random.nextDouble() * 0.2;

        _icons.add(
          FallingIconData(
            icon: icon,
            imagePath: image,
            startX: widget.isBigWin ? bigWinStartX : _random.nextDouble() - 0.1,
            initialDelay: _random.nextDouble(), // 让它们分布在不同的下落阶段
            fallSpeed: widget.speed + _random.nextDouble() * 0.08, // 随机下落速度
            swayAmount: 0 + _random.nextDouble() * 1.0, // 随机摇晃幅度 (30px - 80px)
            swaySpeed: 0.2 + _random.nextDouble() * 0.4, // 随机摇晃频率
            isForeground: false,
            size: 60.0, // 前景大一点，后景小一点，增加景深
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _timeNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;

        return Stack(
          children: [
            // 动画层
            ValueListenableBuilder<double>(
              valueListenable: _timeNotifier,
              builder: (context, time, child) {
                return Stack(
                  children: _icons.map((iconData) {
                    // 1. 计算 Y 轴下落位置
                    // time 是无限增长的，所以 yProgress 也是无限增长的
                    // % 1.0 的作用是：当进度达到 100% 也就是完全落到屏幕外之后，无缝重置为 0%（屏幕最上方外部）
                    double yProgress =
                        (time * iconData.fallSpeed + iconData.initialDelay) %
                        1.0;

                    // 起点 (-100) 和终点 (height + 100) 都在屏幕外面
                    // 这样重置的时候用户绝对看不到“瞬间移动”的破绽
                    double y = -100 + yProgress * (height + 200);

                    // 2. 计算 X 轴摇晃位置 (sin 函数接受无限增长的值会产生完美的平滑波浪)
                    double swayPhase = time * iconData.swaySpeed * 2 * pi;
                    double xOffset = sin(swayPhase) * iconData.swayAmount;
                    double x = (iconData.startX * width) + xOffset;

                    // 3. 计算稍微的旋转效果
                    double rotation = sin(swayPhase) * 0.6;

                    return Positioned(
                      left: x,
                      top: y,
                      child: Transform.rotate(
                        angle: rotation,
                        child: ASImg(
                          name: iconData.imagePath,
                          size: iconData.size.r,
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            // 内容层 (你的 UI 会放在动画的上面)
            widget.child,
          ],
        );
      },
    );
  }
}
