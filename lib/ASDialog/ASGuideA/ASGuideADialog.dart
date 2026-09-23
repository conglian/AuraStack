import 'package:flutter/material.dart';

import '../../ASTool/as_img.dart';
import '../../ASTool/as_stroke_text.dart';

const double _guideDesignWidth = 375;
const double _guideDesignHeight = 812;

/// 170-A / “新用户1”全屏引导页。
///
/// 背景、文字和按钮是三个独立的 UI 层：
/// - `as_guide_a_new_user_1_bg` 只包含童话之门背景；
/// - 标题和副标题由 Flutter 文本绘制；
/// - `as_guide_a_get_started_btn` 是设计稿导出的独立 3 倍按钮切图。
class ASSGuideADialog extends StatelessWidget {
  const ASSGuideADialog({super.key, this.onGetStarted});

  /// 未传入时，点击按钮会关闭当前路由并返回 `true`。
  final VoidCallback? onGetStarted;

  void _handleGetStarted(BuildContext context) {
    if (onGetStarted != null) {
      onGetStarted!();
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _ASSGuideCanvas(
      children: [
        const Positioned.fill(
          child: ASImg(name: 'as_guide_a_new_user_1_bg', fit: BoxFit.fill),
        ),

        // 文字使用代码渲染，不再烘焙在整页图片中。
        const Positioned(
          left: 24,
          right: 24,
          top: 198,
          child: ASStrokeText(
            text: 'Welcome!',
            size: 52,
            color: Colors.white,
            weight: FontWeight.w900,
            skWidth: 6,
            skColor: Color(0xFF7B28B9),
          ),
        ),
        const Positioned(
          left: 18,
          right: 18,
          top: 278,
          child: ASStrokeText(
            text: "Let's Customize Your Lucky Journey.",
            size: 19,
            color: Color(0xFFFFF22D),
            weight: FontWeight.w900,
            skWidth: 4,
            skColor: Color(0xFF33156D),
          ),
        ),

        // Get Started 是单独按钮组件，资源为 786 x 252 WebP（3 倍图）。
        Positioned(
          left: 57,
          top: 579,
          width: 262,
          height: 84,
          child: Semantics(
            button: true,
            label: 'Get Started',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleGetStarted(context),
              child: const ASImg(
                name: 'as_guide_a_get_started_btn',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 170-A / “新用户2”幸运资料页。
///
/// 该页面全部使用 Flutter 组件搭建：背景渐变、黄色装饰板、
/// 白色资料卡和三组选项都是独立组件；只有 Confirm 按钮使用
/// 设计稿导出的独立 3 倍 WebP 切图。
class ASSGuideAUser2Page extends StatefulWidget {
  const ASSGuideAUser2Page({super.key, this.onConfirm});

  /// 确认后的业务回调。未传入时关闭当前路由并返回 `true`。
  final VoidCallback? onConfirm;

  @override
  State<ASSGuideAUser2Page> createState() => _ASSGuideAUser2PageState();
}

class _ASSGuideAUser2PageState extends State<ASSGuideAUser2Page> {
  int _numberIndex = 3;
  int _colorIndex = 3;
  int _styleIndex = 2;

  void _handleConfirm() {
    if (widget.onConfirm != null) {
      widget.onConfirm!();
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _ASSGuideCanvas(
      children: [
        const Positioned.fill(child: _LuckyProfileBackground()),
        const Positioned(
          left: 20,
          right: 20,
          top: 62,
          child: ASStrokeText(
            text: 'Create Your Lucky Profile',
            size: 25,
            color: Colors.white,
            weight: FontWeight.w900,
            skWidth: 2,
            skColor: Color(0xFF551FA8),
          ),
        ),
        const Positioned(
          left: 23,
          top: 106,
          width: 329,
          height: 68,
          child: _LuckyProfileHeader(),
        ),
        Positioned(
          left: 23,
          top: 174,
          width: 329,
          height: 482,
          child: _LuckyProfileCard(
            numberIndex: _numberIndex,
            colorIndex: _colorIndex,
            styleIndex: _styleIndex,
            onNumberChanged: (value) => setState(() => _numberIndex = value),
            onColorChanged: (value) => setState(() => _colorIndex = value),
            onStyleChanged: (value) => setState(() => _styleIndex = value),
          ),
        ),

        // Confirm 使用单独按钮切图，不再使用完整页面截图。
        Positioned(
          left: 57,
          top: 669,
          width: 262,
          height: 84,
          child: Semantics(
            button: true,
            label: 'Confirm lucky profile',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: _handleConfirm,
              child: const ASImg(
                name: 'as_guide_a_confirm_btn',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// 170-A / “新用户3”幸运资料完成页（新版）。
///
/// 背景继续由 Flutter 绘制，避免把设计稿中的整页业务截图当作背景资源；
/// 中间礼盒和完成文案均使用设计稿导出的独立 3 倍 WebP。
class ASSGuideAUser3Page extends StatelessWidget {
  const ASSGuideAUser3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ASSGuideCanvas(
      children: [
        Positioned.fill(child: _LuckyProfileBackground()),

        // 独立礼盒插画：设计尺寸 348 x 296，资源为 1044 x 888 WebP。
        Positioned(
          left: 14,
          top: 172,
          width: 348,
          height: 296,
          child: ASImg(name: 'as_guide_a_user3_gift', fit: BoxFit.contain),
        ),

        // 独立标题切图：设计尺寸 332 x 90，资源为 996 x 270 WebP。
        Positioned(
          left: 22,
          top: 480,
          width: 332,
          height: 90,
          child: ASImg(name: 'as_guide_a_user3_title', fit: BoxFit.contain),
        ),
      ],
    );
  }
}

/// 170-A / “新用户4”首页刮刮卡引导。
///
/// 这里只绘制提示框和点击手势，不绘制首页截图，也不添加黑色遮罩。
/// 页面应覆盖在真实首页上方，坐标与首页 375 x 812 设计坐标保持一致；
/// 外层如需背景色，可在调用 `tipShow` 时通过 `bc` 自定义。
class ASSGuideAUser4Page extends StatelessWidget {
  const ASSGuideAUser4Page({super.key, this.onScratchCardTap});

  /// 点击透明引导层时触发，通常用于进入第一张刮刮卡。
  final VoidCallback? onScratchCardTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onScratchCardTap,
      child: _ASSGuideCanvas(
        children: const [
          // 独立提示框切图：设计尺寸 265 x 89，资源为 3 倍 WebP。
          Positioned(
            left: 32,
            top: 166,
            width: 265,
            height: 89,
            child: IgnorePointer(
              child: ASImg(name: 'as_guide_a_user4_tip', fit: BoxFit.fill),
            ),
          ),

          // 与首页第一张刮刮卡对齐，仅保留独立手势，不重复绘制卡片。
          Positioned(
            left: 83,
            top: 384,
            width: 93,
            height: 98,
            child: IgnorePointer(
              child: ASImg(name: 'as_guide_a_tap_hand', fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

/// 170-A / “新用户5”首页四叶草入口引导。
///
/// 四叶草按钮本体由首页负责绘制，本页只绘制与按钮对齐的点击手势。
/// 页面本身完全透明，不设置任何背景色或黑色遮罩。
class ASSGuideAUser5Page extends StatelessWidget {
  const ASSGuideAUser5Page({super.key, this.onCloverTap});

  /// 点击透明引导层时触发，通常用于打开幸运档案页。
  final VoidCallback? onCloverTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onCloverTap,
      child: _ASSGuideCanvas(
        children: const [
          // 与首页 left: 263、top: 55 的四叶草按钮对齐。
          Positioned(
            left: 273,
            top: 69,
            width: 93,
            height: 98,
            child: IgnorePointer(
              child: ASImg(name: 'as_guide_a_tap_hand', fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }
}

/// 所有新用户引导页共用 375 x 812 的设计坐标系。
class _ASSGuideCanvas extends StatelessWidget {
  const _ASSGuideCanvas({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: SizedBox.expand(
        child: FittedBox(
          // 与首页的 ScreenUtil 坐标一致，宽高分别映射到当前屏幕，
          // 避免 cover 裁切后让透明引导与首页按钮发生偏移。
          fit: BoxFit.fill,
          alignment: Alignment.center,
          child: SizedBox(
            width: _guideDesignWidth,
            height: _guideDesignHeight,
            child: Stack(children: children),
          ),
        ),
      ),
    );
  }
}

class _LuckyProfileBackground extends StatelessWidget {
  const _LuckyProfileBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF0B064B),
                  Color(0xFF260078),
                  Color(0xFF7416EC),
                ],
                stops: [0, 0.56, 1],
              ),
            ),
          ),
        ),
        // 底部紫色云层使用简单形状绘制，避免引入整页截图。
        const Positioned(left: -74, bottom: -55, child: _Cloud(size: 190)),
        const Positioned(left: 70, bottom: -72, child: _Cloud(size: 215)),
        const Positioned(right: -82, bottom: -62, child: _Cloud(size: 205)),
      ],
    );
  }
}

class _Cloud extends StatelessWidget {
  const _Cloud({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size * 0.55,
      decoration: const BoxDecoration(
        color: Color(0xFF6819D1),
        borderRadius: BorderRadius.all(Radius.elliptical(120, 70)),
      ),
    );
  }
}

class _LuckyProfileHeader extends StatelessWidget {
  const _LuckyProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      alignment: Alignment.topCenter,
      children: [
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              colors: [Color(0xFFFFE83D), Color(0xFFFFD725)],
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000000),
                blurRadius: 4,
                offset: Offset(0, 3),
              ),
            ],
          ),
        ),
        Positioned(
          top: 18,
          child: Container(
            width: 84,
            height: 18,
            decoration: BoxDecoration(
              color: const Color(0xFF1C0965),
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        ),
        Positioned(
          top: -14,
          child: Container(
            width: 18,
            height: 39,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              boxShadow: const [
                BoxShadow(color: Color(0x33000000), blurRadius: 3),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LuckyProfileCard extends StatelessWidget {
  const _LuckyProfileCard({
    required this.numberIndex,
    required this.colorIndex,
    required this.styleIndex,
    required this.onNumberChanged,
    required this.onColorChanged,
    required this.onStyleChanged,
  });

  final int numberIndex;
  final int colorIndex;
  final int styleIndex;
  final ValueChanged<int> onNumberChanged;
  final ValueChanged<int> onColorChanged;
  final ValueChanged<int> onStyleChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(23, 24, 23, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEF5),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x44000000),
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 4,
            child: _GuideOptionRow(
              title: "What's Your Lucky Number?",
              options: const [
                _GuideOption(label: '3'),
                _GuideOption(label: '7'),
                _GuideOption(label: '9'),
                _GuideOption(label: 'Other'),
              ],
              selectedIndex: numberIndex,
              onChanged: onNumberChanged,
            ),
          ),
          const _GuideDivider(),
          Expanded(
            flex: 4,
            child: _GuideOptionRow(
              title: "What's Your Lucky Color?",
              options: const [
                _GuideOption(label: 'Blue'),
                _GuideOption(label: 'Gold'),
                _GuideOption(label: 'Green'),
                _GuideOption(label: 'Other'),
              ],
              selectedIndex: colorIndex,
              onChanged: onColorChanged,
            ),
          ),
          const _GuideDivider(),
          Expanded(
            flex: 6,
            child: _GuideOptionRow(
              title: "What's Your Lucky Style?",
              options: const [
                _GuideOption(label: 'Lucky Clover', icon: '☘'),
                _GuideOption(label: 'Lucky Star', icon: '⭐'),
                _GuideOption(label: 'Dice Master', icon: '🎲'),
              ],
              selectedIndex: styleIndex,
              onChanged: onStyleChanged,
              showIcons: true,
            ),
          ),
        ],
      ),
    );
  }
}

class _GuideDivider extends StatelessWidget {
  const _GuideDivider();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Divider(height: 1, thickness: 1, color: Color(0xFFC9BDE0)),
    );
  }
}

class _GuideOptionRow extends StatelessWidget {
  const _GuideOptionRow({
    required this.title,
    required this.options,
    required this.selectedIndex,
    required this.onChanged,
    this.showIcons = false,
  });

  final String title;
  final List<_GuideOption> options;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final bool showIcons;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: Color(0xFF16045C),
            fontFamily: text_fontName,
            fontSize: 16,
            fontWeight: FontWeight.w900,
            decoration: TextDecoration.none,
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(options.length, (index) {
            final option = options[index];
            final selected = index == selectedIndex;
            return Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => onChanged(index),
                child: Column(
                  children: [
                    if (showIcons)
                      Text(
                        option.icon ?? '',
                        style: const TextStyle(
                          fontSize: 31,
                          decoration: TextDecoration.none,
                        ),
                      ),
                    Text(
                      option.label,
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: selected
                            ? const Color(0xFF119B27)
                            : const Color(0xFF1F1740),
                        fontFamily: text_fontName,
                        fontSize: showIcons ? 11 : 13,
                        fontWeight: FontWeight.w900,
                        decoration: TextDecoration.none,
                      ),
                    ),
                    const SizedBox(height: 7),
                    _GuideSelectionDot(selected: selected),
                  ],
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _GuideSelectionDot extends StatelessWidget {
  const _GuideSelectionDot({required this.selected});

  final bool selected;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 160),
      width: 28,
      height: 28,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: selected ? const Color(0xFF39C92C) : const Color(0xFF777782),
        border: selected
            ? Border.all(color: const Color(0xFF178B19), width: 1.5)
            : null,
      ),
      child: selected
          ? const Icon(Icons.check_rounded, size: 21, color: Colors.white)
          : null,
    );
  }
}

class _GuideOption {
  const _GuideOption({required this.label, this.icon});

  final String label;
  final String? icon;
}

/// 第二个“新用户5”页面使用的玩家等级。
///
/// 三个等级共用档案卡中的同一个标签位置，不会把三个按钮同时显示出来。
enum ASSGuideAPlayerLevel { newPlayer, intermediate, advanced }

/// 170-A / 第二个“新用户5”幸运档案弹层。
///
/// 这是覆盖在首页上的独立 UI 组件：页面外围保持透明，只搭建紫色档案卡、
/// 任务进度和关闭按钮。调用 `tipShow` 时可由外部自行设置遮罩颜色。
class ASSGuideAUser5ProfilePage extends StatelessWidget {
  const ASSGuideAUser5ProfilePage({
    super.key,
    this.playerId = 'Xxxxxxx',
    this.level = ASSGuideAPlayerLevel.newPlayer,
    this.completedTaskCount = 1,
    this.progressStep = 1,
    this.totalProgressSteps = 3,
    this.onClose,
  });

  final String playerId;

  /// 修改该状态即可在绿色位置切换 New、蓝色 Intermediate、红色 Advanced。
  final ASSGuideAPlayerLevel level;
  final int completedTaskCount;
  final int progressStep;
  final int totalProgressSteps;
  final VoidCallback? onClose;

  void _handleClose(BuildContext context) {
    if (onClose != null) {
      onClose!();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return _ASSGuideCanvas(
      children: [
        // 页面外围不绘制背景，只保留设计稿中的紫色档案卡主体。
        const Positioned(
          left: 27,
          top: 164,
          width: 321,
          height: 458,
          child: _LuckyProfilePanel(),
        ),

        // 关闭按钮与首页右上区域错开，位置对应第二个新用户5设计稿。
        Positioned(
          left: 322,
          top: 126,
          width: 30,
          height: 30,
          child: Semantics(
            button: true,
            label: 'Close lucky profile',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleClose(context),
              child: const ASImg(name: 'as_close_x', fit: BoxFit.contain),
            ),
          ),
        ),

        // 四叶草头像、玩家 ID 和等级标签都位于上方米白色资料区域。
        const Positioned(
          left: 67,
          top: 207,
          width: 79,
          height: 79,
          child: _LuckyCloverAvatar(),
        ),
        Positioned(
          left: 158,
          top: 207,
          width: 153,
          height: 31,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'ID: $playerId',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: _profileTextStyle(fontSize: 20),
            ),
          ),
        ),
        Positioned(
          left: 157,
          top: 242,
          width: 136,
          height: 31,
          child: _PlayerLevelPill(level: level),
        ),

        // 四项任务使用代码布局，完成状态和未完成状态可独立切换。
        Positioned(
          left: 59,
          top: 340,
          width: 251,
          height: 171,
          child: _LuckyTaskList(completedTaskCount: completedTaskCount),
        ),

        // 底部进度条与宝箱是独立组件，不使用整张页面截图。
        Positioned(
          left: 59,
          top: 521,
          width: 256,
          height: 68,
          child: _LuckyProfileProgress(
            step: progressStep,
            totalSteps: totalProgressSteps,
          ),
        ),
      ],
    );
  }
}

class _LuckyProfilePanel extends StatelessWidget {
  const _LuckyProfilePanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF6535B9),
        borderRadius: BorderRadius.circular(23),
        border: Border.all(color: const Color(0xFF8B5BE4), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 20,
            width: 281,
            height: 116,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBE0),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFE5DDAF), width: 2),
              ),
            ),
          ),
          Positioned(
            left: 20,
            top: 154,
            width: 281,
            height: 287,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF27135C),
                borderRadius: BorderRadius.circular(27),
                border: Border.all(color: const Color(0xFF3E1E81), width: 2),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x55000000),
                    blurRadius: 4,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LuckyCloverAvatar extends StatelessWidget {
  const _LuckyCloverAvatar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Color(0xFF0A57C6),
        boxShadow: [
          BoxShadow(
            color: Color(0x55000000),
            blurRadius: 3,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Color(0xFFFFD91A),
        ),
        child: Container(
          padding: const EdgeInsets.all(3),
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFFF5FFF2),
          ),
          child: const ASImg(name: 'as_guide_a_clover', fit: BoxFit.contain),
        ),
      ),
    );
  }
}

