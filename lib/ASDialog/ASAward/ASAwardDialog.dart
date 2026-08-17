import 'dart:math';

import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/ASLogger.dart';
import 'package:aurastack/ASTool/as_LocalProvider.dart';
import 'package:aurastack/ASTool/as_ad_manger.dart';
import 'package:aurastack/ASTool/as_stroke_text.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../ASTool/as_GradientNumber.dart';
import '../../ASTool/as_GradientText.dart';
import '../../ASTool/as_extension_help.dart';
import '../../ASTool/as_img.dart';
import '../../ASTool/as_spine_tool.dart';
import '../../ASTool/as_text.dart';
import '../../ASTool/ASWithdrawalFlow.dart';
import '../../ASTool/ASTBAEventTool.dart';
import '../../ASTool/ASTrackEvent.dart';
import '../../ASTool/ASAudioUtils.dart';
import '../../moveTool/fountain_anim.dart';
import '../../moveTool/fountain_anim_ex.dart';
import '../../moveTool/leaf_anim.dart';

String _moneyType(String rewardType) =>
    rewardType == 'spins' ? 'spin' : rewardType;

void _fireMoneyEvent(String event, String rewardType, String style) {
  if (rewardType == 'task') return;
  as_event_fire(event, {'types': _moneyType(rewardType), 'style': style});
}

String _rewardAdPlace(String rewardType, String format) =>
    switch ((rewardType, format)) {
      ('dice', 'rv') => ASTrackEvent.diceRewarded,
      ('dice', _) => ASTrackEvent.diceInterstitial,
      ('spins', 'rv') => ASTrackEvent.wheelRewarded,
      ('spins', _) => ASTrackEvent.wheelInterstitial,
      ('task', 'int') => ASTrackEvent.taskInterstitial,
      ('task', _) => '_rv',
      (_, 'rv') => ASTrackEvent.cardRewarded,
      _ => ASTrackEvent.cardInterstitial,
    };

/// YouWin
class ASYouWinDialog extends StatefulWidget {
  final double award;
  final bool isWheel;
  final String rewardType;
  final String rewardStr;

  const ASYouWinDialog({
    super.key,
    required this.award,
    required this.isWheel,
    this.rewardType = 'scratch',
    this.rewardStr = '',
  });

  @override
  State<ASYouWinDialog> createState() => ASYouWinDialogState();
}

