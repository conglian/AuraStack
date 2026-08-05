import 'dart:math';
import 'package:aurastack/ASDialog/ASOther/ASOtherDialog.dart';
import 'package:aurastack/ASTool/as_GradientNumber.dart';
import 'package:aurastack/ASTool/as_GradientText.dart';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:spine_flutter/spine_widget.dart' as spine;
import '../ASDialog/ASCash/ASCashDialog.dart';
import '../ASTool/ASTBAEventTool.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';
import '../ASTool/as_stroke_text.dart';


class ASCash extends StatefulWidget {
  ASCash({super.key});

  @override
  State<ASCash> createState() => ASCashState();
}

class ASCashState extends State<ASCash>
    with SingleTickerProviderStateMixin {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ASLocalProvider>(
        builder: (context, provider, child) {
          return Stack(
            fit: StackFit.expand,
            children: [
              ASImg(
                name: 'as_cash_bg',
                width: 0.width(context),
                height: 0.height(context),
              ),
              ConstrainedBox(
                constraints: BoxConstraints(minHeight: 0.height(context)),
                child: Column(
                  children: [
                    SizedBox(height: 48.h),
                    Row(
                      children: [
                        SizedBox(width: 22.w),
                        ParticleButton(child: ASImg(name: 'as_back_icon', width: 33, height: 33), onTap: (){
                          Navigator.pop(context, 0);
                        }),
                        SizedBox(width: 120.w),
                        ASText(text: 'Cash', size: 20, color: '#FFFFFF'.color(), weight: FontWeight.w600)
                      ],
                    ),
                    SizedBox(height: 100.h,),
                    ASGradientNumberRoller(value: 0.to2Double(provider.as_dollar_number), fontSize: 64, duration: 2),
                    SizedBox(height: 80.h),
                    getWidtNomale(provider),
                    Visibility(child: SizedBox(height: 20.h,)),
                    Visibility(child: getTXRankWidget(provider)),
                    Spacer(),
                    ParticleButton(child: Container(
                      width: 339,
                      height: 50,
                      decoration: BoxDecoration(
                          image: ASDImg('as_zi_btn_bg')
                      ),
                      child: Center(
                        child: ASText(text: 'Withdrawal', size: 24, color: '#FFFFFF'.color(), weight: FontWeight.w600),
                      ),
                    ), onTap: (){
                      context.tipShow(ASCashOutDialog());
                    }),
                    SizedBox(height: 55.h)
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget getTXRankWidget(ASLocalProvider provider){
    return Container(
      width: 339.w,
      height: 120.h,
      decoration: BoxDecoration(
          image: ASDImg('as_tx_bg_act_0')
      ),
      child: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: 15.h),
              Row(
                children: [
                  SizedBox(width: 14.w),
                  ASText(text: '\$ 1000', size: 32, color: provider.as_tx_ing_account == 0 ? '#1C4779'.color() : '#1C7931'.color(), weight: FontWeight.w600),
                  Spacer(),
                  ParticleButton(child: Container(
                    width: 119,
                    height: 33,
                    decoration: BoxDecoration(
                        image: ASDImg('as_zi_s_btn')
                    ),
                    child: Center(
                      child: ASText(text: 'Cut In', size: 16, color: '#FFFFFF'.color(), weight: FontWeight.w600),
                    ),
                  ), onTap: (){

                  }),
                  SizedBox(width: 14.w),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                width: 304.w,
                height: 16.h,
                decoration: BoxDecoration(
                    color: '#C0BFCA'.color(),
                    borderRadius: BorderRadius.circular(8)
                ),
                child: Stack(
                  children: [
                    Positioned(left: 2.w,top: 2.h,child:
                    Container(
                      width: 300.w * 0.5,
                      height: 12.h,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.h),
                          color: '#4045D8'.color()
                      ),
                    )),
                    Center(
                      child: ASStrokeText(text: '50%', size: 12, color: '#FFD000'.color(), weight: FontWeight.w600, skWidth: 1, skColor: '#000000'.color()),
                    )
                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  SizedBox(width: 20.w),
                  ASText(text: 'Payment Within 7-14 Business Days', size: 12, color:'#A4A4A4'.color(), weight: FontWeight.w200)
                ],
              ),
            ],
          ),
          Positioned(right: 8.w,top: 8.h,child: ASImg(name: 'as_ads_icon', width: 32, height: 32))
        ],
      ),
    );
  }

  Widget getWidtNomale(ASLocalProvider provider){
    if (provider.as_dollar_number < 1000){
      return Container(
        width: 347.w,
        height: 217.h,
        decoration: BoxDecoration(
            image: ASDImg(provider.as_tx_ing_account == 0 ? 'as_cash_center_2' : 'as_cash_center_1')
        ),
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Row(
              children: [
                Spacer(),
                SizedBox(
                  width: 126,
                  height: 32,
                  child: ParticleButton(child: Center(child: ASText(text: 'In Progress', size: 16, color: '#FFFFFF'.color(), weight: FontWeight.w600)), onTap: (){

                  }),
                ),
                SizedBox(width: 24.w)
              ],
            ),
            SizedBox(height: 20.h),
            Row(
              children: [
                SizedBox(width: 11.w),
                ASText(text: '\$ 1000', size: 32, color: provider.as_tx_ing_account == 0 ? '#1C4779'.color() : '#1C7931'.color(), weight: FontWeight.w600)
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                SizedBox(width: 11.w),
                ASText(text: 'Risk Monitoring', size: 14, color: '#000000'.color(), weight: FontWeight.w600)
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                SizedBox(width: 11.w),
                SizedBox(width: 328, height: 32,child: ASText(text: "Abnormal activity detected on youraccount.Complete the task to verify you're a real person.", size: 12, color: '#837888'.color(), weight: FontWeight.w500, maxLines: 2))
              ],
            ),
            SizedBox(height: 17.h,),
            Row(
              children: [
                SizedBox(width: 22.w),
                ASImg(name: 'as_tx_box_icon', width: 46, height: 46),
                SizedBox(width: 13.w),
                ASText(text: 'Chests：0/10 Treasure Chests', size: 14, color: '#000000'.color(), weight: FontWeight.w600)
              ],
            )
          ],
        ),
      );
    }
    return Container(
      width: 347.w,
      height: 217.h,
      decoration: BoxDecoration(
          image: ASDImg('as_cash_center_0')
      ),
      child: Column(
        children: [
          SizedBox(height: 16.h,),
          ASText(text: 'Withdrawal Instructions', size: 16, color: '#FFFFFF'.color(), weight: FontWeight.w600),
          SizedBox(height: 25.h,),
          SizedBox(
            width: 347.w - 48.w,
            height: 38,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: text_fontName,
                    color: '#4A474B'.color()
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'For Security,\nThe Minimum Withdrawal is  ',
                  ),
                  TextSpan(
                    text: '\$1000',
                    style: TextStyle(color: '#1C7931'.color(),fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 42.h,),
          SizedBox(
            width: 347.w - 92.w,
            height: 38,
            child: RichText(
              textAlign: TextAlign.left,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 14.0,
                    fontWeight: FontWeight.w600,
                    fontFamily: text_fontName,
                    color: '#000000'.color()
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\$${0.to2Double(1000 - provider.as_dollar_number)}',
                    style: TextStyle(color: '#D86B0B'.color(),fontSize: 14),
                  ),
                  TextSpan(
                    text: ' More Needed To Withdraw ',
                  ),
                  TextSpan(
                    text: '\$1000.',
                    style: TextStyle(color: '#1C7931'.color(),fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Container(
            width: 304,
            height: 16,
            decoration: BoxDecoration(
                color: '#C0BFCA'.color(),
                borderRadius: BorderRadius.circular(8)
            ),
            child: Stack(
              children: [
                Positioned(left: 2,top: 2,child:
                Container(
                  width: 300 * 0.5,
                  height: 12,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: '#4045D8'.color()
                  ),
                )),
                Center(
                  child: ASStrokeText(text: '\$${provider.as_dollar_number}/\$1000', size: 12, color: '#FFFFFF'.color(), weight: FontWeight.w600, skWidth: 1, skColor: '#000000'.color()),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

}