class _PlayerLevelPill extends StatelessWidget {
  const _PlayerLevelPill({required this.level});

  final ASSGuideAPlayerLevel level;

  String get _label => switch (level) {
    ASSGuideAPlayerLevel.newPlayer => 'New Player',
    ASSGuideAPlayerLevel.intermediate => 'Intermediate Player',
    ASSGuideAPlayerLevel.advanced => 'Advanced Player',
  };

  Color get _color => switch (level) {
    ASSGuideAPlayerLevel.newPlayer => const Color(0xFF2D8B46),
    ASSGuideAPlayerLevel.intermediate => const Color(0xFF3479D9),
    ASSGuideAPlayerLevel.advanced => const Color(0xFFE60072),
  };

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: _color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        child: Text(
          _label,
          key: ValueKey(level),
          maxLines: 1,
          style: _profileTextStyle(fontSize: 14, color: Colors.white),
        ),
      ),
    );
  }
}

class _LuckyTaskList extends StatelessWidget {
  const _LuckyTaskList({required this.completedTaskCount});

  final int completedTaskCount;

  static const _tasks = [
    'Complete 1 Scratch Card',
    'Complete 1 Die Roll',
    'Complete 1 Spin',
    'Unlock All Types',
  ];

  @override
  Widget build(BuildContext context) {
    final completed = completedTaskCount.clamp(0, _tasks.length);
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(_tasks.length, (index) {
        final isCompleted = index < completed;
        return SizedBox(
          height: 32,
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _tasks[index],
                  maxLines: 1,
                  style: _profileTextStyle(
                    fontSize: 14,
                    color: isCompleted ? const Color(0xFF69F326) : Colors.white,
                  ),
                ),
              ),
              _TaskStateDot(completed: isCompleted),
            ],
          ),
        );
      }),
    );
  }
}

