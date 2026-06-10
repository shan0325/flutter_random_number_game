import 'dart:math';

class GameRecord {
  const GameRecord({
    required this.record,
    required this.date,
  });

  final String record;
  final String date;

  factory GameRecord.deserialize(String value) {
    final parts = value.split('::');
    return GameRecord(record: parts[0], date: parts[1]);
  }

  String serialize() => '$record::$date';

  static double bestOf(List<GameRecord> records) {
    final recordValues = records.map((record) => double.parse(record.record));
    return recordValues.reduce(min);
  }
}
