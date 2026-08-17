import 'package:json_annotation/json_annotation.dart';

part 'ASGameProgressModel.g.dart';

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ASGameProgressModel {
  final List<ASAdProgressRange> intAd;
  final List<ASAdProgressRange> pigtaskIntAd;
  final ASStandardGameProgress extraBonus;
  @JsonKey(name: 'cash_777')
  final ASCash777Progress cash777;
  final ASStandardGameProgress fortuneRush;
  final ASStandardGameProgress candyRush;
  final ASStandardGameProgress sweetTime;
  @JsonKey(name: 'cash_50x')
  final ASCash50xProgress cash50x;
  final int freeCard;
  final int boxInterval;
  final List<ASRewardRange> boxReward;
  final ASDailyPigTaskProgress dailyPigTask;
  final List<ASRewardRange> diceAward;
  final List<ASRewardRange> wheelAward;
  final List<ASRewardRange> bubbleReward;
  final List<ASWithdrawTaskProgress> withdrawTask;
  final List<int> cutIn;
  final double open_area;

  const ASGameProgressModel({
    this.intAd = const <ASAdProgressRange>[],
    this.pigtaskIntAd = const <ASAdProgressRange>[],
    this.extraBonus = const ASStandardGameProgress(),
    this.cash777 = const ASCash777Progress(),
    this.fortuneRush = const ASStandardGameProgress(),
    this.candyRush = const ASStandardGameProgress(),
    this.sweetTime = const ASStandardGameProgress(),
    this.cash50x = const ASCash50xProgress(),
    this.freeCard = 0,
    this.boxInterval = 0,
    this.boxReward = const <ASRewardRange>[],
    this.dailyPigTask = const ASDailyPigTaskProgress(),
    this.diceAward = const <ASRewardRange>[],
    this.wheelAward = const <ASRewardRange>[],
    this.bubbleReward = const <ASRewardRange>[],
    this.withdrawTask = const <ASWithdrawTaskProgress>[],
    this.cutIn = const <int>[],
    this.open_area = 0.5,
  });

  factory ASGameProgressModel.fromJson(Map<String, dynamic> json) =>
      _$ASGameProgressModelFromJson(json);

  Map<String, dynamic> toJson() => _$ASGameProgressModelToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ASAdProgressRange {
  final int firstNumber;
  final int point;
  final int endNumber;

  const ASAdProgressRange({
    this.firstNumber = 0,
    this.point = 0,
    this.endNumber = 0,
  });

  factory ASAdProgressRange.fromJson(Map<String, dynamic> json) =>
      _$ASAdProgressRangeFromJson(json);

  Map<String, dynamic> toJson() => _$ASAdProgressRangeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ASStandardGameProgress {
  final List<double> pop;
  final ASProbabilityReward point;
  @JsonKey(name: 'null')
  final double nullProbability;
  final double diceProbability;

  const ASStandardGameProgress({
    this.pop = const <double>[],
    this.point = const ASProbabilityReward(),
    this.nullProbability = 0,
    this.diceProbability = 0,
  });

  factory ASStandardGameProgress.fromJson(Map<String, dynamic> json) =>
      _$ASStandardGameProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ASStandardGameProgressToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ASCash777Progress {
  final List<double> pop;
  @JsonKey(name: 'point_7')
  final ASProbabilityReward point7;
  @JsonKey(name: 'point_77')
  final ASProbabilityReward point77;
  @JsonKey(name: 'point_777')
  final ASProbabilityReward point777;
  @JsonKey(name: 'null')
  final double nullProbability;
  final double diceProbability;

  const ASCash777Progress({
    this.pop = const <double>[],
    this.point7 = const ASProbabilityReward(),
    this.point77 = const ASProbabilityReward(),
    this.point777 = const ASProbabilityReward(),
    this.nullProbability = 0,
    this.diceProbability = 0,
  });

  factory ASCash777Progress.fromJson(Map<String, dynamic> json) =>
      _$ASCash777ProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ASCash777ProgressToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ASCash50xProgress {
  final List<double> pop;
  @JsonKey(name: 'point_20x')
  final ASProbabilityReward point20x;
  @JsonKey(name: 'point_30x')
  final ASProbabilityReward point30x;
  @JsonKey(name: 'point_50x')
  final ASProbabilityReward point50x;
  @JsonKey(name: 'null')
  final double nullProbability;
  final double diceProbability;

  const ASCash50xProgress({
    this.pop = const <double>[],
    this.point20x = const ASProbabilityReward(),
    this.point30x = const ASProbabilityReward(),
    this.point50x = const ASProbabilityReward(),
    this.nullProbability = 0,
    this.diceProbability = 0,
  });

  factory ASCash50xProgress.fromJson(Map<String, dynamic> json) =>
      _$ASCash50xProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ASCash50xProgressToJson(this);
}

@JsonSerializable(explicitToJson: true)
class ASProbabilityReward {
  final double probability;
  final List<ASRewardRange> ranges;

  const ASProbabilityReward({
    this.probability = 0,
    this.ranges = const <ASRewardRange>[],
  });

  factory ASProbabilityReward.fromJson(Map<String, dynamic> json) =>
      _$ASProbabilityRewardFromJson(json);

  Map<String, dynamic> toJson() => _$ASProbabilityRewardToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake)
class ASRewardRange {
  final int firstNumber;
  final int endNumber;
  final List<double> reward;

  const ASRewardRange({
    this.firstNumber = 0,
    this.endNumber = 0,
    this.reward = const <double>[],
  });

  factory ASRewardRange.fromJson(Map<String, dynamic> json) =>
      _$ASRewardRangeFromJson(json);

  Map<String, dynamic> toJson() => _$ASRewardRangeToJson(this);
}

@JsonSerializable(fieldRename: FieldRename.snake, explicitToJson: true)
class ASDailyPigTaskProgress {
  final List<ASRewardRange> smallReward;
  final List<ASRewardRange> bigReward;

  const ASDailyPigTaskProgress({
    this.smallReward = const <ASRewardRange>[],
    this.bigReward = const <ASRewardRange>[],
  });

  factory ASDailyPigTaskProgress.fromJson(Map<String, dynamic> json) =>
      _$ASDailyPigTaskProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ASDailyPigTaskProgressToJson(this);
}

@JsonSerializable()
class ASWithdrawTaskProgress {
  final String name;
  final int num;

  const ASWithdrawTaskProgress({this.name = '', this.num = 0});

  factory ASWithdrawTaskProgress.fromJson(Map<String, dynamic> json) =>
      _$ASWithdrawTaskProgressFromJson(json);

  Map<String, dynamic> toJson() => _$ASWithdrawTaskProgressToJson(this);
}

class ASExtraBonusResult {
  final List<int> topNumbers;
  final List<int> bottomNumbers;
  final List<double> rewardValues;
  final bool isWinner;
  final bool hasDice;
  final int winningTopIndex;
  final int winningBottomIndex;

  const ASExtraBonusResult({
    required this.topNumbers,
    required this.bottomNumbers,
    required this.rewardValues,
    required this.isWinner,
    required this.hasDice,
    this.winningTopIndex = -1,
    this.winningBottomIndex = -1,
  });
}

class ASCandyRushResult {
  final List<int> bottomNumbers;
  final double topRewardValue;
  final bool isWinner;
  final bool hasDice;
  final int winningIndex;
  final int diceIndex;

  const ASCandyRushResult({
    required this.bottomNumbers,
    required this.topRewardValue,
    required this.isWinner,
    required this.hasDice,
    this.winningIndex = -1,
    this.diceIndex = -1,
  });
}

class ASSweetTimeResult {
  final List<List<int>> bottomNumberGroups;
  final double topRewardValue;
  final bool isWinner;
  final bool hasDice;
  final int winningGroupIndex;
  final int winningItemIndex;
  final int diceGroupIndex;
  final int diceItemIndex;

  const ASSweetTimeResult({
    required this.bottomNumberGroups,
    required this.topRewardValue,
    required this.isWinner,
    required this.hasDice,
    this.winningGroupIndex = -1,
    this.winningItemIndex = -1,
    this.diceGroupIndex = -1,
    this.diceItemIndex = -1,
  });
}

class ASCash777Result {
  final List<int> bottomNumbers;
  final List<double> rewardValues;
  final double winningRewardValue;
  final bool isWinner;
  final bool hasDice;
  final int winningNumber;
  final int winningIndex;
  final int diceIndex;

  const ASCash777Result({
    required this.bottomNumbers,
    required this.rewardValues,
    required this.winningRewardValue,
    required this.isWinner,
    required this.hasDice,
    this.winningNumber = -1,
    this.winningIndex = -1,
    this.diceIndex = -1,
  });
}

class ASFortuneRushResult {
  final List<int> bottomNumbers;
  final List<double> rewardValues;
  final int topWinningNumber;
  final bool isWinner;
  final bool hasDice;
  final int winningIndex;
  final int rewardIndex;
  final int diceIndex;

  const ASFortuneRushResult({
    required this.bottomNumbers,
    required this.rewardValues,
    required this.topWinningNumber,
    required this.isWinner,
    required this.hasDice,
    this.winningIndex = -1,
    this.rewardIndex = -1,
    this.diceIndex = -1,
  });
}

class ASCash50xResult {
  final List<int> bottomNumbers;
  final List<double> rewardValues;
  final double winningRewardValue;
  final int topWinningNumber;
  final bool isWinner;
  final bool hasDice;
  final int winningIndex;
  final int rewardIndex;
  final int diceIndex;

  const ASCash50xResult({
    required this.bottomNumbers,
    required this.rewardValues,
    required this.topWinningNumber,
    required this.isWinner,
    required this.hasDice,
    this.winningRewardValue = 0,
    this.winningIndex = -1,
    this.rewardIndex = -1,
    this.diceIndex = -1,
  });
}
