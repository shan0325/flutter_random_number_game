import 'achievement.dart';

class AchievementProgress {
  const AchievementProgress({
    required this.id,
    required this.current,
    required this.target,
    this.unlockedAt,
  });

  final AchievementId id;
  final int current;
  final int target;
  final String? unlockedAt;

  bool get isUnlocked => unlockedAt != null;

  double get fraction => target == 0 ? 0 : (current / target).clamp(0, 1);
}
