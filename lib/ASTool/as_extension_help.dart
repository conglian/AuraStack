import 'dart:convert';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension CardWalletSpinearnExtension on String {

  String image() {
    return "assets/images/$this.webp";
  }

  String files() {
    return "assets/File/$this";
  }

  String mp3files() {
    return "File/$this.mp3";
  }

  String jsons() {
    return "assets/File/$this.json";
  }

  String spinepaths() {
    return "assets/spine/$this/";
  }

  Color color({double opacity = 1.0}) {
    final hexCode = this.replaceAll('#', '');
    return Color(int.parse('0x$hexCode')).withOpacity(opacity);
  }

  Color tocolor({double opacity = 1.0}) {
    final hexCode = this.replaceAll('#', '');
    return Color(int.parse('0x$hexCode')).withOpacity(opacity);
  }
}

// 分段打印
void printLongString(String text) {
  const chunkSize = 800;
  for (int i = 0; i < text.length; i += chunkSize) {
    print(
      text.substring(
        i,
        i + chunkSize > text.length ? text.length : i + chunkSize,
      ),
    );
  }
}

extension ScreenExtension on int {

  String dolasType(){
    // if (isBrazilianPortuguese(homeKey.currentContext!)){
    //   return 'R\$';
    // } else {
      return '\$';
    // }
  }

  bool isBrazilianPortuguese(BuildContext context) {
    // 获取当前语言环境
    Locale currentLocale = Localizations.localeOf(context);

    // 判断是否是巴西葡萄牙语
    return currentLocale.languageCode == 'pt' || currentLocale.countryCode == 'BR';
  }

  double width(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  double height(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double safeTop(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  double safeBottom(BuildContext context) {
    return MediaQuery.of(context).padding.top;
  }

  String to2SelfString() {
    double doubleNumber = this.toDouble();
    return doubleNumber.toStringAsFixed(1);
  }

  String to2String(int number) {
    double doubleNumber = number.toDouble();
    return doubleNumber.toStringAsFixed(2);
  }

  double roundToFourDecimals(double value) {
    var multiplier = 100;
    if (value >= 999.00) {
      multiplier = 10000;
    }
    return (value * multiplier).round() / multiplier;
  }

  /// 生成1到20之间的随机整数（包含1和20）
  int getRandomNumberBetween1And20() {
    // 创建随机数生成器实例
    final random = Random();

    // 生成0-19的随机数，然后加1得到1-20
    return random.nextInt(20) + 1;
  }

  /// 生成1到10之间的随机整数（包含1和20）
  int getRandomNumberBetween1And10() {
    // 创建随机数生成器实例
    final random = Random();

    // 生成0-19的随机数，然后加1得到1-20
    return random.nextInt(10) + 1;
  }

  /// 计算里程数
  /// [gender] 性别，传入 '0' 表示男性，'1' 表示女性
  /// [height] 身高，单位为厘米(cm)
  /// [steps] 步数，整数
  /// 返回值：里程数，单位为公里(km)，保留一位小数
  double calculateMileage({
    required int gender,
    required double height,
    required int steps,
  }) {
    // 1. 确定步幅系数
    double strideCoefficient;

    if (gender == 0) {
      // 男性步幅系数判断
      if (height <= 160) {
        strideCoefficient = 0.415;
      } else if (height <= 170) {
        strideCoefficient = 0.445;
      } else {
        strideCoefficient = 0.475;
      }
    } else if (gender == 1) {
      // 女性步幅系数判断
      if (height <= 150) {
        strideCoefficient = 0.413;
      } else if (height <= 160) {
        strideCoefficient = 0.43;
      } else {
        strideCoefficient = 0.453;
      }
    } else {
      // 未知性别返回0
      return 0.0;
    }

    // 2. 计算步长(cm)：身高 * 步幅系数
    final double stepLength = height * strideCoefficient;

    // 3. 计算里程(km)：(步数 * 步长) / 100000（转换单位为km）
    final double mileage = (steps * stepLength) / 100000;

    // 4. 保留一位小数并返回
    return double.parse(mileage.toStringAsFixed(2));
  }
}

class CustomVerticalList<T> extends StatelessWidget {
  final List<T> data;
  final Widget Function(BuildContext, T, int) itemBuilder;

  const CustomVerticalList({
    super.key,
    required this.data,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: data.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        return itemBuilder(context, data[index], index);
      },
    );
  }
}

extension ScreenPadding on double {
  // 封装传入 double 返回数字带逗号类型的函数，保留四位小数
  String formatNumberWithCommas(double number, int Fixed) {
    final numberStr = number.toStringAsFixed(Fixed);
    final parts = numberStr.split('.');
    final integerPart = parts[0];
    final decimalPart = parts.length > 1 ? parts[1] : '';

    final buffer = StringBuffer();
    int counter = 0;
    for (int i = integerPart.length - 1; i >= 0; i--) {
      buffer.write(integerPart[i]);
      counter++;
      if (counter % 3 == 0 && i != 0) {
        buffer.write(',');
      }
    }
    final formattedInteger = buffer.toString().split('').reversed.join();

    return decimalPart.isNotEmpty
        ? '$formattedInteger.$decimalPart'
        : formattedInteger;
  }

  EdgeInsets top(double value) {
    return EdgeInsets.only(top: value);
  }

  EdgeInsets left(double value) {
    return EdgeInsets.only(left: value);
  }

  EdgeInsets bottom(double value) {
    return EdgeInsets.only(bottom: value);
  }

  EdgeInsets right(double value) {
    return EdgeInsets.only(right: value);
  }

  EdgeInsets only(double value, double value1, double value2, double value3) {
    return EdgeInsets.only(
      top: value,
      left: value1,
      bottom: value2,
      right: value3,
    );
  }

  EdgeInsets all(double value) {
    return EdgeInsets.all(value);
  }
}

extension OtherExtension on int {
  String today() {
    DateTime now = DateTime.now();

    String formattedDate =
        '${now.year}/${_twoDigits(now.month)}/${_twoDigits(now.day)}';

    return formattedDate;
  }

  String _twoDigits(int n) {
    if (n >= 10) {
      return '$n';
    }
    return '0$n';
  }

  double to2Double(num value) {
    return double.parse(value.toStringAsFixed(2));
  }
}

extension IterableExtension<E> on Iterable<E> {
  Iterable<T> mapIndexed<T>(T Function(int index, E element) toElement) sync* {
    int index = 0;
    for (final element in this) {
      yield toElement(index++, element);
    }
  }
}

extension TipShow on BuildContext {
  Future tipShow(
    Widget v, {
    Color? bc,
    double blurSigma = 8, // 👈 模糊强度，可调
  }) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: false,
      barrierColor: bc ?? Colors.black.withOpacity(0.7),
      // 透明度不变
      transitionDuration: const Duration(milliseconds: 150),
      transitionBuilder: (ctx, animation, sAnimation, child) {
        final curvedAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOut,
        );
        final reverseCurvedAnimation = CurvedAnimation(
          parent: sAnimation,
          curve: Curves.easeIn,
        );

        return Stack(
          children: [
            /// ✅ 背景模糊层（不影响 barrierColor）
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(
                color: Colors.transparent, // 必须是透明
              ),
            ),

            /// 原来的弹窗动画
            ScaleTransition(
              scale: Tween<double>(begin: 0.4, end: 1).animate(curvedAnimation),
              child: FadeTransition(
                opacity: Tween<double>(
                  begin: 0.3,
                  end: 1,
                ).animate(curvedAnimation),
                child: ScaleTransition(
                  scale: Tween<double>(
                    begin: 1,
                    end: 0.3,
                  ).animate(reverseCurvedAnimation),
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 1,
                      end: 0.2,
                    ).animate(reverseCurvedAnimation),
                    child: child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      pageBuilder: (context, animation, sAnimation) {
        return PopScope(
          canPop: false,
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            child: v,
          ),
        );
      },
    );
  }
}

extension TipShow2 on BuildContext {
  Future tipShow2(Widget child, {Color? bc}) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      transitionDuration: const Duration(milliseconds: 250),
      pageBuilder: (_, __, ___) {
        return WillPopScope(
          onWillPop: () async => false, // 🚫 禁止返回键 & 左滑返回
          child: _AnimatedDialogWrapper(
            child: child,
            background: bc ?? Colors.black.withOpacity(0.7),
          ),
        );
      },
    );
  }
}