class _TaskStateDot extends StatelessWidget {
  const _TaskStateDot({required this.completed});

  final bool completed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: completed ? const Color(0xFF55D21F) : const Color(0xFF7D83A3),
        border: Border.all(
          color: completed ? const Color(0xFFB8FF50) : const Color(0xFFA9AFCC),
          width: 1.5,
        ),
        boxShadow: const [BoxShadow(color: Color(0x44000000), blurRadius: 2)],
      ),
      child: completed
          ? const Icon(Icons.check_rounded, size: 24, color: Colors.white)
          : null,
    );
  }
}

class _LuckyProfileProgress extends StatelessWidget {
  const _LuckyProfileProgress({required this.step, required this.totalSteps});

  final int step;
  final int totalSteps;

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalSteps <= 0 ? 1 : totalSteps;
    final safeStep = step.clamp(0, safeTotal);
    final progress = safeStep / safeTotal;

    return Container(
      padding: const EdgeInsets.fromLTRB(11, 15, 9, 12),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF7E45E3), Color(0xFF5C2ABB)],
        ),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF8149DC), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 4,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Stack(
              alignment: Alignment.centerLeft,
              children: [
                Container(
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF301A6C),
                    borderRadius: BorderRadius.circular(9),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: progress,
                  child: Container(
                    height: 15,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE500),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFF824000)),
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    '$safeStep/$safeTotal',
                    style: _profileTextStyle(fontSize: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          const ASImg(name: 'as_task_box', width: 48, height: 50),
        ],
      ),
    );
  }
}

