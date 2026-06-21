import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/game_difficulty.dart';
import 'package:onetotwentyfive/models/game_record.dart';

void main() {
  test('serializes new records with tap metrics', () {
    const record = GameRecord(
      record: '12.3',
      date: '2026-06-11 10:20:30',
      difficulty: GameDifficulty.hard,
      wrongTapCount: 2,
      totalTapCount: 38,
    );

    expect(
      record.serialize(),
      'hard::12.3::2026-06-11 10:20:30::2::38',
    );
  });

  test('deserializes legacy records as normal difficulty', () {
    final record = GameRecord.deserialize('9.8::2026-06-11 10:20:30');

    expect(record.record, '9.8');
    expect(record.date, '2026-06-11 10:20:30');
    expect(record.difficulty, GameDifficulty.normal);
    expect(record.wrongTapCount, isNull);
    expect(record.totalTapCount, isNull);
  });

  test('deserializes records with difficulty', () {
    final record = GameRecord.deserialize('easy::7.5::2026-06-11 10:20:30');

    expect(record.record, '7.5');
    expect(record.date, '2026-06-11 10:20:30');
    expect(record.difficulty, GameDifficulty.easy);
    expect(record.wrongTapCount, isNull);
    expect(record.totalTapCount, isNull);
  });

  test('deserializes records with tap metrics', () {
    final record = GameRecord.deserialize(
      'normal::12.3::2026-06-11 10:20:30::2::27',
    );

    expect(record.difficulty, GameDifficulty.normal);
    expect(record.wrongTapCount, 2);
    expect(record.totalTapCount, 27);
    expect(record.accuracyPercent, 93);
  });

  test('finds the fastest record', () {
    final best = GameRecord.bestOf(const [
      GameRecord(
        record: '13.4',
        date: '2026-06-11 10:20:30',
        difficulty: GameDifficulty.normal,
      ),
      GameRecord(
        record: '8.1',
        date: '2026-06-11 10:21:30',
        difficulty: GameDifficulty.normal,
      ),
      GameRecord(
        record: '10.0',
        date: '2026-06-11 10:22:30',
        difficulty: GameDifficulty.normal,
      ),
    ]);

    expect(best, 8.1);
  });

  test('finds the fastest record for a specific difficulty', () {
    final best = GameRecord.bestOf(
      const [
        GameRecord(
          record: '6.5',
          date: '2026-06-11 10:20:30',
          difficulty: GameDifficulty.easy,
        ),
        GameRecord(
          record: '12.3',
          date: '2026-06-11 10:21:30',
          difficulty: GameDifficulty.normal,
        ),
        GameRecord(
          record: '9.1',
          date: '2026-06-11 10:22:30',
          difficulty: GameDifficulty.normal,
        ),
      ],
      difficulty: GameDifficulty.normal,
    );

    expect(best, 9.1);
  });
}
