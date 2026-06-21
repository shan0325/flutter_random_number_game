import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/achievement.dart';
import 'package:onetotwentyfive/models/app_theme_id.dart';

void main() {
  test('Classic is always unlocked', () {
    expect(AppThemeId.classic.isUnlocked({}), isTrue);
  });

  test('Midnight unlocks with three achievements', () {
    expect(
      AppThemeId.midnight.isUnlocked({
        AchievementId.firstClear,
        AchievementId.perfectRun,
      }),
      isFalse,
    );
    expect(
      AppThemeId.midnight.isUnlocked({
        AchievementId.firstClear,
        AchievementId.perfectRun,
        AchievementId.hardClear,
      }),
      isTrue,
    );
  });

  test('Neon requires the seven day streak achievement', () {
    expect(
      AppThemeId.neon.isUnlocked({
        AchievementId.firstClear,
        AchievementId.perfectRun,
        AchievementId.hardClear,
        AchievementId.dailyDebut,
        AchievementId.threeDayStreak,
      }),
      isFalse,
    );
    expect(
      AppThemeId.neon.isUnlocked({AchievementId.sevenDayStreak}),
      isTrue,
    );
  });
}