TextStyle _profileTextStyle({
  required double fontSize,
  Color color = const Color(0xFF2B155D),
}) {
  return TextStyle(
    color: color,
    fontFamily: text_fontName,
    fontSize: fontSize,
    fontWeight: FontWeight.w900,
    decoration: TextDecoration.none,
  );
}

/// 170-A / “新用户6”成就解锁页。
///
/// 页面背景使用 Flutter 渐变与云层搭建；成就标题、徽章和 Continue 按钮
/// 分别使用设计稿导出的独立 3 倍 WebP，不使用完整页面截图。
class ASSGuideAUser6AchievementPage extends StatelessWidget {
  const ASSGuideAUser6AchievementPage({super.key, this.onContinue});

  final VoidCallback? onContinue;

  void _handleContinue(BuildContext context) {
    if (onContinue != null) {
      onContinue!();
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return _ASSGuideCanvas(
      children: [
        const Positioned.fill(child: _AchievementBackground()),
        const Positioned(
          left: 13,
          top: 169,
          width: 350,
          height: 58,
          child: ASImg(
            name: 'as_guide_a_achievement_title',
            fit: BoxFit.contain,
          ),
        ),
        const Positioned(
          left: 76,
          top: 246,
          width: 223,
          height: 223,
          child: ASImg(
            name: 'as_guide_a_achievement_badge',
            fit: BoxFit.contain,
          ),
        ),
        const Positioned(
          left: 42,
          top: 487,
          width: 291,
          height: 34,
          child: ASStrokeText(
            text: 'Advanced Player Certification',
            size: 20,
            color: Color(0xFFFFF700),
            weight: FontWeight.w900,
            skWidth: 2,
            skColor: Color(0xFF3F108B),
          ),
        ),
        Positioned(
          left: 57,
          top: 579,
          width: 262,
          height: 84,
          child: Semantics(
            button: true,
            label: 'Continue',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleContinue(context),
              child: const ASImg(
                name: 'as_guide_a_continue_btn',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _AchievementBackground extends StatelessWidget {
  const _AchievementBackground();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF030542),
                  Color(0xFF1713A3),
                  Color(0xFF642BE5),
                ],
                stops: [0, 0.58, 1],
              ),
            ),
          ),
        ),
        const Positioned(left: 23, top: 270, child: _GuideStar(size: 11)),
        const Positioned(right: 30, top: 314, child: _GuideStar(size: 7)),
        const Positioned(left: 118, top: 221, child: _GuideStar(size: 5)),
        const Positioned(left: -72, bottom: -51, child: _Cloud(size: 196)),
        const Positioned(left: 79, bottom: -72, child: _Cloud(size: 216)),
        const Positioned(right: -79, bottom: -58, child: _Cloud(size: 202)),
      ],
    );
  }
}

class _GuideStar extends StatelessWidget {
  const _GuideStar({required this.size});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Icon(Icons.star_rounded, size: size, color: Colors.white);
  }
}

/// 170-A / 第一个“新用户7”签到引导页。
///
/// 页面本身完全透明，只叠加签到日历、点击手势和引导文字；首页由下层真实
/// `ASHome` 提供。日历和手势均为独立 3 倍 WebP。
class ASSGuideAUser7CheckInGuidePage extends StatelessWidget {
  const ASSGuideAUser7CheckInGuidePage({super.key, this.onCheckInTap});

