import 'dart:math';
import 'dart:ui' as ui;
import 'package:aurastack/ASTool/as_extension_help.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

class FountainParticle {
  final String imagePath;

  final double p0x = 0.5;
  final double p0y = 0.5;

  final double p1x;
  final double p1y;
  final double p2x;
  final double p2y;

  final double initialPhase;
  final double speed;
  final double size;
  final double spinSpeed;

  FountainParticle({
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
class InfiniteFountainParticles extends StatefulWidget {
  final Widget child;

  const InfiniteFountainParticles({super.key, required this.child});

  @override
  State<InfiniteFountainParticles> createState() =>
      _InfiniteFountainParticlesState();
}

class _InfiniteFountainParticlesState
    extends State<InfiniteFountainParticles>
    with SingleTickerProviderStateMixin {
  late Ticker _ticker;
  double _time = 0;

  final List<FountainParticle> _particles = [];
  final Map<String, ui.Image> _imageCache = {};
  final Random _random = Random();

  @override
  void initState() {
    super.initState();
    _generateParticles();
    _loadImages();

    _ticker = createTicker((elapsed) {
      _time = elapsed.inMicroseconds / 1000000.0;
      setState(() {}); // 只刷新 CustomPaint
    });

    _ticker.start();
  }

  Future<void> _loadImages() async {
    for (var p in _particles) {
      if (_imageCache.containsKey(p.imagePath)) continue;
      final data = await rootBundle.load(p.imagePath);
      final codec = await ui.instantiateImageCodec(data.buffer.asUint8List());
      final frame = await codec.getNextFrame();
      _imageCache[p.imagePath] = frame.image;
    }
    setState(() {});
  }

  void _generateParticles() {
    final images = [
      'as_dollar_icon'.image(),
      'as_dollar_icon'.image(),
      'as_dollar_icon'.image(),
    ];

    for (int i = 0; i < 3; i++) {
      int count = _random.nextInt(7) + 20;

      for (int j = 0; j < count; j++) {
        _particles.add(FountainParticle(
          imagePath: images[i],
          p1x: 0.4 + (_random.nextDouble() - 0.5) * 0.8,
          p1y: 0.1 + _random.nextDouble() * 0.2,
          p2x: 0.5 + (_random.nextDouble() - 0.5) * 1.5,
          p2y: -0.2 - _random.nextDouble() * 0.3,
          initialPhase: _random.nextDouble(),
          speed: 0.5 + _random.nextDouble() * 0.15,
          size: 60.0 + _random.nextDouble() * 15.0,
          spinSpeed: (_random.nextDouble() - 0.5) * 6 * pi,
        ));
      }
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CustomPaint(
          painter: FountainPainter(
            particles: _particles,
            time: _time,
            imageCache: _imageCache,
          ),
          size: Size.infinite,
        ),
        widget.child,
      ],
    );
  }
}
class FountainPainter extends CustomPainter {
  final List<FountainParticle> particles;
  final double time;
  final Map<String, ui.Image> imageCache;

  FountainPainter({
    required this.particles,
    required this.time,
    required this.imageCache,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      if (!imageCache.containsKey(p.imagePath)) continue;

      final image = imageCache[p.imagePath]!;

      double rawProgress =
          (time * p.speed + p.initialPhase) % 1.0;

      double progress = Curves.easeOut.transform(rawProgress);

      double xProgress =
          pow(1 - progress, 2) * p.p0x +
              2 * (1 - progress) * progress * p.p1x +
              pow(progress, 2) * p.p2x;

      double yProgress =
          pow(1 - progress, 2) * p.p0y +
              2 * (1 - progress) * progress * p.p1y +
              pow(progress, 2) * p.p2y;

      double x = xProgress * size.width;
      double y = yProgress * size.height;

      double rotation = time * p.spinSpeed;

      double scale = 1.0;

      if (rawProgress < 0.1) {
        scale = rawProgress / 0.1;
      }

      final paint = Paint();

      canvas.save();

      canvas.translate(x, y);
      canvas.rotate(rotation);
      canvas.scale(scale);

      final src = Rect.fromLTWH(
        0,
        0,
        image.width.toDouble(),
        image.height.toDouble(),
      );

      final dst = Rect.fromCenter(
        center: Offset.zero,
        width: p.size,
        height: p.size,
      );

      canvas.drawImageRect(image, src, dst, paint);

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant FountainPainter oldDelegate) {
    return true;
  }
}