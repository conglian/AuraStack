import 'dart:async';
import 'dart:math';
import 'package:aurastack/ASDialog/ASOther/ASOtherDialog.dart';
import 'package:aurastack/ASMainVC/ASCash.dart';
import 'package:aurastack/ASMainVC/ASScratch.dart';
import 'package:aurastack/ASMainVC/ASTask.dart';
import 'package:aurastack/ASTool/as_GradientText.dart';
import 'package:aurastack/ASTool/as_shine.dart';
import 'package:aurastack/ASTool/as_spine_tool.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../ASDialog/ASAward/ASAwardDialog.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';
import '../ASTool/as_stroke_text.dart';
import 'ASDice.dart';

final GlobalKey<AShomeState> homeKey = GlobalKey<AShomeState>();

class AShome extends StatefulWidget {
  AShome({super.key});

  @override
  State<AShome> createState() => AShomeState();
}

class AShomeState extends State<AShome> with SingleTickerProviderStateMixin {
  int shineIndex = 0;

  Timer? _shineTimer;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {});

    _shineTimer = Timer.periodic(const Duration(milliseconds: 1200), (_) {
      if (!mounted) return;

      setState(() {
        shineIndex++;

        if (shineIndex >= 6) {
          shineIndex = 0;
        }
      });
    });
  }

  @override
  void dispose() {
    _shineTimer?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didpop, result) {
        context.tipShow(ASWaitDialog());
      },
      child: Scaffold(
        body: Consumer<ASLocalProvider>(
          builder: (context, provider, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ASImg(
                  name: 'as_luanch_bg',
                  width: 0.width(context),
                  height: 0.height(context),
                ),
                ConstrainedBox(
                  constraints: BoxConstraints(minHeight: 0.height(context)),
                  child: Column(
                    children: [
                      SizedBox(height: 50.h),
                      Row(
                        children: [
                          SizedBox(width: 18.w),
                          Container(
                            width: 298.w,
                            height: 51.h,
                            decoration: BoxDecoration(
                              image: ASDImg('as_top_bg'),
                            ),
                            child: Stack(
                              children: [
                                Positioned(
                                  left: 13.w,
                                  top: 10,
                                  child: ASImg(
                                    name: 'as_dollar_icon',
                                    width: 38,
                                    height: 32,
                                  ),
                                ),
                                Positioned(
                                  right: 10.w,
                                  top: 9,
                                  child: ASImg(
                                    name: 'as_pp_0',
                                    width: 82,
                                    height: 32,
                                  ),
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
                                        TextSpan(text: '\$${provider.as_dollar_number}'),
                                        TextSpan(
                                          text: '/\$1000',
                                          style: TextStyle(
                                            color: '#0A8A33'.color(),
                                          ),
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
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_pro_1'),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 138 * 0.5,
                                          height: 11,
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(
                                              5.5,
                                            ),
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
                          Spacer(),
                          ParticleButton(
                            child: ASImg(
                              name: 'as_setting_icon',
                              width: 32,
                              height: 32,
                            ),
                            onTap: () {
                              context.tipShow2(ASGetDollarDiaologWidget(award: 20.0));
                            },
                          ),
                          SizedBox(width: 18.w),
                        ],
                      ),
                      SizedBox(height: 11.h),
                      ParticleButton(
                        onTap: (){
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => ASTask()),
                          );
                        },
                        child: Container(
                          width: 352.w,
                          height: 106.h,
                          decoration: BoxDecoration(
                            image: ASDImg('as_top_pot_bg'),
                          ),
                          child: Stack(
                            children: [
                              Positioned(
                                left: (352.w - 180) * 0.5,
                                bottom: 22,
                                child: Container(
                                  width: 180,
                                  height: 18,
                                  decoration: BoxDecoration(
                                    image: ASDImg('as_home_pro_0'),
                                  ),
                                  child: Stack(
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            width: 180 * 0.5,
                                            height: 18,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(
                                                9,
                                              ),
                                              color: '#FFEE38'.color(),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        width: 180,
                                        height: 18,
                                        child: Center(
                                          child: ASStrokeText(
                                            text: '1/3',
                                            size: 14,
                                            color: '#FFFFFF'.color(),
                                            weight: FontWeight.w900,
                                            skWidth: 1,
                                            skColor: '#000000'.color(),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 0,
                                right: 88.w,
                                child: ASImg(
                                  name: 'as_jackpot_icon',
                                  width: 58,
                                  height: 52,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: 11.h),
                      Row(
                        children: [
                          SizedBox(width: 12.w),
                          ASStrokeText(
                            text: 'Prize',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          SizedBox(width: 8.w),
                          ASImg(name: 'as_dollar_icon', width: 24, height: 24),
                          ASGradientStrokeText(
                            text: '7000',
                            gradientColors: [
                              '#FFE600'.color(),
                              '#FFFFFF'.color(),
                            ],
                            width: 70,
                            height: 24,
                            fontSize: 20,
                            strokeWidth: 1,
                            strokeColor: '#2A0FA6'.color(),
                          ),
                          Spacer(),
                          ASStrokeText(
                            text: 'Win Chance',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          SizedBox(width: 8.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_n', width: 24, height: 24),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          ParticleButton(
                            child: shineIndex == 0
                                ? ASShine(
                                    width: 121.w,
                                    height: 205.h,
                                    child: Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_0'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 50.w),
                                                  ASStrokeText(
                                                    text:
                                                        'X${10 - provider.as_scrach_end_number_0}',
                                                    size: 12,
                                                    color: '#FFFFFF'.color(),
                                                    weight: FontWeight.w900,
                                                    skWidth: 1,
                                                    skColor: '#000000'.color(),
                                                  ),
                                                  Spacer(),
                                                  ASImg(
                                                    name: 'as_add_s_icon',
                                                    width: 17,
                                                    height: 17,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 121.w,
                                    height: 205.h,
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_list_bg_0'),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 21.h,
                                          child: SizedBox(
                                            width: 102.w,
                                            height: 17.h,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 50.w),
                                                ASStrokeText(
                                                  text:
                                                      'X${10 - provider.as_scrach_end_number_0}',
                                                  size: 12,
                                                  color: '#FFFFFF'.color(),
                                                  weight: FontWeight.w900,
                                                  skWidth: 1,
                                                  skColor: '#000000'.color(),
                                                ),
                                                Spacer(),
                                                ASImg(
                                                  name: 'as_add_s_icon',
                                                  width: 17,
                                                  height: 17,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASScratch(type: 0)),
                              );
                            },
                          ),

                          ParticleButton(
                            child: shineIndex == 1
                                ? ASShine(
                                    width: 121.w,
                                    height: 205.h,
                                    child: Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_1'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 50.w),
                                                  ASStrokeText(
                                                    text:
                                                        'X${10 - provider.as_scrach_end_number_1}',
                                                    size: 12,
                                                    color: '#FFFFFF'.color(),
                                                    weight: FontWeight.w900,
                                                    skWidth: 1,
                                                    skColor: '#000000'.color(),
                                                  ),
                                                  Spacer(),
                                                  ASImg(
                                                    name: 'as_add_s_icon',
                                                    width: 17,
                                                    height: 17,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 121.w,
                                    height: 205.h,
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_list_bg_1'),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 21.h,
                                          child: SizedBox(
                                            width: 102.w,
                                            height: 17.h,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 50.w),
                                                ASStrokeText(
                                                  text:
                                                      'X${10 - provider.as_scrach_end_number_1}',
                                                  size: 12,
                                                  color: '#FFFFFF'.color(),
                                                  weight: FontWeight.w900,
                                                  skWidth: 1,
                                                  skColor: '#000000'.color(),
                                                ),
                                                Spacer(),
                                                ASImg(
                                                  name: 'as_add_s_icon',
                                                  width: 17,
                                                  height: 17,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASScratch(type: 1)),
                              );
                            },
                          ),
                          ParticleButton(
                            child: shineIndex == 2
                                ? ASShine(
                                    width: 121.w,
                                    height: 205.h,
                                    child: Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_2'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 50.w),
                                                  ASStrokeText(
                                                    text:
                                                        'X${10 - provider.as_scrach_end_number_2}',
                                                    size: 12,
                                                    color: '#FFFFFF'.color(),
                                                    weight: FontWeight.w900,
                                                    skWidth: 1,
                                                    skColor: '#000000'.color(),
                                                  ),
                                                  Spacer(),
                                                  ASImg(
                                                    name: 'as_add_s_icon',
                                                    width: 17,
                                                    height: 17,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 121.w,
                                    height: 205.h,
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_list_bg_2'),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 21.h,
                                          child: SizedBox(
                                            width: 102.w,
                                            height: 17.h,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 50.w),
                                                ASStrokeText(
                                                  text:
                                                      'X${10 - provider.as_scrach_end_number_2}',
                                                  size: 12,
                                                  color: '#FFFFFF'.color(),
                                                  weight: FontWeight.w900,
                                                  skWidth: 1,
                                                  skColor: '#000000'.color(),
                                                ),
                                                Spacer(),
                                                ASImg(
                                                  name: 'as_add_s_icon',
                                                  width: 17,
                                                  height: 17,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASScratch(type: 2)),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 18.h),
                      Row(
                        children: [
                          SizedBox(width: 12.w),
                          ASStrokeText(
                            text: 'Prize',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          SizedBox(width: 8.w),
                          ASImg(name: 'as_dollar_icon', width: 24, height: 24),
                          ASGradientStrokeText(
                            text: '7000',
                            gradientColors: [
                              '#FFE600'.color(),
                              '#FFFFFF'.color(),
                            ],
                            width: 70,
                            height: 24,
                            fontSize: 20,
                            strokeWidth: 1,
                            strokeColor: '#2A0FA6'.color(),
                          ),
                          Spacer(),
                          ASStrokeText(
                            text: 'Win Chance  ',
                            size: 16,
                            color: '#FFFFFF'.color(),
                            weight: FontWeight.w900,
                            skWidth: 1,
                            skColor: '#2A0FA6'.color(),
                          ),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 2.w),
                          ASImg(name: 'as_home_x_s', width: 24, height: 24),
                          SizedBox(width: 8.w),
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Row(
                        mainAxisAlignment: .center,
                        children: [
                          ParticleButton(
                            child: shineIndex == 3
                                ? ASShine(
                                    width: 121.w,
                                    height: 205.h,
                                    child: Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_3'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 50.w),
                                                  ASStrokeText(
                                                    text:
                                                        'X${10 - provider.as_scrach_end_number_3}',
                                                    size: 12,
                                                    color: '#FFFFFF'.color(),
                                                    weight: FontWeight.w900,
                                                    skWidth: 1,
                                                    skColor: '#000000'.color(),
                                                  ),
                                                  Spacer(),
                                                  ASImg(
                                                    name: 'as_add_s_icon',
                                                    width: 17,
                                                    height: 17,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 121.w,
                                    height: 205.h,
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_list_bg_3'),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 21.h,
                                          child: SizedBox(
                                            width: 102.w,
                                            height: 17.h,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 50.w),
                                                ASStrokeText(
                                                  text:
                                                      'X${10 - provider.as_scrach_end_number_3}',
                                                  size: 12,
                                                  color: '#FFFFFF'.color(),
                                                  weight: FontWeight.w900,
                                                  skWidth: 1,
                                                  skColor: '#000000'.color(),
                                                ),
                                                Spacer(),
                                                ASImg(
                                                  name: 'as_add_s_icon',
                                                  width: 17,
                                                  height: 17,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASScratch(type: 3)),
                              );
                            },
                          ),

                          ParticleButton(
                            child: shineIndex == 4
                                ? ASShine(
                                    width: 121.w,
                                    height: 205.h,
                                    child: Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_4'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 50.w),
                                                  ASStrokeText(
                                                    text:
                                                        'X${10 - provider.as_scrach_end_number_4}',
                                                    size: 12,
                                                    color: '#FFFFFF'.color(),
                                                    weight: FontWeight.w900,
                                                    skWidth: 1,
                                                    skColor: '#000000'.color(),
                                                  ),
                                                  Spacer(),
                                                  ASImg(
                                                    name: 'as_add_s_icon',
                                                    width: 17,
                                                    height: 17,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 121.w,
                                    height: 205.h,
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_list_bg_4'),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 21.h,
                                          child: SizedBox(
                                            width: 102.w,
                                            height: 17.h,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 50.w),
                                                ASStrokeText(
                                                  text:
                                                      'X${10 - provider.as_scrach_end_number_4}',
                                                  size: 12,
                                                  color: '#FFFFFF'.color(),
                                                  weight: FontWeight.w900,
                                                  skWidth: 1,
                                                  skColor: '#000000'.color(),
                                                ),
                                                Spacer(),
                                                ASImg(
                                                  name: 'as_add_s_icon',
                                                  width: 17,
                                                  height: 17,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASScratch(type: 4)),
                              );
                            },
                          ),

                          ParticleButton(
                            child: shineIndex == 5
                                ? ASShine(
                                    width: 121.w,
                                    height: 205.h,
                                    child: Container(
                                      width: 121.w,
                                      height: 205.h,
                                      decoration: BoxDecoration(
                                        image: ASDImg('as_home_list_bg_5'),
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            bottom: 21.h,
                                            child: SizedBox(
                                              width: 102.w,
                                              height: 17.h,
                                              child: Row(
                                                children: [
                                                  SizedBox(width: 50.w),
                                                  ASStrokeText(
                                                    text:
                                                        'X${10 - provider.as_scrach_end_number_5}',
                                                    size: 12,
                                                    color: '#FFFFFF'.color(),
                                                    weight: FontWeight.w900,
                                                    skWidth: 1,
                                                    skColor: '#000000'.color(),
                                                  ),
                                                  Spacer(),
                                                  ASImg(
                                                    name: 'as_add_s_icon',
                                                    width: 17,
                                                    height: 17,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : Container(
                                    width: 121.w,
                                    height: 205.h,
                                    decoration: BoxDecoration(
                                      image: ASDImg('as_home_list_bg_5'),
                                    ),
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 21.h,
                                          child: SizedBox(
                                            width: 102.w,
                                            height: 17.h,
                                            child: Row(
                                              children: [
                                                SizedBox(width: 50.w),
                                                ASStrokeText(
                                                  text:
                                                      'X${10 - provider.as_scrach_end_number_5}',
                                                  size: 12,
                                                  color: '#FFFFFF'.color(),
                                                  weight: FontWeight.w900,
                                                  skWidth: 1,
                                                  skColor: '#000000'.color(),
                                                ),
                                                Spacer(),
                                                ASImg(
                                                  name: 'as_add_s_icon',
                                                  width: 17,
                                                  height: 17,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASScratch(type: 5)),
                              );
                            },
                          ),
                        ],
                      ),
                      Spacer(),
                      Row(
                        mainAxisAlignment: .spaceAround,
                        children: [
                          ParticleButton(
                            child: ASSpine(
                              path: 'treasure'.spinepaths(),
                              width: 75,
                              height: 80,
                            ),
                            onTap: () {},
                          ),
                          ParticleButton(
                            child: ASSpine(
                              path: 'cash'.spinepaths(),
                              width: 126,
                              height: 80,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ASCash()),
                              );
                            },
                          ),
                          ParticleButton(
                            child: ASSpine(
                              path: 'dice'.spinepaths(),
                              width: 57,
                              height: 80,
                            ),
                            onTap: () {},
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
