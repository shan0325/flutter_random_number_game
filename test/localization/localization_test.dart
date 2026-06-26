import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/app.dart';
import 'package:onetotwentyfive/models/daily_challenge_record.dart';
import 'package:onetotwentyfive/models/daily_challenge_stats.dart';
import 'package:onetotwentyfive/models/game_record.dart';
import 'package:onetotwentyfive/services/achievement_storage.dart';

void main() {
  testWidgets('uses Korean for a Korean locale', (tester) async {
    await tester.pumpWidget(
      MyApp(
        locale: const Locale('ko'),
        achievementStorage: _EmptyAchievementStorage(),
      ),
    );
    await tester.pump();

    expect(find.text('일반 게임'), findsOneWidget);
    expect(find.text('시작'), findsOneWidget);
  });

  testWidgets('uses Japanese for a Japanese locale', (tester) async {
    await tester.pumpWidget(
      MyApp(
        locale: const Locale('ja'),
        achievementStorage: _EmptyAchievementStorage(),
      ),
    );
    await tester.pump();

    expect(find.text('通常ゲーム'), findsOneWidget);
    expect(find.text('スタート'), findsOneWidget);
  });

  testWidgets('falls back to English for an unsupported locale', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        locale: const Locale('fr'),
        achievementStorage: _EmptyAchievementStorage(),
      ),
    );
    await tester.pump();

    expect(find.text('CLASSIC'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
  });

  testWidgets('localizes the Korean theme picker and unlock rules', (
    tester,
  ) async {
    await tester.pumpWidget(
      MyApp(
        locale: const Locale('ko'),
        achievementStorage: _EmptyAchievementStorage(),
      ),
    );
    await tester.pump();
    await tester.tap(find.byKey(const Key('theme-picker-button')));
    await tester.pumpAndSettle();

    expect(find.text('테마'), findsOneWidget);
    expect(find.text('클래식'), findsOneWidget);
    expect(find.text('업적 3개를 달성하면 해금됩니다'), findsOneWidget);
  });
}

class _EmptyAchievementStorage implements AchievementStorage {
  final AchievementState _state = AchievementState();

  @override
  Future<AchievementState> loadState() async => _state;

  @override
  Future<void> saveState(AchievementState state) async {}

  @override
  Future<AchievementState> backfill({
    required List<GameRecord> normalRecords,
    required List<DailyChallengeRecord> dailyRecords,
    required DailyChallengeStats dailyStats,
    required DateTime now,
  }) async {
    return _state;
  }
}
