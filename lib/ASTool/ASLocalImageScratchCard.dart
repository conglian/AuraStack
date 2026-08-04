import 'dart:async';
import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'ASAudioUtils.dart';
import 'ASLogger.dart';
import 'as_LocalProvider.dart';
import 'as_extension_help.dart';


class ASLocalImageScratchCard extends StatefulWidget {
  final Widget child;
  final String coverImagePath;
  final double strokeWidth;
  final double scratchThreshold;
  final Duration revealDuration;
  final VoidCallback? onScratchEnd;
  final bool autoScratch;
  final Duration autoScratchDuration;
  final double autoStartY;
  final double contentW;
  final double contentH;

  const ASLocalImageScratchCard({
    Key? key,
    required this.child,
    required this.coverImagePath,
    this.autoStartY = 128.0,
    this.strokeWidth = 40.0,
    this.scratchThreshold = 0.65,
    this.revealDuration = const Duration(milliseconds: 2000),
    this.onScratchEnd,
    this.autoScratch = true,
    this.autoScratchDuration = const Duration(seconds: 2),
    required this.contentW,
    required this.contentH,
  })  : assert(scratchThreshold >= 0 && scratchThreshold <= 1, 'scratchThreshold必须在0-1之间'),
        super(key: key);

  @override
  _ASLocalImageScratchCardState createState() => _ASLocalImageScratchCardState();
}

class _ASLocalImageScratchCardState extends State<ASLocalImageScratchCard> with TickerProviderStateMixin {
  List<Offset> _points = [];
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _fullyRevealed = false;
  ui.Image? _coverImage;
  int _repaintFlag = 0;
  bool _isScratching = false;
  Offset? _currentFingerPosition;

  bool _isAutoScratching = false;
  late AnimationController _autoScratchController;
  StreamSubscription<void>? _autoScratchSubscription;
  List<Offset> _autoScratchPath = [];
  int _currentPathIndex = 0;
  final double _autoStepHeight = 40;
  Offset? _autoCoinPosition;
  int _totalPathPoints = 0;
  late Duration _pointInterval;
  double _totalScratchArea = 0;
  double _totalCardArea = 0;
  bool _coverVisible = false;

