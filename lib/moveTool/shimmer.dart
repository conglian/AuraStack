import 'package:flutter/material.dart';

class Shimmer extends StatefulWidget {
  final Widget child;

  /// 动画周期
  final Duration duration;

  /// 扫光颜色
  final Color highlightColor;

  /// 背景基色
  final Color baseColor;

  /// 斜切角度
  final double angle;

  const Shimmer({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1500),
    this.highlightColor = const Color(0xFFFFFFFF),
    this.baseColor = Colors.transparent,
    this.angle = 20,
  });

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      child: widget.child,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (Rect bounds) {
            final width = bounds.width;
            
            final gradientWidth = width * 0.6;

            // 当前动画进度
            final progress = _controller.value;

            // 让渐变从左侧屏幕外滑到右侧屏幕外
            final dx = (width + gradientWidth) * progress - gradientWidth;

            final transform = Matrix4.translationValues(dx, 0.0, 0.0)
              ..rotateZ(widget.angle * 3.1415926 / 180);

            return LinearGradient(
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: const [0.3, 0.5, 0.7],
              transform: _MatrixGradientTransform(transform),
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: child,
        );
      },
    );
  }
}

class _MatrixGradientTransform extends GradientTransform {
  final Matrix4 matrix;
  const _MatrixGradientTransform(this.matrix);

  @override
  Matrix4 transform(Rect bounds, {TextDirection? textDirection}) {
    return matrix;
  }
}