  final VoidCallback? onCheckInTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onCheckInTap,
      child: _ASSGuideCanvas(
        children: const [
          Positioned(
            left: 100,
            top: 231,
            width: 191,
            height: 215,
            child: IgnorePointer(
              child: ASImg(
                name: 'as_guide_a_checkin_calendar',
                fit: BoxFit.contain,
              ),
            ),
          ),
          Positioned(
            left: 214,
            top: 388,
            width: 93,
            height: 98,
            child: IgnorePointer(
              child: ASImg(name: 'as_guide_a_tap_hand', fit: BoxFit.contain),
            ),
          ),
          Positioned(
            left: 56,
            top: 496,
            width: 263,
            height: 78,
            child: IgnorePointer(
              child: ASStrokeText(
                text: "Tap to Complete\nToday's Check-In",
                size: 28,
                color: Color(0xFFFFF700),
                weight: FontWeight.w900,
                skWidth: 3,
                skColor: Color(0xFF3F108B),
                maxLines: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 170-A / 第二个“新用户7”每日签到面板页。
///
/// 页面外围透明；标题、签到天数、六天状态和黄色奖励区域均由 Flutter 搭建，
/// 日历与 Continue 按钮继续使用独立 3 倍 WebP。
class ASSGuideAUser7CheckInPage extends StatelessWidget {
  const ASSGuideAUser7CheckInPage({
    super.key,
    this.checkedDay = 1,
    this.onRewardTap,
    this.onContinue,
  });

  final int checkedDay;
  final VoidCallback? onRewardTap;
  final VoidCallback? onContinue;

  void _handleContinue(BuildContext context) {
    if (onContinue != null) {
      onContinue!();
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final safeCheckedDay = checkedDay.clamp(0, 6);
    return _ASSGuideCanvas(
      children: [
        const Positioned(
          left: 48,
          top: 133,
          width: 280,
          height: 59,
          child: ASStrokeText(
            text: 'Daily check-in',
            size: 34,
            color: Colors.white,
            weight: FontWeight.w900,
            skWidth: 4,
            skColor: Color(0xFF7A27CE),
          ),
        ),
        const Positioned(
          left: 100,
          top: 195,
          width: 191,
          height: 215,
          child: ASImg(
            name: 'as_guide_a_checkin_calendar',
            fit: BoxFit.contain,
          ),
        ),
        Positioned(
          left: 127,
          top: 397,
          width: 121,
          height: 38,
          child: ASStrokeText(
            text: '$safeCheckedDay Day',
            size: 28,
            color: const Color(0xFFFFF700),
            weight: FontWeight.w900,
            skWidth: 3,
            skColor: const Color(0xFF3F108B),
          ),
        ),
        Positioned(
          left: 10,
          top: 457,
          width: 355,
          height: 192,
          child: _DailyCheckInPanel(
            checkedDay: safeCheckedDay,
            onRewardTap: onRewardTap,
          ),
        ),
        Positioned(
          left: 57,
          top: 671,
          width: 262,
          height: 84,
          child: Semantics(
            button: true,
            label: 'Continue',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleContinue(context),
              child: const ASImg(
                name: 'as_guide_a_continue_btn',
                fit: BoxFit.fill,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyCheckInPanel extends StatelessWidget {
  const _DailyCheckInPanel({required this.checkedDay, this.onRewardTap});

  final int checkedDay;
  final VoidCallback? onRewardTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(13, 14, 13, 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFCEB),
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: const Color(0xFFE3DDB9), width: 2),
        boxShadow: const [
          BoxShadow(
            color: Color(0x66000000),
            blurRadius: 5,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return SizedBox(
                width: 44,
                child: Text(
                  'Day${index + 1}',
                  textAlign: TextAlign.center,
                  style: _profileTextStyle(
                    fontSize: 9,
                    color: index < checkedDay
                        ? const Color(0xFF18992E)
                        : const Color(0xFF777777),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 5),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              final completed = index < checkedDay;
              return SizedBox(
                width: 44,
                child: Align(
                  child: Container(
                    width: 31,
                    height: 31,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: completed
                          ? const Color(0xFF43C82C)
                          : const Color(0xFFD2D2D2),
                    ),
                    child: completed
                        ? const Icon(
                            Icons.check_rounded,
                            size: 23,
                            color: Colors.white,
                          )
                        : null,
                  ),
                ),
              );
            }),
          ),
          const Spacer(),
          Semantics(
            button: true,
            label: 'Claim day $checkedDay reward',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onRewardTap,
              child: Container(
                width: 265,
                height: 74,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC400),
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: const Color(0xFFFFE13B), width: 2),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Day $checkedDay',
                      style: _profileTextStyle(
                        fontSize: 20,
                        color: const Color(0xFF3B176A),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const ASImg(name: 'as_task_box', width: 54, height: 56),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 170-A / “新增次数”浮层。
///
/// 该组件只负责新增次数的提示内容，不绘制首页截图，也不添加黑色背景；
/// 请将它叠加在真实首页上方。刮刮卡、Get 按钮和广告角标均为独立
/// 3 倍 WebP 资源，价格按钮与标题由 Flutter 组件绘制。
class ASSGuideAAddChancesPage extends StatelessWidget {
  const ASSGuideAAddChancesPage({
    super.key,
    this.chanceCount = 5,
    this.price = 500,
    this.onBuyWithCoins,
    this.onWatchAd,
  });

  /// 两种领取方式增加的次数。
  final int chanceCount;

  /// 左侧金币购买所需数量。
  final int price;

  /// 点击左侧金币购买按钮。
  final VoidCallback? onBuyWithCoins;

  /// 点击右侧 Get / 广告领取按钮。
  final VoidCallback? onWatchAd;

  @override
  Widget build(BuildContext context) {
    final safeChanceCount = chanceCount < 0 ? 0 : chanceCount;
    final safePrice = price < 0 ? 0 : price;

    return _ASSGuideCanvas(
      children: [
        // 仅绘制标题后的紫色光晕，整个引导层仍保持透明。
        Positioned(
          left: 25,
          top: 181,
          width: 325,
          height: 46,
          child: IgnorePointer(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: const Color(0xCC731BCB),
                borderRadius: BorderRadius.circular(23),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0xE67513CF),
                    blurRadius: 22,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
        ),

        Positioned(
          left: 32,
          top: 181,
          width: 311,
          height: 46,
          child: _AddChancesTitle(chanceCount: safeChanceCount),
        ),

        // 两张 Extra Bonus 刮刮卡为独立 507 x 534 WebP（3 倍图）。
        const Positioned(
          left: 103,
          top: 271,
          width: 169,
          height: 178,
          child: IgnorePointer(
            child: ASImg(
              name: 'as_guide_a_extra_bonus_cards',
              fit: BoxFit.contain,
            ),
          ),
        ),

        Positioned(
          left: 46,
          top: 463,
          width: 92,
          height: 48,
          child: ASStrokeText(
            text: '+$safeChanceCount',
            size: 34,
            color: const Color(0xFFFFFF00),
            weight: FontWeight.w900,
            skWidth: 4,
            skColor: const Color(0xFF34126F),
          ),
        ),
        Positioned(
          left: 220,
          top: 463,
          width: 92,
          height: 48,
          child: ASStrokeText(
            text: '+$safeChanceCount',
            size: 34,
            color: const Color(0xFFFFFF00),
            weight: FontWeight.w900,
            skWidth: 4,
            skColor: const Color(0xFF34126F),
          ),
        ),

        // 左侧为代码搭建的金币购买按钮，业务逻辑通过回调接入。
        Positioned(
          left: 37,
          top: 522,
          width: 119,
          height: 55,
          child: Semantics(
            button: true,
            label: 'Buy $safeChanceCount chances for $safePrice coins',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onBuyWithCoins,
              child: _AddChancesPriceButton(price: safePrice),
            ),
          ),
        ),

        // Get 是独立按钮切图；广告角标与按钮分层，便于分别替换或隐藏。
        Positioned(
          left: 184,
          top: 522,
          width: 154,
          height: 55,
          child: Semantics(
            button: true,
            label: 'Watch an ad to get $safeChanceCount chances',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onWatchAd,
              child: const ASImg(name: 'as_guide_a_get_btn', fit: BoxFit.fill),
            ),
          ),
        ),
        const Positioned(
          left: 310,
          top: 510,
          width: 34,
          height: 34,
          child: IgnorePointer(
            child: ASImg(name: 'as_guide_a_ad_badge', fit: BoxFit.contain),
          ),
        ),
      ],
    );
  }
}

/// “Wealth +N Chances” 分段着色标题。
class _AddChancesTitle extends StatelessWidget {
  const _AddChancesTitle({required this.chanceCount});

  final int chanceCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const SizedBox(
          width: 91,
          child: ASStrokeText(
            text: 'Wealth',
            size: 23,
            color: Colors.white,
            weight: FontWeight.w900,
            skWidth: 3,
            skColor: Color(0xFF4C087F),
          ),
        ),
        SizedBox(
          width: 61,
          child: ASStrokeText(
            text: '+$chanceCount',
            size: 31,
            color: const Color(0xFFFFFF00),
            weight: FontWeight.w900,
            skWidth: 3,
            skColor: const Color(0xFF4C087F),
          ),
        ),
        const SizedBox(
          width: 105,
          child: ASStrokeText(
            text: 'Chances',
            size: 23,
            color: Colors.white,
            weight: FontWeight.w900,
            skWidth: 3,
            skColor: Color(0xFF4C087F),
          ),
        ),
      ],
    );
  }
}

/// 金币购买按钮使用代码绘制，避免把整块界面烘焙成图片。
class _AddChancesPriceButton extends StatelessWidget {
  const _AddChancesPriceButton({required this.price});

  final int price;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF38C7FF), Color(0xFF127DC7)],
        ),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: const Color(0xFFFFFFD7), width: 3),
        boxShadow: const [
          BoxShadow(
            color: Color(0x800B315B),
            blurRadius: 2,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 25,
            height: 25,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFFF79), Color(0xFFFFB500)],
              ),
              border: Border.all(color: const Color(0xFFFFF0A6), width: 2),
              boxShadow: const [
                BoxShadow(color: Color(0x663A1F00), blurRadius: 2),
              ],
            ),
            child: const Text(
              r'$',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'CarlsbergSansBlack',
                fontSize: 16,
                fontWeight: FontWeight.w900,
                height: 1,
                decoration: TextDecoration.none,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            '$price',
            style: _profileTextStyle(fontSize: 22, color: Colors.white),
          ),
        ],
      ),
    );
  }
}

