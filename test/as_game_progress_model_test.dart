import 'dart:convert';
import 'dart:io';

import 'package:aurastack/ASModel/ASGameProgressModel.dart';
import 'package:aurastack/ASTool/ASGameProgressManager.dart';
import 'package:aurastack/ASTool/as_LocalProvider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('parses the bundled game progress configuration', () {
    final json =
        jsonDecode(File('assets/File/game_progress.json').readAsStringSync())
            as Map<String, dynamic>;

    final model = ASGameProgressModel.fromJson(json);

    expect(model.intAd, hasLength(4));
    expect(model.extraBonus.point.probability, 0.8);
    expect(model.candyRush.point.probability, 0.7);
    expect(model.sweetTime.diceProbability, 0.6);
    expect(model.cash777.point777.ranges.first.reward, <double>[29, 32]);
    expect(model.cash50x.point50x.ranges.last.reward, <double>[0.8, 0.9]);
    expect(model.dailyPigTask.bigReward.last.reward, <double>[40]);
    expect(model.withdrawTask.last.name, 'spins');
    expect(model.cutIn, <int>[5, 8]);

    final encoded = model.toJson();
    expect(encoded, contains('cash_777'));
    expect(encoded, contains('cash_50x'));
    expect(encoded, contains('candy_rush'));
    expect(encoded, contains('sweet_time'));
    expect(encoded, isNot(contains('gold_rush')));
    expect(encoded, isNot(contains('pyramid_adventure')));
  });

  test('generates a forced extra bonus winner with valid scratch data', () {
    final json =
        jsonDecode(File('assets/File/game_progress.json').readAsStringSync())
            as Map<String, dynamic>;
    final manager = ASGameProgressManager.instance;
    manager.gameProgressModel = ASGameProgressModel.fromJson(json);
    ASLocalProvider.instance.as_dollar_number = 100;

    final result = manager.generateExtraBonusResult(true);

    expect(result.isWinner, isTrue);
    expect(result.topNumbers, hasLength(4));
    expect(result.bottomNumbers, hasLength(12));
    expect(result.rewardValues, hasLength(12));
    expect(result.topNumbers.toSet(), hasLength(4));
    expect(result.winningTopIndex, inInclusiveRange(0, 3));
    expect(result.winningBottomIndex, inInclusiveRange(0, 11));
    expect(
      result.bottomNumbers[result.winningBottomIndex],
      result.topNumbers[result.winningTopIndex],
    );
    expect(
      result.bottomNumbers.where(
        (number) => result.topNumbers.contains(number),
      ),
      hasLength(1),
    );
    final bottomNumbersWithoutDice = result.bottomNumbers
        .where((number) => number != -1)
        .toList();
    expect(
      bottomNumbersWithoutDice.toSet(),
      hasLength(bottomNumbersWithoutDice.length),
    );
    expect(
      result.rewardValues.every((value) => value >= 70 && value <= 75),
      isTrue,
    );
    if (result.hasDice) {
      expect(result.bottomNumbers, contains(-1));
      expect(result.bottomNumbers[result.winningBottomIndex], isNot(-1));
    }
  });

  test('uses the last extra bonus reward range above the maximum balance', () {
    final json =
        jsonDecode(File('assets/File/game_progress.json').readAsStringSync())
            as Map<String, dynamic>;
    final manager = ASGameProgressManager.instance;
    manager.gameProgressModel = ASGameProgressModel.fromJson(json);
    ASLocalProvider.instance.as_dollar_number = 1500;

    final result = manager.generateExtraBonusResult(true);

    expect(
      result.rewardValues.every((value) => value >= 40 && value <= 45),
      isTrue,
    );
  });

  test('generates a candy rush winner and keeps dice off the winning cell', () {
    final manager = ASGameProgressManager.instance;
    manager.gameProgressModel = const ASGameProgressModel(
      candyRush: ASStandardGameProgress(
        point: ASProbabilityReward(
          probability: 0.7,
          ranges: <ASRewardRange>[
            ASRewardRange(
              firstNumber: 0,
              endNumber: 200,
              reward: <double>[70, 75],
            ),
          ],
        ),
        diceProbability: 1,
      ),
    );
    ASLocalProvider.instance.as_dollar_number = 100;

    final result = manager.generateCandyRushResult(true);

    expect(result.isWinner, isTrue);
    expect(result.hasDice, isTrue);
    expect(result.bottomNumbers, hasLength(9));
    expect(result.bottomNumbers.where((number) => number == 2), hasLength(1));
    expect(result.bottomNumbers.where((number) => number == -1), hasLength(1));
    expect(result.winningIndex, inInclusiveRange(0, 8));
    expect(result.diceIndex, inInclusiveRange(0, 8));
    expect(result.winningIndex, isNot(result.diceIndex));
    expect(result.bottomNumbers[result.winningIndex], 2);
    expect(result.bottomNumbers[result.diceIndex], -1);
    expect(
      result.bottomNumbers.every(
        (number) => number == -1 || number == 0 || number == 1 || number == 2,
      ),
      isTrue,
    );
    expect(result.topRewardValue, inInclusiveRange(70, 75));
  });

  test(
    'generates grouped sweet time data with protected win and dice cells',
    () {
      final manager = ASGameProgressManager.instance;
      manager.gameProgressModel = const ASGameProgressModel(
        sweetTime: ASStandardGameProgress(
          point: ASProbabilityReward(
            probability: 0.7,
            ranges: <ASRewardRange>[
              ASRewardRange(
                firstNumber: 0,
                endNumber: 200,
                reward: <double>[70, 75],
              ),
            ],
          ),
          diceProbability: 1,
        ),
      );
      ASLocalProvider.instance.as_dollar_number = 100;

      final result = manager.generateSweetTimeResult(true);
      final flatNumbers = result.bottomNumberGroups.expand((group) => group);

      expect(result.isWinner, isTrue);
      expect(result.hasDice, isTrue);
      expect(result.bottomNumberGroups.map((group) => group.length), <int>[
        1,
        2,
        3,
        4,
      ]);
      expect(flatNumbers.where((number) => number == 0), hasLength(1));
      expect(flatNumbers.where((number) => number == -1), hasLength(1));
      expect(
        result.bottomNumberGroups[result.winningGroupIndex][result
            .winningItemIndex],
        0,
      );
      expect(
        result.bottomNumberGroups[result.diceGroupIndex][result.diceItemIndex],
        -1,
      );
      expect(<int>[
        result.winningGroupIndex,
        result.winningItemIndex,
      ], isNot(<int>[result.diceGroupIndex, result.diceItemIndex]));
      expect(
        flatNumbers
            .where((number) => number > 0)
            .every((number) => number <= 99),
        isTrue,
      );
      expect(result.topRewardValue, inInclusiveRange(70, 75));
    },
  );

  test('generates a cash 777 winner with protected win and dice cells', () {
    final manager = ASGameProgressManager.instance;
    manager.gameProgressModel = const ASGameProgressModel(
      cash777: ASCash777Progress(
        point777: ASProbabilityReward(
          probability: 1,
          ranges: <ASRewardRange>[
            ASRewardRange(
              firstNumber: 0,
              endNumber: 200,
              reward: <double>[10, 20],
            ),
          ],
        ),
        diceProbability: 1,
      ),
    );
    ASLocalProvider.instance.as_dollar_number = 100;

    final result = manager.generateCash777Result(true);

    expect(result.isWinner, isTrue);
    expect(result.hasDice, isTrue);
    expect(result.winningNumber, 2);
    expect(result.bottomNumbers, hasLength(12));
    expect(result.rewardValues, hasLength(12));
    expect(result.bottomNumbers.where((number) => number == 2), hasLength(1));
    expect(result.bottomNumbers.where((number) => number == -1), hasLength(1));
    expect(result.winningIndex, isNot(result.diceIndex));
    expect(result.bottomNumbers[result.winningIndex], 2);
    expect(result.bottomNumbers[result.diceIndex], -1);
    expect(
      result.bottomNumbers
          .where((number) => number >= 3)
          .every((number) => number <= 99),
      isTrue,
    );
    expect(
      result.rewardValues.every((value) => value >= 10 && value <= 20),
      isTrue,
    );
    expect(
      result.winningRewardValue,
      (result.rewardValues[result.winningIndex] * 3 * 100).round() / 100,
    );
  });

  test('generates cash 777 fallback rewards when it does not win', () {
    final manager = ASGameProgressManager.instance;
    manager.gameProgressModel = const ASGameProgressModel(
      cash777: ASCash777Progress(nullProbability: 1, diceProbability: 0),
    );

    final result = manager.generateCash777Result(false);

    expect(result.isWinner, isFalse);
    expect(result.hasDice, isFalse);
    expect(result.winningNumber, -1);
    expect(result.winningIndex, -1);
    expect(result.winningRewardValue, 0);
    expect(result.bottomNumbers.every((number) => number >= 3), isTrue);
    expect(
      result.rewardValues.every((value) => value >= 30 && value <= 50),
      isTrue,
    );
  });

  test('generates fortune rush matrix data and selects its row reward', () {
    final manager = ASGameProgressManager.instance;
    manager.gameProgressModel = const ASGameProgressModel(
      fortuneRush: ASStandardGameProgress(
        point: ASProbabilityReward(
          probability: 1,
          ranges: <ASRewardRange>[
            ASRewardRange(
              firstNumber: 0,
              endNumber: 200,
              reward: <double>[70, 75],
            ),
          ],
        ),
        diceProbability: 1,
      ),
    );
    ASLocalProvider.instance.as_dollar_number = 100;

    final result = manager.generateFortuneRushResult(true);

    expect(result.isWinner, isTrue);
    expect(result.hasDice, isTrue);
    expect(result.topWinningNumber, inInclusiveRange(10, 99));
    expect(result.bottomNumbers, hasLength(12));
    expect(result.rewardValues, hasLength(4));
    expect(
      result.bottomNumbers.where((number) => number == result.topWinningNumber),
      hasLength(1),
    );
    expect(result.bottomNumbers.where((number) => number == -1), hasLength(1));
    expect(result.winningIndex, inInclusiveRange(0, 11));
    expect(result.rewardIndex, result.winningIndex ~/ 3);
    expect(result.rewardIndex, inInclusiveRange(0, 3));
    expect(result.winningIndex, isNot(result.diceIndex));
    expect(result.bottomNumbers[result.winningIndex], result.topWinningNumber);
    expect(result.bottomNumbers[result.diceIndex], -1);
    expect(
      result.rewardValues.every((value) => value >= 70 && value <= 75),
      isTrue,
    );
  });
}
