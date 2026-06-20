import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/daily_challenge.dart';

void main() {
  test('creates the same layout for the same date', () {
    final first = DailyChallenge.forDate(DateTime(2026, 6, 20));
    final second = DailyChallenge.forDate(DateTime(2026, 6, 20, 23, 59));

    expect(first.numbers, second.numbers);
    expect(first.dateKey, '2026-06-20');
  });

  test('creates different layouts for different dates', () {
    final first = DailyChallenge.forDate(DateTime(2026, 6, 20));
    final second = DailyChallenge.forDate(DateTime(2026, 6, 21));

    expect(first.numbers, isNot(second.numbers));
  });

  test('contains every number from 1 through 25 exactly once', () {
    final challenge = DailyChallenge.forDate(DateTime(2026, 6, 20));
    final sortedNumbers = [...challenge.numbers]..sort();

    expect(sortedNumbers, List.generate(25, (index) => index + 1));
  });
}
