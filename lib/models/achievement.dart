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
