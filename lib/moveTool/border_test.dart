import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

class ElectricBorder extends StatefulWidget {
  final double width;
  final double height;
  final double intensity; // 扰动强度
  final double speed;     // 流动速度
  final Color color;

  const ElectricBorder({
    super.key,
    this.width = 200,
    this.height = 200,
    this.intensity = 6,
    this.speed = 1,
    this.color = Colors.purpleAccent,
  });

  @override
  State<ElectricBorder> createState() => _ElectricBorderState();
}

class _ElectricBorderState extends State<ElectricBorder>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  double _time = 0;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      setState(() {
        _time = elapsed.inMilliseconds / 1000.0;
      });
    })..start();
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(widget.width, widget.height),
      painter: _ElectricPainter(
        time: _time,
        intensity: widget.intensity,
        speed: widget.speed,
        color: widget.color,
      ),
    );
  }
}
class _ElectricPainter extends CustomPainter {
  final double time;
  final double intensity;
  final double speed;
  final Color color;

  _ElectricPainter({
    required this.time,
    required this.intensity,
    required this.speed,
    required this.color,
  });

  final Random _random = Random(1);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final path = Path();
    final points = _generateElectricRect(size);

    path.moveTo(points.first.dx, points.first.dy);
    for (var p in points) {
      path.lineTo(p.dx, p.dy);
    }
    path.close();

    canvas.drawPath(path, paint);
  }

  List<Offset> _generateElectricRect(Size size) {
    const segments = 100;
    final List<Offset> result = [];

    final perimeter = 2 * (size.width + size.height);

    for (int i = 0; i <= segments; i++) {
      double t = i / segments;
      double distance = t * perimeter;

      Offset basePoint = _pointOnRect(size, distance);

      double noise = sin((t * 20) + time * speed * 5);
      double offsetAmount = noise * intensity;

      Offset normal = _normalOnRect(size, distance);

      result.add(basePoint + normal * offsetAmount);
    }

    return result;
  }

  Offset _pointOnRect(Size size, double d) {
    double w = size.width;
    double h = size.height;

    if (d < w) return Offset(d, 0);
    d -= w;

    if (d < h) return Offset(w, d);
    d -= h;

    if (d < w) return Offset(w - d, h);
    d -= w;

    return Offset(0, h - d);
  }

  Offset _normalOnRect(Size size, double d) {
    double w = size.width;
    double h = size.height;

    if (d < w) return const Offset(0, -1);
    d -= w;

    if (d < h) return const Offset(1, 0);
    d -= h;

    if (d < w) return const Offset(0, 1);
    return const Offset(-1, 0);
  }

  @override
  bool shouldRepaint(covariant _ElectricPainter oldDelegate) => true;
}