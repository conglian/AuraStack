import 'package:flutter/material.dart';
import 'package:spine_flutter/spine_flutter.dart';

class ASSpine extends StatefulWidget {
  const ASSpine({
    super.key,
    required this.path,
    this.width,
    this.height,
    this.animation = 'animation',
    this.loop = true,
    this.fit = BoxFit.contain,
    this.isJson = true,
  });

  /// 不带后缀
  ///
  /// assets/spine/login/login/
  final String path;

  final double? width;
  final double? height;

  /// 默认 animation
  final String animation;

  /// 是否循环
  final bool loop;

  /// json/skel
  final bool isJson;

  final BoxFit fit;

  @override
  State<ASSpine> createState() => _ASSpineState();
}

class _ASSpineState extends State<ASSpine> {
  late final SpineWidgetController controller;

  @override
  void initState() {
    super.initState();

    controller = SpineWidgetController(
      onInitialized: (c) {
        c.animationState.setAnimation(
          0,
          widget.animation,
          widget.loop,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: SpineWidget.fromAsset(
        '${widget.path}skeleton.atlas',
        widget.isJson
            ? '${widget.path}skeleton.json'
            : '${widget.path}skeleton.skel',
        controller,
        fit: widget.fit,
      ),
    );
  }
}
