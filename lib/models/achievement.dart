enum AchievementId {
  firstClear,
  perfectRun,
  normalSprinter,
  hardClear,
  dailyDebut,
  threeDayStreak,
  sevenDayStreak,
  veteran,
}

extension AchievementDefinition on AchievementId {
  String get title {
    switch (this) {
      case AchievementId.firstClear:
        return 'First Clear';
      case AchievementId.perfectRun:
        return 'Perfect Run';
      case AchievementId.normalSprinter:
        return 'Normal Sprinter';
      case AchievementId.hardClear:
        return 'Hard Clear';
      case AchievementId.dailyDebut:
        return 'Daily Debut';
      case AchievementId.threeDayStreak:
        return '3 Day Streak';
      case AchievementId.sevenDayStreak:
        return '7 Day Streak';
      case AchievementId.veteran:
        return 'Veteran';
    }
  }

  String get description {
    switch (this) {
      case AchievementId.firstClear:
        return 'Complete your first game.';
      case AchievementId.perfectRun:
        return 'Complete a game without a wrong tap.';
      case AchievementId.normalSprinter:
        return 'Finish Normal in 15.0 seconds or less.';
      case AchievementId.hardClear:
        return 'Complete Hard mode.';
      case AchievementId.dailyDebut:
        return "Complete Today's Challenge.";
      case AchievementId.threeDayStreak:
        return 'Reach a 3-day daily challenge streak.';
      case AchievementId.sevenDayStreak:
        return 'Reach a 7-day daily challenge streak.';
      case AchievementId.veteran:
        return 'Complete 100 games.';
    }
  }

  int get target {
    switch (this) {
      case AchievementId.threeDayStreak:
        return 3;
      case AchievementId.sevenDayStreak:
        return 7;
      case AchievementId.veteran:
        return 100;
      case AchievementId.firstClear:
      case AchievementId.perfectRun:
      case AchievementId.normalSprinter:
      case AchievementId.hardClear:
      case AchievementId.dailyDebut:
        return 1;
    }
  }
}