  bool _isLoading = true; // ✅ 新增：控制首次加载状态
  bool _hasFinished = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: widget.revealDuration);
    _animation = Tween(begin: 1.0, end: 0.0).animate(_animationController)..addListener(() => setState(() {}));

    ASScratchUpdateNotificationService.stream.listen((value) async {
      ASScratchTapNotificationService.sendToDomandNumberNotification(0);
      if (mounted && value == 0) {
        _resetScratchCard();
      } else if (value == 1) {
        if (widget.autoScratch && mounted && !_isAutoScratching) {
          _startAutoScratch();
          ASAudioUtils().stopAllTempAudio();
          if (ASLocalProvider.instance.as_sound_music){
            ASAudioUtils().playGuaAudio();
          }
        }
      }
    });

    _loadLocalImage();
    _initAutoScratchController();
  }

  void _initAutoScratchController() {
    _autoScratchController = AnimationController(vsync: this, duration: widget.autoScratchDuration);
  }

  Future<void> _loadLocalImage() async {
    try {
      final image = await _loadImage(widget.coverImagePath);
      if (!mounted) return;
      setState(() {
        _coverImage = image;
        _isLoading = false; // ✅ 加载完成后才显示内容
      });
      Future.delayed(const Duration(milliseconds: 100), () {
        if (!mounted) return;
        setState(() {
          _coverVisible = true;
        });
        if (widget.autoScratch) _generateAutoScratchPath();
      });
    } catch (e) {
      asLog.error('加载刮卡图片出错: $e');
    }
  }

  Future<ui.Image> _loadImage(String asset) async {
    final data = await rootBundle.load(asset);
    final bytes = data.buffer.asUint8List();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    return frame.image;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _autoScratchController.dispose();
    _autoScratchSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handlePanUpdate(DragUpdateDetails details, Size size) async {
    if (_fullyRevealed || _isAutoScratching) return;
    setState(() {
      _points.add(details.localPosition);
      _repaintFlag++;
      _isScratching = true;
      _currentFingerPosition = details.localPosition;
      _autoCoinPosition = null;
      _calculateScratchPercentage(size);
    });
  }

  Future<void> _handlePanEnd() async {
    setState(() {
      _isScratching = false;
      _currentFingerPosition = null;
      _points.add(Offset.zero);
      _repaintFlag++;
      _autoCoinPosition = null;
    });
    await ASAudioUtils().stopAllTempAudio();
  }

  void _resetScratchCard() {
    setState(() {
      _hasFinished = false; // ✅ 重置锁
      _points = [];
      _fullyRevealed = false;
      _repaintFlag++;
      _isScratching = false;
      _currentFingerPosition = null;
      _animationController.reset();
      _coverVisible = false;
      _isLoading = true; // ✅ 重置时重新进入加载状态
      _loadLocalImage();
      _resetAutoScratch();
    });
  }

  void _resetAutoScratch() {
    _isAutoScratching = false;
    _currentPathIndex = 0;
    _autoScratchPath.clear();
    _autoCoinPosition = null;
    _autoScratchController.reset();
    _autoScratchSubscription?.cancel();
    _autoScratchSubscription = null;
    _totalScratchArea = 0;
  }

  void _generateAutoScratchPath() {
    if (_coverImage == null) return;
    final size = Size(widget.contentW, widget.contentH);
    final cardWidth = size.width;
    final cardHeight = size.height;
    _totalCardArea = cardWidth * cardHeight;

    _autoScratchPath.clear();
    _currentPathIndex = 0;
    double y = widget.autoStartY;
    bool rightToLeft = false;

    while (y < cardHeight) {
      double startX = rightToLeft ? cardWidth : 0;
      double endX = rightToLeft ? 0 : cardWidth;
      double step = 5;
      for (double x = startX; (rightToLeft && x >= endX) || (!rightToLeft && x <= endX); x += rightToLeft ? -step : step) {
        _autoScratchPath.add(Offset(x, y));
      }
      y += _autoStepHeight;
      rightToLeft = !rightToLeft;
    }

    _totalPathPoints = _autoScratchPath.length;
    _calculatePointInterval();
  }

  void _calculatePointInterval() {
    if (_totalPathPoints <= 0) return;
    final totalMilliseconds = widget.autoScratchDuration.inMilliseconds;
    final interval = totalMilliseconds / _totalPathPoints;
    _pointInterval = const Duration(milliseconds: 1);  // 自动刮卡速度：越小越快
  }

  void _addAutoScratchPoint(Offset point) {
    setState(() {
      _points.add(point);
      _repaintFlag++;
      _isScratching = true;
      _autoCoinPosition = point;
    });
  }

  void _startAutoScratch() {
    if (_coverImage == null || _autoScratchPath.isEmpty) return;
    _autoScratchSubscription?.cancel();

    setState(() {
      _isAutoScratching = true;
      _isScratching = true;
      _currentPathIndex = 0;
      _autoScratchController.forward();
      _totalScratchArea = 0;

      _autoScratchSubscription = Stream.periodic(_pointInterval, (i) => i)
          .take(_totalPathPoints)
          .listen((index) {
        if (_isAutoScratching && _currentPathIndex < _autoScratchPath.length) {
          _addAutoScratchPoint(_autoScratchPath[_currentPathIndex]);
          _currentPathIndex++;
          _calculateScratchPercentage(Size(widget.contentW, widget.contentH));
        }
      });
    });
  }

  double _calculateDistance(Offset p1, Offset p2) {
    double dx = p2.dx - p1.dx;
    double dy = p2.dy - p1.dy;
    return sqrt(dx * dx + dy * dy);
  }

  void _calculateScratchPercentage(Size size) {
    if (_hasFinished) return; // ✅ 关键修复
    if (_points.isEmpty || _totalCardArea == 0) return;
    double scratchArea = 0;
    for (int i = 1; i < _points.length; i++) {
      if (_points[i] == Offset.zero || _points[i - 1] == Offset.zero) continue;
      double distance = _calculateDistance(_points[i - 1], _points[i]);
      scratchArea += distance * widget.strokeWidth;
    }
    _totalScratchArea = scratchArea;
    double percent = scratchArea / _totalCardArea;
    if (percent >= widget.scratchThreshold || _currentPathIndex >= _autoScratchPath.length) {
      _finishAutoScratch(percent);
    }
  }

  Future<void> _finishAutoScratch([double? finalPercent]) async {

    if (_hasFinished) return; // ✅ 关键修复
    _hasFinished = true;
    setState(() {
      _isAutoScratching = false;
      _fullyRevealed = true;
      widget.onScratchEnd?.call();
      _animationController.forward();
      _autoScratchSubscription?.cancel();
      _autoScratchSubscription = null;
    });
    await ASAudioUtils().stopAllTempAudio();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      // ✅ 防止先看到 child
      return SizedBox(
        width: widget.contentW,
        height: widget.contentH,
        child: const ColoredBox(color: Colors.transparent),
      );
    }

    return GestureDetector(
      onPanStart: _isAutoScratching ? null : (details) async {
        if (_fullyRevealed) return;
        ASScratchTapNotificationService.sendToDomandNumberNotification(0);
        setState(() {
          _points.add(details.localPosition);
          _repaintFlag++;
          _isScratching = true;
          _currentFingerPosition = details.localPosition;
          _autoCoinPosition = null;
        });
        // CS_event_fire('scratch_card', {'type' : 'user'});
        if (ASLocalProvider.instance.as_sound_music) {
          await ASAudioUtils().playGuaAudio();
        }
      },
      onPanUpdate: _isAutoScratching ? null : (details) => _handlePanUpdate(details, Size(widget.contentW, widget.contentH)),
      onPanEnd: _isAutoScratching ? null : (details) => _handlePanEnd(),
      child: Stack(
        children: [
          widget.child,
          if (_coverVisible && (!_fullyRevealed || _animation.value > 0) && _coverImage != null)
            Opacity(
              opacity: _animation.value,
              child: CustomPaint(
                painter: _LocalScratchPainter(
                  points: _points,
                  strokeWidth: widget.strokeWidth,
                  coverImage: _coverImage!,
                  repaintFlag: _repaintFlag,
                  fullyRevealed: _fullyRevealed,
                  contentW: widget.contentW,
                  contentH: widget.contentH,
                ),
              ),
            ),
          if ((_isScratching || _isAutoScratching) && (_currentFingerPosition != null || _autoCoinPosition != null))
            _buildCoinImage(),
        ],
      ),
    );
  }

  Widget _buildCoinImage() {
    final position = _isAutoScratching ? _autoCoinPosition : _currentFingerPosition;
    if (position == null) return const SizedBox();
    return Positioned(
      left: position.dx - 15,
      top: position.dy - 15,
      child: SizedBox(
        width: 60,
        height: 60,
        child: Image.asset('cs_tap_icon'.image(), fit: BoxFit.fill),
      ),
    );
  }
}