/// 170-A / “Magic Shop” 魔法收藏册。
///
/// 页面主体、相册卡、关闭按钮与十二个收藏品均为设计稿独立导出的
/// 3 倍 WebP；奖励数量、完成进度和点击逻辑由 Flutter 代码控制。
/// 这里只绘制弹层本身，不包含首页截图，建议使用 `tipShowFromLeft` 展示。
enum ASSGuideAMagicCollectible {
  ticket,
  lollipop,
  diamond,
  gift,
  crown,
  moon,
  purse,
  bow,
  pig,
  clover,
  wand,
  key,
}

/// Magic Shop 图片资源统一入口，其他页面可直接复用，避免再次下载。
extension ASSGuideAMagicCollectibleAsset on ASSGuideAMagicCollectible {
  String assetName({required bool unlocked}) {
    // 设计资源中的钥匙是固定奖励，只提供一个原始资源；锁定外观由代码着色，
    // 其余十一件收藏品均使用设计稿导出的 locked / unlocked 两张 3 倍图。
    if (this == ASSGuideAMagicCollectible.key) {
      return 'as_guide_a_magic_key_unlocked';
    }
    return 'as_guide_a_magic_${name}_${unlocked ? 'unlocked' : 'locked'}';
  }

  String get semanticLabel => switch (this) {
    ASSGuideAMagicCollectible.ticket => 'Star ticket',
    ASSGuideAMagicCollectible.lollipop => 'Lollipop',
    ASSGuideAMagicCollectible.diamond => 'Magic diamond',
    ASSGuideAMagicCollectible.gift => 'Gift',
    ASSGuideAMagicCollectible.crown => 'Crown',
    ASSGuideAMagicCollectible.moon => 'Moon',
    ASSGuideAMagicCollectible.purse => 'Heart purse',
    ASSGuideAMagicCollectible.bow => 'Heart bow',
    ASSGuideAMagicCollectible.pig => 'Lucky pig',
    ASSGuideAMagicCollectible.clover => 'Clover',
    ASSGuideAMagicCollectible.wand => 'Star wand',
    ASSGuideAMagicCollectible.key => 'Magic key',
  };
}

class ASSGuideAMagicShopPage extends StatelessWidget {
  const ASSGuideAMagicShopPage({
    super.key,
    this.reward = 1000,
    this.completedItemCount = 1,
    this.totalItemCount = 12,
    this.unlockedItems = _defaultUnlockedMagicItems,
    this.onItemTap,
    this.onClose,
  });

  /// 完成整本收藏册后的奖励。
  final int reward;

  /// 当前收集数量，用于头部进度条。
  final int completedItemCount;

  /// 收藏品总数。
  final int totalItemCount;

  /// 已解锁收藏品。切换集合内容即可替换对应的两种本地图片状态。
  final Set<ASSGuideAMagicCollectible> unlockedItems;

  /// 点击收藏品时返回 0 到 11 的下标。
  final ValueChanged<int>? onItemTap;

  final VoidCallback? onClose;

