import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'as_extension_help.dart';
import 'as_stroke_text.dart';

class ASGradientText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Gradient gradient;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final TextOverflow? overflow;
  final bool softWrap;
  final int? maxLines;
  final double? textScaleFactor;

  const ASGradientText(
    this.text, {
    Key? key,
    required this.fontSize,
    required this.gradient,
    this.textAlign,
    this.textDirection,
    this.overflow,
    this.softWrap = true,
    this.maxLines,
    this.textScaleFactor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ShaderMask(
      blendMode: BlendMode.srcIn,
      shaderCallback: (bounds) => gradient.createShader(
        Rect.fromLTWH(0, 0, bounds.width, bounds.height),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: fontSize,
          fontFamily: text_fontName,
          color: Colors.white, // 必须为白色，否则渐变不会生效
        ),
        textAlign: textAlign,
        textDirection: textDirection,
        overflow: overflow,
        softWrap: softWrap,
        maxLines: maxLines,
        textScaleFactor: textScaleFactor,
      ),
    );
  }
}

class ASGradientStrokeText extends StatelessWidget {
  final String text;
  final List<Color> gradientColors;
  final Color strokeColor;
  final double strokeWidth;
  final int fontSize;
  final double width;
  final double height;

  const ASGradientStrokeText({
    super.key,
    required this.text,
    required this.gradientColors,
    required this.width,
    required this.height,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
    required this.fontSize,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: CustomPaint(
        painter: _ASGradientStrokeTextPainter(
          text: text,
          gradientColors: gradientColors,
          strokeColor: strokeColor,
          strokeWidth: strokeWidth,
          fontSizes: fontSize,
        ),
      ),
    );
  }
}

class _ASGradientStrokeTextPainter extends CustomPainter {
  final String text;
  final List<Color> gradientColors;
  final Color strokeColor;
  final double strokeWidth;
  final int fontSizes;

  _ASGradientStrokeTextPainter({
    required this.text,
    required this.gradientColors,
    required this.strokeColor,
    required this.strokeWidth,
    required this.fontSizes,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final baseStyle = TextStyle(
      fontSize: fontSizes.toDouble(),
      fontWeight: FontWeight.w900,
      fontFamily: text_fontName,
      color: Colors.white,
    );

    // 文字布局
    final textSpan = TextSpan(text: text, style: baseStyle);
    final textPainter = TextPainter(
      text: textSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    // 居中绘制 offset
    final offset = Offset(
      (size.width - textPainter.width) / 2,
      (size.height - textPainter.height) / 2,
    );

    final rect = Rect.fromLTWH(0, 0, size.width, size.height);

    // 描边
    final strokePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..color = strokeColor
      ..isAntiAlias = true;

    final strokeTextSpan = TextSpan(
      text: text,
      style: baseStyle.copyWith(foreground: strokePaint),
    );

    final strokeTextPainter = TextPainter(
      text: strokeTextSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    strokeTextPainter.paint(canvas, offset);

    // 渐变填充
    final fillPaint = Paint()
      ..shader = LinearGradient(
        colors: gradientColors,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(rect)
      ..isAntiAlias = true;

    final fillTextSpan = TextSpan(
      text: text,
      style: baseStyle.copyWith(foreground: fillPaint),
    );

    final fillTextPainter = TextPainter(
      text: fillTextSpan,
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    )..layout();

    fillTextPainter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
