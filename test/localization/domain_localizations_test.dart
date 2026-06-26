import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/l10n/domain_localizations.dart';
import 'package:onetotwentyfive/l10n/generated/app_localizations.dart';
import 'package:onetotwentyfive/models/achievement.dart';
import 'package:onetotwentyfive/models/app_theme_id.dart';
import 'package:onetotwentyfive/models/game_difficulty.dart';
import 'package:onetotwentyfive/models/game_result.dart';

void main() {
  final korean = lookupAppLocalizations(const Locale('ko'));
  final japanese = lookupAppLocalizations(const Locale('ja'));

  test('localizes domain labels in Korean', () {
    expect(GameDifficulty.hard.localizedLabel(korean), '어려움');
    expect(AchievementId.perfectRun.localizedTitle(korean), '완벽한 플레이');
    expect(AppThemeId.neon.localizedName(korean), '네온');
  });

  test('localizes result values in Japanese', () {
    const result = GameResult(
      elapsedMilliseconds: 9500,
      correctTapCount: 25,
      wrongTapCount: 0,
      previousBest: 10,
    );

    expect(result.localizedGrade(japanese), 'パーフェクト');
    expect(result.localizedBestDelta(japanese), '0.5秒速い');
  });
}