  void _handleClose(BuildContext context) {
    if (onClose != null) {
      onClose!();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final safeTotal = totalItemCount < 1 ? 1 : totalItemCount;
    final safeCompleted = completedItemCount.clamp(0, safeTotal);
    final safeReward = reward < 0 ? 0 : reward;

    return _ASSGuideCanvas(
      children: [
        // 空白书本面板切图不包含收藏品、奖励文字或首页背景。
        const Positioned(
          left: 0,
          top: 119,
          width: 375,
          height: 693,
          child: IgnorePointer(
            child: ASImg(name: 'as_guide_a_magic_shop_panel', fit: BoxFit.fill),
          ),
        ),

        // 相册卡与进度信息分层摆放，后续可直接替换奖励和进度。
        const Positioned(
          left: 67,
          top: 240,
          width: 70,
          height: 84,
          child: IgnorePointer(
            child: ASImg(
              name: 'as_guide_a_magic_album_card',
              fit: BoxFit.contain,
            ),
          ),
        ),
        Positioned(
          left: 140,
          top: 244,
          width: 174,
          height: 18,
          child: Text(
            'Complete The Album To Win',
            maxLines: 1,
            style: _profileTextStyle(
              fontSize: 12,
              color: const Color(0xFF77719A),
            ),
          ),
        ),
        Positioned(
          left: 140,
          top: 265,
          child: Row(
            children: [
              const _MagicShopCoin(),
              const SizedBox(width: 5),
              Text(
                '$safeReward',
                style: _profileTextStyle(
                  fontSize: 24,
                  color: const Color(0xFF3B176B),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          left: 140,
          top: 294,
          width: 158,
          height: 15,
          child: _MagicShopProgress(completed: safeCompleted, total: safeTotal),
        ),

        // 每件收藏品均为独立资源和点击区域，没有使用整页截图。
        for (var index = 0; index < _magicShopItems.length; index++)
          Positioned(
            left: _magicShopItems[index].left,
            top: _magicShopItems[index].top,
            width: _magicShopItems[index].width,
            height: _magicShopItems[index].height,
            child: Semantics(
              button: onItemTap != null,
              label: _magicShopItems[index].item.semanticLabel,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: onItemTap == null ? null : () => onItemTap!(index),
                child: _MagicShopCollectibleImage(
                  item: _magicShopItems[index].item,
                  unlocked: unlockedItems.contains(_magicShopItems[index].item),
                ),
              ),
            ),
          ),

        // 关闭按钮独立于书本主体，Navigator.pop 会触发反向滑出动画。
        Positioned(
          left: 327,
          top: 73,
          width: 28,
          height: 28,
          child: Semantics(
            button: true,
            label: 'Close magic shop',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _handleClose(context),
              child: const ASImg(
                name: 'as_guide_a_magic_close',
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _MagicShopCollectibleImage extends StatelessWidget {
  const _MagicShopCollectibleImage({
    required this.item,
    required this.unlocked,
  });

  final ASSGuideAMagicCollectible item;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final image = ASImg(
      name: item.assetName(unlocked: unlocked),
      fit: BoxFit.contain,
    );

    // 钥匙在设计稿中是固定奖励，没有重复保存第二张相同资源；
    // 未解锁时通过颜色过滤得到状态，仍复用同一张本地 WebP。
    if (item == ASSGuideAMagicCollectible.key && !unlocked) {
      return ColorFiltered(
        colorFilter: const ColorFilter.mode(Color(0xFF5E506B), BlendMode.srcIn),
        child: image,
      );
    }
    return image;
  }
}

class _MagicShopProgress extends StatelessWidget {
  const _MagicShopProgress({required this.completed, required this.total});

  final int completed;
  final int total;

  @override
  Widget build(BuildContext context) {
    final progress = completed / total;

    return Row(
      children: [
        Expanded(
          child: Container(
            height: 13,
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: const Color(0xFF421274),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFFFF20), Color(0xFFFFDB00)],
                    ),
                    borderRadius: BorderRadius.circular(6),
                  ),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 5),
        SizedBox(
          width: 32,
          child: Text(
            '$completed/$total',
            style: _profileTextStyle(
              fontSize: 11,
              color: const Color(0xFF3B176B),
            ),
          ),
        ),
      ],
    );
  }
}

class _MagicShopCoin extends StatelessWidget {
  const _MagicShopCoin();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const RadialGradient(
          colors: [Color(0xFFFFFF79), Color(0xFFFFB400)],
        ),
        border: Border.all(color: const Color(0xFFFFF2A0), width: 2),
        boxShadow: const [BoxShadow(color: Color(0x55371600), blurRadius: 2)],
      ),
      child: const Icon(Icons.star_rounded, size: 16, color: Colors.white),
    );
  }
}

class _MagicShopItemPlacement {
  const _MagicShopItemPlacement(
    this.item,
    this.left,
    this.top,
    this.width,
    this.height,
  );

  final ASSGuideAMagicCollectible item;
  final double left;
  final double top;
  final double width;
  final double height;
}

/// 收藏品坐标与 375 x 812 首页坐标系对齐。
const List<_MagicShopItemPlacement> _magicShopItems = [
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.ticket, 147, 340, 56, 48),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.lollipop, 91, 340, 47, 61),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.diamond, 157, 402, 58, 58),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.gift, 232, 341, 56, 57),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.crown, 87, 470, 55, 54),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.moon, 88, 400, 61, 70),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.purse, 231, 469, 56, 57),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.bow, 229, 405, 56, 49),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.pig, 84, 540, 62, 59),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.clover, 158, 540, 55, 55),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.wand, 158, 470, 48, 61),
  _MagicShopItemPlacement(ASSGuideAMagicCollectible.key, 238, 537, 48, 62),
];

/// 对应当前设计稿的默认展示状态；业务可传入自己的集合覆盖。
const Set<ASSGuideAMagicCollectible> _defaultUnlockedMagicItems = {
  ASSGuideAMagicCollectible.ticket,
  ASSGuideAMagicCollectible.diamond,
  ASSGuideAMagicCollectible.crown,
  ASSGuideAMagicCollectible.purse,
  ASSGuideAMagicCollectible.bow,
  ASSGuideAMagicCollectible.pig,
  ASSGuideAMagicCollectible.wand,
  ASSGuideAMagicCollectible.key,
};

/// Decor Shop 商品数据。
class ASSGuideADecorShopItem {
  const ASSGuideADecorShopItem({
    required this.name,
    required this.price,
    required this.assetName,
  });

  final String name;
  final int price;
  final String assetName;
}

typedef ASSGuideADecorBuyCallback =
    void Function(int index, ASSGuideADecorShopItem item);

/// 170-A / “Decor Shop” 装饰商店页面。
///
/// 顶部招牌、商品图、Buy 按钮与关闭按钮均为独立的 3 倍 WebP，
/// 卡片、价格和滚动逻辑由 Flutter 搭建。默认暂放 6 个商品；网格在
/// 手机上保持两列，宽屏会自动增加列数，并支持纵向滚动。
class ASSGuideADecorShopPage extends StatelessWidget {
  const ASSGuideADecorShopPage({
    super.key,
    this.balance = 1000,
    this.items = _defaultDecorShopItems,
    this.onBuy,
    this.onClose,
  });

  final int balance;
  final List<ASSGuideADecorShopItem> items;
  final ASSGuideADecorBuyCallback? onBuy;
  final VoidCallback? onClose;

