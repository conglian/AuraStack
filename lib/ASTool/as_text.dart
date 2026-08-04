import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'as_stroke_text.dart';

class ASText extends StatelessWidget {
  final String text;
  final double size;
  final Color color;
  final FontWeight weight;
  final int maxLines;
  final TextAlign? align;
  final bool useType;
  final bool is_btn;

  const ASText({
    required this.text,
    required this.size,
    required this.color,
    required this.weight,
    this.maxLines = 1,
    this.align,
    this.useType = false,
    this.is_btn = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle;
    if (useType) {
      textStyle = TextStyle(
        fontSize: size,
        color: color,
        height: 1.15,
        fontWeight: weight,
        fontFamily: text_fontName,
        decoration: TextDecoration.none,
      );
    } else {
      textStyle = TextStyle(
        fontSize: size,
        color: color,
        height: 1.15,
        fontWeight: weight,
        fontFamily: text_fontName,
        decoration: TextDecoration.none,
      );
    }

    return Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      style: textStyle,
    );
  }
}

class ASUnderlineTextButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double fontSize;
  final Color textColor;
  final Color? underlineColor;
  final double? thickness;
  final TextDecorationStyle decorationStyle;
  final EdgeInsetsGeometry? padding;

  /// ✅ 外部只需传入颜色列表
  final List<Color>? gradientColors;

  const ASUnderlineTextButton({
    Key? key,
    required this.text,
    this.onPressed,
    this.fontSize = 14.0,
    this.textColor = Colors.white,
    this.underlineColor,
    this.thickness,
    this.decorationStyle = TextDecorationStyle.solid,
    this.padding,
    this.gradientColors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // 如果外部传入了 gradientColors，则构造线性渐变
    final Gradient? gradient =
        (gradientColors != null && gradientColors!.length >= 2)
        ? LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradientColors!,
          )
        : null;

    final textWidget = Text(
      text,
      style: TextStyle(
        fontFamily: text_fontName,
        fontSize: fontSize,
        color: gradient == null ? textColor : Colors.white,
        decoration: TextDecoration.underline,
        decorationColor: underlineColor ?? textColor,
        decorationThickness: thickness ?? 1.0,
        decorationStyle: decorationStyle,
      ),
    );

    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: padding ?? EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: gradient != null
          ? ShaderMask(
              shaderCallback: (bounds) => gradient.createShader(
                Rect.fromLTWH(0, 0, bounds.width, bounds.height),
              ),
              blendMode: BlendMode.srcIn,
              child: textWidget,
            )
          : textWidget,
    );
  }
}

class ASBouncyText extends StatefulWidget {
  final String text; // 显示文字
  final double fontSize; // 字体大小
  final Color color; // 字体颜色
  final FontWeight fontWeight; // 字重
  final bool enableAnimation; // 是否启用动画

  final double? width; // 可选宽度
  final Color? backgroundColor; // 可选背景色

  final double strokeWidth; // 描边宽度（0 = 不描边）
  final Color? strokeColor; // 描边颜色

  const ASBouncyText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    this.fontWeight = FontWeight.normal,
    this.enableAnimation = true,
    this.width,
    this.backgroundColor,
    this.strokeWidth = 0,
    this.strokeColor,
  });

  @override
  State<ASBouncyText> createState() => _ASBouncyTextState();
}

class _ASBouncyTextState extends State<ASBouncyText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scale = Tween<double>(
      begin: 0.85,
      end: 1.05,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.enableAnimation) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ASBouncyText oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.enableAnimation != widget.enableAnimation) {
      if (widget.enableAnimation) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0;
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget text = _buildText();

    // 动画控制
    if (widget.enableAnimation) {
      text = ScaleTransition(
        scale: _scale,
        child: text,
      );
    }

    return Container(
      width: widget.width,
      padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      color: widget.backgroundColor,
      child: text,
    );
  }

  /// 🎯 文本 + 描边层
  Widget _buildText() {
    final hasStroke =
        widget.strokeWidth > 0 && widget.strokeColor != null;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 描边层
        if (hasStroke)
          Text(
            widget.text,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: text_fontName,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight,
              foreground: Paint()
                ..style = PaintingStyle.stroke
                ..strokeWidth = widget.strokeWidth
                ..color = widget.strokeColor!,
            ),
          ),

        // 正常文字层
        Text(
          widget.text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: text_fontName,
            fontSize: widget.fontSize,
            fontWeight: widget.fontWeight,
            color: widget.color,
          ),
        ),
      ],
    );
  }
}


class ASBouncyChild extends StatefulWidget {
  final  Widget child; // 显示文字
  final bool enableAnimation; // ✅ 是否启用动画

  const ASBouncyChild({
    super.key,
    this.enableAnimation = true, required this.child, // 默认开启动画
  });

  @override
  State<ASBouncyChild> createState() => _ASBouncyChildState();
}

class _ASBouncyChildState extends State<ASBouncyChild>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scale = Tween(
      begin: 0.85,
      end: 1.05,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    if (widget.enableAnimation) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant ASBouncyChild oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部切换动画状态时，动态启停动画
    if (oldWidget.enableAnimation != widget.enableAnimation) {
      if (widget.enableAnimation) {
        _controller.repeat(reverse: true);
      } else {
        _controller.stop();
        _controller.value = 1.0; // 停止时恢复正常大小
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ 没开动画时，直接返回普通 Text
    if (!widget.enableAnimation) {
      return widget.child;
    }

    return ScaleTransition(
      scale: _scale,
      child: widget.child,
    );
  }
}
