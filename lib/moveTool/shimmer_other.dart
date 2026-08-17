import 'package:flutter/material.dart';

class ShimmerOther extends StatefulWidget {
  static ShimmerOtherState? of(BuildContext context) {
    return context.findAncestorStateOfType<ShimmerOtherState>();
  }

  const ShimmerOther({super.key, this.linearGradient, this.child});

  final LinearGradient? linearGradient;
  final Widget? child;

  @override
  ShimmerOtherState createState() => ShimmerOtherState();
}

class ShimmerOtherState extends State<ShimmerOther>
    with SingleTickerProviderStateMixin {
  late AnimationController _shimmerController;
  Listenable get shimmerChanges => _shimmerController;

  static const shimmerGradient = LinearGradient(
    colors: [
      Color(0xFFEBEBF4),
      // Color(0xFFF4F4F4),
      Colors.amber,
      Color(0xFFEBEBF4),
    ],
    stops: [0.1, 0.3, 0.4],
    begin: Alignment(-1.0, -0.3),
    end: Alignment(1.0, 0.3),
    tileMode: TileMode.clamp,
  );

  Gradient get gradient => LinearGradient(
    colors: widget.linearGradient?.colors ?? shimmerGradient.colors,
    stops: widget.linearGradient?.stops ?? shimmerGradient.stops,
    begin: widget.linearGradient?.begin ?? shimmerGradient.begin,
    end: widget.linearGradient?.end ?? shimmerGradient.end,
    transform: _SlidingGradientTransform(
      slidePercent: _shimmerController.value,
    ),
  );

  bool get isSized =>
      (context.findRenderObject() as RenderBox?)?.hasSize ?? false;

  Size get size => (context.findRenderObject() as RenderBox).size;

  Offset getDescendantOffset({
    required RenderBox descendant,
    Offset offset = Offset.zero,
  }) {
    final shimmerBox = context.findRenderObject() as RenderBox;
    return descendant.localToGlobal(offset, ancestor: shimmerBox);
  }

  @override
  void initState() {
    super.initState();
    _shimmerController = AnimationController.unbounded(vsync: this)
      ..repeat(min: -0.5, max: 1.5, period: const Duration(milliseconds: 2000));
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child ?? const SizedBox();
  }
}

class _SlidingGradientTransform extends GradientTransform {
  const _SlidingGradientTransform({required this.slidePercent});

  final double slidePercent;

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * slidePercent, 0.0, 0.0);
  }
}
