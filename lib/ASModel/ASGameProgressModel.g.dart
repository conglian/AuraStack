// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ASGameProgressModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ASGameProgressModel _$ASGameProgressModelFromJson(Map<String, dynamic> json) =>
    ASGameProgressModel(
      intAd: (json['int_ad'] as List<dynamic>?)
              ?.map(
                  (e) => ASAdProgressRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASAdProgressRange>[],
      pigtaskIntAd: (json['pigtask_int_ad'] as List<dynamic>?)
              ?.map(
                  (e) => ASAdProgressRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASAdProgressRange>[],
      extraBonus: json['extra_bonus'] == null
          ? const ASStandardGameProgress()
          : ASStandardGameProgress.fromJson(
              json['extra_bonus'] as Map<String, dynamic>),
      cash777: json['cash_777'] == null
          ? const ASCash777Progress()
          : ASCash777Progress.fromJson(
              json['cash_777'] as Map<String, dynamic>),
      fortuneRush: json['fortune_rush'] == null
          ? const ASStandardGameProgress()
          : ASStandardGameProgress.fromJson(
              json['fortune_rush'] as Map<String, dynamic>),
      candyRush: json['candy_rush'] == null
          ? const ASStandardGameProgress()
          : ASStandardGameProgress.fromJson(
              json['candy_rush'] as Map<String, dynamic>),
      sweetTime: json['sweet_time'] == null
          ? const ASStandardGameProgress()
          : ASStandardGameProgress.fromJson(
              json['sweet_time'] as Map<String, dynamic>),
      cash50x: json['cash_50x'] == null
          ? const ASCash50xProgress()
          : ASCash50xProgress.fromJson(
              json['cash_50x'] as Map<String, dynamic>),
      freeCard: (json['free_card'] as num?)?.toInt() ?? 0,
      boxInterval: (json['box_interval'] as num?)?.toInt() ?? 0,
      boxReward: (json['box_reward'] as List<dynamic>?)
              ?.map((e) => ASRewardRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASRewardRange>[],
      dailyPigTask: json['daily_pig_task'] == null
          ? const ASDailyPigTaskProgress()
          : ASDailyPigTaskProgress.fromJson(
              json['daily_pig_task'] as Map<String, dynamic>),
      diceAward: (json['dice_award'] as List<dynamic>?)
              ?.map((e) => ASRewardRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASRewardRange>[],
      wheelAward: (json['wheel_award'] as List<dynamic>?)
              ?.map((e) => ASRewardRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASRewardRange>[],
      bubbleReward: (json['bubble_reward'] as List<dynamic>?)
              ?.map((e) => ASRewardRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASRewardRange>[],
      withdrawTask: (json['withdraw_task'] as List<dynamic>?)
              ?.map((e) =>
                  ASWithdrawTaskProgress.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASWithdrawTaskProgress>[],
      cutIn: (json['cut_in'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const <int>[],
      open_area: (json['open_area'] as num?)?.toDouble() ?? 0.5,
    );

Map<String, dynamic> _$ASGameProgressModelToJson(
        ASGameProgressModel instance) =>
    <String, dynamic>{
      'int_ad': instance.intAd.map((e) => e.toJson()).toList(),
      'pigtask_int_ad': instance.pigtaskIntAd.map((e) => e.toJson()).toList(),
      'extra_bonus': instance.extraBonus.toJson(),
      'cash_777': instance.cash777.toJson(),
      'fortune_rush': instance.fortuneRush.toJson(),
      'candy_rush': instance.candyRush.toJson(),
      'sweet_time': instance.sweetTime.toJson(),
      'cash_50x': instance.cash50x.toJson(),
      'free_card': instance.freeCard,
      'box_interval': instance.boxInterval,
      'box_reward': instance.boxReward.map((e) => e.toJson()).toList(),
      'daily_pig_task': instance.dailyPigTask.toJson(),
      'dice_award': instance.diceAward.map((e) => e.toJson()).toList(),
      'wheel_award': instance.wheelAward.map((e) => e.toJson()).toList(),
      'bubble_reward': instance.bubbleReward.map((e) => e.toJson()).toList(),
      'withdraw_task': instance.withdrawTask.map((e) => e.toJson()).toList(),
      'cut_in': instance.cutIn,
      'open_area': instance.open_area,
    };

ASAdProgressRange _$ASAdProgressRangeFromJson(Map<String, dynamic> json) =>
    ASAdProgressRange(
      firstNumber: (json['first_number'] as num?)?.toInt() ?? 0,
      point: (json['point'] as num?)?.toInt() ?? 0,
      endNumber: (json['end_number'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ASAdProgressRangeToJson(ASAdProgressRange instance) =>
    <String, dynamic>{
      'first_number': instance.firstNumber,
      'point': instance.point,
      'end_number': instance.endNumber,
    };

ASStandardGameProgress _$ASStandardGameProgressFromJson(
        Map<String, dynamic> json) =>
    ASStandardGameProgress(
      pop: (json['pop'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
      point: json['point'] == null
          ? const ASProbabilityReward()
          : ASProbabilityReward.fromJson(json['point'] as Map<String, dynamic>),
      nullProbability: (json['null'] as num?)?.toDouble() ?? 0,
      diceProbability: (json['dice_probability'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ASStandardGameProgressToJson(
        ASStandardGameProgress instance) =>
    <String, dynamic>{
      'pop': instance.pop,
      'point': instance.point.toJson(),
      'null': instance.nullProbability,
      'dice_probability': instance.diceProbability,
    };

ASCash777Progress _$ASCash777ProgressFromJson(Map<String, dynamic> json) =>
    ASCash777Progress(
      pop: (json['pop'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
      point7: json['point_7'] == null
          ? const ASProbabilityReward()
          : ASProbabilityReward.fromJson(
              json['point_7'] as Map<String, dynamic>),
      point77: json['point_77'] == null
          ? const ASProbabilityReward()
          : ASProbabilityReward.fromJson(
              json['point_77'] as Map<String, dynamic>),
      point777: json['point_777'] == null
          ? const ASProbabilityReward()
          : ASProbabilityReward.fromJson(
              json['point_777'] as Map<String, dynamic>),
      nullProbability: (json['null'] as num?)?.toDouble() ?? 0,
      diceProbability: (json['dice_probability'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ASCash777ProgressToJson(ASCash777Progress instance) =>
    <String, dynamic>{
      'pop': instance.pop,
      'point_7': instance.point7.toJson(),
      'point_77': instance.point77.toJson(),
      'point_777': instance.point777.toJson(),
      'null': instance.nullProbability,
      'dice_probability': instance.diceProbability,
    };

ASCash50xProgress _$ASCash50xProgressFromJson(Map<String, dynamic> json) =>
    ASCash50xProgress(
      pop: (json['pop'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
      point20x: json['point_20x'] == null
          ? const ASProbabilityReward()
          : ASProbabilityReward.fromJson(
              json['point_20x'] as Map<String, dynamic>),
      point30x: json['point_30x'] == null
          ? const ASProbabilityReward()
          : ASProbabilityReward.fromJson(
              json['point_30x'] as Map<String, dynamic>),
      point50x: json['point_50x'] == null
          ? const ASProbabilityReward()
          : ASProbabilityReward.fromJson(
              json['point_50x'] as Map<String, dynamic>),
      nullProbability: (json['null'] as num?)?.toDouble() ?? 0,
      diceProbability: (json['dice_probability'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ASCash50xProgressToJson(ASCash50xProgress instance) =>
    <String, dynamic>{
      'pop': instance.pop,
      'point_20x': instance.point20x.toJson(),
      'point_30x': instance.point30x.toJson(),
      'point_50x': instance.point50x.toJson(),
      'null': instance.nullProbability,
      'dice_probability': instance.diceProbability,
    };

ASProbabilityReward _$ASProbabilityRewardFromJson(Map<String, dynamic> json) =>
    ASProbabilityReward(
      probability: (json['probability'] as num?)?.toDouble() ?? 0,
      ranges: (json['ranges'] as List<dynamic>?)
              ?.map((e) => ASRewardRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASRewardRange>[],
    );

Map<String, dynamic> _$ASProbabilityRewardToJson(
        ASProbabilityReward instance) =>
    <String, dynamic>{
      'probability': instance.probability,
      'ranges': instance.ranges.map((e) => e.toJson()).toList(),
    };

ASRewardRange _$ASRewardRangeFromJson(Map<String, dynamic> json) =>
    ASRewardRange(
      firstNumber: (json['first_number'] as num?)?.toInt() ?? 0,
      endNumber: (json['end_number'] as num?)?.toInt() ?? 0,
      reward: (json['reward'] as List<dynamic>?)
              ?.map((e) => (e as num).toDouble())
              .toList() ??
          const <double>[],
    );

Map<String, dynamic> _$ASRewardRangeToJson(ASRewardRange instance) =>
    <String, dynamic>{
      'first_number': instance.firstNumber,
      'end_number': instance.endNumber,
      'reward': instance.reward,
    };

ASDailyPigTaskProgress _$ASDailyPigTaskProgressFromJson(
        Map<String, dynamic> json) =>
    ASDailyPigTaskProgress(
      smallReward: (json['small_reward'] as List<dynamic>?)
              ?.map((e) => ASRewardRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASRewardRange>[],
      bigReward: (json['big_reward'] as List<dynamic>?)
              ?.map((e) => ASRewardRange.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ASRewardRange>[],
    );

Map<String, dynamic> _$ASDailyPigTaskProgressToJson(
        ASDailyPigTaskProgress instance) =>
    <String, dynamic>{
      'small_reward': instance.smallReward.map((e) => e.toJson()).toList(),
      'big_reward': instance.bigReward.map((e) => e.toJson()).toList(),
    };

ASWithdrawTaskProgress _$ASWithdrawTaskProgressFromJson(
        Map<String, dynamic> json) =>
    ASWithdrawTaskProgress(
      name: json['name'] as String? ?? '',
      num: (json['num'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ASWithdrawTaskProgressToJson(
        ASWithdrawTaskProgress instance) =>
    <String, dynamic>{
      'name': instance.name,
      'num': instance.num,
    };