class _LocalScratchPainter extends CustomPainter {
  final List<Offset> points;
  final ui.Image coverImage;
  final double strokeWidth;
  final bool fullyRevealed;
  final int repaintFlag;
  final double contentW;
  final double contentH;

  _LocalScratchPainter({
    required this.points,
    required this.coverImage,
    required this.strokeWidth,
    required this.fullyRevealed,
    required this.repaintFlag,
    required this.contentW,
    required this.contentH,
  });

  @override
  void paint(Canvas canvas, Size size) {
    size = Size(contentW, contentH);

    canvas.saveLayer(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint(),
    );

    /// 1️⃣ 绘制遮罩图（BoxFit.fill）
    if (!fullyRevealed) {
      final imageSize = Size(
        coverImage.width.toDouble(),
        coverImage.height.toDouble(),
      );

      final fittedSizes = applyBoxFit(
        BoxFit.fill,
        imageSize,
        size,
      );

      final Rect srcRect = Alignment.center.inscribe(
        fittedSizes.source,
        Offset.zero & imageSize,
      );

      final Rect dstRect = Alignment.center.inscribe(
        fittedSizes.destination,
        Offset.zero & size,
      );

      canvas.drawImageRect(
        coverImage,
        srcRect,
        dstRect,
        Paint(),
      );
    }

    /// 2️⃣ 擦除路径
    if (points.isNotEmpty) {
      final path = Path();
      bool isFirst = true;

      for (final point in points) {
        if (point == Offset.zero) {
          isFirst = true;
          continue;
        }

        if (isFirst) {
          path.moveTo(point.dx, point.dy);
          isFirst = false;
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }

      final erasePaint = Paint()
        ..blendMode = BlendMode.clear
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..style = PaintingStyle.stroke;

      canvas.drawPath(path, erasePaint);
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(_LocalScratchPainter oldDelegate) {
    return oldDelegate.points != points ||
        oldDelegate.coverImage != coverImage ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.fullyRevealed != fullyRevealed ||
        oldDelegate.repaintFlag != repaintFlag;
  }
}


class ASScratchUpdateNotificationService {
  static final StreamController<int> _streamController = StreamController<int>.broadcast();

  static Stream<int> get stream => _streamController.stream;

  static void sendToDomandNumberNotification(int value) {
    _streamController.sink.add(value);
  }

  static void close() {
    _streamController.close();
  }
}

class ASScratchTapNotificationService {
  static final StreamController<int> _streamController = StreamController<int>.broadcast();

  static Stream<int> get stream => _streamController.stream;

  static void sendToDomandNumberNotification(int value) {
    _streamController.sink.add(value);
  }

  static void close() {
    _streamController.close();
  }
}

final swapKey1 = GlobalKey<_ASCardSwapAnimatorState>();
final swapKey2 = GlobalKey<_ASCardSwapAnimatorState>();
final swapKey3 = GlobalKey<_ASCardSwapAnimatorState>();
final swapKey4 = GlobalKey<_ASCardSwapAnimatorState>();
final swapKey5 = GlobalKey<_ASCardSwapAnimatorState>();
final swapKey6 = GlobalKey<_ASCardSwapAnimatorState>();

class ASCardSwapAnimator extends StatefulWidget {
  final Widget child;                 // 初始卡片
  final Duration duration;

  const ASCardSwapAnimator({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 650),
  });

  @override
  State<ASCardSwapAnimator> createState() => _ASCardSwapAnimatorState();
}

class _ASCardSwapAnimatorState extends State<ASCardSwapAnimator>
    with SingleTickerProviderStateMixin {

  late Widget _current;
  Widget? _next;

  late AnimationController _controller;

  late Animation<double> oldOffsetX;
  late Animation<double> oldRotation;

  late Animation<double> newOffsetX;
  late Animation<double> newRotation;
  late Animation<double> newOpacity;

  @override
  void initState() {
    super.initState();

    _current = widget.child;

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    oldOffsetX = Tween<double>(begin: 0, end: 280).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.0, 0.65, curve: Curves.easeIn)),
    );