extension TipShowAdvanced on BuildContext {
  Future tipShowAdvanced(Widget v, {Color? bc, double blurSigma = 10}) {
    return showGeneralDialog(
      context: this,
      barrierDismissible: false,
      barrierColor: bc ?? Colors.black.withOpacity(0.65),
      transitionDuration: const Duration(milliseconds: 350),
      transitionBuilder: (ctx, animation, secondaryAnimation, child) {
        /// ===== 显示动画 =====
        final showCurve = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutBack, // 带回弹
        );

        final showFade = CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
        );

        /// ===== 关闭动画 =====
        final hideCurve = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeInCubic,
        );

        final hideFade = CurvedAnimation(
          parent: secondaryAnimation,
          curve: const Interval(0.0, 0.5, curve: Curves.easeIn),
        );

        return Stack(
          children: [
            /// 背景模糊
            BackdropFilter(
              filter: ImageFilter.blur(sigmaX: blurSigma, sigmaY: blurSigma),
              child: Container(color: Colors.transparent),
            ),

            /// 主动画
            SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 1.1),
                end: Offset.zero,
              ).animate(showCurve),
              child: FadeTransition(
                opacity: Tween<double>(begin: 0.0, end: 1.0).animate(showFade),
                child: ScaleTransition(
                  scale: TweenSequence<double>([
                    /// 关闭时轻微放大再吸入
                    TweenSequenceItem(
                      tween: Tween(begin: 1.0, end: 1.05),
                      weight: 20,
                    ),
                    TweenSequenceItem(
                      tween: Tween(begin: 1.05, end: 0.2),
                      weight: 80,
                    ),
                  ]).animate(hideCurve),
                  child: FadeTransition(
                    opacity: Tween<double>(
                      begin: 1.0,
                      end: 0.0,
                    ).animate(hideFade),
                    child: ScaleTransition(
                      /// 显示时微缩放到正常大小
                      scale: Tween<double>(
                        begin: 0.95,
                        end: 1.0,
                      ).animate(showCurve),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return PopScope(
          canPop: false,
          child: Dialog(
            insetPadding: EdgeInsets.zero,
            backgroundColor: Colors.transparent,
            child: v,
          ),
        );
      },
    );
  }
}

class _AnimatedDialogWrapper extends StatefulWidget {
  final Widget child;
  final Color background;

