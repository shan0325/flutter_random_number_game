import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/game_result.dart';

void main() {
  test('calculates accuracy from correct and total taps', () {
    const result = GameResult(
      elapsedMilliseconds: 12300,
      correctTapCount: 25,
      wrongTapCount: 3,
      previousBest: 11.8,
    );

    expect(result.totalTapCount, 28);
    expect(result.accuracyPercent, 89);
  });

  test('grades a perfect run', () {
    const result = GameResult(
      elapsedMilliseconds: 9000,
      correctTapCount: 25,
      wrongTapCount: 0,
      previousBest: 0,
    );

    expect(result.gradeLabel, 'Perfect');
  });

  test('detects a new best record when there is no previous best', () {
    const result = GameResult(
      elapsedMilliseconds: 9000,
      correctTapCount: 25,
      wrongTapCount: 0,
      previousBest: 0,
    );

    expect(result.isNewBest, isTrue);
    expect(result.bestDeltaLabel, 'First record');
  });

  test('detects a new best record against previous best', () {
    const result = GameResult(
      elapsedMilliseconds: 9400,
      correctTapCount: 25,
      wrongTapCount: 1,
      previousBest: 10.2,
    );

    expect(result.isNewBest, isTrue);
    expect(result.bestDeltaLabel, '0.8s faster');
  });

  test('detects a slower result against previous best', () {
    const result = GameResult(
      elapsedMilliseconds: 11800,
      correctTapCount: 25,
      wrongTapCount: 2,
      previousBest: 10.2,
    );

    expect(result.isNewBest, isFalse);
    expect(result.bestDeltaLabel, '1.6s slower');
  });
}
