import 'package:flutter/material.dart';

import '../ASDialog/ASAward/ASAwardDialog.dart';
import '../ASDialog/ASCash/ASCashDialog.dart';
import '../ASDialog/ASOther/ASOtherDialog.dart';
import '../ASMainVC/ASCash.dart';
import '../ASMainVC/ASDice.dart';
import '../ASMainVC/ASScratch.dart';
import 'ASGameProgressManager.dart';
import 'as_LocalProvider.dart';
import 'as_extension_help.dart';

/// Coordinates the three configured tasks in one withdrawal round.
class ASWithdrawalFlow {
  ASWithdrawalFlow._();

  static final ASWithdrawalFlow instance = ASWithdrawalFlow._();

  ASLocalProvider get provider => ASLocalProvider.instance;

  String? taskName(int index) {
    final tasks = ASGameProgressManager().gameProgressModel.withdrawTask;
    if (index < 1 || index > tasks.length) return null;
    return tasks[index - 1].name.toLowerCase();
  }

  int taskTotal(int index) {
    final tasks = ASGameProgressManager().gameProgressModel.withdrawTask;
    if (index < 1 || index > tasks.length) return 0;
    return tasks[index - 1].num;
  }

  String taskTitle(int index) => switch (index) {
    1 => 'High Demand Alert',
    2 => 'High Traffic Withdrawal Queue',
    _ => 'Secure Payout Protection',
  };

  String taskDescription(int index) => switch (index) {
    1 => 'Secure your withdrawal spot before it fills up.',
    2 => 'Verify now to secure your payout position.',
    _ => 'Finish verification to unlock your reward.',
  };

  String taskIcon(String name) => switch (name) {
    'dice' => 'as_tx_dice_icon',
    'spins' => 'as_tx_wheel_icon',
    'treasure' => 'as_tx_treasure_icon',
    _ => 'as_tx_scratch_icon',
  };

  String taskProgressLabel(String name, int progress, int total) => switch (name) {
    'scratch' => 'Scratch $progress/$total Card',
    'dice' => 'Play $progress/$total dice',
    'treasure' => 'Play $progress/$total treasure',
    'spins' => 'Play $progress/$total spin',
    _ => '$progress/$total',
  };

  Future<void> showTask(
    BuildContext context,
    int index, {
    bool closeCurrentPageBeforeOpen = false,
  }) async {
    final name = taskName(index);
    if (name == null) return;
    final result = await context.tipShow2(
      ASTXHumanDialog(
        taskIndex: index,
        title: taskTitle(index),
        description: taskDescription(index),
        taskName: name,
        progress: provider.withdrawalTaskCounter(name),
        total: taskTotal(index),
      ),
    );
    if (result == 1 && context.mounted) {
      final navigator = Navigator.of(context);
      final shouldCloseCurrentPage =
          closeCurrentPageBeforeOpen || navigator.canPop();
      if (!shouldCloseCurrentPage) {
        await openTaskPage(context, name);
        return;
      }
      // 无论当前位于哪一层任务页面，都先回到首页一级路由。
      navigator.popUntil((route) => route.isFirst);
      await Future.delayed(const Duration(milliseconds: 300));
      if (navigator.mounted) {
        await openTaskPage(navigator.context, name);
      }
    }
  }

  Future<void> openTaskPage(BuildContext context, String name) async {
    switch (name) {
      case 'scratch':
        final used = [
          provider.as_scrach_end_number_0,
          provider.as_scrach_end_number_1,
          provider.as_scrach_end_number_2,
          provider.as_scrach_end_number_3,
          provider.as_scrach_end_number_4,
          provider.as_scrach_end_number_5,
        ];
        final type = used.indexWhere((count) => count < 10);
        if (type >= 0) {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => ASScratch(type: type)),
          );
        }
      case 'dice':
        await context.tipShow(const ASDice());
      case 'spins':
        await context.tipShow(const ASDice());
      case 'treasure':
        final interval = ASGameProgressManager().gameProgressModel.boxInterval;
        if (interval > 0 && provider.as_box_index >= interval) {
          await context.tipShow(ASBoxOpenDiaologWidget());
        } else {
          final used = [
            provider.as_scrach_end_number_0,
            provider.as_scrach_end_number_1,
            provider.as_scrach_end_number_2,
            provider.as_scrach_end_number_3,
            provider.as_scrach_end_number_4,
            provider.as_scrach_end_number_5,
          ];
          final type = used.indexWhere((count) => count < 10);
          if (type >= 0) {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ASScratch(type: type)),
            );
          }
        }
    }
  }

  Future<void> record(String name, BuildContext context) async {
    final index = provider.as_tx_task_index;
    if (index < 1 || taskName(index) != name) return;
    final count = await provider.incrementWithdrawalTaskCounter(name);
    if (count < taskTotal(index) || !context.mounted) return;

    if (index == 1) {
      final result = await context.tipShow(const ASyunying6Dialog());
      if (result != 1 || !context.mounted) return;
      await provider.setWithdrawalTaskIndex(2);
      await showTask(context, 2);
    } else if (index == 2) {
      final application = await context.tipShow(const ASyunying4Dialog());
      if (application != 1 || !context.mounted) return;
      await context.tipShow(const ASyunying5Dialog());
      if (!context.mounted) return;
      await provider.setWithdrawalTaskIndex(3);
      await showTask(context, 3);
    } else if (index == 3) {
      // 等申请成功弹窗退场及上一轮抬手事件结束，避免立即关闭恭喜弹窗。
      await Future.delayed(const Duration(milliseconds: 500));
      if (!context.mounted) return;
      await context.tipShow(const ASTXATaskEndDialog());
      if (!context.mounted) return;
      await provider.finalizeWithdrawalTaskFlow();
      if (context.mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ASCash()),
        );
      }
    }
  }
}
