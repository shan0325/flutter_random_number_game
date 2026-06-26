import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/l10n/generated/app_localizations.dart';
import 'package:onetotwentyfive/models/achievement.dart';
import 'package:onetotwentyfive/models/achievement_progress.dart';
import 'package:onetotwentyfive/models/app_theme_id.dart';
import 'package:onetotwentyfive/models/game_difficulty.dart';
import 'package:onetotwentyfive/models/game_record.dart';
import 'package:onetotwentyfive/models/game_result.dart';
import 'package:onetotwentyfive/screens/achievement_screen.dart';
import 'package:onetotwentyfive/screens/record_screen.dart';
import 'package:onetotwentyfive/screens/statistics_screen.dart';
import 'package:onetotwentyfive/theme/game_theme.dart';
import 'package:onetotwentyfive/widgets/game_result_dialog.dart';

void main() {
  testWidgets('localizes the records screen in Korean', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        const Locale('ko'),
        RecordScreen(
          records: List.of(const [
            GameRecord(
              record: '10.0',
              date: '2026-06-21 10:00:00',
              difficulty: GameDifficulty.easy,
            ),
          ]),
          difficulty: GameDifficulty.easy,
        ),
      ),
    );

    expect(find.text('기록'), findsOneWidget);
    expect(find.text('기록순'), findsOneWidget);
    expect(find.textContaining('쉬움'), findsOneWidget);
  });

  testWidgets('localizes achievements in Japanese', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        const Locale('ja'),
        const AchievementScreen(
          achievements: [
            AchievementProgress(
              id: AchievementId.firstClear,
              current: 1,
              target: 1,
              unlockedAt: '2026-06-21',
            ),
          ],
        ),
      ),
    );

    expect(find.text('実績'), findsOneWidget);
    expect(find.text('初クリア'), findsOneWidget);
    expect(find.text('ゲームを初めてクリアする。'), findsOneWidget);
  });

  testWidgets('localizes statistics in Korean', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        const Locale('ko'),
        const StatisticsScreen(
          records: [],
          dailyCompletionCount: 0,
          bestDailyStreak: 0,
          unlockedAchievementCount: 0,
          totalAchievementCount: 8,
        ),
      ),
    );

    expect(find.text('통계'), findsOneWidget);
    expect(find.text('쉬움'), findsOneWidget);
    expect(find.text('쉬움 난이도 기록이 없습니다'), findsOneWidget);
  });

  testWidgets('localizes the result dialog in Japanese', (tester) async {
    await tester.pumpWidget(
      _localizedApp(
        const Locale('ja'),
        GameResultDialog(
          result: const GameResult(
            elapsedMilliseconds: 9500,
            correctTapCount: 25,
            wrongTapCount: 0,
            previousBest: 10,
          ),
          difficulty: GameDifficulty.normal,
          record: '9.5',
          onPlayAgain: () {},
          onViewRecords: () {},
        ),
      ),
    );

    expect(find.text('新記録！'), findsOneWidget);
    expect(find.text('パーフェクト'), findsOneWidget);
    expect(find.text('もう一度'), findsOneWidget);
  });
}

Widget _localizedApp(Locale locale, Widget home) {
  return MaterialApp(
    locale: locale,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    theme: buildGameTheme(AppThemeId.classic),
    home: home,
  );
}
