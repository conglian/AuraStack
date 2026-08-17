import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';

class ASShine extends StatefulWidget {
  const ASShine({
    super.key,
    required this.child,
    this.width,
    this.height,
    this.duration = const Duration(milliseconds: 2000),
  });

  final Widget child;

  final double? width;
  final double? height;

  final Duration duration;

  @override
  State<ASShine> createState() => _ASShineState();
}

class _ASShineState extends State<ASShine>
    with SingleTickerProviderStateMixin {

  late final AnimationController _controller;

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
    return SizedBox(
      width: widget.width,
      height: widget.height,

      child: AnimatedBuilder(
        animation: _controller,

        builder: (_, child) {

          return ShaderMask(

            blendMode: BlendMode.srcATop,

            shaderCallback: (rect) {

              final w = rect.width;
              final h = rect.height;


              // 从顶部进入，到底部离开
              final dy = lerpDouble(
                -h,
                h * 2,
                _controller.value,
              )!;


              return LinearGradient(

                begin: Alignment.topLeft,
                end: Alignment.bottomRight,

                colors: const [
                  Colors.transparent,
                  Colors.transparent,
                  Color(0x52FFFFFF),
                  Color(0xCCFFFFFF),
                  Color(0x52FFFFFF),
                  Colors.transparent,
                  Colors.transparent,
                ],

                stops: const [
                  0,
                  0.45,
                  0.48,
                  0.5,
                  0.52,
                  0.55,
                  1,
                ],

                transform: _SlidingGradientTransform(
                  dy: dy,
                  angle: pi / 4,
                ),

              ).createShader(
                Rect.fromLTWH(0, 0, w, h),
              );

            },

            child: child,

          );

        },

        child: widget.child,

      ),

    );
  }
}



class _SlidingGradientTransform extends GradientTransform {

  const _SlidingGradientTransform({
    required this.dy,
    required this.angle,
  });


  final double dy;

  final double angle;


  @override
  Matrix4? transform(
      Rect bounds, {
        TextDirection? textDirection,
      }) {

    return Matrix4.identity()

    // Y轴移动，实现从上往下扫
      ..translate(0.0, dy)

    // 保留45度倾斜
      ..rotateZ(angle);

  }
}