  const _AnimatedDialogWrapper({required this.child, required this.background});

  @override
  State<_AnimatedDialogWrapper> createState() => _AnimatedDialogWrapperState();
}

class _AnimatedDialogWrapperState extends State<_AnimatedDialogWrapper>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _bgOpacity;
  late Animation<double> _scale;
  late Animation<double> _childOpacity;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );

    _bgOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _scale = Tween(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));

    _childOpacity = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (_, __) {
        return Stack(
          children: [
            // 背景蒙层渐变（不闪烁）
            Opacity(
              opacity: _bgOpacity.value,
              child: Container(color: widget.background),
            ),

            // 弹框本体
            Center(
              child: Transform.scale(
                scale: _scale.value,
                child: Opacity(
                  opacity: _childOpacity.value,
                  child: Dialog(
                    insetPadding: EdgeInsets.zero,
                    backgroundColor: Colors.transparent,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class BoomUniqueStringUtil {
  BoomUniqueStringUtil._internal();

  //加密：“data”：原始字符串；“code”：需求文档标题前的项目编号
  static String encrypt(String data, int code) {
    final dataBytes = utf8.encode(data);
    List<int> xorList = [];
    for (int i = 0; i < dataBytes.length; i++) {
      xorList.add(dataBytes[i] ^ code);
    }
    return base64.encode(xorList);
  }

  //解密：“data”：加密字符串；“code”：需求文档标题前的项目编号
  static String decrypt(String data, int code) {
    final decode = base64.decode(data);
    final decode2 = decode.toList();
    List<int> xorList = [];
    for (int i = 0; i < decode2.length; i++) {
      xorList.add(decode2[i] ^ code);
    }
    return utf8.decode(xorList);
  }
}

// 记录cash数值100倍数不重复
class ASThresholdTrigger {
  static const String _key = "as_triggered_levels";
  Set<int> _triggered = {};

  /// 初始化，从本地加载
  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _triggered = (prefs.getStringList(_key)?.map(int.parse).toSet()) ?? {};
  }

  /// 检查是否触发
  Future<void> check(
    int value, {
    int step = 5,
    required Function(int level) onTrigger,
  }) async {
    int level = (value ~/ step) * step;

    if (level < step) return;

    // 已经触发过，则不再触发
    if (_triggered.contains(level)) return;

    // 触发
    onTrigger(level);

    // 标记触发并保存到本地
    _triggered.add(level);
    await _save();
  }

  /// 保存到本地
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _key,
      _triggered.map((e) => e.toString()).toList(),
    );
  }
}

class ParticleButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final double size; // 粒子范围，默认100

  const ParticleButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.size = 100,
  }) : super(key: key);

  @override
  State<ParticleButton> createState() => _ParticleButtonState();
}

class _ParticleButtonState extends State<ParticleButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<_Particle> _particles = [];
  Offset _tapOffset = Offset.zero; // 点击位置相对按钮左上角

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        )..addListener(() {
          setState(() {});
        });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    _tapOffset = details.localPosition;
  }

  void _handleTap() {
    HapticFeedback.mediumImpact(); // 点击震动

    final rnd = Random();
    _particles = List.generate(20, (index) {
      return _Particle(
        x: _tapOffset.dx,
        y: _tapOffset.dy,
        dx: (rnd.nextDouble() - 0.5) * widget.size,
        dy: (rnd.nextDouble() - 0.5) * widget.size,
        color: Colors.cyanAccent,
        radius: rnd.nextDouble() * 4 + 2,
      );
    });

    _controller.forward(from: 0);
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _handleTapDown, // 获取点击位置
      onTap: _handleTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          widget.child, // 按钮保持原位
          if (_controller.isAnimating || _controller.value > 0)
            Positioned.fill(
              child: CustomPaint(
                painter: _ParticlePainter(_particles, _controller.value),
              ),
            ),
        ],
      ),
    );
  }
}

class _Particle {
  double x, y;
  final double dx, dy;
  final Color color;
  final double radius;

  _Particle({
    required this.x,
    required this.y,
    required this.dx,
    required this.dy,
    required this.color,
    required this.radius,
  });
}

class _ParticlePainter extends CustomPainter {
  final List<_Particle> particles;
  final double progress;

  _ParticlePainter(this.particles, this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var p in particles) {
      final x = p.x + p.dx * progress;
      final y = p.y + p.dy * progress;
      final alpha = ((1 - progress) * 255).toInt();
      paint.color = p.color.withAlpha(alpha);
      canvas.drawCircle(Offset(x, y), p.radius * (1 - progress), paint);
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlePainter oldDelegate) => true;
}
