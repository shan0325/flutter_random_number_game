import 'dart:math';

import 'game_difficulty.dart';
import 'game_record.dart';

class GameStatistics {
  const GameStatistics({
    required this.difficulty,
    required this.playCount,
    required this.recordsWithTapData,
    required this.recentTimes,
    this.bestSeconds,
    this.recentAverageSeconds,
    this.averageWrongTaps,
    this.averageAccuracyPercent,
  });

  factory GameStatistics.forDifficulty(
    List<GameRecord> records,
    GameDifficulty difficulty,
  ) {
    final filtered = records
        .where((record) => record.difficulty == difficulty)
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));

    if (filtered.isEmpty) {
      return GameStatistics(
        difficulty: difficulty,
        playCount: 0,
        recordsWithTapData: 0,
        recentTimes: const [],
      );
    }

    final allTimes = filtered.map((record) => double.parse(record.record));
    final recentRecords = filtered.length <= 10
        ? filtered
        : filtered.sublist(filtered.length - 10);
    final recentTimes = recentRecords
        .map((record) => double.parse(record.record))
        .toList(growable: false);
    final tapRecords = filtered
        .where(
          (record) =>
              record.wrongTapCount != null &&
              record.totalTapCount != null &&
              record.accuracyPercent != null,
        )
        .toList();

    return GameStatistics(
      difficulty: difficulty,
      playCount: filtered.length,
      recordsWithTapData: tapRecords.length,
      bestSeconds: allTimes.reduce(min),
      recentAverageSeconds:
          recentTimes.reduce((a, b) => a + b) / recentTimes.length,
      averageWrongTaps: tapRecords.isEmpty
          ? null
          : tapRecords
                  .map((record) => record.wrongTapCount!)
                  .reduce((a, b) => a + b) /
              tapRecords.length,
      averageAccuracyPercent: tapRecords.isEmpty
          ? null
          : tapRecords
                  .map((record) => record.accuracyPercent!)
                  .reduce((a, b) => a + b) /
              tapRecords.length,
      recentTimes: recentTimes,
    );
  }

  final GameDifficulty difficulty;
  final int playCount;
  final int recordsWithTapData;
  final double? bestSeconds;
  final double? recentAverageSeconds;
  final double? averageWrongTaps;
  final double? averageAccuracyPercent;
  final List<double> recentTimes;

  bool get hasData => playCount > 0;
}
