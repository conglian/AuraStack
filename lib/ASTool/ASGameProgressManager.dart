import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';

import '../ASModel/ASGameProgressModel.dart';
import 'ASLogger.dart';
import 'as_LocalProvider.dart';

class ASGameProgressManager {
  ASGameProgressManager._internal();

  static final ASGameProgressManager _instance =
      ASGameProgressManager._internal();

  factory ASGameProgressManager() => _instance;

  static ASGameProgressManager get instance => _instance;

  static const String _localAssetPath = 'assets/File/game_progress.json';

  ASGameProgressModel gameProgressModel = const ASGameProgressModel();

  Future<ASGameProgressModel> initGameProgressJson() => loadLocalData();

  Future<ASGameProgressModel> loadLocalData() async {
    try {
      final jsonString = await rootBundle.loadString(_localAssetPath);
      final jsonObject = jsonDecode(jsonString);

      if (jsonObject is! Map<String, dynamic>) {
        throw const FormatException(
          'game_progress.json must contain a JSON object.',
        );
      }

      gameProgressModel = ASGameProgressModel.fromJson(jsonObject);
      asLog.success(
        'Local game-progress configuration loaded.',
        tag: 'ASGameProgressManager',
      );
      return gameProgressModel;
    } catch (error, stackTrace) {
      asLog.error(
        'Failed to load $_localAssetPath',
        tag: 'ASGameProgressManager',
        error: error,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  /// When [forceWin] is false, the configured probability decides the result.
  ASExtraBonusResult generateExtraBonusResult(bool forceWin) {
    final random = Random();
    final config = gameProgressModel.extraBonus;
    final isWinner =
        forceWin || _passesProbability(random, config.point.probability);
    final hasDice = _passesProbability(random, config.diceProbability);

    final topNumbers = _uniqueNumbers(random, 4, <int>{});
    final excludedNumbers = <int>{...topNumbers};
    final bottomNumbers = _uniqueNumbers(random, 12, excludedNumbers);

    var winningTopIndex = -1;
    var winningBottomIndex = -1;
    if (isWinner) {
      winningTopIndex = random.nextInt(topNumbers.length);
      winningBottomIndex = random.nextInt(bottomNumbers.length);
      bottomNumbers[winningBottomIndex] = topNumbers[winningTopIndex];
    }

    if (hasDice) {
      final availableIndexes = <int>[
        for (var index = 0; index < bottomNumbers.length; index++)
          if (index != winningBottomIndex) index,
      ];
      final diceIndex =
          availableIndexes[random.nextInt(availableIndexes.length)];
      bottomNumbers[diceIndex] = -1;
    }

    final rewardRange = _rewardRangeForBalance(
      config.point.ranges,
      ASLocalProvider.instance.as_dollar_number,
    );
    final rewardValues = List<double>.generate(
      bottomNumbers.length,
      (_) => _randomReward(random, rewardRange.reward),
      growable: false,
    );

    return ASExtraBonusResult(
      topNumbers: List<int>.unmodifiable(topNumbers),
      bottomNumbers: List<int>.unmodifiable(bottomNumbers),
      rewardValues: List<double>.unmodifiable(rewardValues),
      isWinner: isWinner,
      hasDice: hasDice,
      winningTopIndex: winningTopIndex,
      winningBottomIndex: winningBottomIndex,
    );
  }

  /// When [forceWin] is false, the configured probability decides the result.
  ASCandyRushResult generateCandyRushResult(bool forceWin) {
    final random = Random();
    final config = gameProgressModel.candyRush;
    final isWinner =
        forceWin || _passesProbability(random, config.point.probability);
    final hasDice = _passesProbability(random, config.diceProbability);
    final bottomNumbers = List<int>.generate(
      9,
      (_) => random.nextInt(2),
      growable: false,
    );

    var winningIndex = -1;
    if (isWinner) {
      winningIndex = random.nextInt(bottomNumbers.length);
      bottomNumbers[winningIndex] = 2;
    }

    var diceIndex = -1;
    if (hasDice) {
      final availableIndexes = <int>[
        for (var index = 0; index < bottomNumbers.length; index++)
          if (index != winningIndex) index,
      ];
      diceIndex = availableIndexes[random.nextInt(availableIndexes.length)];
      bottomNumbers[diceIndex] = -1;
    }

    final rewardRange = _rewardRangeForBalance(
      config.point.ranges,
      ASLocalProvider.instance.as_dollar_number,
    );

    return ASCandyRushResult(
      bottomNumbers: List<int>.unmodifiable(bottomNumbers),
      topRewardValue: _randomReward(random, rewardRange.reward),
      isWinner: isWinner,
      hasDice: hasDice,
      winningIndex: winningIndex,
      diceIndex: diceIndex,
    );
  }

  /// When [forceWin] is false, the configured probability decides the result.
  ASSweetTimeResult generateSweetTimeResult(bool forceWin) {
    final random = Random();
    final config = gameProgressModel.sweetTime;
    final isWinner =
        forceWin || _passesProbability(random, config.point.probability);
    final hasDice = _passesProbability(random, config.diceProbability);
    const groupSizes = <int>[1, 2, 3, 4];
    final flatNumbers = _uniqueNumbers(random, 10, <int>{});

    var winningFlatIndex = -1;
    if (isWinner) {
      winningFlatIndex = random.nextInt(flatNumbers.length);
      flatNumbers[winningFlatIndex] = 0;
    }

    var diceFlatIndex = -1;
    if (hasDice) {
      final availableIndexes = <int>[
        for (var index = 0; index < flatNumbers.length; index++)
          if (index != winningFlatIndex) index,
      ];
      diceFlatIndex = availableIndexes[random.nextInt(availableIndexes.length)];
      flatNumbers[diceFlatIndex] = -1;
    }

    final bottomNumberGroups = <List<int>>[];
    var startIndex = 0;
    for (final size in groupSizes) {
      bottomNumberGroups.add(
        List<int>.unmodifiable(
          flatNumbers.sublist(startIndex, startIndex + size),
        ),
      );
      startIndex += size;
    }

    final winningPosition = _groupPosition(winningFlatIndex, groupSizes);
    final dicePosition = _groupPosition(diceFlatIndex, groupSizes);
    final rewardRange = _rewardRangeForBalance(
      config.point.ranges,
      ASLocalProvider.instance.as_dollar_number,
    );

    return ASSweetTimeResult(
      bottomNumberGroups: List<List<int>>.unmodifiable(bottomNumberGroups),
      topRewardValue: _randomReward(random, rewardRange.reward),
      isWinner: isWinner,
      hasDice: hasDice,
      winningGroupIndex: winningPosition[0],
      winningItemIndex: winningPosition[1],
      diceGroupIndex: dicePosition[0],
      diceItemIndex: dicePosition[1],
    );
  }

  ASCash777Result generateCash777Result(bool forceWin) {
    final random = Random();
    final config = gameProgressModel.cash777;
    final winningNumber = _cash777WinningNumber(random, config, forceWin);
    final isWinner = winningNumber >= 0;
    final hasDice = _passesProbability(random, config.diceProbability);
    final bottomNumbers = _uniqueNumbersInRange(random, 12, 3, 99, <int>{});

    var winningIndex = -1;
    if (isWinner) {
      winningIndex = random.nextInt(bottomNumbers.length);
      bottomNumbers[winningIndex] = winningNumber;
    }

    var diceIndex = -1;
    if (hasDice) {
      final availableIndexes = <int>[
        for (var index = 0; index < bottomNumbers.length; index++)
          if (index != winningIndex) index,
      ];
      diceIndex = availableIndexes[random.nextInt(availableIndexes.length)];
      bottomNumbers[diceIndex] = -1;
    }

    final rewardRange = isWinner
        ? _rewardRangeForBalance(
            _cash777Point(config, winningNumber).ranges,
            ASLocalProvider.instance.as_dollar_number,
          ).reward
        : const <double>[30, 50];
    final rewardValues = List<double>.generate(
      bottomNumbers.length,
      (_) => _randomReward(random, rewardRange),
      growable: false,
    );
    final winningRewardValue = isWinner
        ? (rewardValues[winningIndex] * (winningNumber + 1) * 100).round() / 100
        : 0.0;

    return ASCash777Result(
      bottomNumbers: List<int>.unmodifiable(bottomNumbers),
      rewardValues: List<double>.unmodifiable(rewardValues),
      winningRewardValue: winningRewardValue,
      isWinner: isWinner,
      hasDice: hasDice,
      winningNumber: winningNumber,
      winningIndex: winningIndex,
      diceIndex: diceIndex,
    );
  }

  /// The 12 cells are arranged as three columns by four rows.
  ASFortuneRushResult generateFortuneRushResult(bool forceWin) {
    final random = Random();
    final config = gameProgressModel.fortuneRush;
    final isWinner =
        forceWin || _passesProbability(random, config.point.probability);
    final hasDice = _passesProbability(random, config.diceProbability);
    final topWinningNumber = random.nextInt(90) + 10;
    final bottomNumbers = _uniqueNumbersInRange(random, 12, 10, 99, <int>{
      topWinningNumber,
    });

    var winningIndex = -1;
    var rewardIndex = -1;
    if (isWinner) {
      winningIndex = random.nextInt(bottomNumbers.length);
      bottomNumbers[winningIndex] = topWinningNumber;
      rewardIndex = winningIndex ~/ 3;
    }

    var diceIndex = -1;
    if (hasDice) {
      final availableIndexes = <int>[
        for (var index = 0; index < bottomNumbers.length; index++)
          if (index != winningIndex) index,
      ];
      diceIndex = availableIndexes[random.nextInt(availableIndexes.length)];
      bottomNumbers[diceIndex] = -1;
    }

    final rewardRange = _rewardRangeForBalance(
      config.point.ranges,
      ASLocalProvider.instance.as_dollar_number,
    );
    final rewardValues = List<double>.generate(
      4,
      (_) => _randomReward(random, rewardRange.reward),
      growable: false,
    );

    return ASFortuneRushResult(
      bottomNumbers: List<int>.unmodifiable(bottomNumbers),
      rewardValues: List<double>.unmodifiable(rewardValues),
      topWinningNumber: topWinningNumber,
      isWinner: isWinner,
      hasDice: hasDice,
      winningIndex: winningIndex,
      rewardIndex: rewardIndex,
      diceIndex: diceIndex,
    );
  }

  int _cash777WinningNumber(
    Random random,
    ASCash777Progress config,
    bool forceWin,
  ) {
    final winningWeights = <double>[
      max(0, config.point7.probability).toDouble(),
      max(0, config.point77.probability).toDouble(),
      max(0, config.point777.probability).toDouble(),
    ];
    final winningWeight = winningWeights.reduce((sum, value) => sum + value);
    if (winningWeight <= 0) {
      if (forceWin) {
        throw StateError('cash_777 needs at least one winning probability.');
      }
      return -1;
    }

    final nullWeight = max(0, config.nullProbability).toDouble();
    final roll =
        random.nextDouble() *
        (forceWin ? winningWeight : winningWeight + nullWeight);
    if (!forceWin && roll >= winningWeight) return -1;

    var cumulativeWeight = 0.0;
    for (var index = 0; index < winningWeights.length; index++) {
      cumulativeWeight += winningWeights[index];
      if (roll < cumulativeWeight) return index;
    }
    return winningWeights.length - 1;
  }

  ASProbabilityReward _cash777Point(
    ASCash777Progress config,
    int winningNumber,
  ) {
    switch (winningNumber) {
      case 0:
        return config.point7;
      case 1:
        return config.point77;
      case 2:
        return config.point777;
      default:
        throw RangeError.range(winningNumber, 0, 2, 'winningNumber');
    }
  }

  bool _passesProbability(Random random, double probability) {
    if (probability <= 0) return false;
    if (probability >= 1) return true;
    return random.nextDouble() < probability;
  }

  List<int> _uniqueNumbers(Random random, int count, Set<int> excludedNumbers) {
    return _uniqueNumbersInRange(random, count, 1, 99, excludedNumbers);
  }

  List<int> _uniqueNumbersInRange(
    Random random,
    int count,
    int minValue,
    int maxValue,
    Set<int> excludedNumbers,
  ) {
    if (maxValue < minValue ||
        maxValue - minValue + 1 - excludedNumbers.length < count) {
      throw ArgumentError('The requested unique-number range is too small.');
    }

    final numbers = <int>[];
    final usedNumbers = <int>{...excludedNumbers};
    while (numbers.length < count) {
      final number = random.nextInt(maxValue - minValue + 1) + minValue;
      if (usedNumbers.add(number)) numbers.add(number);
    }
    return numbers;
  }

  List<int> _groupPosition(int flatIndex, List<int> groupSizes) {
    if (flatIndex < 0) return const <int>[-1, -1];

    var itemIndex = flatIndex;
    for (var groupIndex = 0; groupIndex < groupSizes.length; groupIndex++) {
      if (itemIndex < groupSizes[groupIndex]) {
        return <int>[groupIndex, itemIndex];
      }
      itemIndex -= groupSizes[groupIndex];
    }
    throw RangeError.index(flatIndex, groupSizes, 'flatIndex');
  }

  ASRewardRange _rewardRangeForBalance(
    List<ASRewardRange> ranges,
    double balance,
  ) {
    if (ranges.isEmpty) {
      throw StateError('Game point ranges cannot be empty.');
    }

    var selectedRange = ranges.first;
    for (final range in ranges) {
      if (balance >= range.firstNumber) selectedRange = range;
      if (balance >= range.firstNumber && balance < range.endNumber) {
        return range;
      }
    }
    return selectedRange;
  }

  double _randomReward(Random random, List<double> rewardRange) {
    if (rewardRange.length < 2) {
      throw StateError('A game reward range needs two values.');
    }

    final firstInCents = (rewardRange[0] * 100).round();
    final secondInCents = (rewardRange[1] * 100).round();
    final minInCents = min(firstInCents, secondInCents);
    final maxInCents = max(firstInCents, secondInCents);
    final valueInCents =
        minInCents + random.nextInt(maxInCents - minInCents + 1);
    return valueInCents / 100;
  }
}
