  import 'dart:math';
  import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/ASLocalImageScratchCard.dart';
  import 'package:aurastack/ASTool/as_spine_tool.dart';
  import 'package:aurastack/ASTool/as_text.dart';
  import 'package:flutter/material.dart';
  import 'package:flutter_screenutil/flutter_screenutil.dart';
  import 'package:provider/provider.dart';
  import '../ASDialog/ASAward/ASAwardDialog.dart';
  import '../ASModel/ASGameProgressModel.dart';
import '../ASTool/ASLogger.dart';
import '../ASTool/as_LocalProvider.dart';
  import '../ASTool/as_extension_help.dart';
  import '../ASTool/as_img.dart';
  import '../ASTool/as_stroke_text.dart';
import 'ASDice.dart';

  class ASScratch extends StatefulWidget {
    final int type;
    ASScratch({super.key, required this.type});

    @override
    State<ASScratch> createState() => ASScratchState();
  }

  class ASScratchState extends State<ASScratch> with TickerProviderStateMixin {

    bool scractch_end_animation = false;

    bool auto_scrach = false;

    final GlobalKey _bottomDiceKey = GlobalKey();
    BuildContext? _scratchDiceContext;
    late final AnimationController _diceFlyController;
    OverlayEntry? _diceFlyOverlay;
    bool _hideScratchDice = false;

    ASExtraBonusResult result1 = ASExtraBonusResult(topNumbers: [], bottomNumbers: [], rewardValues: [], isWinner: false, hasDice: false);

    ASCandyRushResult result2 = ASCandyRushResult(bottomNumbers: [], topRewardValue: 0.0, isWinner: false, hasDice: false);

    ASSweetTimeResult result3 = ASSweetTimeResult(bottomNumberGroups: [], topRewardValue: 0, isWinner: false, hasDice: false);

    ASCash777Result result4 = ASCash777Result(bottomNumbers: [], rewardValues: [], winningRewardValue: 0, isWinner: false, hasDice: false);

    ASFortuneRushResult result5 = ASFortuneRushResult(bottomNumbers: [], rewardValues: [], topWinningNumber: 0, isWinner: false, hasDice: false);

    ASCash50xResult result6 = ASCash50xResult(bottomNumbers: [], rewardValues: [], topWinningNumber: 0, isWinner: false, hasDice: false);

    @override
    void initState() {
      super.initState();
      _diceFlyController = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1500),
      )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          _removeDiceFlyOverlay();
        }
      });
      setResult();
    }

    void setResult(){
      if (widget.type == 0){
        result1 = ASGameProgressManager().generateExtraBonusResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
      } else if (widget.type == 1){
        result2 = ASGameProgressManager().generateCandyRushResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
      } else if (widget.type == 2){
        result3 = ASGameProgressManager().generateSweetTimeResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
      } else if (widget.type == 3){
        result4 = ASGameProgressManager().generateCash777Result(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
      } else if (widget.type == 4){
        result5 = ASGameProgressManager().generateFortuneRushResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
      } else if (widget.type == 5){
        result6 = ASGameProgressManager().generateCash50xResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
      }
    }


    @override
    void dispose() {
      _removeDiceFlyOverlay();
      _diceFlyController.dispose();
      super.dispose();
    }

    void _startDiceFlyAnimation() {
      if (_diceFlyController.isAnimating) return;

      final scratchDiceContext = _scratchDiceContext;
      final sourceBox = scratchDiceContext != null && scratchDiceContext.mounted
          ? scratchDiceContext.findRenderObject() as RenderBox?
          : null;
      final targetBox =
          _bottomDiceKey.currentContext?.findRenderObject() as RenderBox?;
      final overlay = Overlay.of(context);
      final overlayBox = overlay.context.findRenderObject() as RenderBox?;
      if (sourceBox == null || targetBox == null || overlayBox == null) return;

      final sourceCenter = overlayBox.globalToLocal(
        sourceBox.localToGlobal(sourceBox.size.center(Offset.zero)),
      );
      final targetCenter = overlayBox.globalToLocal(
        targetBox.localToGlobal(targetBox.size.center(Offset.zero)),
      );
      final imageSize = sourceBox.size;

      _removeDiceFlyOverlay();
      _diceFlyOverlay = OverlayEntry(
        builder: (context) {
          return AnimatedBuilder(
            animation: _diceFlyController,
            builder: (context, child) {
              final progress = _diceFlyController.value;
              final travelProgress = Curves.easeInOutCubic.transform(
                min(progress / 0.84, 1.0),
              );
              final controlPoint = Offset(
                (sourceCenter.dx + targetCenter.dx) / 2 - 34.w,
                min(sourceCenter.dy, targetCenter.dy) - 86.h,
              );
              final position = _quadraticBezier(
                sourceCenter,
                controlPoint,
                targetCenter,
                travelProgress,
              );
              final landingProgress =
                  ((progress - 0.84) / 0.16).clamp(0.0, 1.0);
              final opacity = 1 - Curves.easeIn.transform(landingProgress);
              final scale = progress < 0.16
                  ? 1 + Curves.easeOutBack.transform(progress / 0.16) * 0.18
                  : 1.18 - travelProgress * 0.25 + landingProgress * 0.25;
              final rotation =
                  travelProgress * pi * 2.5 +
                  sin(travelProgress * pi * 3) * 0.12;

              return Positioned(
                left: position.dx - imageSize.width / 2,
                top: position.dy - imageSize.height / 2,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: opacity,
                    child: Transform.rotate(
                      angle: rotation,
                      child: Transform.scale(scale: scale, child: child),
                    ),
                  ),
                ),
              );
            },
            child: ASImg(
              name: 'as_dice_key',
              width: imageSize.width,
              height: imageSize.height,
            ),
          );
        },
      );
      overlay.insert(_diceFlyOverlay!);
      _diceFlyController.forward(from: 0);
    }

    Offset _quadraticBezier(
      Offset start,
      Offset control,
      Offset end,
      double progress,
    ) {
      final inverse = 1 - progress;
      return start * (inverse * inverse) +
          control * (2 * inverse * progress) +
          end * (progress * progress);
    }

    void _removeDiceFlyOverlay() {
      _diceFlyOverlay?.remove();
      _diceFlyOverlay = null;
      _scratchDiceContext = null;
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
                                      TextSpan(text: '\$${0.to2Double(provider.as_dollar_number)}'),
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
                                        width: 138 * (provider.as_dollar_number / 1000),
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
                        SizedBox(
                          key: _bottomDiceKey,
                          width: 57,
                          height: 80,
                          child: ParticleButton(
                            child: ASSpine(
                              path: 'dice'.spinepaths(),
                              width: 57,
                              height: 80,
                            ),
                            onTap: () {
                              context.tipShow2(ASDice());
                            },
                          ),
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
      } else if (widget.type == 5){
        return swapKey6;
      } else {
        return swapKey1;
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
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) _startDiceFlyAnimation();
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
                        Visibility(visible: scractch_end_animation && widget.type == 2,child: ASImg(name: 'as_scratch_end_2_bg',
                          width: 361.w,
                          height: 589.h,)),
                        getScrachContentWidget(),
                        Visibility(visible: !result3.isWinner && scractch_end_animation && widget.type == 2,child: SizedBox(
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
                  ASBouncyText(text: '${result1.topNumbers.first}', fontSize: 40, color:scractch_end_animation && result1.winningTopIndex == 0 ? Colors.white : '#000000'.color(),enableAnimation: scractch_end_animation && result1.winningTopIndex == 0),
                  ASBouncyText(text: '${result1.topNumbers[1]}', fontSize: 40, color:scractch_end_animation && result1.winningTopIndex == 1 ? Colors.white : '#000000'.color(),enableAnimation: scractch_end_animation && result1.winningTopIndex == 1),
                  ASBouncyText(text: '${result1.topNumbers[2]}', fontSize: 40, color:scractch_end_animation && result1.winningTopIndex == 2 ? Colors.white : '#000000'.color(),enableAnimation: scractch_end_animation && result1.winningTopIndex == 2),
                  ASBouncyText(text: '${result1.topNumbers.last}', fontSize: 40, color:scractch_end_animation && result1.winningTopIndex == 3 ? Colors.white : '#000000'.color(),enableAnimation: scractch_end_animation && result1.winningTopIndex == 3),
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
                          if (result1.bottomNumbers[index] == -1)
                            SizedBox(
                              width: 43,
                              height: 59.h,
                              child: Column(
                                children: [
                                  SizedBox(height: 14.h),
                                  Visibility(
                                    visible: !_hideScratchDice,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: Builder(
                                      builder: (diceContext) {
                                        _scratchDiceContext = diceContext;
                                        return SizedBox(
                                          width: 43,
                                          height: 45,
                                          child: ASBouncyImage(imagePath: 'as_dice_key', width: 43, height: 45, enableAnimation: scractch_end_animation),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          if (result1.bottomNumbers[index] != -1)
                            ASBouncyText(text: '${result1.bottomNumbers[index]}', fontSize: 32, color: scractch_end_animation && result1.winningBottomIndex == index ? Colors.white : '#162333'.color(), enableAnimation: scractch_end_animation && result1.winningBottomIndex == index),
                          if (result1.bottomNumbers[index] != -1)
                            ASBouncyText(text: '\$${result1.rewardValues[index]}', fontSize: 20, color: scractch_end_animation && result1.winningBottomIndex == index ? '#FFF429'.color() : '#11853C'.color(), enableAnimation: scractch_end_animation && result1.winningBottomIndex == index)
                        ],
                      );
                    },
                  ),
                  Visibility(visible: !result1.isWinner && scractch_end_animation,child: SizedBox(
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
              ASBouncyText(text: '\$${result2.topRewardValue}', fontSize: 36, color: '#44128F'.color(), enableAnimation: scractch_end_animation && result2.isWinner),
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
                            if (result2.bottomNumbers[index] == -1)
                              SizedBox(
                                width: 43,
                                height: 59.h,
                                child: Column(
                                  children: [
                                    SizedBox(height: 20.h),
                                    Visibility(
                                      visible: !_hideScratchDice,
                                      maintainSize: true,
                                      maintainAnimation: true,
                                      maintainState: true,
                                      child: Builder(
                                        builder: (diceContext) {
                                          _scratchDiceContext = diceContext;
                                          return SizedBox(
                                            width: 43,
                                            height: 45,
                                            child: ASBouncyImage(imagePath: 'as_dice_key', width: 43, height: 45, enableAnimation: scractch_end_animation),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            if (result2.bottomNumbers[index] != -1)
                              ASBouncyImage(imagePath: 'as_scartch_data_${result2.bottomNumbers[index]}_n', width: (293.w / 3), height: (202.h / 3), enableAnimation: scractch_end_animation && result2.bottomNumbers[index] == 2)
                          ],
                        );
                      },
                    ),
                    Visibility(visible: !result2.isWinner && scractch_end_animation,child: SizedBox(
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
          width: 331.w,
          height: 395.h,
          child: Stack(
            children: [
              Positioned(left: (0.width(context) - 212.w) * 0.5,top: 53.h,child:ASBouncyChild(enableAnimation: scractch_end_animation && result3.isWinner,child: SizedBox(width: 150.w,height: 20.h,child: ASText(text: '\$${result3.topRewardValue}', size: 18, color: '#FFDF27'.color(), weight: FontWeight.w900, align: .center)))),
              if (result3.bottomNumberGroups.first.first != 0 && result3.bottomNumberGroups.first.first != -1)
                Positioned(left: (0.width(context) - 100) * 0.5,top: 95.h,child:ASText(text: '${result3.bottomNumberGroups.first.first}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups.first.first == 0)
                Positioned(left: (0.width(context) - 93.w) * 0.5,top: 90.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups.first.first == -1)
                Positioned(left: (0.width(context) - 96.w) * 0.5,top: 84.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[1].first != 0 && result3.bottomNumberGroups[1].first != -1)
                Positioned(left: 116.w,top: 142.h,child:ASText(text: '${result3.bottomNumberGroups[1].first}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[1].first == 0)
                Positioned(left: 114.w,top: 136.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[1].first == -1)
                Positioned(left: 110.w,top: 130.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[1].last != 0 && result3.bottomNumberGroups[1].last != -1)
                Positioned(right: 116.w,top: 142.h,child:ASText(text: '${result3.bottomNumberGroups[1].last}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[1].last == 0)
                Positioned(right: 114.w,top: 136.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[1].last == -1)
                Positioned(right: 110.w,top: 130.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[2].first != 0 && result3.bottomNumberGroups[2].first != -1)
                Positioned(left: 89.w,top: 187.h,child:ASText(text: '${result3.bottomNumberGroups[2].first}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[2].first == 0)
                Positioned(left: 86.w,top: 181.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[2].first == -1)
                Positioned(left: 80.w,top: 178.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[2].last != 0 && result3.bottomNumberGroups[2].last != -1)
                Positioned(right: 89.w,top: 187.h,child:ASText(text: '${result3.bottomNumberGroups[2].last}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[2].last == 0)
                Positioned(right: 86.w,top: 181.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[2].last == -1)
                Positioned(right: 80.w,top: 178.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[2][1] != 0 && result3.bottomNumberGroups[2][1] != -1)
                Positioned(right: (0.width(context) - 82.w) * 0.5,top: 187.h,child:ASText(text: '${result3.bottomNumberGroups[2][1]}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[2][1] == 0)
                Positioned(right: (0.width(context) - 90.w) * 0.5,top: 181.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[2][1] == -1)
                Positioned(right: (0.width(context) - 100.w) * 0.5,top: 178.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[3].first != 0 && result3.bottomNumberGroups[3].first != -1)
                Positioned(left: 58.w,top: 240.h,child:ASText(text: '${result3.bottomNumberGroups[3].first}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[3].first == 0)
                Positioned(left: 54.w,top: 234.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[3].first == -1)
                Positioned(left: 52.w,top: 230.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[3].last != 0 && result3.bottomNumberGroups[3].last != -1)
                Positioned(right: 58.w,top: 240.h,child:ASText(text: '${result3.bottomNumberGroups[3].last}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[3].last == 0)
                Positioned(right: 54.w,top: 234.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[3].last == -1)
                Positioned(right: 52.w,top: 230.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[3][1] != 0 && result3.bottomNumberGroups[3][1] != -1)
                Positioned(left: 118.w,top: 240.h,child:ASText(text: '${result3.bottomNumberGroups[3][1]}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[3][1] == 0)
                Positioned(left: 114.w,top: 234.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[3][1] == -1)
                Positioned(left: 110.w,top: 230.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              if (result3.bottomNumberGroups[3][2] != 0 && result3.bottomNumberGroups[3][2] != -1)
                Positioned(right: 118.w,top: 240.h,child:ASText(text: '${result3.bottomNumberGroups[3][2]}', size: 20, color: '#574D4D'.color(), weight: FontWeight.w900)),
              if (result3.bottomNumberGroups[3][2] == 0)
                Positioned(right: 114.w,top: 234.h,child: Container(width: 33, height: 33, color: scractch_end_animation ? Colors.transparent : Colors.transparent,child: ASBouncyImage(imagePath: 'as_dangao_icon', width: 33, height: 33, enableAnimation: scractch_end_animation))),
              if (result3.bottomNumberGroups[3][2] == -1)
                Positioned(right: 110.w,top: 230.h,
                  child: SizedBox(
                    width: 43,
                    height: 45,
                    child: Column(
                      children: [
                        Visibility(
                          visible: !_hideScratchDice,
                          maintainSize: true,
                          maintainAnimation: true,
                          maintainState: true,
                          child: Builder(
                            builder: (diceContext) {
                              _scratchDiceContext = diceContext;
                              return SizedBox(
                                width: 43,
                                height: 45,
                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 32, height: 32, enableAnimation: scractch_end_animation),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
                padding: EdgeInsets.only(top: 10.h, left: 20.w), // 移除默认的padding// 最多显示10个
                itemBuilder: (context, index) {
                  return Stack(
                    children: [
                      Column(
                        mainAxisAlignment: .center,
                        children: [
                          if (result4.bottomNumbers[index] == 0 || result4.bottomNumbers[index] == 1 || result4.bottomNumbers[index] == 2)
                            ASBouncyImage(imagePath: 'as_scartch_data_3_${result4.bottomNumbers[index]}', width: 51, height: 39),
                          if (result4.bottomNumbers[index] == 0 || result4.bottomNumbers[index] == 1 || result4.bottomNumbers[index] == 2)
                            SizedBox(height: 5.h),
                          if (result4.bottomNumbers[index] != 0 && result4.bottomNumbers[index] != 1 && result4.bottomNumbers[index] != 2 && result4.bottomNumbers[index] != -1)
                            ASBouncyText(enableAnimation: scractch_end_animation && index == result4.winningIndex, text: '${result4.bottomNumbers[index]}', fontSize: 32, color: '#0D2A7B'.color()),
                          if (result4.bottomNumbers[index] != -1)
                            ASBouncyChild(enableAnimation: scractch_end_animation && index == result4.winningIndex, child: ASStrokeText(text: '\$${result4.rewardValues[index]}', size: 20, color: '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 1, skColor: '#081E5D'.color())),
                          if (result4.bottomNumbers[index] == -1)
                            SizedBox(
                              width: 43,
                              height: 59.h,
                              child: Column(
                                children: [
                                  SizedBox(height: 20.h),
                                  Visibility(
                                    visible: !_hideScratchDice,
                                    maintainSize: true,
                                    maintainAnimation: true,
                                    maintainState: true,
                                    child: Builder(
                                      builder: (diceContext) {
                                        _scratchDiceContext = diceContext;
                                        return SizedBox(
                                          width: 43,
                                          height: 45,
                                          child: ASBouncyImage(imagePath: 'as_dice_key', width: 43, height: 45, enableAnimation: scractch_end_animation),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
            Visibility(visible: !result4.isWinner && scractch_end_animation,child: SizedBox(
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
                  ASBouncyChild(enableAnimation: scractch_end_animation && result5.isWinner, child: ASStrokeText(text: '${result5.topWinningNumber}', size: 32, color: '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color())),
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
                                if (result5.bottomNumbers[index] != -1)
                                 Container(width: (190.w / 3),height: (180.w / 4),decoration: BoxDecoration(
                                    color: index == result5.winningIndex ? Colors.white : Colors.transparent,
                                    borderRadius: BorderRadius.circular(8.h)
                                ),child: ASBouncyText(text: '${result5.bottomNumbers[index]}', fontSize: 24, color: index == result5.winningIndex ? '#B92323'.color() : '#333333'.color(), enableAnimation: scractch_end_animation && index == result5.winningIndex)),
                                if (result5.bottomNumbers[index] == -1)
                                  SizedBox(
                                    width: (190.w / 3),
                                    height: (180.w / 4),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 0.h),
                                        Visibility(
                                          visible: !_hideScratchDice,
                                          maintainSize: true,
                                          maintainAnimation: true,
                                          maintainState: true,
                                          child: Builder(
                                            builder: (diceContext) {
                                              _scratchDiceContext = diceContext;
                                              return SizedBox(
                                                width: 44,
                                                height: 48,
                                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 43, height: 45, enableAnimation: scractch_end_animation),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                                color: result5.rewardIndex == 0 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation && result5.rewardIndex == 0, child: ASStrokeText(text: '\$${result5.rewardValues.first}', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                            Container(width: 80.w,height: 180.w / 4,decoration: BoxDecoration(
                                color: result5.rewardIndex == 1 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation && result5.rewardIndex == 1, child: ASStrokeText(text: '\$${result5.rewardValues[1]}', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                            Container(width: 80.w,height: 180.w / 4,decoration: BoxDecoration(
                                color: result5.rewardIndex == 2 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation && result5.rewardIndex == 2, child: ASStrokeText(text: '\$${result5.rewardValues[2]}', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                            Container(width: 80.w,height: 180.w / 4,decoration: BoxDecoration(
                                color: result5.rewardIndex == 3 ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: ASBouncyChild(enableAnimation: scractch_end_animation && result5.rewardIndex == 3, child: ASStrokeText(text: '\$${result5.rewardValues.last}', size: 24, color: '#FFEA00'.color(), weight: FontWeight.w900, skWidth: 2, skColor: '#000000'.color()))),
                          ],
                        ),
                      )
                    ],
                  )
                ],
              ),
              Visibility(visible: !result5.isWinner && scractch_end_animation,child: SizedBox(
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
                  SizedBox(height: result6.isWinner ? 56.h : 48.h),
                  Padding(padding: EdgeInsetsGeometry.only(left: 4.w),child: ASImg(name: 'as_scratch_data_top_${result6.topWinningNumber}', width: result6.isWinner ? 70.w : 60.h, height:result6.isWinner ? 40.w : 60.w)),
                  SizedBox(height: result6.isWinner ? 44.h : 32.h),
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
                                color: index == result6.winningIndex && scractch_end_animation == true ? Colors.white : Colors.transparent,
                                borderRadius: BorderRadius.circular(8.h)
                            ),child: Column(
                              children: [
                                SizedBox(height: 8.h),
                                if ((20 == result6.bottomNumbers[index] || 30 == result6.bottomNumbers[index] || 50 == result6.bottomNumbers[index]) && result6.bottomNumbers[index] != -1)
                                  ASBouncyImage(enableAnimation: scractch_end_animation == true && result6.winningIndex == index,imagePath: 'as_scractch_data_5_${result6.bottomNumbers[index]}', width: 60, height: 32),
                                if (20 != result6.bottomNumbers[index] && 30 != result6.bottomNumbers[index] && 50 != result6.bottomNumbers[index] && result6.bottomNumbers[index] != -1)
                                  ASBouncyImage(enableAnimation: scractch_end_animation == true && result6.winningIndex == index,imagePath: 'as_scractch_data_5_${result6.bottomNumbers[index]}', width: 42, height: 42),
                                if (20 == result6.bottomNumbers[index] || 30 == result6.bottomNumbers[index] || 50 == result6.bottomNumbers[index])
                                  SizedBox(height: 8.h),
                                if (-1 == result6.bottomNumbers[index])
                                  SizedBox(
                                    width: (190.w / 3),
                                    height: (180.w / 4),
                                    child: Column(
                                      children: [
                                        SizedBox(height: 0.h),
                                        Visibility(
                                          visible: !_hideScratchDice,
                                          maintainSize: true,
                                          maintainAnimation: true,
                                          maintainState: true,
                                          child: Builder(
                                            builder: (diceContext) {
                                              _scratchDiceContext = diceContext;
                                              return SizedBox(
                                                width: 44,
                                                height: 48,
                                                child: ASBouncyImage(imagePath: 'as_dice_key', width: 43, height: 45, enableAnimation: scractch_end_animation),
                                              );
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                if (-1 != result6.bottomNumbers[index])
                                  ASBouncyChild(enableAnimation: scractch_end_animation == true && result6.winningIndex == index,child: ASStrokeText(text: '\$${result6.rewardValues[index]}', size: 18, color:scractch_end_animation && result6.winningIndex == index ? '#FFE100'.color() : '#FFFFFF'.color(), weight: FontWeight.w900, skWidth: 2, skColor:scractch_end_animation && result6.winningIndex == index ? '#180D74'.color() : '#180D74'.color())),
                              ],
                            ))
                          ],
                        );
                      },
                    ),
                  )
                ],
              ),
              Visibility(visible: !result6.isWinner && scractch_end_animation == true,child: SizedBox(
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

    Future<void> scrachEndDialog() async {
      await Future.delayed(const Duration(milliseconds: 300));
      setState(() {
        scractch_end_animation = true;
        _hideScratchDice = true;
      });
      await ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_scrach_all_countName, ASLocalProvider.instance.as_scrach_all_count + 1);
      Future.delayed(Duration(milliseconds: 2000),() async {
        showAwardDialog();
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
        if (widget.type == 0){
          result1 = ASGameProgressManager().generateExtraBonusResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
        } else if (widget.type == 1){
          result2 = ASGameProgressManager().generateCandyRushResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
        } else if (widget.type == 2){
          result3 = ASGameProgressManager().generateSweetTimeResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
        } else if (widget.type == 3){
          result4 = ASGameProgressManager().generateCash777Result(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
        } else if (widget.type == 4){
          result5 = ASGameProgressManager().generateFortuneRushResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
        } else if (widget.type == 5){
          result6 = ASGameProgressManager().generateCash50xResult(ASLocalProvider.instance.as_scrach_all_count <= ASGameProgressManager().gameProgressModel.freeCard);
        }
        await Future.delayed(const Duration(milliseconds: 200));
        ASScratchUpdateNotificationService.sendToDomandNumberNotification(0);
        setState(() {
          scractch_end_animation = false;
          _hideScratchDice = false;
        });
      });
    }

    Future<void> showAwardDialog() async {
      double award = 0.0;
      bool isWin = false;
      List<double> pop = [];
      bool hasDice = false;
      if (widget.type == 0){
        isWin = result1.isWinner;
        hasDice = result1.hasDice;
        award = result1.isWinner
            ? result1.rewardValues[result1.winningBottomIndex]
            : 0.0;
        pop = ASGameProgressManager().gameProgressModel.extraBonus.pop;
      } else if (widget.type == 1){
        isWin = result2.isWinner;
        hasDice = result2.hasDice;
        award = result2.topRewardValue;
        pop = ASGameProgressManager().gameProgressModel.candyRush.pop;
      } else if (widget.type == 2){
        isWin = result3.isWinner;
        hasDice = result3.hasDice;
        award = result3.topRewardValue;
        pop = ASGameProgressManager().gameProgressModel.sweetTime.pop;
      } else if (widget.type == 3){
        isWin = result4.isWinner;
        hasDice = result4.hasDice;
        award = result4.winningRewardValue;
        pop = ASGameProgressManager().gameProgressModel.cash777.pop;
      } else if (widget.type == 4){
        isWin = result5.isWinner;
        hasDice = result5.hasDice;
        award = result5.isWinner
            ? result5.rewardValues[result5.rewardIndex]
            : 0.0;
        pop = ASGameProgressManager().gameProgressModel.fortuneRush.pop;
      } else if (widget.type == 5){
        isWin = result6.isWinner;
        hasDice = result6.hasDice;
        award = result6.isWinner
            ? result6.winningRewardValue
            : 0.0;
        pop = ASGameProgressManager().gameProgressModel.cash50x.pop;
      }
      if (isWin == true){
        if (award < pop.first){
          showYouwin(award);
        } else if (award >= pop.first && award <= pop.last){
          showSuperwin(award);
        } else {
          showJackPot(award);
        }
      }
      if (hasDice){
        await ASLocalProvider.instance.updateint(ASLocalProvider.instance.as_dice_numberName, ASLocalProvider.instance.as_dice_number + 1);
      }
    }

    void showYouwin(double award){
      context.tipShow2(ASYouWinDialog(award: award, isWheel: false));
    }

    void showSuperwin(double award){
      context.tipShow2(ASSuperWinDialog(award: award));
    }

    void showJackPot(double award){
      context.tipShow2(ASJackPotDialog(award: award));
    }
  }
