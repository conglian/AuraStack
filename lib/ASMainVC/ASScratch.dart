  import 'dart:math';
  import 'package:aurastack/ASTool/ASLocalImageScratchCard.dart';
  import 'package:aurastack/ASTool/as_spine_tool.dart';
  import 'package:aurastack/ASTool/as_text.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:provider/provider.dart';
  import '../ASDialog/ASAward/ASAwardDialog.dart';
  import '../ASTool/as_LocalProvider.dart';
  import '../ASTool/as_extension_help.dart';
  import '../ASTool/as_img.dart';
  import '../ASTool/as_stroke_text.dart';
  import 'ASCash.dart';

  class ASScratch extends StatefulWidget {
    final int type;
    ASScratch({super.key, required this.type});

    @override
    State<ASScratch> createState() => ASScratchState();
  }

  class ASScratchState extends State<ASScratch> with TickerProviderStateMixin {

    bool scractch_end_animation = false;

    bool auto_scrach = false;

    @override
    void initState() {
      super.initState();
    }

    @override
    void dispose() {
      super.dispose();
    }

    String getTopSpineName(){
      String name = 'candyrush'.spinepaths();
      if (widget.type == 0){
        name = 'extrabonus'.spinepaths();
      } else if (widget.type == 1){
        name = 'candyrush'.spinepaths();
      } else if (widget.type == 2){
        name = 'sweettime'.spinepaths();
      } else if (widget.type == 3){
        name = 'triple777'.spinepaths();
      } else if (widget.type == 4){
        name = 'fortunerush'.spinepaths();
      } else if (widget.type == 5){
        name = '50x'.spinepaths();
      }
      return name;
    }

    int getTopdollarName(){
      int dollars = 50;
      if (widget.type == 0){
        dollars = 50;
      } else if (widget.type == 1){
        dollars = 60;
      } else if (widget.type == 2){
        dollars = 70;
      } else if (widget.type == 3){
        dollars = 80;
      } else if (widget.type == 4){
        dollars = 90;
      } else if (widget.type == 5){
        dollars = 100;
      }
      return dollars;
    }


    @override
    Widget build(BuildContext context) {
      return Scaffold(
        backgroundColor: Colors.transparent,
        body: Consumer<ASLocalProvider>(
          builder: (context, provider, child) {
            return Stack(
              fit: StackFit.expand,
              children: [
                ASImg(name: 'as_scratch_bgs_${widget.type}', width: 0.width(context), height: 0.height(context)),
                Column(
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
                            name: 'as_home_btn',
                            width: 36,
                            height: 36,
                          ),
                          onTap: () {
                            Navigator.pop(context, 0);
                          },
                        ),
                        SizedBox(width: 18.w),
                      ],
                    ),
                    SizedBox(height: 17.28.h,),
                    ASCardSwapAnimator(key: getkey(), child: getScrachCardBg()),
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
                          child: ASImg(name: 'as_reall_btn', width: 197.w, height: 65.h,),
                          onTap: () {
                            if (!auto_scrach){
                              auto_scrach = true;
                              ASScratchUpdateNotificationService.sendToDomandNumberNotification(1);
                              Future.delayed(Duration(milliseconds: 3000),(){
                                if (!mounted) return;
                                auto_scrach = false;
                              });
                            }
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
                )
              ],
            );
          },
        ),
      );
    }

    GlobalKey getkey(){
      if (widget.type == 0){
        return swapKey1;
      } else if (widget.type == 1){
        return swapKey2;
      } else if (widget.type == 2){
        return swapKey3;
      } else if (widget.type == 3){
        return swapKey4;
      } else if (widget.type == 4){
        return swapKey5;
      } else {
        return swapKey6;
      }
    }

    double getautosctratchTopH(){
      double toph = 0;
      return toph;
    }

    Widget getScrachCardBg(){
      return  Stack(
        children: [
          Container(
            width: 361.w,
            height: 589.h,
            decoration: BoxDecoration(
                image: ASDImg('as_scratch_center_bg_${widget.type}')
            ),
            child: Column(
              children: [
                SizedBox(height: 0.h),
                ASSpine(path: getTopSpineName(), width: 330.w, height: 90.h),
                Row(
                  mainAxisAlignment: .center,
                  children: [
                    ASStrokeText(text: 'Top Prize ', size: 20, color: '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#096898'.color()),
                    ASStrokeText(text: '\$${getTopdollarName()} ', size: 20, color: '#FFE600'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#096898'.color()),
                  ],
                ),
                if (widget.type == 0)
                  SizedBox(height: 75.h,),
                if (widget.type == 3)
                  SizedBox(height: 38.h,),
                if (widget.type == 4)
                  SizedBox(height: 48.h,),
                if (widget.type == 2)
                  SizedBox(height: 48.h,),
                if (widget.type != 3 && widget.type != 4 && widget.type != 2 && widget.type != 0)
                  SizedBox(height: 63.h),
                ASLocalImageScratchCard(autoStartY: getautosctratchTopH(),onScratchEnd: (){
                  setState(() {
                    scractch_end_animation = true;
                  });
                  scrachEndDialog();
                },coverImagePath: 'as_scratch_bg_${widget.type}'.image(), contentW: 313.w, contentH: 313.w, child: Container(
                    width: 313.w,
                    height: 313.w,
                    decoration: BoxDecoration(
                        image: ASDImg('as_scratch_center_${widget.type}')
                    ),
                    child: Stack(
                      children: [
                        getScrachContentWidget(),
                        Visibility(visible: scractch_end_animation && widget.type == 2,child: ASImg(name: 'as_scratch_end_2_bg',
                          width: 361.w,
                          height: 589.h,)),
                        Visibility(visible: scractch_end_animation && widget.type == 2,child: SizedBox(
                          width: 361.w,
                          height: 589.h,
                          child: Column(
                            mainAxisAlignment: .spaceEvenly,
                            children: [
                              ASImg(name: 'as_scratch_nowin_0', width: 273.w, height: 78.h,),
                              ASImg(name: 'as_scratch_nowin_1', width: 197.w, height: 25.h,),
                            ],
                          ),
                        ))
                      ],
                    )
                ))
              ],
            ),
          ),
        ],
      );
    }

    Widget getScrachContentWidget(){
      if (widget.type == 0){
        return Column(
          children: [
            Container(
              width: 311.w,
              height: 72.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.h),
                  color: scractch_end_animation == true ? '#000000'.color(opacity: 0.5) : Colors.transparent
              ),
              child: Row(
                mainAxisAlignment: .spaceAround,
                children: [
                  ASBouncyText(text: '20', fontSize: 40, color: '#000000'.color(),enableAnimation: scractch_end_animation),
                  ASBouncyText(text: '30', fontSize: 40, color: '#000000'.color(),enableAnimation: scractch_end_animation),
                  ASBouncyText(text: '50', fontSize: 40, color: '#FFFFFF'.color(),enableAnimation: scractch_end_animation),
                  ASBouncyText(text: '60', fontSize: 40, color: '#FFFFFF'.color(),enableAnimation: scractch_end_animation),
                ],
              ),
            ),
            SizedBox(height: 34.h),
            Container(
              width: 311.w,
              height: 198.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.h),
                  color: scractch_end_animation == true ? '#000000'.color(opacity: 0.5) : Colors.transparent
              ),
              child: Stack(
                children: [
                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4, // 一行5个
                      mainAxisSpacing: 0, // 垂直间距
                      crossAxisSpacing: 0, // 水平间距
                      childAspectRatio: (311.w / 4) / (198.h / 3), // 宽高比
                    ),
                    itemCount: 12,
                    padding: EdgeInsets.only(top: 0.h, left: 0.w), // 移除默认的padding// 最多显示10个
                    itemBuilder: (context, index) {
                      return Column(
                        children: [
                          ASBouncyText(text: '23', fontSize: 32, color: '#162333'.color(), enableAnimation: scractch_end_animation),
                          ASBouncyText(text: '\$20.02', fontSize: 20, color: '#11853C'.color(), enableAnimation: scractch_end_animation)
                        ],
                      );
                    },
                  ),
                  Visibility(visible: true,child: SizedBox(
                    width: 311.w,
                    height: 198.h,
                    child: Column(
                      mainAxisAlignment: .spaceEvenly,
                      children: [
                        ASImg(name: 'as_scratch_nowin_0', width: 273.w, height: 78.h,),
                        ASImg(name: 'as_scratch_nowin_1', width: 197.w, height: 25.h,),
                      ],
                    ),
                  ))
                ],
              ),
            )
          ],
        );
      } else if (widget.type == 1){
        return SizedBox(
          width: 311.w,
          child: Column(
            children: [
              SizedBox(height: 30.h),
              ASBouncyText(text: '\$30.20', fontSize: 36, color: '#44128F'.color(), enableAnimation: scractch_end_animation),
              SizedBox(height: 16.h),
              Container(
                width: 293.w,
                height: 202.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8.h),
                    color: scractch_end_animation == true ? '#000000'.color(opacity: 0.5) : Colors.transparent
                ),
                child: Stack(
                  children: [
                    GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, // 一行5个
                        mainAxisSpacing: 0, // 垂直间距
                        crossAxisSpacing: 0, // 水平间距
                        childAspectRatio: (293.w / 3) / (202.h / 3), // 宽高比
                      ),
                      itemCount: 9,
                      padding: EdgeInsets.only(top: 0.h, left: 0.w), // 移除默认的padding// 最多显示10个
                      itemBuilder: (context, index) {
                        return Column(
                          children: [
                            ASBouncyImage(imagePath: 'as_scartch_data_0_n', width: (293.w / 3), height: (202.h / 3), enableAnimation: scractch_end_animation)
                          ],
                        );
                      },
                    ),
                    Visibility(visible: true,child: SizedBox(
                      width: 293.w,
                      height: 202.h,
                      child: Column(
                        mainAxisAlignment: .spaceEvenly,
                        children: [
                          ASImg(name: 'as_scratch_nowin_0', width: 273.w, height: 78.h,),
                          ASImg(name: 'as_scratch_nowin_1', width: 197.w, height: 25.h,),
                        ],
                      ),
                    ))
                  ],
                ),
              )
            ],
          ),
        );
      } else if (widget.type == 2){
        return SizedBox(
          width: 313.w,
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: .center,
                children: [
                  SizedBox(height: 48.h),
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ASText(text: '25', size: 24, color: '#FFDF27'.color(), weight: FontWeight.w900),
                    ],
                  ),
                  SizedBox(height: 25.h),
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ASText(text: '25', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                    ],
                  ),
                  SizedBox(height: 27.h),
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ASText(text: '25', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                      SizedBox(width: 38.w),
                      ASText(text: '32', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                    ],
                  ),
                  SizedBox(height: 27.h),
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ASText(text: '25', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                      SizedBox(width: 38.w),
                      ASBouncyImage(imagePath: 'as_dangao_icon', width: 24, height: 24, enableAnimation: scractch_end_animation),
                      // ASText(text: '32', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                      SizedBox(width: 38.w),
                      ASText(text: '38', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                    ],
                  ),
                  SizedBox(height: 34.h),
                  Row(
                    mainAxisAlignment: .center,
                    children: [
                      ASText(text: '25', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                      SizedBox(width: 38.w),
                      ASText(text: '32', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                      SizedBox(width: 38.w),
                      ASText(text: '38', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                      SizedBox(width: 38.w),
                      ASText(text: '40', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900),
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      } else if (widget.type == 3){
        return Stack(
          children: [
            Container(
              width: 313.w,
              height: 294.h,
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.h),
                  color: scractch_end_animation == true ? '#000000'.color(opacity: 0.5) : Colors.transparent
              ),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 4, // 一行5个
                  mainAxisSpacing: 0, // 垂直间距
                  crossAxisSpacing: 0, // 水平间距
                  childAspectRatio: (313.w / 4) / (294.h / 3), // 宽高比
                ),
                itemCount: 12,
                padding: EdgeInsets.only(top: 0.h, left: 20.w), // 移除默认的padding// 最多显示10个
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Column(
                        mainAxisAlignment: .center,
                        children: [
                          ASText(text: '20', size: 32, color: '#0D2A7B'.color(), weight: FontWeight.w900),
                          // ASBouncyImage(imagePath: 'as_scartch_data_3_1', width: 51, height: 39, enableAnimation: scractch_end_animation),
                          ASBouncyChild(enableAnimation: scractch_end_animation, child: ASStrokeText(text: '\$20.32', size: 20, color: '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 1, skColor: '#081E5D'.color())),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Visibility(visible: scractch_end_animation,child: SizedBox(
              width: 313.w,
              height: 294.h,
              child: Column(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  ASImg(name: 'as_scratch_nowin_0', width: 273.w, height: 78.h,),
                  ASImg(name: 'as_scratch_nowin_1', width: 197.w, height: 25.h,),
                ],
              ),
            ))
          ],
        );
      } else if (widget.type == 4){
        return Container(
          width: 313.w,
          height: 300.h,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15.h),
              color: scractch_end_animation == true ? '#000000'.color(opacity: 0.5) : Colors.transparent
          ),
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: 34.h),
                  ASBouncyChild(enableAnimation: scractch_end_animation, child: ASStrokeText(text: '14', size: 32, color: '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color())),
                  SizedBox(height: 33.h),
                  Row(
                    children: [
                      SizedBox(width: 20.w),
                      Container(
                        width: 190.w,
                        height: 180.w,
                        decoration: BoxDecoration(
                            color: Colors.transparent
                        ),
                        child: GridView.builder(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3, // 一行5个
                            mainAxisSpacing: 0, // 垂直间距
                            crossAxisSpacing: 0, // 水平间距
                            childAspectRatio: (190.w / 3) / (180.w / 4), // 宽高比
                          ),
                          itemCount: 12,
                          padding: EdgeInsets.only(top: 0.h, left: 0.w), // 移除默认的padding// 最多显示10个
                          itemBuilder: (context, index) {
                            return Column(
                              mainAxisAlignment: .center,
                              children: [
                                Container(width: (190.w / 3),height: (180.w / 4),decoration: BoxDecoration(
                                    color: index == 1 ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.h)
                                ),child: ASBouncyText(text: '20', fontSize: 24, color: index == 1 ? '#B92323'.color() : '#333333'.color(), enableAnimation: scractch_end_animation))
                              ],
                            );
                          },
                        ),
                      ),
                      SizedBox(
                        width: 80.w,
                        height: 180.w,
                        child: Column(
                          mainAxisAlignment: .spaceAround,
                          children: [
                            Container(width: 80.w,height: 180.w / 4,decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation, child: ASStrokeText(text: '\$30.23', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                            Container(width: 80.w,height: 180.w / 4,decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation, child: ASStrokeText(text: '\$38.23', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                            Container(width: 80.w,height: 180.w / 4,decoration: BoxDecoration(
                                color: Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation, child: ASStrokeText(text: '\$34.23', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                            Container(width: 80.w,height: 180.w / 4,decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation, child: ASStrokeText(text: '\$88.23', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              Visibility(visible: scractch_end_animation,child: SizedBox(
                width: 313.w,
                height: 300.h,
                child: Column(
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    ASImg(name: 'as_scratch_nowin_0', width: 273.w, height: 78.h,),
                    ASImg(name: 'as_scratch_nowin_1', width: 197.w, height: 25.h,),
                  ],
                ),
              ))
            ],
          ),
        );
      } else if (widget.type == 5){
        return SizedBox(
          width: 311.w,
          height: 337.h,
          child: Stack(
            children: [
              Column(
                children: [
                  SizedBox(height: scractch_end_animation ? 47.h : 58.h),
                  Padding(padding: EdgeInsetsGeometry.only(left: 4.w),child: ASImg(name: 'as_scratch_data_top_1', width: scractch_end_animation ? 60.w : 70.w, height: scractch_end_animation ? 60.w : 37.h)),
                  SizedBox(height: 34.h),
                  Container(
                    width: 311.w,
                    height: 158.h,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15.h),
                        color: scractch_end_animation == true ? '#000000'.color(opacity: 0.5) : Colors.transparent
                    ),
                    child: GridView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 4, // 一行5个
                        mainAxisSpacing: 0, // 垂直间距
                        crossAxisSpacing: 0, // 水平间距
                        childAspectRatio: (311.w / 4) / (158.w / 2), // 宽高比
                      ),
                      itemCount: 8,
                      padding: EdgeInsets.only(top: 0.h, left: 0.w), // 移除默认的padding// 最多显示10个
                      itemBuilder: (context, index) {
                        return Column(
                          mainAxisAlignment: .center,
                          children: [
                            Container(width: 80.w,height: 60.h,decoration: BoxDecoration(
                                color: index == 1 && scractch_end_animation ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: Column(
                              children: [
                                SizedBox(height: 8.h),
                                if (index == 1)
                                  ASBouncyImage(enableAnimation: scractch_end_animation,imagePath: 'as_scractch_data_5_20', width: 60, height: 32),
                                if (index != 1)
                                  ASBouncyImage(enableAnimation: scractch_end_animation,imagePath: 'as_scractch_data_5_3', width: 42, height: 42),
                                if (index == 1)
                                  SizedBox(height: 8.h),
                                ASBouncyChild(enableAnimation: scractch_end_animation,child: ASStrokeText(text: '\$30.44', size: 18, color: '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#180D74'.color())),
                              ],
                            ))
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
              Visibility(visible: scractch_end_animation,child: SizedBox(
                width: 313.w,
                height: 337.h,
                child: Column(
                  mainAxisAlignment: .spaceEvenly,
                  children: [
                    ASImg(name: 'as_scratch_nowin_0', width: 273.w, height: 78.h,),
                    ASImg(name: 'as_scratch_nowin_1', width: 197.w, height: 25.h,),
                  ],
                ),
              ))
            ],
          ),

        );
      }
      return SizedBox();
    }

    void scrachEndDialog(){
      Future.delayed(Duration(milliseconds: 2000),(){
        if (!mounted) return;
        setState(() {
          scractch_end_animation = false;
        });
        ASScratchUpdateNotificationService.sendToDomandNumberNotification(0);
        if (widget.type == 0){
          swapKey1.currentState?.runSwap(getScrachCardBg());
        } else if (widget.type == 1){
          swapKey2.currentState?.runSwap(getScrachCardBg());
        } else if (widget.type == 2){
          swapKey3.currentState?.runSwap(getScrachCardBg());
        } else if (widget.type == 3){
          swapKey4.currentState?.runSwap(getScrachCardBg());
        } else if (widget.type == 4){
          swapKey5.currentState?.runSwap(getScrachCardBg());
        } else if (widget.type == 5){
          swapKey6.currentState?.runSwap(getScrachCardBg());
        }
      });
    }
  }


