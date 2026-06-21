import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/game_difficulty.dart';
import 'package:onetotwentyfive/models/game_record.dart';
import 'package:onetotwentyfive/models/game_statistics.dart';

void main() {
  test('filters records by difficulty', () {
    final stats = GameStatistics.forDifficulty(
      [
        _record('10.0', '2026-06-20 10:00:00', GameDifficulty.easy),
        _record('20.0', '2026-06-20 11:00:00', GameDifficulty.normal),
      ],
      GameDifficulty.normal,
    );

    expect(stats.playCount, 1);
    expect(stats.bestSeconds, 20);
  });

  test('uses at most the ten most recent games for average and trend', () {
    final records = List.generate(12, (index) {
      final day = (index + 1).toString().padLeft(2, '0');
      return _record(
        '${index + 1}.0',
        '2026-06-$day 10:00:00',
        GameDifficulty.normal,
      );
    });

    final stats = GameStatistics.forDifficulty(
      records,
      GameDifficulty.normal,
    );

    expect(stats.recentTimes, [3, 4, 5, 6, 7, 8, 9, 10, 11, 12]);
    expect(stats.recentAverageSeconds, 7.5);
  });

  test('excludes legacy records from tap averages', () {
    final stats = GameStatistics.forDifficulty(
      [
        _record('10.0', '2026-06-20 10:00:00', GameDifficulty.normal),
        _record(
          '12.0',
          '2026-06-20 11:00:00',
          GameDifficulty.normal,
          wrongTapCount: 2,
          totalTapCount: 27,
        ),
        _record(
          '13.0',
          '2026-06-20 12:00:00',
          GameDifficulty.normal,
          wrongTapCount: 0,
          totalTapCount: 25,
        ),
      ],
      GameDifficulty.normal,
    );

    expect(stats.recordsWithTapData, 2);
    expect(stats.averageWrongTaps, 1);
    expect(stats.averageAccuracyPercent, 96.5);
  });

  test('returns an empty state when a difficulty has no records', () {
    final stats = GameStatistics.forDifficulty(
      const [],
      GameDifficulty.hard,
    );

    expect(stats.hasData, isFalse);
    expect(stats.bestSeconds, isNull);
    expect(stats.recentAverageSeconds, isNull);
  });
}

GameRecord _record(
  String time,
  String date,
  GameDifficulty difficulty, {
  int? wrongTapCount,
  int? totalTapCount,
}) {
  return GameRecord(
    record: time,
    date: date,
    difficulty: difficulty,
    wrongTapCount: wrongTapCount,
    totalTapCount: totalTapCount,
  );
}
