import 'dart:math';

import 'game_difficulty.dart';

class GameRecord {
  const GameRecord({
    required this.record,
    required this.date,
    required this.difficulty,
  });

  final String record;
  final String date;
  final GameDifficulty difficulty;

  factory GameRecord.deserialize(String value) {
    final parts = value.split('::');
    if (parts.length == 2) {
      return GameRecord(
        record: parts[0],
        date: parts[1],
        difficulty: GameDifficulty.normal,
      );
    }

    return GameRecord(
      difficulty: GameDifficulty.values.byName(parts[0]),
      record: parts[1],
      date: parts[2],
    );
  }

  String serialize() => '${difficulty.name}::$record::$date';

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
