import 'package:aurastack/ASDialog/ASAward/ASAwardDialog.dart';
import 'package:aurastack/ASMainVC/ASDice.dart';
import 'package:aurastack/ASMainVC/ASScratch.dart';
import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/as_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import '../ASTool/as_LocalProvider.dart';
import '../ASTool/ASTBAEventTool.dart';
import '../ASTool/ASTrackEvent.dart';
import '../ASTool/as_extension_help.dart';
import '../ASTool/as_img.dart';
import '../ASTool/as_stroke_text.dart';

class ASTask extends StatefulWidget {
  const ASTask({super.key});

  @override
  State<ASTask> createState() => ASTaskState();
}

class ASTaskState extends State<ASTask> {
  static const List<_ASTaskConfig> _tasks = [
    _ASTaskConfig('Scratch ExtraBonus 3 Card', 'as_task_card'),
    _ASTaskConfig('Scratch CandyRush 3 Card', 'as_task_card'),
    _ASTaskConfig('Scratch SweetTime 3 Card', 'as_task_card'),
    _ASTaskConfig('Scratch Cash777 3 Card', 'as_task_card'),
    _ASTaskConfig('Scratch FortuneRush 3 Card', 'as_task_card'),
    _ASTaskConfig('Scratch Cash 50X 3 Card', 'as_task_card'),
    _ASTaskConfig('Play 3 Spin', 'as_task_wheel'),
    _ASTaskConfig('Play 3 Treasure', 'as_task_box'),
    _ASTaskConfig('Play 3 Dice', 'as_task_dice'),
  ];

