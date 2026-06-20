import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/daily_challenge_record.dart';
import 'package:onetotwentyfive/models/daily_challenge_stats.dart';

void main() {
  test('current streak includes today when today is complete', () {
    final stats = DailyChallengeStats.fromRecords(
      [
        _record('2026-06-18'),
        _record('2026-06-19'),
        _record('2026-06-20'),
      ],
      today: DateTime(2026, 6, 20),
    );

    expect(stats.currentStreak, 3);
  });

  test('current streak falls back to yesterday before today is complete', () {
    final stats = DailyChallengeStats.fromRecords(
      [
        _record('2026-06-18'),
        _record('2026-06-19'),
      ],
      today: DateTime(2026, 6, 20),
    );

    expect(stats.currentStreak, 2);
  });

  test('current streak resets when yesterday and today are incomplete', () {
    final stats = DailyChallengeStats.fromRecords(
      [_record('2026-06-18')],
      today: DateTime(2026, 6, 20),
    );

    expect(stats.currentStreak, 0);
  });

  test('best streak finds the longest historical sequence', () {
    final stats = DailyChallengeStats.fromRecords(
      [
        _record('2026-06-01'),
        _record('2026-06-02'),
        _record('2026-06-10'),
        _record('2026-06-11'),
        _record('2026-06-12'),
      ],
      today: DateTime(2026, 6, 20),
    );

    expect(stats.bestStreak, 3);
  });

  test('recent days are ordered oldest to newest', () {
    final stats = DailyChallengeStats.fromRecords(
      [
        _record('2026-06-14'),
        _record('2026-06-17'),
        _record('2026-06-20'),
      ],
      today: DateTime(2026, 6, 20),
    );

    expect(
      stats.recentDays.map((day) => day.dateKey),
      [
        '2026-06-14',
        '2026-06-15',
        '2026-06-16',
        '2026-06-17',
        '2026-06-18',
        '2026-06-19',
        '2026-06-20',
      ],
    );
    expect(
      stats.recentDays.map((day) => day.completed),
      [true, false, false, true, false, false, true],
    );
  });
}

DailyChallengeRecord _record(String dateKey) {
  return DailyChallengeRecord(
    dateKey: dateKey,
    bestMilliseconds: 10000,
  );
}
