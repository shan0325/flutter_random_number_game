import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/app.dart';
import 'package:onetotwentyfive/models/achievement.dart';
import 'package:onetotwentyfive/models/daily_challenge_record.dart';
import 'package:onetotwentyfive/models/daily_challenge_stats.dart';
import 'package:onetotwentyfive/models/game_record.dart';
import 'package:onetotwentyfive/screens/number_game_screen.dart';
import 'package:onetotwentyfive/services/achievement_storage.dart';
import 'package:onetotwentyfive/services/daily_challenge_storage.dart';
import 'package:onetotwentyfive/services/game_sound_player.dart';
import 'package:onetotwentyfive/services/record_storage.dart';
import 'package:onetotwentyfive/services/sound_preference_storage.dart';

void main() {
  testWidgets('shows the game start screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('1to25'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
    expect(find.text('CLASSIC'), findsOneWidget);
    expect(find.text('DAILY'), findsOneWidget);
    expect(find.text("TODAY'S BEST"), findsNothing);
  });

  testWidgets('shows only daily challenge content in daily mode', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    await tester.tap(find.text('DAILY'));
    await tester.pump();

    expect(find.text("TODAY'S CHALLENGE"), findsOneWidget);
    expect(find.text('Easy'), findsNothing);
    expect(find.text('Normal'), findsNothing);
    expect(find.text('Hard'), findsNothing);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('plays countdown sounds for 3, 2, and 1', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );

    await tester.tap(find.text('START'));
    expect(
      soundPlayer.effects,
      [GameSoundEffect.countdownTick],
    );

    await tester.pump(const Duration(seconds: 1));
    expect(
      soundPlayer.effects,
      [
        GameSoundEffect.countdownTick,
        GameSoundEffect.countdownTick,
      ],
    );

    await tester.pump(const Duration(seconds: 1));
    expect(
      soundPlayer.effects,
      [
        GameSoundEffect.countdownTick,
        GameSoundEffect.countdownTick,
        GameSoundEffect.countdownGo,
      ],
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('plays distinct sounds for correct and wrong numbers', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );

    await _startGame(tester);
    soundPlayer.effects.clear();

    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();

    expect(
      soundPlayer.effects,
      [
        GameSoundEffect.correct,
        GameSoundEffect.wrong,
      ],
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('plays a completion sound after the final number', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );

    await tester.tap(find.text('Easy'));
    await _startGame(tester);
    soundPlayer.effects.clear();

    for (var number = 1; number <= 16; number++) {
      await tester.tap(find.text('$number'));
      await tester.pump();
    }

    expect(soundPlayer.effects.last, GameSoundEffect.complete);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sound toggle mutes effects and saves the preference', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();
    final preferenceStorage = _FakeSoundPreferenceStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: preferenceStorage,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('sound-toggle')));
    await tester.pump();
    await tester.tap(find.text('START'));

    expect(preferenceStorage.savedValues, [false]);
    expect(soundPlayer.effects, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows today challenge best on the start screen', (
    WidgetTester tester,
  ) async {
    final dailyStorage = _FakeDailyChallengeStorage(
      records: [
        const DailyChallengeRecord(
          dateKey: '2026-06-20',
          bestMilliseconds: 9800,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          dailyChallengeStorage: dailyStorage,
          dateProvider: () => DateTime(2026, 6, 20),
          gameSoundPlayer: _FakeGameSoundPlayer(),
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('DAILY'));
    await tester.pump();

    expect(find.text("TODAY'S CHALLENGE"), findsOneWidget);
    expect(find.text("TODAY'S BEST 9.8"), findsOneWidget);
  });

  testWidgets('daily challenge saves separately from normal records', (
    WidgetTester tester,
  ) async {
    final dailyStorage = _FakeDailyChallengeStorage();
    final recordStorage = _FakeRecordStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          dailyChallengeStorage: dailyStorage,
          dateProvider: () => DateTime(2026, 6, 20),
          gameSoundPlayer: _FakeGameSoundPlayer(),
          recordStorage: recordStorage,
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('DAILY'));
    await tester.pump();
    await tester.tap(find.text('START'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    for (var number = 1; number <= 25; number++) {
      await tester.tap(find.text('$number'));
      await tester.pump();
    }

    expect(dailyStorage.savedDateKey, '2026-06-20');
    expect(dailyStorage.savedMilliseconds, isNotNull);
    expect(recordStorage.saveCount, 0);
    expect(find.text("Today's Challenge"), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('shows current and best challenge streaks', (
    WidgetTester tester,
  ) async {
    final dailyStorage = _FakeDailyChallengeStorage(
      records: [
        _dailyRecord('2026-06-10'),
        _dailyRecord('2026-06-11'),
        _dailyRecord('2026-06-12'),
        _dailyRecord('2026-06-18'),
        _dailyRecord('2026-06-19'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          dailyChallengeStorage: dailyStorage,
          dateProvider: () => DateTime(2026, 6, 20),
          gameSoundPlayer: _FakeGameSoundPlayer(),
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('DAILY'));
    await tester.pump();

    expect(find.text('STREAK 2'), findsOneWidget);
    expect(find.text('BEST 3'), findsOneWidget);
    expect(find.byKey(const Key('daily-day-2026-06-19')), findsOneWidget);
  });

  testWidgets('challenge result shows the updated streak', (
    WidgetTester tester,
  ) async {
    final dailyStorage = _FakeDailyChallengeStorage(
      records: [
        _dailyRecord('2026-06-18'),
        _dailyRecord('2026-06-19'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          dailyChallengeStorage: dailyStorage,
          dateProvider: () => DateTime(2026, 6, 20),
          gameSoundPlayer: _FakeGameSoundPlayer(),
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('DAILY'));
    await tester.pump();
    await tester.tap(find.text('START'));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));
    await tester.pump(const Duration(seconds: 1));

    for (var number = 1; number <= 25; number++) {
      await tester.tap(find.text('$number'));
      await tester.pump();
    }

    expect(find.text('Streak'), findsOneWidget);
    expect(find.text('3 days'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('announces newly unlocked achievements in the result', (
    WidgetTester tester,
  ) async {
    final achievementStorage = _FakeAchievementStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          achievementStorage: achievementStorage,
          gameSoundPlayer: _FakeGameSoundPlayer(),
          recordStorage: _FakeRecordStorage(),
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Easy'));
    await _startGame(tester);
    for (var number = 1; number <= 16; number++) {
      await tester.tap(find.text('$number'));
      await tester.pump();
    }

    expect(find.text('Achievement Unlocked'), findsOneWidget);
    expect(find.text('First Clear'), findsOneWidget);
    expect(find.text('Perfect Run'), findsOneWidget);
    expect(
      achievementStorage.state.unlockedIds,
      containsAll([
        AchievementId.firstClear,
        AchievementId.perfectRun,
      ]),
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('opens the achievement screen from the trophy button', (
    WidgetTester tester,
  ) async {
    final achievementStorage = _FakeAchievementStorage(
      state: AchievementState(
        unlockDates: {
          AchievementId.firstClear: '2026-06-20 10:00:00',
        },
        completedGames: 1,
      ),
    );

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          achievementStorage: achievementStorage,
          gameSoundPlayer: _FakeGameSoundPlayer(),
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('achievements-button')));
    await tester.pumpAndSettle();

    expect(find.text('Achievements'), findsOneWidget);
    expect(find.text('1 / 8 unlocked'), findsOneWidget);
    expect(find.text('First Clear'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Veteran'),
      300,
      scrollable: find.byType(Scrollable),
    );
    expect(find.text('Veteran'), findsOneWidget);
  });
}

Future<void> _startGame(WidgetTester tester) async {
  await tester.tap(find.text('START'));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

class _FakeGameSoundPlayer implements GameSoundPlayer {
  final effects = <GameSoundEffect>[];

  @override
  Future<void> play(GameSoundEffect effect) async {
    effects.add(effect);
  }

  @override
  Future<void> dispose() async {}
}

class _FakeSoundPreferenceStorage implements SoundPreferenceStorage {
  final savedValues = <bool>[];

  @override
  Future<bool> loadSoundEnabled() async => true;

  @override
  Future<void> saveSoundEnabled(bool enabled) async {
    savedValues.add(enabled);
  }
}

class _FakeDailyChallengeStorage implements DailyChallengeStorage {
  _FakeDailyChallengeStorage({
    this.records = const [],
  });

  final List<DailyChallengeRecord> records;
  String? savedDateKey;
  int? savedMilliseconds;

  @override
  Future<int?> loadBestMilliseconds(String dateKey) async {
    for (final record in records) {
      if (record.dateKey == dateKey) return record.bestMilliseconds;
    }
    return null;
  }

  @override
  Future<List<DailyChallengeRecord>> loadRecords() async => [...records];

  @override
  Future<void> saveBest(String dateKey, int elapsedMilliseconds) async {
    savedDateKey = dateKey;
    savedMilliseconds = elapsedMilliseconds;
  }
}

DailyChallengeRecord _dailyRecord(String dateKey) {
  return DailyChallengeRecord(
    dateKey: dateKey,
    bestMilliseconds: 10000,
  );
}

class _FakeRecordStorage implements RecordStorage {
  int saveCount = 0;

  @override
  Future<List<GameRecord>> loadRecords() async => [];

  @override
  Future<void> saveRecords(List<GameRecord> records) async {
    saveCount++;
  }
}

class _FakeAchievementStorage implements AchievementStorage {
  _FakeAchievementStorage({AchievementState? state})
      : state = state ?? AchievementState();

  AchievementState state;

  @override
  Future<AchievementState> loadState() async => state;

  @override
  Future<void> saveState(AchievementState state) async {
    this.state = state;
  }

  @override
  Future<AchievementState> backfill({
    required List<GameRecord> normalRecords,
    required List<DailyChallengeRecord> dailyRecords,
    required DailyChallengeStats dailyStats,
    required DateTime now,
  }) async {
    return state;
  }
}
