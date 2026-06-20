import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/achievement.dart';
import 'package:onetotwentyfive/models/daily_challenge_record.dart';
import 'package:onetotwentyfive/models/daily_challenge_stats.dart';
import 'package:onetotwentyfive/models/game_difficulty.dart';
import 'package:onetotwentyfive/models/game_record.dart';
import 'package:onetotwentyfive/services/achievement_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late AchievementStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = AchievementStorage();
  });

  test('persists unlock dates and completed game count', () async {
    final state = AchievementState(
      unlockDates: {
        AchievementId.firstClear: '2026-06-20 10:00:00',
      },
      completedGames: 3,
    );

    await storage.saveState(state);
    final loaded = await storage.loadState();

    expect(
      loaded.unlockDates[AchievementId.firstClear],
      '2026-06-20 10:00:00',
    );
    expect(loaded.completedGames, 3);
  });

  test('ignores malformed unlock entries', () async {
    SharedPreferences.setMockInitialValues({
      AchievementStorage.unlocksKey: [
        'invalid',
        'unknown::2026-06-20 10:00:00',
        'firstClear::2026-06-20 10:00:00',
      ],
    });

    final loaded = await storage.loadState();

    expect(loaded.unlockDates.keys, {AchievementId.firstClear});
  });

  test('backfills achievements that existing records can prove', () async {
    final normalRecords = [
      const GameRecord(
        record: '14.9',
        date: '2026-06-10 10:00:00',
        difficulty: GameDifficulty.normal,
      ),
      const GameRecord(
        record: '30.0',
        date: '2026-06-11 10:00:00',
        difficulty: GameDifficulty.hard,
      ),
    ];
    final dailyRecords = [
      _dailyRecord('2026-06-18'),
      _dailyRecord('2026-06-19'),
      _dailyRecord('2026-06-20'),
    ];
    final stats = DailyChallengeStats.fromRecords(
      dailyRecords,
      today: DateTime(2026, 6, 20),
    );

    final state = await storage.backfill(
      normalRecords: normalRecords,
      dailyRecords: dailyRecords,
      dailyStats: stats,
      now: DateTime(2026, 6, 20, 12),
    );

    expect(state.completedGames, 5);
    expect(
      state.unlockDates.keys,
      containsAll([
        AchievementId.firstClear,
        AchievementId.normalSprinter,
        AchievementId.hardClear,
        AchievementId.dailyDebut,
        AchievementId.threeDayStreak,
      ]),
    );
    expect(state.unlockDates, isNot(contains(AchievementId.perfectRun)));
  });
}

DailyChallengeRecord _dailyRecord(String dateKey) {
  return DailyChallengeRecord(
    dateKey: dateKey,
    bestMilliseconds: 10000,
  );
}
