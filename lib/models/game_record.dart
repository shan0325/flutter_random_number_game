import 'dart:math';

import 'game_difficulty.dart';

class GameRecord {
  const GameRecord({
    required this.record,
    required this.date,
    required this.difficulty,
    this.wrongTapCount,
    this.totalTapCount,
  });

  final String record;
  final String date;
  final GameDifficulty difficulty;
  final int? wrongTapCount;
  final int? totalTapCount;

  int? get accuracyPercent {
    final total = totalTapCount;
    final wrong = wrongTapCount;
    if (total == null || wrong == null || total <= 0) return null;
    return (((total - wrong) / total) * 100).round();
  }

  factory GameRecord.deserialize(String value) {
    final parts = value.split('::');
    if (parts.length == 2) {
      return GameRecord(
        record: parts[0],
        date: parts[1],
        difficulty: GameDifficulty.normal,
      );
    }

    final hasTapMetrics = parts.length >= 5;
    return GameRecord(
      difficulty: GameDifficulty.values.byName(parts[0]),
      record: parts[1],
      date: parts[2],
      wrongTapCount: hasTapMetrics ? int.tryParse(parts[3]) : null,
      totalTapCount: hasTapMetrics ? int.tryParse(parts[4]) : null,
    );
  }

  String serialize() {
    if (wrongTapCount == null || totalTapCount == null) {
      return '${difficulty.name}::$record::$date';
    }
    return '${difficulty.name}::$record::$date::'
        '$wrongTapCount::$totalTapCount';
  }

  static double bestOf(
    List<GameRecord> records, {
    GameDifficulty? difficulty,
  }) {
    final filteredRecords = difficulty == null
        ? records
        : records.where((record) => record.difficulty == difficulty);
    final recordValues =
        filteredRecords.map((record) => double.parse(record.record));
    return recordValues.reduce(min);
  }
}
