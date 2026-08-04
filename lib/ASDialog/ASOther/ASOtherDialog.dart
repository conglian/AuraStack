import 'dart:math';

import 'package:aurastack/ASTool/as_LocalProvider.dart';
import 'package:aurastack/ASTool/as_extension_help.dart';
import 'package:aurastack/ASTool/as_img.dart';
import 'package:aurastack/ASTool/as_shine.dart';
import 'package:aurastack/ASTool/as_spine_tool.dart';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ASTool/as_stroke_text.dart';

enum ToolType { notice, nowifi, loadfaild, limted }

// 广告上线/无网/加载失败/通知
class ASToolDialog extends StatefulWidget {
  final ToolType type;

  const ASToolDialog({super.key, required this.type});

  @override
  State<ASToolDialog> createState() => ASToolDialogState();
}

class ASToolDialogState extends State<ASToolDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _scaleController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeInOut),
    );

    _scaleController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 12.h),
            Container(
              width: 347,
              height: 308,
              decoration: BoxDecoration(image: ASDImg('as_tool_bg')),
              child: Column(
                children: [
                  SizedBox(height: 16),
                  ASText(
                    text: gettitleName(),
                    size: 20,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w700,
                  ),
                  SizedBox(height: 26),
                  SizedBox(
                    width: 155,
                    height: 140,
                    child: Center(child: ASImg(name: getIconName())),
                  ),
                  SizedBox(height: 18),
                  SizedBox(
                    width: 248,
                    height: 40,
                    child: Center(
                      child: ASText(
                        text: getTripsName(),
                        size: 16,
                        color: '#4A474B'.color(),
                        weight: FontWeight.w600,
                        maxLines: 2,
                        align: .center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 27.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 0);
              },
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: getBtnName(),
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            Visibility(
              visible: widget.type == .notice,
              child: SizedBox(height: 12.h),
            ),
            Visibility(
              visible: widget.type == .notice,
              child: ASUnderlineTextButton(
                text: 'Later On',
                textColor: '#CEC4D5'.color(),
                underlineColor: '#CEC4D5'.color(),
                fontSize: 16,
                onPressed: () {
                  Navigator.pop(context, 0);
                },
              ),
            ),
            SizedBox(height: 88.h),
          ],
        ),
        Visibility(
          visible: widget.type != .limted,
          child: Positioned(
            right: 30.w,
            bottom: 220.h,
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: ASImg(name: 'cs_tap_icon', width: 93, height: 98),
            ),
          ),
        ),
      ],
    );
  }

  String gettitleName() {
    String name = 'Ad Limit Reached';
    if (widget.type == .limted) {
      name = 'Ad Limit Reached';
    } else if (widget.type == .loadfaild) {
      name = 'Quick Break - Back Soon!';
    } else if (widget.type == .nowifi) {
      name = 'No Network Currently';
    } else if (widget.type == .notice) {
      name = 'Unlock More Rewards';
    }
    return name;
  }

  String getIconName() {
    String name = 'as_limteds_icon';
    if (widget.type == .limted) {
      name = 'as_limteds_icon';
    } else if (widget.type == .loadfaild) {
      name = 'as_loadfaild_icon';
    } else if (widget.type == .nowifi) {
      name = 'as_wifi_icon';
    } else if (widget.type == .notice) {
      name = 'as_notice_icon';
    }
    return name;
  }

  String getTripsName() {
    String name = 'You’re all set for today! Come back tomorrow for more ads.';
    if (widget.type == .limted) {
      name = 'You’re all set for today! Come back tomorrow for more ads.';
    } else if (widget.type == .loadfaild) {
      name = 'More Cash Coming!';
    } else if (widget.type == .nowifi) {
      name = 'Large rewards were interrupted';
    } else if (widget.type == .notice) {
      name = 'Enable notifications to get more reward opportunities.';
    }
    return name;
  }

  String getBtnName() {
    String name = 'Ok';
    if (widget.type == .limted) {
      name = 'Ok';
    } else if (widget.type == .loadfaild) {
      name = 'Try Again';
    } else if (widget.type == .nowifi) {
      name = 'Try Again';
    } else if (widget.type == .notice) {
      name = 'Allow & Get \$10';
    }
    return name;
  }
}

// 退出挽留
class ASWaitDialog extends StatefulWidget {
  const ASWaitDialog({super.key});

