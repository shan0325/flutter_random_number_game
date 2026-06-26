import 'achievement.dart';

enum AppThemeId {
  classic,
  midnight,
  neon;

  String get storageValue => name;

  bool isUnlocked(Set<AchievementId> unlockedAchievements) {
    switch (this) {
      case AppThemeId.classic:
        return true;
      case AppThemeId.midnight:
        return unlockedAchievements.length >= 3;
      case AppThemeId.neon:
        return unlockedAchievements.contains(AchievementId.sevenDayStreak);
    }
  }

  static AppThemeId fromStorageValue(String? value) {
    return AppThemeId.values.firstWhere(
      (theme) => theme.storageValue == value,
      orElse: () => AppThemeId.classic,
    );
  }
}
