import 'achievement.dart';

enum AppThemeId {
  classic,
  midnight,
  neon;

  String get storageValue => name;

  String get displayName {
    switch (this) {
      case AppThemeId.classic:
        return 'Classic';
      case AppThemeId.midnight:
        return 'Midnight';
      case AppThemeId.neon:
        return 'Neon';
    }
  }

  String? get unlockDescription {
    switch (this) {
      case AppThemeId.classic:
        return null;
      case AppThemeId.midnight:
        return 'Unlock 3 achievements';
      case AppThemeId.neon:
        return 'Complete the 7 Day Streak achievement';
    }
  }

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