  @override
  State<ASWaitDialog> createState() => ASWaitDialogState();
}

class ASWaitDialogState extends State<ASWaitDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Spacer(),
            Container(
              width: 0.width(context),
              height: 311.h,
              decoration: BoxDecoration(image: ASDImg('as_wait_bg')),
              child: Column(
                children: [
                  SizedBox(height: 46.h),
                  Row(
                    children: [
                      SizedBox(width: 25.w),
                      ASText(
                        text: 'Wait!',
                        size: 48,
                        color: '#451F80'.color(),
                        weight: FontWeight.w700,
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      SizedBox(width: 25.w),
                      ASText(
                        text: 'You next surprise is almost ready!',
                        size: 16,
                        color: '#451F80'.color(),
                        weight: FontWeight.w600,
                      ),
                    ],
                  ),
                  SizedBox(height: 35.h),
                  Row(
                    children: [
                      SizedBox(width: 25.w),
                      SizedBox(
                        width: 331,
                        height: 40,
                        child: ASText(
                          text:
                              'leave now and you‘ll miss today’s bouns spin.would you like to stay and check it out?',
                          size: 14,
                          color: '#4A474B'.color(),
                          weight: FontWeight.w600,
                          maxLines: 2,
                          align: .left,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 15.h),
                  ParticleButton(
                    onTap: () {
                      Navigator.pop(context, 0);
                    },
                    child: Container(
                      width: 339,
                      height: 55,
                      decoration: BoxDecoration(image: ASDImg('as_zi_btn_bg')),
                      child: Center(
                        child: ASText(
                          text: 'Keep Playing',
                          size: 24,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  ASUnderlineTextButton(
                    text: 'Exit Anyway',
                    fontSize: 16,
                    textColor: '#65576F'.color(),
                    underlineColor: '#65576F'.color(),
                    onPressed: () {
                      SystemNavigator.pop();
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
        Positioned(
          right: 0,
          bottom: 200.h,
          child: ASImg(name: 'as_wait_icon', width: 227, height: 232),
        ),
      ],
    );
  }
}

// 首次获得奖励
class ASFristAwardDialog extends StatefulWidget {
  const ASFristAwardDialog({super.key});

  @override
  State<ASFristAwardDialog> createState() => ASFristAwardDialogState();
}

class ASFristAwardDialogState extends State<ASFristAwardDialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ParticleButton(
      onTap: () {
        Navigator.pop(context, 1);
      },
      child: Stack(
        children: [
          Positioned(
            left: 16.w,
            top: 48.h,
            child: Container(
              width: 298.w,
              height: 51.h,
              decoration: BoxDecoration(image: ASDImg('as_top_bg')),
              child: Stack(
                children: [
                  Positioned(
                    left: 13.w,
                    top: 10,
                    child: ASImg(name: 'as_dollar_icon', width: 38, height: 32),
                  ),
                  Positioned(
                    right: 10.w,
                    top: 9,
                    child: ASImg(name: 'as_pp_0', width: 82, height: 32),
                  ),
                  Positioned(
                    left: 50.w,
                    top: 9,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w900,
                          fontFamily: text_fontName,
                          color: '#733A1B'.color(),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                '\$${ASLocalProvider.instance.as_dollar_number}',
                          ),
                          TextSpan(
                            text: '/\$1000',
                            style: TextStyle(color: '#0A8A33'.color()),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    left: 50.w,
                    bottom: 22,
                    child: Container(
                      width: 138,
                      height: 11,
                      decoration: BoxDecoration(image: ASDImg('as_home_pro_1')),
                      child: Row(
                        children: [
                          Container(
                            width: 138 * 0.5,
                            height: 11,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5.5),
                              color: '#FFEE38'.color(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            left: 56.w,
            top: 110.h,
            child: Container(
              width: 265,
              height: 89,
              decoration: BoxDecoration(image: ASDImg('as_doaller_bgs')),
              child: Stack(
                children: [
                  Positioned(
                    left: 24.w,
                    top: 50,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.w900,
                          fontFamily: text_fontName,
                          color: '#DC2918'.color(),
                        ),
                        children: <TextSpan>[
                          TextSpan(
                            text:
                                '\$${ASLocalProvider.instance.as_dollar_number}',
                          ),
                          TextSpan(
                            text: ' Stored In Account. ',
                            style: TextStyle(color: '#240B4F'.color()),
                          ),
                        ],
                      ),
                    ),
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

// 运营1
class ASYunying1Dialog extends StatefulWidget {
  const ASYunying1Dialog({super.key});

  @override
  State<ASYunying1Dialog> createState() => ASYunying1DialogState();
}

class ASYunying1DialogState extends State<ASYunying1Dialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  late final Animation<Offset> _leftAnimation;
  late final Animation<Offset> _rightAnimation;
  late Route _route;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _leftAnimation = Tween<Offset>(
      begin: const Offset(-1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _rightAnimation = Tween<Offset>(
      begin: const Offset(1.2, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    // 2秒后关闭当前页面
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      final navigator = Navigator.of(context);

      // 当前 route 仍然在栈里才关闭
      if (_route.isCurrent) {
        navigator.pop(0);
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _route = ModalRoute.of(context)!;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: 0,
          top: 392.h,
          child: SlideTransition(
            position: _rightAnimation,
            child: ASImg(name: 'as_right_icons', width: 363, height: 96),
          ),
        ),
        Positioned(
          left: 0,
          top: 294.h,
          child: SlideTransition(
            position: _leftAnimation,
            child: ASImg(name: 'as_left_icons', width: 362, height: 158),
          ),
        ),
      ],
    );
  }
}

// 运营2
class ASyunying2Dialog extends StatefulWidget {
  const ASyunying2Dialog({super.key});

  @override
  State<ASyunying2Dialog> createState() => ASyunying2DialogState();
}

class ASyunying2DialogState extends State<ASyunying2Dialog>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            ASImg(name: 'as_yunying2_top', width: 358, height: 62),
            SizedBox(height: 22.h),
            Row(
              children: [
                Spacer(),
                ASImg(name: 'as_yunying2_center', width: 265, height: 101),
                SizedBox(width: 30.w),
              ],
            ),
            SizedBox(height: 3.5.h),
            ASSpine(width: 169, height: 165, path: 'securemoney'.spinepaths()),
            SizedBox(height: 15.h),
            SizedBox(
              width: 309,
              height: 72,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.w700,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Your game was a success! To send your '),
                    TextSpan(
                      text: '\$20 ',
                      style: TextStyle(color: '#FFE100'.color()),
                    ),
                    TextSpan(
                      text: 'in earnings, we just need your payout info.. ',
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 36.h),
            ParticleButton(
              onTap: () {
                Navigator.pop(context, 1);
              },
              child: Container(
                width: 339,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),
                child: Center(
                  child: ASText(
                    text: 'Secure My Winnings',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            SizedBox(height: 18.h),
            ASUnderlineTextButton(
              text: 'Later On',
              fontSize: 16,
              textColor: '#CEC4D5'.color(),
              underlineColor: '#CEC4D5'.color(),
              onPressed: () {
                Navigator.pop(context, 0);
              },
            ),
          ],
        ),
      ],
    );
  }
}

// 运营3
class ASyunying3Dialog extends StatefulWidget {
  const ASyunying3Dialog({super.key});

  @override
  State<ASyunying3Dialog> createState() => ASyunying3DialogState();
}

class ASyunying3DialogState extends State<ASyunying3Dialog>
    with TickerProviderStateMixin {
  late AnimationController _noticeController;

  late AnimationController _noticeController1;

  late Animation<double> _noticeAnimation;

  late Animation<double> _noticeAnimation1;

  @override
  void initState() {
    super.initState();

    _noticeController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _noticeController1 = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    );

    _noticeAnimation = Tween<double>(
      begin: 1.2,
      end: -1.2,
    ).animate(CurvedAnimation(parent: _noticeController, curve: Curves.linear));

    _noticeAnimation1 = Tween<double>(begin: 1.0, end: -1.0).animate(
      CurvedAnimation(parent: _noticeController1, curve: Curves.linear),
    );

    _noticeController.repeat();

    _noticeController1.repeat();
  }

  @override
  void dispose() {
    _noticeController.dispose();

    _noticeController1.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            SizedBox(
              width: 0.width(context),
              height: 76.h,

              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  AnimatedBuilder(
                    animation: _noticeAnimation,

                    builder: (_, child) {
                      return Positioned(
                        left: _noticeAnimation.value * 300.w,
                        top: 0,
                        child: child!,
                      );
                    },
                    child: Container(
                      width: 227.w,
                      height: 29.h,
                      decoration: BoxDecoration(image: ASDImg('as_yunying3_0')),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 38.w,
                            top: 7,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: text_fontName,
                                  color: '#262933'.color(),
                                ),
                                children: <TextSpan>[
                                  const TextSpan(text: 'Congrats, '),
                                  TextSpan(
                                    text: '1****${Random().nextInt(900) + 99} ',
                                    style: TextStyle(color: '#3844B2'.color()),
                                  ),
                                  const TextSpan(text: 'withdrew '),
                                  TextSpan(
                                    text: '\$1000',
                                    style: TextStyle(color: '#1E7C2D'.color()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  AnimatedBuilder(
                    animation: _noticeAnimation1,

                    builder: (_, child) {
                      return Positioned(
                        left: _noticeAnimation1.value * 300.w - 50.w,
                        top: 31.h,
                        child: child!,
                      );
                    },

                    child: Container(
                      width: 227.w,
                      height: 29.h,
                      decoration: BoxDecoration(image: ASDImg('as_yunying3_1')),
                      child: Stack(
                        children: [
                          Positioned(
                            left: 38.w,
                            top: 7,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 12.0,
                                  fontWeight: FontWeight.w600,
                                  fontFamily: text_fontName,
                                  color: '#262933'.color(),
                                ),
                                children: <TextSpan>[
                                  const TextSpan(text: 'Congrats, '),
                                  TextSpan(
                                    text: '1****${Random().nextInt(900) + 99} ',
                                    style: TextStyle(color: '#3844B2'.color()),
                                  ),
                                  const TextSpan(text: 'withdrew '),
                                  TextSpan(
                                    text: '\$1000',
                                    style: TextStyle(color: '#1E7C2D'.color()),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 8.h),
            ASImg(name: 'as_yunying3_top', width: 223, height: 38),
            SizedBox(height: 10.h),
            SizedBox(
              width: 312,
              height: 42,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 18.0,
                    fontWeight: FontWeight.w900,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: <TextSpan>[
                    TextSpan(text: 'Your withdrawal progress is ahead of '),
                    TextSpan(
                      text: '92% ',
                      style: TextStyle(color: '#FFEA00'.color()),
                    ),
                    TextSpan(text: 'of users! '),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              width: 317,
              height: 351,
              decoration: BoxDecoration(image: ASDImg('as_yunying3_center')),
              child: Stack(
                children: [
                  Positioned(
                    left: 37.w,
                    top: 54.h,
                    child: ASText(
                      text: '\$${ASLocalProvider.instance.as_dollar_number}',
                      size: 48,
                      color: '#FFFFFF'.color(),
                      weight: FontWeight.w700,
                    ),
                  ),
                  Positioned(
                    left: 34.w,
                    top: 140.h,
                    child: ASImg(
                      name: 'as_yunying3_line',
                      width: 18,
                      height: 96,
                    ),
                  ),
                  Positioned(
                    left: 60.w,
                    top: 174.h,
                    child: ASText(
                      text:
                          'Just \$${1000 - ASLocalProvider.instance.as_dollar_number} away from payout!',
                      size: 14,
                      color: '#B11212'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 60.w,
                    top: 140.h,
                    child: ASText(
                      text: 'Submit payment information',
                      size: 14,
                      color: '#312E2D'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 60.w,
                    top: 204.h,
                    child: ASText(
                      text: 'Revenue received',
                      size: 14,
                      color: '#8E8779'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                  Positioned(
                    left: 13.w,
                    bottom: 14.h,
                    child: ParticleButton(
                      onTap: () {
                        Navigator.pop(context, 1);
                      },
                      child: Container(
                        width: 287,
                        height: 55,
                        decoration: BoxDecoration(
                          image: ASDImg('as_yellow_btn_bg'),
                        ),
                        child: Center(
                          child: ASText(
                            text: 'Play Game',
                            size: 24,
                            color: '#5C300E'.color(),
                            weight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 34.h),
            Container(
              width: 339.w,
              height: 120.h,
              decoration: BoxDecoration(image: ASDImg('as_yunying3_bottom')),
              child: Stack(
                children: [
                  Column(
                    children: [
                      SizedBox(height: 15.h),
                      Row(
                        children: [
                          SizedBox(width: 14.w),
                          ASText(
                            text: '\$ 1000',
                            size: 32,
                            color: '#1C4779'.color(),
                            weight: FontWeight.w600,
                          ),
                          Spacer(),
                          ParticleButton(
                            child: Container(
                              width: 119,
                              height: 33,
                              decoration: BoxDecoration(
                                image: ASDImg('as_zi_s_btn'),
                              ),
                              child: Center(
                                child: ASText(
                                  text: 'Cash Out',
                                  size: 16,
                                  color: '#FFFFFF'.color(),
                                  weight: FontWeight.w600,
                                ),
                              ),
                            ),
                            onTap: () {},
                          ),
                          SizedBox(width: 14.w),
                        ],
                      ),
                      SizedBox(height: 8.h),
                      Container(
                        width: 304.w,
                        height: 16.h,
                        decoration: BoxDecoration(
                          color: '#C0BFCA'.color(),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Stack(
                          children: [
                            Positioned(
                              left: 2.w,
                              top: 2.h,
                              child: Container(
                                width:
                                    300.w *
                                    (ASLocalProvider.instance.as_dollar_number /
                                        1000),
                                height: 12.h,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6.h),
                                  color: '#4045D8'.color(),
                                ),
                              ),
                            ),
                            Center(
                              child: ASStrokeText(
                                text:
                                    '${((ASLocalProvider.instance.as_dollar_number / 1000) * 100).toInt()}%',
                                size: 12,
                                color: '#FFD000'.color(),
                                weight: FontWeight.w600,
                                skWidth: 1,
                                skColor: '#000000'.color(),
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          SizedBox(width: 20.w),
                          ASText(
                            text: 'Accumulate \$1000 to cash out.',
                            size: 12,
                            color: '#4A474B'.color(),
                            weight: FontWeight.w200,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 运营4
class ASyunying4Dialog extends StatefulWidget {
  const ASyunying4Dialog({super.key});

  @override
  State<ASyunying4Dialog> createState() => ASyunying4DialogState();
}

class ASyunying4DialogState extends State<ASyunying4Dialog>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    // 无限旋转
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    // 12 秒进度
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
    )..forward();
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 41.h),

            /// 无限旋转
            RotationTransition(
              turns: _rotateController,
              child: ASImg(name: 'as_loading_icon', width: 108, height: 108),
            ),

            SizedBox(height: 51.h),

            /// 12 秒进度条
            Container(
              width: 217,
              height: 16,
              decoration: BoxDecoration(
                color: '#FFFFFF'.color(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: AnimatedBuilder(
                animation: _progressController,
                builder: (_, __) {
                  return Stack(
                    children: [
                      Positioned(
                        left: 1,
                        top: 1,
                        child: Container(
                          width: 215 * _progressController.value,
                          height: 14,
                          decoration: BoxDecoration(
                            color: '#E8800A'.color(),
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),

            SizedBox(height: 31.h),

            SizedBox(
              width: 287,
              height: 48,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: const <TextSpan>[
                    TextSpan(
                      text:
                          'Due to a high number of requests, processing may take a bit longer.',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 57.h),

            ParticleButton(
              onTap: () {
                Navigator.pop(context, 1);
              },
              child: Container(
                width: 287,
                height: 55,
                decoration: BoxDecoration(image: ASDImg('as_yellow_s_bg')),
                child: Center(
                  child: ASText(
                    text: 'Skip Now',
                    size: 24,
                    color: '#5C300E'.color(),
                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),

        Positioned(
          right: 58.w,
          bottom: 224.h,
          child: ASImg(name: 'as_ads_icon', width: 47, height: 47),
        ),
      ],
    );
  }
}

// 运营5
class ASyunying5Dialog extends StatefulWidget {
  const ASyunying5Dialog({super.key});

  @override
  State<ASyunying5Dialog> createState() => ASyunying5DialogState();
}

class ASyunying5DialogState extends State<ASyunying5Dialog>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                const Spacer(),
                ParticleButton(
                  child: SizedBox(
                    width: 40,
                    height: 40,
                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),
                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),
                SizedBox(width: 32.w),
              ],
            ),
            SizedBox(height: 11.h),
            ASImg(name: 'as_duis_icons', width: 143, height: 151),
            SizedBox(height: 37.h),
            Container(
              width: 217,
              height: 16,
              decoration: BoxDecoration(
                color: '#FFFFFF'.color(),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  Positioned(
                    left: 1,
                    top: 1,
                    child: Container(
                      width: 215 * 1.0,
                      height: 14,
                      decoration: BoxDecoration(
                        color: '#E8800A'.color(),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 31.h),

            SizedBox(
              width: 287,
              height: 48,
              child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: text_fontName,
                    color: '#FFFFFF'.color(),
                  ),
                  children: const <TextSpan>[
                    TextSpan(
                      text:
                          'Due to a high number of requests, processing may take a bit longer.',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// 运营6
class ASyunying6Dialog extends StatefulWidget {
  const ASyunying6Dialog({super.key});

  @override
  State<ASyunying6Dialog> createState() => ASyunying6DialogState();
}

class ASyunying6DialogState extends State<ASyunying6Dialog>
    with TickerProviderStateMixin {
  /// 三张牌当前位置
  final List<int> _positions = [0, 1, 2];

  /// 三个位置横坐标
  late List<double> _cardX;

  /// 当前是否开始动画
  bool _isOpening = false;

  /// 中间牌结果
  bool _showResult = false;

  /// 左右牌结果
  bool _showLeftResult = false;
  bool _showRightResult = false;

  // 翻开后的结果-自定义
  List<String> _resultImages = [
    'as_yunying6_0',
    'as_yunying6_2',
    'as_yunying6_1',
  ];

  /// 洗牌控制器
  late AnimationController _shuffleController;

  /// 三张牌翻牌控制器
  late AnimationController _centerFlipController;
  late AnimationController _leftFlipController;
  late AnimationController _rightFlipController;

  /// 翻牌动画
  late Animation<double> _centerFlipAnimation;
  late Animation<double> _leftFlipAnimation;
  late Animation<double> _rightFlipAnimation;

  /// 光效呼吸
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;

  @override
  void initState() {
    super.initState();

    final screenWidth = 1.sw;

    const cardWidth = 123.0;

    /// 三张牌平分布局
    final space = (screenWidth - cardWidth * 3) / 4;

    _cardX = [space, space * 2 + cardWidth, space * 3 + cardWidth * 2];

    _shuffleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _centerFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _leftFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _rightFlipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _centerFlipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _centerFlipController, curve: Curves.easeInOut),
    );

    _leftFlipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _leftFlipController, curve: Curves.easeInOut),
    );

    _rightFlipAnimation = Tween<double>(begin: 0, end: pi).animate(
      CurvedAnimation(parent: _rightFlipController, curve: Curves.easeInOut),
    );

    _breathController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _breathAnimation = Tween<double>(begin: 1.0, end: 1.08).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _shuffleController.dispose();

    _centerFlipController.dispose();

    _leftFlipController.dispose();

    _rightFlipController.dispose();

    _breathController.dispose();

    super.dispose();
  }

  /// 开始三张牌交换
  Future<void> _openCard() async {
    if (_isOpening) return;

    setState(() {
      _isOpening = true;

      _showResult = false;

      _showLeftResult = false;

      _showRightResult = false;

      _centerFlipController.reset();

      _leftFlipController.reset();

      _rightFlipController.reset();

      _breathController.stop();

      _breathController.reset();
    });

    final random = Random();

    /// 持续2秒洗牌
    final endTime = DateTime.now().millisecondsSinceEpoch + 2000;

    while (DateTime.now().millisecondsSinceEpoch < endTime) {
      int first = random.nextInt(3);

      int second = random.nextInt(3);

      while (first == second) {
        second = random.nextInt(3);
      }

      final temp = _positions[first];

      _positions[first] = _positions[second];

      _positions[second] = temp;

      if (mounted) {
        setState(() {});
      }

      await Future.delayed(const Duration(milliseconds: 260));
    }

    /// 中间牌先显示光效
    setState(() {
      _showResult = true;
    });

    /// 光效呼吸
    _breathController.repeat(reverse: true);

    /// 中间牌翻开
    await _centerFlipController.forward();

    await Future.delayed(const Duration(milliseconds: 200));

    /// 左边牌翻开
    setState(() {
      _showLeftResult = true;
    });

    await _leftFlipController.forward();

    await Future.delayed(const Duration(milliseconds: 200));

    /// 右边牌翻开
    setState(() {
      _showRightResult = true;
    });

    await _rightFlipController.forward();

    setState(() {
      _isOpening = false;
    });
  }

  Widget _buildCard(int index) {
    Widget card = Container(
      width: 123,
      height: 164,

      decoration: BoxDecoration(
        image: index == 1 && _showResult ? ASDImg('as_yunying6_guang') : null,
      ),

      child: Stack(
        children: [
          Positioned(
            left: 2.5,

            top: 5.5,

            child: ASImg(name: _getCardImage(index), width: 117, height: 158),
          ),
        ],
      ),
    );

    Animation<double> animation;

    if (index == 0) {
      animation = _leftFlipAnimation;
    } else if (index == 1) {
      animation = _centerFlipAnimation;
    } else {
      animation = _rightFlipAnimation;
    }

    return AnimatedBuilder(
      animation: animation,

      builder: (_, child) {
        final angle = animation.value;

        return Transform(
          alignment: Alignment.center,

          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0015)
            ..rotateY(angle),

          child: angle > pi / 2
              ? Transform(
                  alignment: Alignment.center,

                  transform: Matrix4.identity()..rotateY(pi),

                  child: index == 1 && _showResult
                      ? ScaleTransition(
                          scale: _breathAnimation,

                          child: _resultCard(index),
                        )
                      : _resultCard(index),
                )
              : child,
        );
      },

      child: card,
    );
  }

  String _getCardImage(int index) {
    double angle;

    if (index == 0) {
      angle = _leftFlipAnimation.value;
    } else if (index == 1) {
      angle = _centerFlipAnimation.value;
    } else {
      angle = _rightFlipAnimation.value;
    }

    // 没翻过90度，一直显示背面
    if (angle < pi / 2) {
      return 'as_yunying6_bg';
    }

    // 翻过90度后显示结果

    if (index == 0 && _showLeftResult) {
      return 'as_yunying6_1';
    }

    if (index == 1 && _showResult) {
      return 'as_yunying6_0';
    }

    if (index == 2 && _showRightResult) {
      return 'as_yunying6_2';
    }

    return 'as_yunying6_bg';
  }

  Widget _resultCard(int index) {
    final imageName = _resultImages[index];

    return Container(
      width: 123,

      height: 164,

      decoration: BoxDecoration(
        image: index == 1 ? ASDImg('as_yunying6_guang') : null,
      ),

      child: Stack(
        children: [
          Positioned(
            left: 2.5,

            top: 5.5,

            child: ASImg(name: imageName, width: 117, height: 158),
          ),
        ],
      ),
    );
  }

  /// 单张牌移动动画
  Widget _cardAnimation(int index, double left) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 260),

      curve: Curves.easeInOut,

      left: left,

      top: 0,

      child: _buildCard(index),
    );
  }

  Widget _buildCards() {
    return SizedBox(
      width: 1.sw,

      height: 164,

      child: Stack(
        children: [
          _cardAnimation(_positions[0], _cardX[_positions[0]]),

          _cardAnimation(_positions[1], _cardX[_positions[1]]),

          _cardAnimation(_positions[2], _cardX[_positions[2]]),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            Row(
              children: [
                const Spacer(),

                ParticleButton(
                  child: SizedBox(
                    width: 40,

                    height: 40,

                    child: Center(
                      child: ASImg(name: 'as_close_w', width: 18, height: 18),
                    ),
                  ),

                  onTap: () {
                    Navigator.pop(context, 0);
                  },
                ),

                SizedBox(width: 32.w),
              ],
            ),

            SizedBox(height: 21.h),

            ASImg(name: 'as_yunying6_top', width: 345, height: 69),

            SizedBox(height: 31.h),

            _buildCards(),

            SizedBox(height: 31.h),

            ParticleButton(
              onTap: () {
                _openCard();
              },

              child: Container(
                width: 339,

                height: 55,

                decoration: BoxDecoration(image: ASDImg('as_yellow_btn_bg')),

                child: Center(
                  child: ASText(
                    text: _isOpening ? 'Opening...' : 'Open (3)',

                    size: 24,

                    color: '#5C300E'.color(),

                    weight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            SizedBox(height: 50.h),
          ],
        ),
      ],
    );
  }
}
