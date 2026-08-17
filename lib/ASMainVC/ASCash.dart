import 'dart:convert';
import 'dart:math';
import 'package:aurastack/ASDialog/ASOther/ASOtherDialog.dart';
import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/as_GradientNumber.dart';
import 'package:aurastack/ASTool/as_GradientText.dart';
import 'package:aurastack/ASTool/as_ad_manger.dart';
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
import '../ASTool/ASTrackEvent.dart';
import '../ASTool/as_LocalProvider.dart';
import '../ASTool/ASWithdrawalFlow.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';
import '../ASTool/as_stroke_text.dart';
import 'ASScratch.dart';

class ASCash extends StatefulWidget {
  final bool autoStartWithdrawal;

  ASCash({super.key, this.autoStartWithdrawal = false});

  @override
  State<ASCash> createState() => ASCashState();
}

class ASCashState extends State<ASCash> with SingleTickerProviderStateMixin {
  final Set<int> _cutInLoadingIndexes = <int>{};

  Future<void> _openWithdrawal(ASLocalProvider provider) async {
    as_event_fire(ASTrackEvent.cashPageClick, {});
    if (provider.as_dollar_number < 1000) {
      final result = await context.tipShow(const ASCashOutDialog());
      if (result != 1 || !mounted) return;
      _openRandomAvailableScratch(provider);
      return;
    }

    if (provider.as_account_id.trim().isEmpty) {
      final formResult = await context.tipShow2(const ASyunying3Dialog());
      if (formResult != 1 || !mounted) return;
      await provider.init();
      if (!mounted || provider.as_account_id.trim().isEmpty) return;
    }

    final infoResult = await context.tipShow2(const ASTXInfoDialog());
    if (infoResult != 1 || !mounted) return;
    final started = await provider.beginWithdrawalTaskFlow();
    if (started && mounted) {
      await ASWithdrawalFlow.instance.showTask(
        context,
        1,
        closeCurrentPageBeforeOpen: true,
      );
    }
  }