  void _handleClose(BuildContext context) {
    if (onClose != null) {
      onClose!();
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final safeBalance = balance < 0 ? 0 : balance;
    final safeTop = MediaQuery.paddingOf(context).top;

    return Material(
      color: const Color(0xFF070A59),
      child: LayoutBuilder(
        builder: (context, constraints) {
          // 以 375 宽设计稿为基准，小屏缩小、大屏限制最大缩放，
          // 避免顶部控件在平板上被无上限放大。
          final scale = (constraints.maxWidth / _guideDesignWidth)
              .clamp(0.78, 1.25)
              .toDouble();
          final horizontalPadding = 21 * scale;
          final gridTop = safeTop + 178 * scale;

          return Stack(
            children: [
              const Positioned.fill(child: _DecorShopBackground()),

              // 独立招牌切图；不包含余额、关闭按钮或任何商品卡片。
              Positioned(
                left: (constraints.maxWidth - _guideDesignWidth * scale) / 2,
                top: safeTop + 45 * scale,
                width: _guideDesignWidth * scale,
                height: 140 * scale,
                child: const IgnorePointer(
                  child: ASImg(
                    name: 'as_guide_a_decor_shop_header',
                    fit: BoxFit.fill,
                  ),
                ),
              ),

              Positioned(
                left: 12 * scale,
                top: safeTop + 18 * scale,
                child: _DecorShopBalance(balance: safeBalance, scale: scale),
              ),
              Positioned(
                right: 17 * scale,
                top: safeTop + 20 * scale,
                width: 28 * scale,
                height: 28 * scale,
                child: Semantics(
                  button: true,
                  label: 'Close decor shop',
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: () => _handleClose(context),
                    child: const ASImg(
                      name: 'as_guide_a_decor_close',
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              // 默认 6 个商品。MaxCrossAxisExtent 让手机为两列，
              // 平板等宽屏自动增加列数，同时保留设计稿卡片比例。
              Positioned.fill(
                top: gridTop,
                child: GridView.builder(
                  physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics(),
                  ),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    30 + MediaQuery.paddingOf(context).bottom,
                  ),
                  itemCount: items.length,
                  gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
                    maxCrossAxisExtent: 180 * scale,
                    mainAxisSpacing: 12 * scale,
                    crossAxisSpacing: 14 * scale,
                    childAspectRatio: 161 / 252,
                  ),
                  itemBuilder: (context, index) {
                    final item = items[index];
                    return _DecorShopCard(
                      item: item,
                      onBuy: onBuy == null ? null : () => onBuy!(index, item),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _DecorShopBackground extends StatelessWidget {
  const _DecorShopBackground();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF030445), Color(0xFF111472), Color(0xFF2427A7)],
        ),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: const [
          Positioned(
            left: -105,
            bottom: -125,
            width: 300,
            height: 235,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF6568E6),
                borderRadius: BorderRadius.all(Radius.circular(160)),
              ),
            ),
          ),
          Positioned(
            right: -90,
            bottom: -105,
            width: 310,
            height: 210,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Color(0xFF7073EC),
                borderRadius: BorderRadius.all(Radius.circular(160)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorShopBalance extends StatelessWidget {
  const _DecorShopBalance({required this.balance, required this.scale});

  final int balance;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 127 * scale,
      height: 36 * scale,
      padding: EdgeInsets.symmetric(horizontal: 5 * scale),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20 * scale),
      ),
      child: Row(
        children: [
          Container(
            width: 29 * scale,
            height: 29 * scale,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const RadialGradient(
                colors: [Color(0xFFFFFF74), Color(0xFFFFA600)],
              ),
              border: Border.all(
                color: const Color(0xFFFFD329),
                width: 2 * scale,
              ),
            ),
            child: Icon(
              Icons.star_rounded,
              size: 19 * scale,
              color: const Color(0xFFFFF29D),
            ),
          ),
          SizedBox(width: 7 * scale),
          Expanded(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                '$balance',
                style: _profileTextStyle(
                  fontSize: 22 * scale,
                  color: const Color(0xFF29368D),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DecorShopCard extends StatelessWidget {
  const _DecorShopCard({required this.item, this.onBuy});

  final ASSGuideADecorShopItem item;
  final VoidCallback? onBuy;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final scale = constraints.maxWidth / 161;
        final safePrice = item.price < 0 ? 0 : item.price;

        return Container(
          padding: EdgeInsets.fromLTRB(
            8 * scale,
            8 * scale,
            8 * scale,
            7 * scale,
          ),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF08064A), Color(0xFF19117B)],
            ),
            borderRadius: BorderRadius.circular(14 * scale),
            border: Border.all(color: const Color(0xFFC7CCFF), width: 2),
            boxShadow: const [
              BoxShadow(
                color: Color(0x55000035),
                blurRadius: 3,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            children: [
              SizedBox(
                height: 28 * scale,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    item.name,
                    maxLines: 1,
                    style: _profileTextStyle(
                      fontSize: 20 * scale,
                      color: const Color(0xFFFFF8D7),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: ASImg(name: item.assetName, fit: BoxFit.contain),
              ),
              Container(
                width: double.infinity,
                height: 28 * scale,
                decoration: BoxDecoration(
                  color: const Color(0xFF062A71),
                  borderRadius: BorderRadius.circular(15 * scale),
                  border: Border.all(color: const Color(0xFF72CBFF)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 19 * scale,
                      height: 19 * scale,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [Color(0xFFFFFF72), Color(0xFFFFA600)],
                        ),
                      ),
                      child: Icon(
                        Icons.star_rounded,
                        size: 13 * scale,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(width: 5 * scale),
                    Text(
                      '$safePrice',
                      style: _profileTextStyle(
                        fontSize: 20 * scale,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 5 * scale),
              Semantics(
                button: true,
                label: 'Buy ${item.name} for $safePrice coins',
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: onBuy,
                  child: SizedBox(
                    width: double.infinity,
                    height: 45 * scale,
                    child: const ASImg(
                      name: 'as_guide_a_decor_buy_btn',
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// 暂定的 6 个商品，后续接入接口时可通过 `items` 整体替换。
const List<ASSGuideADecorShopItem> _defaultDecorShopItems = [
  ASSGuideADecorShopItem(
    name: 'Berry Bake',
    price: 1000,
    assetName: 'as_guide_a_decor_berry_bake',
  ),
  ASSGuideADecorShopItem(
    name: 'Berry Bake',
    price: 1000,
    assetName: 'as_guide_a_decor_berry_bake',
  ),
  ASSGuideADecorShopItem(
    name: 'Berry Bake',
    price: 1000,
    assetName: 'as_guide_a_decor_berry_bake',
  ),
  ASSGuideADecorShopItem(
    name: 'Berry Bake',
    price: 1000,
    assetName: 'as_guide_a_decor_berry_bake',
  ),
  ASSGuideADecorShopItem(
    name: 'Berry Bake',
    price: 1000,
    assetName: 'as_guide_a_decor_berry_bake',
  ),
  ASSGuideADecorShopItem(
    name: 'Berry Bake',
    price: 1000,
    assetName: 'as_guide_a_decor_berry_bake',
  ),
];