  @override
  void initState() {
    super.initState();
    as_event_fire(ASTrackEvent.pigTaskPage, {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Consumer<ASLocalProvider>(
        builder: (context, provider, child) {
          final completedCount = provider.as_task_progress
              .where((progress) => progress >= 3)
              .length;
          final canClaimPig = completedCount >= _tasks.length;

          return Stack(
            fit: StackFit.expand,
            children: [
              ASImg(
                name: 'as_task_bg',
                width: 0.width(context),
                height: 0.height(context),
              ),
              SafeArea(
                bottom: false,
                child: Column(
                  children: [
                    SizedBox(
                      height: 42,
                      child: Row(
                        children: [
                          SizedBox(width: 22.w),
                          ParticleButton(
                            child: ASImg(
                              name: 'as_back_icon',
                              width: 33,
                              height: 33,
                            ),
                            onTap: () => Navigator.pop(context, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 130.h),
                    _buildPigProgress(
                      provider,
                      canClaimPig,
                    ),
                    SizedBox(height: 12.h),
                    Expanded(
                      child: ListView.separated(
                        padding: EdgeInsets.only(bottom: 28.h),
                        itemCount: _tasks.length,
                        separatorBuilder: (_, _) => SizedBox(height: 6.h),
                        itemBuilder: (_, index) {
                          return Center(
                            child: _buildTaskCell(provider, index),
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
    );
  }

  Widget _buildPigProgress(
    ASLocalProvider provider,
    bool canClaimPig,
  ) {
    final pigProgress = provider.as_task_pig_progress;
    final progress = pigProgress / 9;
    return Container(
      width: 351.w,
      height: 64.h,
      decoration: BoxDecoration(image: ASDImg('as_task_center_bgs')),
      child: Stack(
        children: [
          Positioned(
            left: (351.w - 246) * 0.5,
            top: 22.h,
            child: Container(
              width: 246,
              height: 18,
              decoration: BoxDecoration(image: ASDImg('as_home_pro_0')),
              child: Stack(
                children: [
                  Container(
                    width: 246 * progress,
                    height: 18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(9),
                      color: '#FFEE38'.color(),
                    ),
                  ),
                  Center(
                    child: ASStrokeText(
                      text: '$pigProgress/9',
                      size: 14,
                      color: '#FFFFFF'.color(),
                      weight: FontWeight.w900,
                      skWidth: 1,
                      skColor: '#000000'.color(),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 8.h,
            right: 0.w,
            child: ParticleButton(
              onTap: () => _claimPigReward(provider, canClaimPig),
              child: ASBouncyImage(
                imagePath: 'as_task_pig',
                width: 58,
                height: 52,
                enableAnimation: canClaimPig && !provider.as_task_pig_claimed,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTaskCell(ASLocalProvider provider, int index) {
    final task = _tasks[index];
    final progress = provider.as_task_progress[index].clamp(0, 3);
    final isComplete = progress >= 3;
    final isClaimed = provider.as_task_claimed[index];
    final background = isClaimed
        ? 'as_task_center_2'
        : isComplete
            ? 'as_task_center_1'
            : 'as_task_center_0';
    final reward = ASGameProgressManager().getSmallTaskRewardValue();

    return Container(
      width: 351.w,
      height: 86.h,
      decoration: BoxDecoration(image: ASDImg(background)),
      child: Row(
        children: [
          SizedBox(width: 8.w),
          ASImg(name: task.icon, width: 50, height: 52),
          SizedBox(width: 0.w),
          SizedBox(
            width: 170.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 16.h),
                ASText(
                  text: task.title,
                  size: 12,
                  color: isClaimed
                      ? '#94A48F'.color()
                      : '#642C1B'.color(),
                  weight: FontWeight.w900,
                  maxLines: 1,
                ),
                SizedBox(height: 12.h),
                Container(
                  width: 108.w,
                  height: 18.h,
                  decoration: BoxDecoration(
                    color: isClaimed
                        ? '#9AC4A0'.color()
                        : '#D6D2B7'.color(),
                    borderRadius: BorderRadius.circular(9.h),
                  ),
                  child: Stack(
                    children: [
                      Container(
                        width: 108.w * (progress / 3),
                        height: 18.h,
                        decoration: BoxDecoration(
                          color: isClaimed
                              ? '#75B581'.color()
                              : '#39A43B'.color(),
                          borderRadius: BorderRadius.circular(9.h),
                        ),
                      ),
                      Center(
                        child: ASStrokeText(
                          text: '$progress/3',
                          size: 14,
                          color: '#FFFFFF'.color(),
                          weight: FontWeight.w700,
                          skWidth: 1,
                          skColor: '#000000'.color(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!isClaimed)
            Expanded(
              child: Column(
                children: [
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ASImg(name: 'as_doaller_wheel', width: 25, height: 25),
                      SizedBox(width: 3.w),
                      ASStrokeText(
                        text: '\$${_formatReward(reward)}',
                        size: 18,
                        color: '#FFFFFF'.color(),
                        weight: FontWeight.w900,
                        skWidth: 2,
                        skColor: '#7D3F1A'.color(),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  ParticleButton(
                    onTap: () => isComplete
                        ? _claimTask(provider, index, reward)
                        : _goTask(index),
                    child: ASImg(
                      name: isComplete ? 'as_task_claim' : 'as_task_go',
                      width: 94.w,
                      height: 31.h,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Future<void> _claimTask(
    ASLocalProvider provider,
    int index,
    double reward,
  ) async {
    if (provider.as_task_progress[index] < 3 ||
        provider.as_task_claimed[index]) {
      return;
    }
    await provider.claimTask(index);
    await provider.updatedouble(provider.as_dollar_numberName, reward);
  }

  Future<void> _goTask(int index) async {
    if (index < 6) {
      await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ASScratch(type: index)),
      );
      return;
    }
    if (index == 6 || index == 8) {
      await context.tipShow2(ASDice());
      return;
    }
    Navigator.pop(context, 0);
  }

  Future<void> _claimPigReward(
    ASLocalProvider provider,
    bool canClaimPig,
  ) async {
    if (!canClaimPig || provider.as_task_pig_claimed) return;
    as_event_fire(ASTrackEvent.pigTaskEndClick, {});
    // TODO: 在这里添加顶部金猪奖励领取逻辑。
    context.tipShow(
      ASJackPotDialog(
        award: ASGameProgressManager().getSmallTaskRewardValue(),
        rewardType: 'task',
      ),
    );
    await provider.claimTaskPig();
  }

  String _formatReward(double value) {
    if (value == value.truncateToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(2);
  }
}

class _ASTaskConfig {
  final String title;
  final String icon;

  const _ASTaskConfig(this.title, this.icon);
}
