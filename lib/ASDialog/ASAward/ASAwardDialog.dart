import 'dart:math';

import 'package:aurastack/ASTool/as_LocalProvider.dart';
import 'package:aurastack/ASTool/as_stroke_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ASTool/as_GradientNumber.dart';
import '../../ASTool/as_GradientText.dart';
import '../../ASTool/as_extension_help.dart';
import '../../ASTool/as_img.dart';
import '../../ASTool/as_spine_tool.dart';
import '../../ASTool/as_text.dart';

/// YouWin
class ASYouWinDialog extends StatefulWidget {
  final double award;
  final bool isWheel;

  const ASYouWinDialog({super.key, required this.award, required this.isWheel});

  @override
  State<ASYouWinDialog> createState() => ASYouWinDialogState();
}

class ASYouWinDialogState extends State<ASYouWinDialog>
    with SingleTickerProviderStateMixin {
  bool _showAwardButton = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showAwardButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          width: 0.width(context),
          height: 0.height(context),

          child: ASSpine(path: 'caidai'.spinepaths()),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            ASSpine(
              width: 0.width(context),

              height: 420.h,

              path: 'youwin'.spinepaths(),
            ),

            SizedBox(height: 56.h),

            ParticleButton(
              onTap: () {
                Navigator.pop(context, 1);
              },

              child: Container(
                width: 262,

                height: ASLocalProvider.instance.as_scrach_all_count >= 4
                    ? 96
                    : 84,

                decoration: BoxDecoration(
                  image: ASDImg(
                    ASLocalProvider.instance.as_scrach_all_count >= 4
                        ? 'as_ad_btn'
                        : 'as_claim_b_btn',
                  ),
                ),

                child: ASLocalProvider.instance.as_scrach_all_count >= 4
                    ? Center(
                        child: Row(
                          mainAxisAlignment: .center,
                          children: [
                            ASStrokeText(
                              text: 'Claim +',
                              size: 28,
                              color: '#FFFFFF'.color(),
                              weight: FontWeight.w900,
                              skWidth: 2,
                              skColor: '#41740A'.color(),
                            ),
                            ASStrokeText(
                              text: '\$${(0.to2Double(widget.award * 2))}',
                              size: 28,
                              color: '#F7FF00'.color(),
                              weight: FontWeight.w900,
                              skWidth: 2,
                              skColor: '#41740A'.color(),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
            ),

            SizedBox(height: 20.h),

            Visibility(
              visible: ASLocalProvider.instance.as_scrach_all_count >= 4,
              child: Opacity(
                opacity: _showAwardButton ? 1 : 0,

                child: ASUnderlineTextButton(
                  text: '\$${widget.award}',

                  underlineColor: '#FFFFFF'.color(),

                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),

        Positioned(
          width: 0.width(context),

          bottom: 288.h,

          child: ASStrokeText(
            text: '\$${widget.award}',

            size: 48,

            color: '#FFFFFF'.color(),

            weight: FontWeight.w900,

            skWidth: 3,

            skColor: '#8A320C'.color(),
          ),
        ),

        Positioned(
          left: 30.w,
          bottom: 234.h,
          child: Visibility(
            visible: ASLocalProvider.instance.as_scrach_all_count >= 4,
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
                          TextSpan(text: '\$${ASLocalProvider.instance.as_dollar_number}'),
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
        ),
      ],
    );
  }
}

/// SuperWin
class ASSuperWinDialog extends StatefulWidget {
  final double award;

  const ASSuperWinDialog({super.key, required this.award});

  @override
  State<ASSuperWinDialog> createState() => ASSuperWinDialogState();
}

class ASSuperWinDialogState extends State<ASSuperWinDialog>
    with SingleTickerProviderStateMixin {
  bool _showAwardButton = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showAwardButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          width: 0.width(context),
          height: 0.height(context),

          child: ASSpine(path: 'caidai'.spinepaths()),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            ASSpine(
              width: 0.width(context),

              height: 420.h,

              path: 'superwin'.spinepaths(),
            ),

            SizedBox(height: 56.h),

            ParticleButton(
              onTap: () {
                Navigator.pop(context, 1);
              },

              child: Container(
                width: 262,

                height: ASLocalProvider.instance.as_scrach_all_count >= 4
                    ? 96
                    : 84,

                decoration: BoxDecoration(
                  image: ASDImg(
                    ASLocalProvider.instance.as_scrach_all_count >= 4
                        ? 'as_ad_btn'
                        : 'as_claim_b_btn',
                  ),
                ),

                child: ASLocalProvider.instance.as_scrach_all_count >= 4
                    ? Center(
                        child: Row(
                          mainAxisAlignment: .center,
                          children: [
                            ASStrokeText(
                              text: 'Claim +',
                              size: 28,
                              color: '#FFFFFF'.color(),
                              weight: FontWeight.w900,
                              skWidth: 2,
                              skColor: '#41740A'.color(),
                            ),
                            ASStrokeText(
                              text: '\$${widget.award * 2}',
                              size: 28,
                              color: '#F7FF00'.color(),
                              weight: FontWeight.w900,
                              skWidth: 2,
                              skColor: '#41740A'.color(),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
            ),

            SizedBox(height: 20.h),

            Visibility(
              visible: ASLocalProvider.instance.as_scrach_all_count >= 4,
              child: Opacity(
                opacity: _showAwardButton ? 1 : 0,

                child: ASUnderlineTextButton(
                  text: '\$${widget.award}',

                  underlineColor: '#FFFFFF'.color(),

                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),

        Positioned(
          width: 0.width(context),

          bottom: 288.h,

          child: ASStrokeText(
            text: '\$${widget.award}',

            size: 48,

            color: '#FFFFFF'.color(),

            weight: FontWeight.w900,

            skWidth: 3,

            skColor: '#8A320C'.color(),
          ),
        ),

        Positioned(
          left: 30.w,
          bottom: 234.h,
          child: Visibility(
            visible: ASLocalProvider.instance.as_scrach_all_count >= 4,
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
                          TextSpan(text: '\$${ASLocalProvider.instance.as_dollar_number}'),
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
        ),
      ],
    );
  }
}

/// JackPot
class ASJackPotDialog extends StatefulWidget {
  final double award;

  const ASJackPotDialog({super.key, required this.award});

  @override
  State<ASJackPotDialog> createState() => ASJackPotDialogState();
}

class ASJackPotDialogState extends State<ASJackPotDialog>
    with SingleTickerProviderStateMixin {
  bool _showAwardButton = false;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showAwardButton = true;
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          width: 0.width(context),
          height: 0.height(context),

          child: ASSpine(path: 'caidai'.spinepaths()),
        ),

        Column(
          mainAxisAlignment: MainAxisAlignment.center,

          crossAxisAlignment: CrossAxisAlignment.center,

          children: [
            ASSpine(
              width: 0.width(context),

              height: 420.h,

              path: 'jackpot'.spinepaths(),
            ),

            SizedBox(height: 56.h),

            ParticleButton(
              onTap: () {
                Navigator.pop(context, 1);
              },

              child: Container(
                width: 262,

                height: ASLocalProvider.instance.as_scrach_all_count >= 4
                    ? 96
                    : 84,

                decoration: BoxDecoration(
                  image: ASDImg(
                    ASLocalProvider.instance.as_scrach_all_count >= 4
                        ? 'as_ad_btn'
                        : 'as_claim_b_btn',
                  ),
                ),

                child: ASLocalProvider.instance.as_scrach_all_count >= 4
                    ? Center(
                        child: Row(
                          mainAxisAlignment: .center,
                          children: [
                            ASStrokeText(
                              text: 'Claim +',
                              size: 28,
                              color: '#FFFFFF'.color(),
                              weight: FontWeight.w900,
                              skWidth: 2,
                              skColor: '#41740A'.color(),
                            ),
                            ASStrokeText(
                              text: '\$${0.to2Double(widget.award * 2)}',
                              size: 28,
                              color: '#F7FF00'.color(),
                              weight: FontWeight.w900,
                              skWidth: 2,
                              skColor: '#41740A'.color(),
                            ),
                          ],
                        ),
                      )
                    : SizedBox(),
              ),
            ),

            SizedBox(height: 20.h),

            Visibility(
              visible: ASLocalProvider.instance.as_scrach_all_count >= 4,
              child: Opacity(
                opacity: _showAwardButton ? 1 : 0,

                child: ASUnderlineTextButton(
                  text: '\$${widget.award}',

                  underlineColor: '#FFFFFF'.color(),

                  fontSize: 20,
                ),
              ),
            ),
          ],
        ),

        Positioned(
          width: 0.width(context),

          bottom: 288.h,

          child: ASStrokeText(
            text: '\$${widget.award}',

            size: 48,

            color: '#FFFFFF'.color(),

            weight: FontWeight.w900,

            skWidth: 3,

            skColor: '#8A320C'.color(),
          ),
        ),

        Positioned(
          left: 30.w,
          bottom: 234.h,
          child: Visibility(
            visible: ASLocalProvider.instance.as_scrach_all_count >= 4,
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
                          TextSpan(text: '\$${ASLocalProvider.instance.as_dollar_number}'),
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
        ),
      ],
    );
  }
}

/// 宝箱引导
class ASBoxGuideDialog extends StatefulWidget {
  const ASBoxGuideDialog({super.key});

  @override
  State<ASBoxGuideDialog> createState() => ASBoxGuideDialogState();
}

class ASBoxGuideDialogState extends State<ASBoxGuideDialog>
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
        Positioned(
          left: 20.w,
          bottom: 88.h,
          child: ASImg(name: 'as_box_guide', width: 265, height: 89),
        ),
        ParticleButton(
          onTap: () {
            Navigator.pop(context, 0);
          },
          child: Positioned(
            left: 28.w,
            bottom: 20.h,
            child: ASSpine(
              path: 'treasure'.spinepaths(),
              width: 75,
              height: 80,
            ),
          ),
        ),
        ParticleButton(
          onTap: () {
            Navigator.pop(context, 0);
          },
          child: Positioned(
            left: 72.w,
            bottom: 12.h,
            child: ASSpine(path: 'shouzhi'.spinepaths(), width: 80, height: 80),
          ),
        ),
      ],
    );
  }
}

// 开宝箱
class ASBoxOpenDiaologWidget extends StatefulWidget {
  ASBoxOpenDiaologWidget({super.key});

  @override
  State<ASBoxOpenDiaologWidget> createState() => ASBoxOpenDiaologWidgetState();
}

class ASBoxOpenDiaologWidgetState extends State<ASBoxOpenDiaologWidget>
    with SingleTickerProviderStateMixin {
  var _showanimation = true;

  var _showBottom = false;

  var _openOne = false;

  var _openTwo = false;

  var _openThree = false;

  var _tap_index = 0;

  var doals_one = 20.00;

  var doals_two = 30.00;

  var doals_three = 40.00;

  var open_index = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    updateboxnumber();
    // sj_event_fire('box_pop', {});
  }

  Future<void> updateboxnumber() async {
    await ASLocalProvider.instance.updateint(
      ASLocalProvider.instance.as_box_indexName,
      0,
    );
  }

  Future<void> playbgMUsic() async {
    // SJAudioUtils().playAward3Audio();
    // Future.delayed(Duration(milliseconds: 1500), () async {
    //   await SJAudioUtils().stopAllTempAudio();
    //   await SJAudioUtils().playBGM();
    // });
  }

  openBox() async {
    // await SJAudioUtils().playBoxAudio();
    setState(() {
      _showBottom = true;
      _showanimation = false;
    });
    Future.delayed(Duration(milliseconds: 1200), () {
      // SJAudioUtils().stopAllTempAudio();
      // SJAudioUtils().playBGM();
      if (!mounted) return;
      setState(() {
        if (!_openOne) {
          _openOne = true;
        }
        if (!_openTwo) {
          _openTwo = true;
        }
        if (!_openThree) {
          _openThree = true;
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: SizedBox(
              width: 0.width(context),
              height: 0.height(context),
              child: Column(
                children: [
                  SizedBox(height: 120.h),
                  ASSpine(
                    path: 'congratulation'.spinepaths(),
                    width: 300.w,
                    height: 120.h,
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: _openOne && _tap_index == 0,
            child: Positioned(
              left: 10.w,
              top: 400.h,
              width: 180.0.w,
              height: 180.0.h,
              child: ASSpine(
                path: 'box_light'.spinepaths(),
                width: 180.w,
                height: 180.h,
              ),
            ),
          ),
          Visibility(
            visible: true,
            child: Positioned(
              left: 28.w,
              top: 428.h,
              width: 150.w,
              height: 130.h,
              child: ParticleButton(
                onTap: () {
                  open_index = doals_one;
                  _openOne = true;
                  _tap_index = 0;
                  openBox();
                },
                child: ASSpine(
                  path: _openOne == true
                      ? 'box_2'.spinepaths()
                      : 'box_1'.spinepaths(),
                  width: 150.w,
                  height: 130.h,
                  loop: _openOne == true ? false : true,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _openOne,
            child: Positioned(
              left: 70.w,
              top: 530.h,
              width: 150.0.w,
              height: 30.h,
              child: SizedBox(
                width: 120.0.w,
                height: 30.h,
                child: Row(
                  children: [
                    SizedBox(width: 0.w),
                    ASGradientNumberRoller(
                      value: doals_one,
                      duration: 1000,
                      fontSize: 20.0.sp,
                      gradientColors: ['#FFFFFF'.color(), '#FFFFFF'.color()],
                      borderColor: '#47118F'.color(),
                      borderWidth: 2.0,
                      decimalPlaces: 2, // 动态调整小数位
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: _openTwo && _tap_index == 1,
            child: Positioned(
              right: 20.w,
              top: 400.h,
              width: 180.0.w,
              height: 180.0.h,
              child: ASSpine(
                path: 'box_light'.spinepaths(),
                width: 180.w,
                height: 180.h,
              ),
            ),
          ),
          Visibility(
            visible: true,
            child: Positioned(
              right: 28.w,
              top: 428.h,
              width: 150.w,
              height: 130.h,
              child: ParticleButton(
                onTap: () {
                  open_index = doals_two;
                  _openTwo = true;
                  _tap_index = 1;
                  openBox();
                },
                child: ASSpine(
                  path: _openTwo == true
                      ? 'box_2'.spinepaths()
                      : 'box_1'.spinepaths(),
                  width: 150.w,
                  height: 130.h,
                  loop: _openTwo == true ? false : true,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _openTwo,
            child: Positioned(
              right: 30.w,
              top: 530.h,
              width: 150.0.w,
              height: 30.h,
              child: SizedBox(
                width: 120.0.w,
                height: 30.h,
                child: Row(
                  children: [
                    SizedBox(width: 44.w),
                    ASGradientNumberRoller(
                      value: doals_two,
                      duration: 1000,
                      fontSize: 20.0.sp,
                      gradientColors: ['#FFFFFF'.color(), '#FFFFFF'.color()],
                      borderColor: '#47118F'.color(),
                      borderWidth: 2.0,
                      decimalPlaces: 2, // 动态调整小数位
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: _openThree && _tap_index == 2,
            child: Positioned(
              right: (0.width(context) - 180.0.w) * 0.5,
              top: 248.h,
              width: 180.0.w,
              height: 180.0.h,
              child: ASSpine(
                path: 'box_light'.spinepaths(),
                width: 180.w,
                height: 180.h,
              ),
            ),
          ),
          Visibility(
            visible: true,
            child: Positioned(
              right: (0.width(context) - 150.0.w) * 0.5,
              top: 248.h,
              width: 150.w,
              height: 130.h,
              child: ParticleButton(
                onTap: () {
                  open_index = doals_three;
                  _openThree = true;
                  _tap_index = 2;
                  openBox();
                },
                child: ASSpine(
                  path: _openThree == true
                      ? 'box_2'.spinepaths()
                      : 'box_1'.spinepaths(),
                  width: 150.w,
                  height: 130.h,
                  loop: _openThree == true ? false : true,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _openThree,
            child: Positioned(
              right: (0.width(context) - 188.w) * 0.5,
              top: 388.h,
              width: 150.0.w,
              height: 30.h,
              child: SizedBox(
                width: 150.0.w,
                height: 30.h,
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    ASGradientNumberRoller(
                      value: doals_three,
                      duration: 1000,
                      fontSize: 20.0.sp,
                      gradientColors: ['#FFFFFF'.color(), '#FFFFFF'.color()],
                      borderColor: '#47118F'.color(),
                      borderWidth: 2.0,
                      decimalPlaces: 2, // 动态调整小数位
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showanimation,
            child: Positioned(
              left: 52.w,
              top: 562.h,
              width: 112.0.w,
              height: 36.0.h,
              child: ParticleButton(
                onTap: () {
                  open_index = doals_one;
                  _openOne = true;
                  _tap_index = 0;
                  openBox();
                },
                child: Container(
                  decoration: BoxDecoration(image: ASDImg('as_open_btn')),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showanimation,
            child: Positioned(
              right: 52.w,
              top: 562.h,
              width: 112.0.w,
              height: 36.0.h,
              child: ParticleButton(
                onTap: () {
                  open_index = doals_two;
                  _openTwo = true;
                  _tap_index = 1;
                  openBox();
                },
                child: Container(
                  decoration: BoxDecoration(image: ASDImg('as_open_btn')),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showanimation,
            child: Positioned(
              right: (0.width(context) - 112.0.w) * 0.5,
              top: 380.h,
              width: 112.0.w,
              height: 36.0.h,
              child: ParticleButton(
                onTap: () {
                  open_index = doals_three;
                  _openThree = true;
                  _tap_index = 2;
                  openBox();
                },
                child: Container(
                  decoration: BoxDecoration(image: ASDImg('as_open_btn')),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showBottom,
            child: ParticleButton(
              onTap: () {
                // sj_event_fire('box_pop_claim', {});
                // await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.sj_show_boxName,false);
                // SJJoyAds().sj_showAd(context, 'scxji_boxreward_rv', onCacheResponse: (onCacheResponse){
                //   if (!mounted)return;
                //   Navigator.of(context).pop(0);
                //   SJScratchNextNotificationService.sendToDomandNumberNotification(0);
                // }, adDidClosed: (adDidClosed) async {
                //   if (!context.mounted) return;
                Navigator.pop(context, 0);
                //   var value = doals_one + doals_two + doals_three;
                //   await ASLocalProvider.instance.updateint(ASLocalProvider.instance.sj_tx_box_indexName, ASLocalProvider.instance.sj_tx_box_index + 1);
                //   await ASLocalProvider.instance.updatedouble(ASLocalProvider.instance.sj_dolas_numberName, (value));
                //   playAwardmp3();
                //   showThreeTxTask();
                //   showFourTxTask();
                // });
              },
              child: Positioned(
                right: (0.width(context) - 260.w) * 0.5,
                top: 580.h,
                width: 262.0.w,
                height: 96.0.h,
                child: Container(
                  width: 262.0.w,
                  height: 96.0.h,
                  decoration: BoxDecoration(image: ASDImg('as_ad_btn')),
                  child: Stack(
                    children: [
                      Center(
                        child: ASStrokeText(
                          text:
                              'All + \$${(doals_one + doals_two + doals_three).toStringAsFixed(2)}',
                          size: 28,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w400,
                          skWidth: 2,
                          skColor: '#41740A'.color(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Visibility(
            visible: _showBottom,
            child: Positioned(
              right: (0.width(context) - 200) * 0.5,
              top: 680.h,
              width: 200.0,
              height: 52.0,
              child: ASUnderlineTextButton(
                text: 'Only \$${open_index.toStringAsFixed(2)}',
                fontSize: 20.sp,
                gradientColors: [
                  '#FFFFFF'.color(),
                  '#FFFFFF'.color(),
                  '#FFF6D7'.color(),
                  '#FFF0B4'.color(),
                ],
                underlineColor: '#FFFFFF'.color(),
                onPressed: () async {
                  // sj_event_fire('box_pop_claim', {});
                  // await ASLocalProvider.instance.updateBool(ASLocalProvider.instance.sj_show_boxName,false);
                  // if (SJNumberHelpers().checkProbability()){
                  //   SJJoyAds().sj_showAd(context, 'scxji_boxreward_int', onCacheResponse: (onCacheResponse){
                  //     if (!mounted)return;
                  //     Navigator.of(context).pop(0);
                  //     SJScratchNextNotificationService.sendToDomandNumberNotification(0);
                  //   }, adDidClosed: (adDidClosed) async {
                  //     if (!mounted)return;
                  //     Navigator.of(context).pop(0);
                  //     var value = 0.0;
                  //     if (_openOne){
                  //       value = doals_one;
                  //     } else if (_openTwo){
                  //       value = doals_two;
                  //     } else {
                  //       value = doals_three;
                  //     }
                  //     await ASLocalProvider.instance.updateint(ASLocalProvider.instance.sj_box_indexName, 0);
                  //     await ASLocalProvider.instance.updateint(ASLocalProvider.instance.sj_tx_box_indexName, ASLocalProvider.instance.sj_tx_box_index + 1);
                  //     await ASLocalProvider.instance.updatedouble(ASLocalProvider.instance.sj_dolas_numberName, (value));
                  //     playAwardmp3();
                  //     showThreeTxTask();
                  //     showFourTxTask();
                  //   });
                  // } else {
                  //   if (!mounted)return;
                  //   Navigator.of(context).pop(0);
                  //
                  //   var value = 0.0;
                  //   if (_openOne){
                  //     value = doals_one;
                  //   } else if (_openTwo){
                  //     value = doals_two;
                  //   } else {
                  //     value = doals_three;
                  //   }
                  //   await  ASLocalProvider.instance.updateint(ASLocalProvider.instance.sj_box_indexName, 0);
                  //   await ASLocalProvider.instance.updateint(ASLocalProvider.instance.sj_tx_box_indexName, ASLocalProvider.instance.sj_tx_box_index + 1);
                  //   await ASLocalProvider.instance.updatedouble(ASLocalProvider.instance.sj_dolas_numberName, (value));
                  //   playAwardmp3();
                  //   showThreeTxTask();
                  //   showFourTxTask();
                  // }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void playAwardmp3() {
    // WidgetsBinding.instance.addPostFrameCallback((_) async {
    //   await SJAudioUtils().playDolasAudio();
    //   Future.delayed(Duration(milliseconds: 1300), () async {
    //     await SJAudioUtils().stopAllTempAudio();
    //     if (ASLocalProvider.instance.sj_bg_music){
    //       await SJAudioUtils().playBGM();
    //     }
    //   });
    // });
  }
}

// 老用户宝箱
class ASBoxOldDiaologWidget extends StatefulWidget {
  ASBoxOldDiaologWidget({super.key});

  @override
  State<ASBoxOldDiaologWidget> createState() => ASBoxOldDiaologWidgetState();
}

class ASBoxOldDiaologWidgetState extends State<ASBoxOldDiaologWidget>
    with SingleTickerProviderStateMixin {
  var _showanimation = true;

  var _showBottom = false;

  var _openOne = false;

  var doals_one = 20.0;

  var open_index = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // sj_event_fire('box_pop_nu', {});
    updateboxnumber();
  }

  Future<void> updateboxnumber() async {
    await ASLocalProvider.instance.updateint(
      ASLocalProvider.instance.as_box_indexName,
      0,
    );
  }

  openBox() {
    // SJAudioUtils().playBoxAudio();
    Future.delayed(Duration(milliseconds: 1200), () {
      // SJAudioUtils().stopAllTempAudio();
      // SJAudioUtils().playBGM();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            child: SizedBox(
              width: 0.width(context),
              height: 0.height(context),
              child: Column(
                children: [
                  SizedBox(height: 120.h),
                  SizedBox(
                    width: 0.width(context),
                    height: 134.h,
                    child: Column(
                      children: [
                        SizedBox(height: 62.h),
                        ASGradientStrokeText(
                          text: randomTitle(),
                          gradientColors: [
                            '#FFFF10'.color(),
                            '#FF9D00'.color(),
                          ],
                          width: 335.w,
                          height: 48.h,
                          fontSize: 32,
                          strokeWidth: 2,
                          strokeColor: '#F50D53'.color(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Visibility(
            visible: true,
            child: Positioned(
              left: (0.width(context) - 280.w) * 0.5,
              top: 280.h,
              width: 280.0.w,
              height: 200.0.h,
              child: ParticleButton(
                onTap: () {
                  setState(() {
                    open_index = doals_one;
                    _openOne = true;
                  });
                  openBox();
                },
                child: ASSpine(
                  path: _openOne == true
                      ? 'box_old_2'.spinepaths()
                      : 'box_old_1'.spinepaths(),
                  loop: _openOne == true ? false : true,
                ),
              ),
            ),
          ),
          Visibility(
            visible: _openOne,
            child: Positioned(
              left: (0.width(context) - 120.w) * 0.5,
              top: 474.h,
              width: 200.0.w,
              height: 40.h,
              child: SizedBox(
                width: 200.0.w,
                height: 30.h,
                child: Row(
                  children: [
                    SizedBox(width: 10.w),
                    ASGradientNumberRoller(
                      value: doals_one,
                      duration: 1000,
                      fontSize: 32.0.sp,
                      gradientColors: ['#FFFFFF'.color(), '#FFFFFF'.color()],
                      borderColor: '#47118F'.color(),
                      borderWidth: 2.0,
                      decimalPlaces: 2, // 动态调整小数位
                    ),
                  ],
                ),
              ),
            ),
          ),
          Visibility(
            visible: true,
            child: Positioned(
              right: (0.width(context) - 262.w) * 0.5,
              top: 550.h,
              width: 262.0.w,
              height: 76.0.h,
              child: ParticleButton(
                onTap: () async {
                  // setState(() {
                  //   open_index = doals_one;
                  //   _openOne = true;
                  // });
                  // openBox();
                  // 直接给 不需要看ad
                  Navigator.pop(context, 0);
                },
                child: Container(
                  width: 262.w,
                  height: 84.h,
                  decoration: BoxDecoration(image: ASDImg('as_green_btn')),
                  child: Stack(
                    children: [
                      Positioned(
                        left: 60.w,
                        top: 20.h,
                        child: ASStrokeText(
                          text: _openOne == true
                              ? 'Claim \$$doals_one'
                              : 'Claim \$???',
                          size: 28,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w900,
                          skWidth: 2,
                          skColor: '#41740A'.color(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String randomTitle() {
    const titles = [
      "Ready！Set！ Cash！",
      "You've Got Mail!",
      "Lookin' Sharp!",
      "Claim Your Daily Bonus!",
      "Daily Wealth Moment！",
    ];

    return titles[Random().nextInt(titles.length)];
  }
}

// 获取美元动画
class ASGetDollarDiaologWidget extends StatefulWidget {
  final double award;
  const ASGetDollarDiaologWidget({super.key, required this.award});

  @override
  State<ASGetDollarDiaologWidget> createState() =>
      _ASGetDollarDiaologWidgetState();
}

class DollarItem {
  DollarItem({
    required this.start,
    required this.control,
    required this.size,
    required this.rotation,
    required this.delay,
    required this.duration,
  });

  final Offset start;

  final Offset control;

  final double size;

  final double rotation;

  final int delay;

  final int duration;

  /// 是否已经开始飞
  bool started = false;

  /// 是否已经结束
  bool finished = false;
}

class DollarStatus {
  DollarStatus({
    required this.position,
    required this.scale,
    required this.hide,
  });

  final Offset position;

  final double scale;

  final bool hide;
}

class _ASGetDollarDiaologWidgetState extends State<ASGetDollarDiaologWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;

  final Random random = Random();

  final List<DollarItem> items = [];

  static const int dollarCount = 20;

  /// 收集目标
  static const Offset target = Offset(50, 80);

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    controller.addListener(() {
      if (mounted) {
        setState(() {});
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      createDollar();
      setState(() {});
      // 显示100ms开始飞
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          controller.forward();
        }
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted && Navigator.canPop(context)) {
          Navigator.pop(context, 0);
        }
      }
    });
  }

  void createDollar() {
    items.clear();

    final size = MediaQuery.of(context).size;

    final center = Offset(size.width / 2, size.height / 2);

    /*
    美元堆形状

          4
        5 5
      6 6 6
    7 7 7 7
  8 8 8 8 8

  共30张
  */

    const rows = [2,3, 4, 5, 6];

    const double gapX = 25;

    const double gapY = 20;

    int index = 0;

    for (int row = 0; row < rows.length; row++) {
      int count = rows[row];

      double rowWidth = (count - 1) * gapX;

      double startX = center.dx - rowWidth / 2;

      double y = center.dy - 50 + row * gapY;

      for (int col = 0; col < count; col++) {
        double x = startX + col * gapX;

        // 轻微随机，让美元堆自然
        x += random.nextDouble() * 12 - 6;

        y += random.nextDouble() * 8 - 4;

        // 越下面越大
        double scale = 0.75 + row * 0.07 + random.nextDouble() * 0.08;

        // 固定旋转
        double rotate = (random.nextDouble() - 0.5) * 0.3;

        Offset control = Offset(
          (x + target.dx) / 2 + random.nextDouble() * 160 - 80,

          y - 150 - random.nextDouble() * 80,
        );

        items.add(
          DollarItem(
            start: Offset(x, y),

            control: control,

            size: scale,

            rotation: rotate,

            // 每张间隔30ms
            delay: index * 25,

            // 飞行时间
            duration: 380 + random.nextInt(80),
          ),
        );

        index++;
      }
    }
  }

  Offset bezier(Offset start, Offset control, Offset end, double t) {
    double one = 1 - t;

    return Offset(
      one * one * start.dx + 2 * one * t * control.dx + t * t * end.dx,

      one * one * start.dy + 2 * one * t * control.dy + t * t * end.dy,
    );
  }

  DollarStatus? getDollarStatus(DollarItem item) {
    int time = controller.lastElapsedDuration?.inMilliseconds ?? 0;

    // 还没有开始
    if (time < item.delay) {
      return null;
    }

    // 标记已经开始
    item.started = true;

    double progress = (time - item.delay) / item.duration;

    // 飞完
    if (progress >= 1) {
      item.finished = true;

      return DollarStatus(position: target, scale: 0, hide: true);
    }

    progress = Curves.easeOutCubic.transform(progress);

    Offset position = bezier(item.start, item.control, target, progress);

    return DollarStatus(
      position: position,
      scale: item.size * (1 - progress * 0.75),
      hide: false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,

      height: double.infinity,

      child: Stack(
        children: items.map((item) {
          final status = getDollarStatus(item);


// 已结束，不显示
          if(item.finished){
            return const SizedBox();
          }


// 未开始，显示小山
          if(status == null){
            return Positioned(
              left: item.start.dx - 40,
              top: item.start.dy - 25,
              child: Transform.rotate(
                angle:item.rotation,
                child:Transform.scale(
                  scale:item.size,
                  child:ASImg(
                    name:'as_dollars_icons',
                    width:72,
                    height:48,
                  ),
                ),
              ),
            );
          }
// 飞行中
          return Positioned(
            left:status.position.dx - 40,
            top:status.position.dy - 25,
            child:Transform.rotate(
              angle:item.rotation,
              child:Transform.scale(
                scale:status.scale,
                child:ASImg(
                  name:'as_dollars_icons',
                  width:72,
                  height:48,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();

    super.dispose();
  }
}