  void _openRandomAvailableScratch(ASLocalProvider provider) {
    final usedCounts = [
      provider.as_scrach_end_number_0,
      provider.as_scrach_end_number_1,
      provider.as_scrach_end_number_2,
      provider.as_scrach_end_number_3,
      provider.as_scrach_end_number_4,
      provider.as_scrach_end_number_5,
    ];
    final availableTypes = <int>[
      for (var index = 0; index < usedCounts.length; index++)
        if (usedCounts[index] < 10) index,
    ];
    if (availableTypes.isEmpty) return;
    final type = availableTypes[Random().nextInt(availableTypes.length)];
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => ASScratch(type: type)),
      (route) => route.isFirst,
    );
  }

  void _cutIn(ASLocalProvider provider, int recordIndex, int currentProgress) {
    if (currentProgress >= 100 || _cutInLoadingIndexes.contains(recordIndex)) {
      return;
    }
    final increment = ASGameProgressManager().getCutInProgressValue();
    if (increment <= 0) return;
    as_event_fire(ASTrackEvent.cutIn, {});
    setState(() {
      _cutInLoadingIndexes.add(recordIndex);
    });

    ASCardAds().as_showAd(
      context,
      ASTrackEvent.withdrawalCutInRewarded,
      onCacheResponse: (_) {
        if (!mounted) return;
        setState(() {
          _cutInLoadingIndexes.remove(recordIndex);
        });
      },
      adDidClosed: (success) async {
        if (success) {
          await provider.incrementWithdrawalQueueProgress(
            recordIndex,
            increment,
          );
        }
        if (!mounted) return;
        setState(() {
          _cutInLoadingIndexes.remove(recordIndex);
        });
      },
    );
  }

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.cashPage, {});
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final provider = ASLocalProvider.instance;
      if (widget.autoStartWithdrawal && provider.as_tx_task_index == 0) {
        _openWithdrawal(provider);
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Consumer<ASLocalProvider>(
        builder: (context, provider, child) {
          final withdrawalRecords = _withdrawalRecords(provider.as_tx_list);
          final isWithdrawing =
              provider.as_txing_status && !provider.as_tx_end_status;
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
                        ParticleButton(
                          child: ASImg(
                            name: 'as_back_icon',
                            width: 33,
                            height: 33,
                          ),
                          onTap: () {
                            Navigator.pop(context, 0);
                          },
                        ),
                        SizedBox(width: 120.w),
                        ASText(
                          text: 'Cash',
                          size: 20,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w600,
                        ),
                      ],
                    ),
                    SizedBox(height: 100.h),
                    ASGradientNumberRoller(
                      value: 0.to2Double(provider.as_dollar_number),
                      fontSize: 64,
                      duration: 2,
                      gradientColors: ['#FFD500'.color(), '#FFD500'.color()],
                      borderColor: Colors.transparent,
                      borderWidth: 0.0,
                    ),
                    SizedBox(height: 80.h),
                    if (withdrawalRecords.isNotEmpty)
                      getTXRankWidget(provider, withdrawalRecords),
                    if (withdrawalRecords.isNotEmpty && isWithdrawing)
                      SizedBox(height: 20.h),
                    isWithdrawing
                        ? GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTap: () => ASWithdrawalFlow.instance.showTask(
                              context,
                              provider.as_tx_task_index,
                              closeCurrentPageBeforeOpen: true,
                            ),
                            child: getWidtNomale(provider, withdrawalRecords),
                          )
                        : getWidtNomale(provider, withdrawalRecords),
                    Spacer(),
                    if (!isWithdrawing)
                      ParticleButton(
                        child: Container(
                          width: 339,
                          height: 50,
                          decoration: BoxDecoration(
                            image: ASDImg('as_zi_btn_bg'),
                          ),
                          child: Center(
                            child: ASText(
                              text: 'Withdrawal',
                              size: 24,
                              color: '#FFFFFF'.color(),
                              weight: FontWeight.w600,
                            ),
                          ),
                        ),
                        onTap: () => _openWithdrawal(provider),
                      ),
                    SizedBox(height: 55.h),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget getTXRankWidget(ASLocalProvider provider, List<Object?> records) {
    return SizedBox(
      width: 339.w,
      height: 120.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: records.length,
        separatorBuilder: (context, index) => SizedBox(width: 8.w),
        itemBuilder: (context, index) =>
            _buildTXRankItem(provider, records[index], index),
      ),
    );
  }

  List<Object?> _withdrawalRecords(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) return const [];

    try {
      final decoded = jsonDecode(value);
      if (decoded is List) {
        return decoded
            .where((record) => _recordProgress(record) < 100)
            .toList();
      }
    } catch (_) {
      // 兼容旧版本使用逗号或竖线拼接的本地数据。
    }

    final records = value
        .split(RegExp(r'[,|]'))
        .where((item) => item.trim().isNotEmpty)
        .toList();
    return records;
  }

  int _recordAccount(Object? record, ASLocalProvider provider) {
    if (record is Map) {
      final account = record['account'];
      if (account is num) return account.toInt().clamp(0, 1);
    }
    return provider.as_tx_ing_account.clamp(0, 1);
  }

  int _recordProgress(Object? record) {
    if (record is Map) {
      final progress = record['progress'];
      if (progress is num) return progress.toInt().clamp(0, 100);
    }
    return 0;
  }

  Widget _buildTXRankItem(
    ASLocalProvider provider,
    Object? record,
    int recordIndex,
  ) {
    final account = _recordAccount(record, provider);
    final progress = _recordProgress(record);
    final isLoading = _cutInLoadingIndexes.contains(recordIndex);
    return Container(
      width: 339.w,
      height: 120.h,
      decoration: BoxDecoration(image: ASDImg('as_tx_bg_act_$account')),
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
                    color: account == 0 ? '#1C4779'.color() : '#1C7931'.color(),
                    weight: FontWeight.w600,
                  ),
                  Spacer(),
                  ParticleButton(
                    child: Container(
                      width: 119,
                      height: 33,
                      decoration: BoxDecoration(image: ASDImg('as_zi_s_btn')),
                      child: Center(
                        child: ASText(
                          text: isLoading ? 'Loading...' : 'Cut In',
                          size: 16,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w600,
                        ),
                      ),
                    ),
                    onTap: () => _cutIn(provider, recordIndex, progress),
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
                        width: 300.w * progress / 100,
                        height: 12.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6.h),
                          color: '#4045D8'.color(),
                        ),
                      ),
                    ),
                    Center(
                      child: ASStrokeText(
                        text: '$progress%',
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
                    text: 'Payment Within 7-14 Business Days',
                    size: 12,
                    color: '#A4A4A4'.color(),
                    weight: FontWeight.w200,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            right: 8.w,
            top: 8.h,
            child: ASImg(name: 'as_ads_icon', width: 32, height: 32),
          ),
        ],
      ),
    );
  }

  Widget getWidtNomale(ASLocalProvider provider, List<Object?> records) {
    final isWithdrawing =
        provider.as_txing_status && !provider.as_tx_end_status;
    final activeAccount = isWithdrawing
        ? provider.as_tx_pending_account
        : (records.isEmpty
              ? provider.as_tx_ing_account
              : _recordAccount(records.last, provider));
    final availableBalance = provider.as_dollar_number.clamp(0.0, 1000.0);
    final amountNeeded = max(0.0, 1000.0 - provider.as_dollar_number);
    final withdrawalProgress = availableBalance / 1000.0;
    if (isWithdrawing) {
      final taskIndex = provider.as_tx_task_index;
      final taskName =
          ASWithdrawalFlow.instance.taskName(taskIndex) ?? 'treasure';
      final taskTotal = ASWithdrawalFlow.instance.taskTotal(taskIndex);
      final taskProgress = provider.withdrawalTaskCounter(taskName);
      return Container(
        width: 347.w,
        height: 237,
        decoration: BoxDecoration(
          image: ASDImg(
            activeAccount == 0 ? 'as_cash_center_2' : 'as_cash_center_1',
          ),
        ),
        child: Column(
          children: [
            SizedBox(height: 8),
            Row(
              children: [
                Spacer(),
                SizedBox(
                  width: 126.w,
                  height: 24,
                  child: Center(
                    child: ASText(
                      text: 'In Progress',
                      size: 16,
                      color: '#FFFFFF'.color(),
                      weight: FontWeight.w600,
                    ),
                  ),
                ),
                SizedBox(width: 14.w),
              ],
            ),
            SizedBox(height: 18),
            Row(
              children: [
                SizedBox(width: 11.w),
                ASText(
                  text: '\$ 1000',
                  size: 32,
                  color: activeAccount == 0
                      ? '#1C4779'.color()
                      : '#1C7931'.color(),
                  weight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                SizedBox(width: 11.w),
                ASText(
                  text: 'Risk Monitoring',
                  size: 14,
                  color: '#000000'.color(),
                  weight: FontWeight.w600,
                ),
              ],
            ),
            SizedBox(height: 8),
            Row(
              children: [
                SizedBox(width: 11.w),
                SizedBox(
                  width: 328.w,
                  height: 32,
                  child: ASText(
                    text:
                        "Abnormal activity detected on youraccount. Complete the task to verify you're a real person.",
                    size: 11,
                    color: '#837888'.color(),
                    weight: FontWeight.w200,
                    maxLines: 2,
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Row(
              children: [
                SizedBox(width: 32.w),
                ASImg(
                  name: ASWithdrawalFlow.instance.taskIcon(taskName),
                  width: 46,
                  height: 46,
                ),
                SizedBox(width: 24.w),
                ASText(
                  text: ASWithdrawalFlow.instance.taskProgressLabel(
                    taskName,
                    taskProgress,
                    taskTotal,
                  ),
                  size: 14,
                  color: '#000000'.color(),
                  weight: FontWeight.w600,
                ),
              ],
            ),
          ],
        ),
      );
    }
    return Container(
      width: 347.w,
      height: 217.h,
      decoration: BoxDecoration(image: ASDImg('as_cash_center_0')),
      child: Column(
        children: [
          SizedBox(height: 16.h),
          ASText(
            text: 'Withdrawal Instructions',
            size: 16,
            color: '#FFFFFF'.color(),
            weight: FontWeight.w600,
          ),
          SizedBox(height: 25.h),
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
                  color: '#4A474B'.color(),
                ),
                children: <TextSpan>[
                  TextSpan(text: 'For Security,\nThe Minimum Withdrawal is  '),
                  TextSpan(
                    text: '\$1000',
                    style: TextStyle(color: '#1C7931'.color(), fontSize: 20),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 38.h),
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
                  color: '#000000'.color(),
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: '\$${amountNeeded.toStringAsFixed(2)}',
                    style: TextStyle(color: '#D86B0B'.color(), fontSize: 14),
                  ),
                  TextSpan(text: ' More Needed To Withdraw '),
                  TextSpan(
                    text: '\$1000.',
                    style: TextStyle(color: '#1C7931'.color(), fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 0.h),
          Container(
            width: 304.w,
            height: 16,
            decoration: BoxDecoration(
              color: '#C0BFCA'.color(),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Stack(
              children: [
                Positioned(
                  left: 2.w,
                  top: 2,
                  child: Container(
                    width:
                        300.w *
                        (withdrawalProgress >= 1 ? 1 : withdrawalProgress),
                    height: 12,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      color: '#4045D8'.color(),
                    ),
                  ),
                ),
                Center(
                  child: ASStrokeText(
                    text: '\$${availableBalance.toStringAsFixed(2)}/\$1000',
                    size: 12,
                    color: '#FFFFFF'.color(),
                    weight: FontWeight.w600,
                    skWidth: 1,
                    skColor: '#000000'.color(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
