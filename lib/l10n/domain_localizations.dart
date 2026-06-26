import '../models/achievement.dart';
import '../models/app_theme_id.dart';
import '../models/game_difficulty.dart';
import '../models/game_result.dart';
import 'generated/app_localizations.dart';

extension LocalizedGameDifficulty on GameDifficulty {
  String localizedLabel(AppLocalizations l10n) {
    return switch (this) {
      GameDifficulty.easy => l10n.difficultyEasy,
      GameDifficulty.normal => l10n.difficultyNormal,
      GameDifficulty.hard => l10n.difficultyHard,
    };
  }
}

extension LocalizedAchievement on AchievementId {
  String localizedTitle(AppLocalizations l10n) {
    return switch (this) {
      AchievementId.firstClear => l10n.achievementFirstClearTitle,
      AchievementId.perfectRun => l10n.achievementPerfectRunTitle,
      AchievementId.normalSprinter => l10n.achievementNormalSprinterTitle,
      AchievementId.hardClear => l10n.achievementHardClearTitle,
      AchievementId.dailyDebut => l10n.achievementDailyDebutTitle,
      AchievementId.threeDayStreak => l10n.achievementThreeDayStreakTitle,
      AchievementId.sevenDayStreak => l10n.achievementSevenDayStreakTitle,
      AchievementId.veteran => l10n.achievementVeteranTitle,
    };
  }

  String localizedDescription(AppLocalizations l10n) {
    return switch (this) {
      AchievementId.firstClear => l10n.achievementFirstClearDescription,
      AchievementId.perfectRun => l10n.achievementPerfectRunDescription,
      AchievementId.normalSprinter => l10n.achievementNormalSprinterDescription,
      AchievementId.hardClear => l10n.achievementHardClearDescription,
      AchievementId.dailyDebut => l10n.achievementDailyDebutDescription,
      AchievementId.threeDayStreak => l10n.achievementThreeDayStreakDescription,
      AchievementId.sevenDayStreak => l10n.achievementSevenDayStreakDescription,
      AchievementId.veteran => l10n.achievementVeteranDescription,
    };
  }
}

extension LocalizedAppTheme on AppThemeId {
  String localizedName(AppLocalizations l10n) {
    return switch (this) {
      AppThemeId.classic => l10n.themeClassic,
      AppThemeId.midnight => l10n.themeMidnight,
      AppThemeId.neon => l10n.themeNeon,
    };
  }

  String? localizedUnlockDescription(AppLocalizations l10n) {
    return switch (this) {
      AppThemeId.classic => null,
      AppThemeId.midnight => l10n.unlockThreeAchievements,
      AppThemeId.neon => l10n.completeSevenDayStreak,
    };
  }
}

extension LocalizedGameResult on GameResult {
  String localizedGrade(AppLocalizations l10n) {
    if (wrongTapCount == 0) return l10n.gradePerfect;
    if (wrongTapCount <= 2) return l10n.gradeSharp;
    return l10n.gradeTryAgain;
  }

  String localizedBestDelta(AppLocalizations l10n) {
    if (previousBest == 0) return l10n.firstRecord;

    final delta = (elapsedSeconds - previousBest).abs().toStringAsFixed(1);
    return isNewBest ? l10n.secondsFaster(delta) : l10n.secondsSlower(delta);
  }
}

String localizedWeekday(AppLocalizations l10n, int weekday) {
  return switch (weekday) {
    DateTime.monday => l10n.weekdayMonday,
    DateTime.tuesday => l10n.weekdayTuesday,
    DateTime.wednesday => l10n.weekdayWednesday,
    DateTime.thursday => l10n.weekdayThursday,
    DateTime.friday => l10n.weekdayFriday,
    DateTime.saturday => l10n.weekdaySaturday,
    DateTime.sunday => l10n.weekdaySunday,
    _ => '',
  };
}
