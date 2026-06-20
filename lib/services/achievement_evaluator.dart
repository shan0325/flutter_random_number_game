import '../models/achievement.dart';
import '../models/achievement_progress.dart';
import '../models/daily_challenge_record.dart';
import '../models/daily_challenge_stats.dart';
import '../models/game_difficulty.dart';
import '../models/game_record.dart';
import 'achievement_storage.dart';

class AchievementEvaluationContext {
  const AchievementEvaluationContext({
    required this.difficulty,
    required this.elapsedMilliseconds,
    required this.wrongTapCount,
    required this.isDailyChallenge,
    required this.currentStreak,
    required this.completedGames,
  });

  final GameDifficulty difficulty;
  final int elapsedMilliseconds;
  final int wrongTapCount;
  final bool isDailyChallenge;
  final int currentStreak;
  final int completedGames;
}

class AchievementEvaluator {
  Set<AchievementId> evaluate(
    AchievementEvaluationContext context, {
    required Set<AchievementId> unlockedIds,
  }) {
    final qualified = <AchievementId>{
      AchievementId.firstClear,
      if (context.wrongTapCount == 0) AchievementId.perfectRun,
      if (context.difficulty == GameDifficulty.normal &&
          context.elapsedMilliseconds <= 15000)
        AchievementId.normalSprinter,
      if (context.difficulty == GameDifficulty.hard) AchievementId.hardClear,
      if (context.isDailyChallenge) AchievementId.dailyDebut,
      if (context.currentStreak >= 3) AchievementId.threeDayStreak,
      if (context.currentStreak >= 7) AchievementId.sevenDayStreak,
      if (context.completedGames >= 100) AchievementId.veteran,
    };

    return qualified.difference(unlockedIds);
  }

  List<AchievementProgress> buildProgress({
    required AchievementState state,
    required List<GameRecord> normalRecords,
    required List<DailyChallengeRecord> dailyRecords,
    required DailyChallengeStats dailyStats,
  }) {
    final hasNormalSprint = normalRecords.any(
      (record) =>
          record.difficulty == GameDifficulty.normal &&
          (double.tryParse(record.record) ?? double.infinity) <= 15,
    );
    final hasHardClear = normalRecords.any(
      (record) => record.difficulty == GameDifficulty.hard,
    );

    int currentFor(AchievementId id) {
      if (state.unlockDates.containsKey(id)) return id.target;

      switch (id) {
        case AchievementId.firstClear:
          return state.completedGames.clamp(0, 1);
        case AchievementId.perfectRun:
          return 0;
        case AchievementId.normalSprinter:
          return hasNormalSprint ? 1 : 0;
        case AchievementId.hardClear:
          return hasHardClear ? 1 : 0;
        case AchievementId.dailyDebut:
          return dailyRecords.isEmpty ? 0 : 1;
        case AchievementId.threeDayStreak:
        case AchievementId.sevenDayStreak:
          return dailyStats.bestStreak.clamp(0, id.target);
        case AchievementId.veteran:
          return state.completedGames.clamp(0, id.target);
      }
    }

    return AchievementId.values.map((id) {
      return AchievementProgress(
        id: id,
        current: currentFor(id),
        target: id.target,
        unlockedAt: state.unlockDates[id],
      );
    }).toList();
  }
}
