import 'dart:math';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';
import '../ASTool/as_stroke_text.dart';

class ASTask extends StatefulWidget {
  ASTask({super.key});

  @override
  State<ASTask> createState() => ASTaskState();
}

class ASTaskState extends State<ASTask> with TickerProviderStateMixin {

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
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ASLocalProvider>(
        builder: (context, provider, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ASImg(name: 'as_task_bg', width: 0.width(context), height: 0.height(context)),
              Column(
                children: [
                  SizedBox(height: 48.h),
                  Row(
                    children: [
                      SizedBox(width: 22.w),
                      ParticleButton(child: ASImg(name: 'as_back_icon', width: 33, height: 33), onTap: (){
                        Navigator.pop(context, 0);
                      }),
                    ],
                  ),
                  SizedBox(height: 150.h),
                  Container(
                    width: 351.w,
                    height: 64.h,
                    decoration: BoxDecoration(
                      image: ASDImg('as_task_center_bgs')
                    ),
                    child: Stack(
                      children: [
                        Positioned(
                          left: (351.w - 246) * 0.5,
                          top: 22.h,
                          child: Container(
                            width: 246,
                            height: 18,
                            decoration: BoxDecoration(
                              image: ASDImg('as_home_pro_0'),
                            ),
                            child: Stack(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      width: 246 * 0.5,
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
                                  width: 246,
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
                          bottom: 12.h,
                          right: 58.w,
                          child: ASImg(
                            name: 'as_jackpot_icon',
                            width: 52,
                            height: 48,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: 0.width(context),
                    height: 460.h,
                    child: ListView.builder(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: 5,
                      itemBuilder: (_, index) {
                        return Center(
                          child: Container(
                            width: 351.w,
                            height: 80.h,
                            decoration: BoxDecoration(
                                image: ASDImg('as_task_center_1')
                            ),
                            child: getCellwidget(index),
                          ),
                        );
                      },
                    ),
                  )
                ],
              )
            ],
          );
        },
      ),
    );
  }
  Widget getCellwidget(int index){
    return Row(
      children: [
        SizedBox(width: 11.w),
        ASImg(name: 'as_task_wheel', width: 52, height: 50),
        SizedBox(width: 9.w),
        Column(
          children: [
            SizedBox(height: 17.h),
            ASText(text: 'tasktasktask', size: 20, color: '#642C1B'.color(), weight: FontWeight.w900),
            Container(
              width: 108.w,
              height: 18.h,
              decoration: BoxDecoration(
                color: '#D6D2B7'.color(),
                borderRadius: BorderRadius.circular(9.h)
              ),
              child: Stack(
                children: [
                  Container(
                    width: 108.w * 0.3,
                    height: 18.h,
                    decoration: BoxDecoration(
                        color: '#39A43B'.color(),
                        borderRadius: BorderRadius.circular(9.h)
                    ),
                  ),
                  Center(
                    child: ASStrokeText(text: '1/3', size: 14, color: '#FFFFFF'.color(), weight: FontWeight.w700, skWidth: 1, skColor: '#000000'.color()),
                  )
                ],
              ),
            ),
          ],
        ),
        Spacer(),
        SizedBox(
          width: 120.w,
          height: 80.h,
          child: Column(
            children: [
              SizedBox(height: 11.h),
              Row(
                mainAxisAlignment: .spaceEvenly,
                children: [
                  ASImg(name: 'as_doaller_wheel', width: 28, height: 28),
                  ASStrokeText(text: '100', size: 20, color: '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#7D3F1A'.color())
                ],
              ),
              SizedBox(height: 3.h),
              ParticleButton(child: ASImg(name: 'as_task_go', width: 94.w, height: 31.h,), onTap: (){

              }),
              
            ],
          ),
        )
      ],
    );
  }
}


