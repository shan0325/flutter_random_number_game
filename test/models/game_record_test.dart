import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/game_record.dart';

void main() {
  test('serializes to the existing shared preferences format', () {
    const record = GameRecord(record: '12.3', date: '2026-06-11 10:20:30');

    expect(record.serialize(), '12.3::2026-06-11 10:20:30');
  });

  test('deserializes from the existing shared preferences format', () {
    final record = GameRecord.deserialize('9.8::2026-06-11 10:20:30');

    expect(record.record, '9.8');
    expect(record.date, '2026-06-11 10:20:30');
  });

  test('finds the fastest record', () {
    final best = GameRecord.bestOf(const [
      GameRecord(record: '13.4', date: '2026-06-11 10:20:30'),
      GameRecord(record: '8.1', date: '2026-06-11 10:21:30'),
      GameRecord(record: '10.0', date: '2026-06-11 10:22:30'),
    ]);

    expect(best, 8.1);
  });
}