class ASYouWinDialogState extends State<ASYouWinDialog>
    with SingleTickerProviderStateMixin {
  bool _showAwardButton = false;

  @override
  void initState() {
    super.initState();
    _fireMoneyEvent(ASTrackEvent.moneyPopup, widget.rewardType, 'uwin');
    ASAudioUtils().playCashAudio();

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
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Stack(
        alignment: .center,
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
                width: 0.width(context) * 0.8,

                height: 420.h,

                path: 'youwin'.spinepaths(),
              ),

              SizedBox(height: 56.h),

              ParticleButton(
                onTap: () async {
                  _fireMoneyEvent(
                    ASLocalProvider.instance.as_scrach_all_count >
                            ASGameProgressManager().gameProgressModel.freeCard
                        ? ASTrackEvent.moneyPopupDoubleClick
                        : ASTrackEvent.moneyPopupSingleClick,
                    widget.rewardType,
                    'uwin',
                  );
                  if (ASLocalProvider.instance.as_scrach_all_count <=
                      ASGameProgressManager().gameProgressModel.freeCard) {
                    Navigator.pop(context, 1);
                    await ASLocalProvider.instance.updatedouble(
                      ASLocalProvider.instance.as_dollar_numberName,
                      0.to2Double(widget.award * 1),
                    );
                  } else {
                    ASCardAds().as_showAd(
                      context,
                      _rewardAdPlace(widget.rewardType, 'rv'),
                      onCacheResponse: (onCacheResponse) {
                        Navigator.pop(context, 0);
                      },
                      adDidClosed: (adDidClosed) async {
                        Navigator.pop(context, 1);
                        await ASLocalProvider.instance.updatedouble(
                          ASLocalProvider.instance.as_dollar_numberName,
                          0.to2Double(widget.award * 2),
                        );
                      },
                    );
                  }
                },

                child: Container(
                  width: 262,

                  height:
                      ASLocalProvider.instance.as_scrach_all_count >
                          ASGameProgressManager().gameProgressModel.freeCard
                      ? 96
                      : 84,

                  decoration: BoxDecoration(
                    image: ASDImg(
                      ASLocalProvider.instance.as_scrach_all_count >
                              ASGameProgressManager().gameProgressModel.freeCard
                          ? 'as_ad_btn'
                          : 'as_claim_b_btn',
                    ),
                  ),

                  child:
                      ASLocalProvider.instance.as_scrach_all_count >
                          ASGameProgressManager().gameProgressModel.freeCard
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
                visible:
                    ASLocalProvider.instance.as_scrach_all_count >
                    ASGameProgressManager().gameProgressModel.freeCard,
                child: Opacity(
                  opacity: _showAwardButton ? 1 : 0,

                  child: ASUnderlineTextButton(
                    onPressed: () async {
                      _fireMoneyEvent(
                        ASTrackEvent.moneyPopupSingleClick,
                        widget.rewardType,
                        'uwin',
                      );
                      if (ASGameProgressManager().showInterstitialAd()) {
                        ASCardAds().as_showAd(
                          context,
                          _rewardAdPlace(widget.rewardType, 'int'),
                          onCacheResponse: (onCacheResponse) {
                            Navigator.pop(context, 0);
                          },
                          adDidClosed: (adDidClosed) async {
                            Navigator.pop(context, 1);
                            await ASLocalProvider.instance.updatedouble(
                              ASLocalProvider.instance.as_dollar_numberName,
                              0.to2Double(widget.award * 1),
                            );
                          },
                        );
                      } else {
                        Navigator.pop(context, 1);
                        await ASLocalProvider.instance.updatedouble(
                          ASLocalProvider.instance.as_dollar_numberName,
                          0.to2Double(widget.award * 1),
                        );
                      }
                    },
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

            bottom: 320.h,

            child: SizedBox(
              width: 0.width(context),
              height: 48,
              child: ASStrokeText(
                text: widget.rewardStr.length > 0
                    ? widget.rewardStr
                    : '\$${widget.award}',

                size: 38,

                color: '#FFFFFF'.color(),

                weight: FontWeight.w900,

                skWidth: 3,

                skColor: '#8A320C'.color(),
                align: .center,
              ),
            ),
          ),

          Positioned(
            left: (0.width(context) - 298) * 0.5,
            bottom: 234.h,
            child: Visibility(
              visible: true,
              child: Container(
                width: 298,
                height: 51,
                decoration: BoxDecoration(image: ASDImg('as_top_bg')),
                child: Stack(
                  children: [
                    Positioned(
                      left: 13,
                      top: 6,
                      child: ASImg(
                        name: 'as_dollar_icon',
                        width: 38,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 6,
                      child: ASImg(
                        name:
                            'as_pp_${ASLocalProvider.instance.as_tx_ing_account}',
                        width: 82,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      left: 52,
                      top: 5,
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
                                  '\$${0.to2Double(ASLocalProvider.instance.as_dollar_number)}',
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
                      left: 53,
                      bottom: 16,
                      child: Container(
                        width: 138,
                        height: 11,
                        decoration: BoxDecoration(
                          image: ASDImg('as_home_pro_1'),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width:
                                  138 *
                                  (ASLocalProvider.instance.as_dollar_number /
                                              1000 >=
                                          1
                                      ? 1
                                      : ASLocalProvider
                                                .instance
                                                .as_dollar_number /
                                            1000),
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
      ),
    );
  }
}

/// SuperWin
class ASSuperWinDialog extends StatefulWidget {
  final double award;
  final String rewardType;
  final String rewardStr;

  const ASSuperWinDialog({
    super.key,
    required this.award,
    this.rewardType = 'scratch',
    this.rewardStr = '',
  });

  @override
  State<ASSuperWinDialog> createState() => ASSuperWinDialogState();
}

class ASSuperWinDialogState extends State<ASSuperWinDialog>
    with SingleTickerProviderStateMixin {
  bool _showAwardButton = false;

  @override
  void initState() {
    super.initState();
    _fireMoneyEvent(ASTrackEvent.moneyPopup, widget.rewardType, 'superwin');
    ASAudioUtils().playRewardStage2Audio();

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
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Stack(
        alignment: .center,
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
                width: 0.width(context) * 0.8,

                height: 420.h,

                path: 'superwin'.spinepaths(),
              ),

              SizedBox(height: 56.h),

              ParticleButton(
                onTap: () async {
                  _fireMoneyEvent(
                    ASLocalProvider.instance.as_scrach_all_count >
                            ASGameProgressManager().gameProgressModel.freeCard
                        ? ASTrackEvent.moneyPopupDoubleClick
                        : ASTrackEvent.moneyPopupSingleClick,
                    widget.rewardType,
                    'superwin',
                  );
                  if (ASLocalProvider.instance.as_scrach_all_count <=
                      ASGameProgressManager().gameProgressModel.freeCard) {
                    Navigator.pop(context, 1);
                    await ASLocalProvider.instance.updatedouble(
                      ASLocalProvider.instance.as_dollar_numberName,
                      0.to2Double(widget.award * 1),
                    );
                  } else {
                    ASCardAds().as_showAd(
                      context,
                      _rewardAdPlace(widget.rewardType, 'rv'),
                      onCacheResponse: (onCacheResponse) {
                        Navigator.pop(context, 0);
                      },
                      adDidClosed: (adDidClosed) async {
                        Navigator.pop(context, 1);
                        await ASLocalProvider.instance.updatedouble(
                          ASLocalProvider.instance.as_dollar_numberName,
                          0.to2Double(widget.award * 2),
                        );
                      },
                    );
                  }
                },

                child: Container(
                  width: 262,

                  height:
                      ASLocalProvider.instance.as_scrach_all_count >
                          ASGameProgressManager().gameProgressModel.freeCard
                      ? 96
                      : 84,

                  decoration: BoxDecoration(
                    image: ASDImg(
                      ASLocalProvider.instance.as_scrach_all_count >
                              ASGameProgressManager().gameProgressModel.freeCard
                          ? 'as_ad_btn'
                          : 'as_claim_b_btn',
                    ),
                  ),

                  child:
                      ASLocalProvider.instance.as_scrach_all_count >
                          ASGameProgressManager().gameProgressModel.freeCard
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
                visible:
                    ASLocalProvider.instance.as_scrach_all_count >
                    ASGameProgressManager().gameProgressModel.freeCard,
                child: Opacity(
                  opacity: _showAwardButton ? 1 : 0,

                  child: ASUnderlineTextButton(
                    onPressed: () async {
                      _fireMoneyEvent(
                        ASTrackEvent.moneyPopupSingleClick,
                        widget.rewardType,
                        'superwin',
                      );
                      if (ASGameProgressManager().showInterstitialAd()) {
                        ASCardAds().as_showAd(
                          context,
                          _rewardAdPlace(widget.rewardType, 'int'),
                          onCacheResponse: (onCacheResponse) {
                            Navigator.pop(context, 0);
                          },
                          adDidClosed: (adDidClosed) async {
                            Navigator.pop(context, 1);
                            await ASLocalProvider.instance.updatedouble(
                              ASLocalProvider.instance.as_dollar_numberName,
                              0.to2Double(widget.award * 1),
                            );
                          },
                        );
                      } else {
                        Navigator.pop(context, 1);
                        await ASLocalProvider.instance.updatedouble(
                          ASLocalProvider.instance.as_dollar_numberName,
                          0.to2Double(widget.award * 1),
                        );
                      }
                    },
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

            bottom: 320.h,

            child: ASStrokeText(
              text: widget.rewardStr.length > 0
                  ? widget.rewardStr
                  : '\$${widget.award}',

              size: 38,

              color: '#FFFFFF'.color(),

              weight: FontWeight.w900,

              skWidth: 3,

              skColor: '#8A320C'.color(),
            ),
          ),

          Positioned(
            left: (0.width(context) - 298) * 0.5,
            bottom: 234.h,
            child: Visibility(
              visible: true,
              child: Container(
                width: 298,
                height: 51,
                decoration: BoxDecoration(image: ASDImg('as_top_bg')),
                child: Stack(
                  children: [
                    Positioned(
                      left: 13,
                      top: 6,
                      child: ASImg(
                        name: 'as_dollar_icon',
                        width: 38,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 6,
                      child: ASImg(
                        name:
                            'as_pp_${ASLocalProvider.instance.as_tx_ing_account}',
                        width: 82,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      left: 52,
                      top: 5,
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
                                  '\$${0.to2Double(ASLocalProvider.instance.as_dollar_number)}',
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
                      left: 53,
                      bottom: 16,
                      child: Container(
                        width: 138,
                        height: 11,
                        decoration: BoxDecoration(
                          image: ASDImg('as_home_pro_1'),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width:
                                  138 *
                                  (ASLocalProvider.instance.as_dollar_number /
                                              1000 >=
                                          1
                                      ? 1
                                      : ASLocalProvider
                                                .instance
                                                .as_dollar_number /
                                            1000),
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
      ),
    );
  }
}

/// JackPot
class ASJackPotDialog extends StatefulWidget {
  final double award;
  final String rewardType;
  final String rewardStr;

  const ASJackPotDialog({
    super.key,
    required this.award,
    this.rewardType = 'scratch',
    this.rewardStr = '',
  });

  @override
  State<ASJackPotDialog> createState() => ASJackPotDialogState();
}

class ASJackPotDialogState extends State<ASJackPotDialog>
    with SingleTickerProviderStateMixin {
  bool _showAwardButton = false;

  @override
  void initState() {
    super.initState();
    _fireMoneyEvent(ASTrackEvent.moneyPopup, widget.rewardType, 'jacktot');
    ASAudioUtils().playBigwinAudio();

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
    return SizedBox(
      width: 0.width(context),
      height: 0.height(context),
      child: Stack(
        alignment: .center,
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
                width: 0.width(context) * 0.8,

                height: 420.h,

                path: 'jackpot'.spinepaths(),
              ),

              SizedBox(height: 56.h),

              ParticleButton(
                onTap: () async {
                  _fireMoneyEvent(
                    ASLocalProvider.instance.as_scrach_all_count >
                            ASGameProgressManager().gameProgressModel.freeCard
                        ? ASTrackEvent.moneyPopupDoubleClick
                        : ASTrackEvent.moneyPopupSingleClick,
                    widget.rewardType,
                    'jacktot',
                  );
                  if (ASLocalProvider.instance.as_scrach_all_count <=
                      ASGameProgressManager().gameProgressModel.freeCard) {
                    Navigator.pop(context, 1);
                    await ASLocalProvider.instance.updatedouble(
                      ASLocalProvider.instance.as_dollar_numberName,
                      0.to2Double(widget.award * 1),
                    );
                  } else {
                    ASCardAds().as_showAd(
                      context,
                      _rewardAdPlace(widget.rewardType, 'rv'),
                      onCacheResponse: (onCacheResponse) {
                        Navigator.pop(context, 0);
                      },
                      adDidClosed: (adDidClosed) async {
                        Navigator.pop(context, 1);
                        await ASLocalProvider.instance.updatedouble(
                          ASLocalProvider.instance.as_dollar_numberName,
                          0.to2Double(widget.award * 2),
                        );
                      },
                    );
                  }
                },

                child: Container(
                  width: 262,

                  height:
                      ASLocalProvider.instance.as_scrach_all_count >
                          ASGameProgressManager().gameProgressModel.freeCard
                      ? 96
                      : 84,

                  decoration: BoxDecoration(
                    image: ASDImg(
                      ASLocalProvider.instance.as_scrach_all_count >
                              ASGameProgressManager().gameProgressModel.freeCard
                          ? 'as_ad_btn'
                          : 'as_claim_b_btn',
                    ),
                  ),

                  child:
                      ASLocalProvider.instance.as_scrach_all_count >
                          ASGameProgressManager().gameProgressModel.freeCard
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
                visible:
                    ASLocalProvider.instance.as_scrach_all_count >
                    ASGameProgressManager().gameProgressModel.freeCard,
                child: Opacity(
                  opacity: _showAwardButton ? 1 : 0,

                  child: ASUnderlineTextButton(
                    onPressed: () async {
                      _fireMoneyEvent(
                        ASTrackEvent.moneyPopupSingleClick,
                        widget.rewardType,
                        'jacktot',
                      );
                      if (ASGameProgressManager().showInterstitialAd()) {
                        ASCardAds().as_showAd(
                          context,
                          _rewardAdPlace(widget.rewardType, 'int'),
                          onCacheResponse: (onCacheResponse) {
                            Navigator.pop(context, 0);
                          },
                          adDidClosed: (adDidClosed) async {
                            Navigator.pop(context, 1);
                            await ASLocalProvider.instance.updatedouble(
                              ASLocalProvider.instance.as_dollar_numberName,
                              0.to2Double(widget.award * 1),
                            );
                          },
                        );
                      } else {
                        Navigator.pop(context, 1);
                        await ASLocalProvider.instance.updatedouble(
                          ASLocalProvider.instance.as_dollar_numberName,
                          0.to2Double(widget.award * 1),
                        );
                      }
                    },
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

            bottom: 320.h,

            child: ASStrokeText(
              text: widget.rewardStr.length > 0
                  ? widget.rewardStr
                  : '\$${widget.award}',

              size: 38,

              color: '#FFFFFF'.color(),

              weight: FontWeight.w900,

              skWidth: 3,

              skColor: '#8A320C'.color(),
            ),
          ),

          Positioned(
            left: (0.width(context) - 298) * 0.5,
            bottom: 234.h,
            child: Visibility(
              visible: true,
              child: Container(
                width: 298,
                height: 51,
                decoration: BoxDecoration(image: ASDImg('as_top_bg')),
                child: Stack(
                  children: [
                    Positioned(
                      left: 13,
                      top: 6,
                      child: ASImg(
                        name: 'as_dollar_icon',
                        width: 38,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      right: 10,
                      top: 6,
                      child: ASImg(
                        name:
                            'as_pp_${ASLocalProvider.instance.as_tx_ing_account}',
                        width: 82,
                        height: 32,
                      ),
                    ),
                    Positioned(
                      left: 52,
                      top: 5,
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
                                  '\$${0.to2Double(ASLocalProvider.instance.as_dollar_number)}',
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
                      left: 53,
                      bottom: 16,
                      child: Container(
                        width: 138,
                        height: 11,
                        decoration: BoxDecoration(
                          image: ASDImg('as_home_pro_1'),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width:
                                  138 *
                                  (ASLocalProvider.instance.as_dollar_number /
                                              1000 >=
                                          1
                                      ? 1
                                      : ASLocalProvider
                                                .instance
                                                .as_dollar_number /
                                            1000),
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
      ),
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
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        Navigator.pop(context, true);
      },
      child: SizedBox(
        width: 0.width(context),
        height: 0.height(context),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              left: 20.w,
              bottom: 88.h,
              child: ASImg(name: 'as_box_guide', width: 265, height: 89),
            ),
            Positioned(
              left: 10.w,
              bottom: 20.h,
              child: ASSpine(
                path: 'treasure'.spinepaths(),
                width: 75,
                height: 80,
              ),
            ),
            Positioned(
              left: 42.w,
              bottom: 12.h,
              child: const ASTapGuide(width: 80, height: 80),
            ),
          ],
        ),
      ),
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

  var doals_one = ASGameProgressManager().getBoxRewardValue();

  var doals_two = ASGameProgressManager().getBoxRewardValue();

  var doals_three = ASGameProgressManager().getBoxRewardValue();

  var open_index = 0.0;

  bool _taskProgressAdded = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    as_event_fire(ASTrackEvent.boxPopup, {});
    updateboxnumber();
  }

  Future<void> updateboxnumber() async {
    await ASLocalProvider.instance.updateint(
      ASLocalProvider.instance.as_box_indexName,
      0,
    );
  }

  Future<void> _completeBoxTaskOnce() async {
    if (_taskProgressAdded) return;
    _taskProgressAdded = true;
    await ASLocalProvider.instance.incrementTaskProgress(7);
  }

  openBox() async {
    ASAudioUtils().playchouAudio();
    setState(() {
      _showBottom = true;
      _showanimation = false;
    });
    Future.delayed(Duration(milliseconds: 1200), () {
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
              left: _openOne ? 28.w : 48.w,
              top: _openOne ? 428.h : 448.h,
              width: 150.w,
              height: 130.h,
              child: ParticleButton(
                onTap: () {
                  if (_openOne == true ||
                      _openTwo == true ||
                      _openThree == true)
                    return;
                  open_index = doals_one;
                  _openOne = true;
                  _tap_index = 0;
                  openBox();
                },
                child: ASSpine(
                  path: _openOne == true
                      ? 'box_2'.spinepaths()
                      : 'box_1'.spinepaths(),
                  width: _openOne ? 150.w : 100.w,
                  height: _openOne ? 130.h : 100.h,
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
              right: _openTwo ? 28.w : 14.w,
              top: _openTwo ? 428.h : 448.h,
              width: 150.w,
              height: 130.h,
              child: ParticleButton(
                onTap: () {
                  if (_openOne == true ||
                      _openTwo == true ||
                      _openThree == true)
                    return;
                  open_index = doals_two;
                  _openTwo = true;
                  _tap_index = 1;
                  openBox();
                },
                child: ASSpine(
                  path: _openTwo == true
                      ? 'box_2'.spinepaths()
                      : 'box_1'.spinepaths(),
                  width: _openTwo ? 150.w : 100.w,
                  height: _openTwo ? 130.h : 100.h,
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
              top: 218.h,
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
              right: (0.width(context) - (_openThree ? 150.w : 190.w)) * 0.5,
              top: _openThree ? 248.h : 272.h,
              width: 150.w,
              height: 130.h,
              child: ParticleButton(
                onTap: () {
                  if (_openOne == true ||
                      _openTwo == true ||
                      _openThree == true)
                    return;
                  open_index = doals_three;
                  _openThree = true;
                  _tap_index = 2;
                  openBox();
                },
                child: ASSpine(
                  path: _openThree == true
                      ? 'box_2'.spinepaths()
                      : 'box_1'.spinepaths(),
                  width: _openThree ? 150.w : 100.w,
                  height: _openThree ? 130.h : 100.h,
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
              onTap: () async {
                as_event_fire(ASTrackEvent.boxPopupDoubleClick, {});
                var value = doals_one + doals_two + doals_three;
                ASCardAds().as_showAd(
                  context,
                  ASTrackEvent.boxRewarded,
                  onCacheResponse: (onCacheResponse) {
                    Navigator.pop(context, 0);
                  },
                  adDidClosed: (adDidClosed) async {
                    //   playAwardmp3();
                    await _completeBoxTaskOnce();
                    if (!mounted) return;
                    final navigator = Navigator.of(context);
                    Navigator.pop(context, 1);
                    await ASLocalProvider.instance.updatedouble(
                      ASLocalProvider.instance.as_dollar_numberName,
                      0.to2Double(value),
                    );
                    await Future.delayed(const Duration(milliseconds: 300));
                    if (navigator.mounted) {
                      await ASWithdrawalFlow.instance.record(
                        'treasure',
                        navigator.context,
                      );
                    }
                  },
                );
                await ASLocalProvider.instance.updateint(
                  ASLocalProvider.instance.as_box_indexName,
                  0,
                );
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
                  as_event_fire(ASTrackEvent.boxPopupSingleClick, {});
                  if (!mounted) return;
                  var value = 0.0;
                  if (_openOne) {
                    value = doals_one;
                  } else if (_openTwo) {
                    value = doals_two;
                  } else {
                    value = doals_three;
                  }
                  if (ASGameProgressManager().showInterstitialAd()) {
                    ASCardAds().as_showAd(
                      context,
                      ASTrackEvent.boxInterstitial,
                      onCacheResponse: (onCacheResponse) {
                        Navigator.pop(context, 0);
                      },
                      adDidClosed: (adDidClosed) async {
                        //   playAwardmp3();
                        await _completeBoxTaskOnce();
                        if (!mounted) return;
                        Navigator.pop(context, 1);
                        await ASLocalProvider.instance.updatedouble(
                          ASLocalProvider.instance.as_dollar_numberName,
                          0.to2Double(value),
                        );
                      },
                    );
                  } else {
                    await _completeBoxTaskOnce();
                    await ASLocalProvider.instance.updatedouble(
                      ASLocalProvider.instance.as_dollar_numberName,
                      0.to2Double(value),
                    );
                    if (mounted) Navigator.pop(context, 1);
                  }
                  await ASLocalProvider.instance.updateint(
                    ASLocalProvider.instance.as_box_indexName,
                    0,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void playAwardmp3() {
    ASAudioUtils().playDolasAudio();
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

  var _isClaiming = false;

  late final double doals_one;

  var open_index = 0.0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    as_event_fire(ASTrackEvent.dailyBox, {});
    doals_one = ASGameProgressManager().getBoxRewardValue();
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
            width: 0.width(context),
            height: 0.height(context),
            child: ASSpine(path: 'caidai'.spinepaths()),
          ),
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
                        Center(
                          child: ASGradientStrokeText(
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
              left: (0.width(context) - (_openOne ? 280.w : 200.w)) * 0.5,
              top: _openOne ? 280.h : 320.h,
              width: _openOne ? 280.0.w : 200.w,
              height: _openOne ? 200.0.h : 150.h,
              child: ParticleButton(
                onTap: () {
                  as_event_fire(ASTrackEvent.dailyBoxClick, {});
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
          if (!_openOne)
            Positioned(
              left: (0.width(context) - 80.w) * 0.5 + 42.w,
              top: 380.h,
              child: IgnorePointer(
                child: ASTapGuide(width: 80.w, height: 80.h),
              ),
            ),
          Visibility(
            visible: _openOne,
            child: Positioned(
              left: (0.width(context) - 200.w) * 0.5,
              top: 474.h,
              width: 200.0.w,
              height: 40.h,
              child: SizedBox(
                width: 200.0.w,
                height: 30.h,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ASGradientNumberRoller(
                      value: doals_one,
                      duration: 1000,
                      fontSize: 32.0.sp,
                      gradientColors: ['#FFFFFF'.color(), '#FFFFFF'.color()],
                      borderColor: '#47118F'.color(),
                      borderWidth: 2.0,
                      decimalPlaces: 2,
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
                  if (!_openOne || _isClaiming) return;
                  _isClaiming = true;
                  Navigator.pop(context, 1);
                  await ASLocalProvider.instance.updatedouble(
                    ASLocalProvider.instance.as_dollar_numberName,
                    0.to2Double(doals_one),
                  );
                },
                child: Container(
                  width: 262.w,
                  height: 84.h,
                  decoration: BoxDecoration(image: ASDImg('as_green_btn')),
                  child: Center(
                    child: ASStrokeText(
                      text: _openOne == true
                          ? 'Claim \$${doals_one.toStringAsFixed(2)}'
                          : 'Claim \$???',
                      size: 28,
                      color: '#FFFFFF'.color(),
                      weight: FontWeight.w900,
                      skWidth: 2,
                      skColor: '#41740A'.color(),
                    ),
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
  const ASGetDollarDiaologWidget({super.key});

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
  ModalRoute<dynamic>? _dialogRoute;

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

    ASAudioUtils().prepareDolasAudio();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      createDollar();
      setState(() {});
      // 显示100ms开始飞
      Future.delayed(const Duration(milliseconds: 100), () {
        if (mounted) {
          ASAudioUtils().playDolasAudio();
          controller.forward();
        }
      });
    });

    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        final route = _dialogRoute;
        final navigator = route?.navigator;
        if (route != null && navigator != null && route.isActive) {
          navigator.removeRoute(route, 0);
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _dialogRoute ??= ModalRoute.of(context);
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

    const rows = [2, 3, 4, 5, 6];

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
          if (item.finished) {
            return const SizedBox();
          }

          // 未开始，显示小山
          if (status == null) {
            return Positioned(
              left: item.start.dx - 40,
              top: item.start.dy - 25,
              child: Transform.rotate(
                angle: item.rotation,
                child: Transform.scale(
                  scale: item.size,
                  child: ASImg(name: 'as_dollars_icons', width: 72, height: 48),
                ),
              ),
            );
          }
          // 飞行中
          return Positioned(
            left: status.position.dx - 40,
            top: status.position.dy - 25,
            child: Transform.rotate(
              angle: item.rotation,
              child: Transform.scale(
                scale: status.scale,
                child: ASImg(name: 'as_dollars_icons', width: 72, height: 48),
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
