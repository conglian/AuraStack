import 'dart:math';
import 'package:aurastack/ASTool/as_img.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// 定义单个井喷图标的数据模型
class FountainIconData {
  final IconData icon;
  final String imagePath;

  // 贝塞尔曲线的三个点
  final double p0x = 0.5; // 起点 X（0.5 表示屏幕中心）
  final double p0y = 0.5; // 起点 Y（0.5 表示屏幕中心，可以根据需要改成 0.8 靠下的位置）
  final double p1x; // 控制点 X（喷射的弯曲度）
  final double p1y; // 控制点 Y（决定轨迹）
  final double p2x; // 终点 X（屏幕外左右散开）
  final double p2y; // 终点 Y（屏幕上方外部）

  final double initialPhase; // 初始生命周期偏移 (0.0 - 1.0)，防止同时喷发
  final double speed; // 喷射速度
  final double size; // 图标尺寸
  final double spinSpeed; // 旋转速度

  FountainIconData({
    required this.icon,
    required this.imagePath,
    required this.p1x,
    required this.p1y,
    required this.p2x,
    required this.p2y,
    required this.initialPhase,
    required this.speed,
    required this.size,
    required this.spinSpeed,
  });
}

/// 无限井喷动画背景组件
class InfiniteFountainWidget extends StatefulWidget {
  final Widget child; // 可以包裹其他组件

  const InfiniteFountainWidget({super.key, required this.child});

  @override
  State<InfiniteFountainWidget> createState() => _InfiniteFountainWidgetState();
}

class _InfiniteFountainWidgetState extends State<InfiniteFountainWidget>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  // 记录无限增长的秒数
  final ValueNotifier<double> _timeNotifier = ValueNotifier(0.0);

  final List<FountainIconData> _icons = [];
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateIcons();

    _ticker = createTicker((elapsed) {
      _timeNotifier.value = elapsed.inMicroseconds / 1000000.0;
    });
    _ticker.start();
  }

  void _generateIcons() {
    final iconTypes = [Icons.money, Icons.ice_skating, Icons.light];
    final images = ['as_dollar_icon', 'as_dollars_icons', 'as_dollar_icon'];

    for (int i = 0; i < 3; i++) {
      final icon = iconTypes[i];
      final imagePath = images[i];
      // 每种 icon 随机取 20-26 个
      int count = _random.nextInt(7) + 20;

      for (int j = 0; j < count; j++) {
        _icons.add(
          FountainIconData(
            icon: icon,
            imagePath: imagePath,
            // 控制点：向上方散开
            p1x: 0.5 + (_random.nextDouble() - 0.5) * 0.8,
            p1y: 0.2 + _random.nextDouble() * 0.2,
            // 终点：飞出屏幕上方
            p2x:
                0.5 +
                (_random.nextDouble() - 0.5) * 1.5, // 左右广泛散开 (-25% 到 125%)
            p2y: -0.2 - _random.nextDouble() * 0.3, // 飞出顶部屏幕外 (-20% 到 -50%)

            initialPhase: _random.nextDouble(), // 0.0 到 1.0 的随机初始进度，让喷发错落有致
            speed: 0.25 + _random.nextDouble() * 0.15, // 随机速度 (控制完成一次喷发的时间)
            size: 60.0, // 随机大小
            spinSpeed: (_random.nextDouble() - 0.5) * 6 * pi, // 随机正反向旋转
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
                    // 1. 计算该图标当前的生命周期进度 (0.0 -> 1.0 无限循环)
                    double rawProgress =
                        (time * iconData.speed + iconData.initialPhase) % 1.0;

                    // 使用 easeOut 让喷发一开始有爆发力（快），后面平滑飞出（慢）
                    double progress = Curves.easeOut.transform(rawProgress);

                    // 2. 贝塞尔曲线计算 X 和 Y
                    double xProgress =
                        pow(1 - progress, 2) * iconData.p0x +
                        2 * (1 - progress) * progress * iconData.p1x +
                        pow(progress, 2) * iconData.p2x;

                    double yProgress =
                        pow(1 - progress, 2) * iconData.p0y +
                        2 * (1 - progress) * progress * iconData.p1y +
                        pow(progress, 2) * iconData.p2y;

                    double x = xProgress * width;
                    double y = yProgress * height;

                    // 3. 旋转角度计算 (随真实时间旋转，更自然)
                    double rotation = time * iconData.spinSpeed;

                    // 4. 透明度与缩放 (为了让图标在中心点重生时不突兀)
                    double opacity = 1.0;
                    double scale = 1.0;

                    if (rawProgress < 0.1) {
                      // 刚出生时 (0% - 10%)：从小变大，从透明变实体
                      opacity = rawProgress / 0.1;
                      scale = rawProgress / 0.1;
                    } else if (rawProgress > 0.8) {
                      // 快消失时 (80% - 100%)：渐渐变透明，融于背景
                      opacity = (1.0 - rawProgress) / 0.2;
                    }

                    return Positioned(
                      left: x,
                      top: y,
                      child: Transform.translate(
                        // 修正锚点到中心
                        offset: Offset(-iconData.size / 2, -iconData.size / 2),
                        child: Transform.scale(
                          scale: scale,
                          child: Transform.rotate(
                            angle: rotation,
                            child: ASImg(
                              name: iconData.imagePath,
                              size: iconData.size.r, // 适配你的 ScreenUtil
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            // UI 内容层
            widget.child,
          ],
        );
      },
    );
  }
}