    oldRotation = Tween<double>(begin: 0, end: 0.35).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.0, 0.7, curve: Curves.easeIn)),
    );

    newOffsetX = Tween<double>(begin: -280, end: 0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.35, 1.0, curve: Curves.easeOutBack)),
    );

    newRotation = Tween<double>(begin: -0.35, end: 0).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.35, 1.0, curve: Curves.easeOut)),
    );

    newOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller,
          curve: const Interval(0.3, 1.0, curve: Curves.easeOut)),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override void didUpdateWidget(ASCardSwapAnimator oldWidget) {
    super.didUpdateWidget(oldWidget);
    // 当外部 child 改变时，如果没有正在动画，需要更新 _current
    if (oldWidget.child != widget.child && _next == null) {
      setState(() {
        _current = widget.child;
      });
    }
  }

  /// 外部调用 controller.swapTo(newCard) 时触发此处
  Future<void> runSwap(Widget newCard) async {
    if (!mounted) return;

    if (_next != null) return; // 动画未结束时不允许叠加切换

    _next = newCard;

    await _controller.forward();

    if (!mounted) return;

    // 动画结束：替换 current
    setState(() {
      _current = _next!;
      _next = null;
    });

    _controller.reset();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        return Stack(
          children: [

            /// OLD CARD
            Transform.translate(
              offset: Offset(oldOffsetX.value, 0),
              child: Transform.rotate(
                angle: oldRotation.value,
                child: _current,
              ),
            ),

            /// NEW CARD（可能为空）
            if (_next != null)
              Opacity(
                opacity: newOpacity.value,
                child: Transform.translate(
                  offset: Offset(newOffsetX.value, 0),
                  child: Transform.rotate(
                    angle: newRotation.value,
                    child: _next!,
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}