import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/achievement.dart';
import 'package:onetotwentyfive/models/game_difficulty.dart';
import 'package:onetotwentyfive/services/achievement_evaluator.dart';

void main() {
  test('unlocks completion achievements at their thresholds', () {
    final evaluator = AchievementEvaluator();
    const context = AchievementEvaluationContext(
      difficulty: GameDifficulty.hard,
      elapsedMilliseconds: 14000,
      wrongTapCount: 0,
      isDailyChallenge: false,
      currentStreak: 7,
      completedGames: 100,
    );

    expect(
      evaluator.evaluate(context, unlockedIds: {}),
      containsAll([
        AchievementId.firstClear,
        AchievementId.perfectRun,
        AchievementId.hardClear,
        AchievementId.threeDayStreak,
        AchievementId.sevenDayStreak,
        AchievementId.veteran,
      ]),
    );
  });

  test('normal sprinter requires normal difficulty and 15 seconds or less', () {
    final evaluator = AchievementEvaluator();

    final qualifying = evaluator.evaluate(
      _context(
        difficulty: GameDifficulty.normal,
        elapsedMilliseconds: 15000,
      ),
      unlockedIds: {},
    );
    final tooSlow = evaluator.evaluate(
      _context(
        difficulty: GameDifficulty.normal,
        elapsedMilliseconds: 15100,
      ),
      unlockedIds: {},
    );
    final wrongDifficulty = evaluator.evaluate(
      _context(
        difficulty: GameDifficulty.easy,
        elapsedMilliseconds: 10000,
      ),
      unlockedIds: {},
    );

    expect(qualifying, contains(AchievementId.normalSprinter));
    expect(tooSlow, isNot(contains(AchievementId.normalSprinter)));
    expect(wrongDifficulty, isNot(contains(AchievementId.normalSprinter)));
  });

  test('daily debut requires a daily challenge completion', () {
    final evaluator = AchievementEvaluator();

    expect(
      evaluator.evaluate(
        _context(isDailyChallenge: true),
        unlockedIds: {},
      ),
      contains(AchievementId.dailyDebut),
    );
    expect(
      evaluator.evaluate(
        _context(isDailyChallenge: false),
        unlockedIds: {},
      ),
      isNot(contains(AchievementId.dailyDebut)),
    );
  });

  test('does not return achievements that are already unlocked', () {
    final evaluator = AchievementEvaluator();

    final unlocked = evaluator.evaluate(
      _context(wrongTapCount: 0),
      unlockedIds: {
        AchievementId.firstClear,
        AchievementId.perfectRun,
      },
    );

    expect(unlocked, isNot(contains(AchievementId.firstClear)));
    expect(unlocked, isNot(contains(AchievementId.perfectRun)));
  });
}

AchievementEvaluationContext _context({
  GameDifficulty difficulty = GameDifficulty.normal,
  int elapsedMilliseconds = 20000,
  int wrongTapCount = 1,
  bool isDailyChallenge = false,
  int currentStreak = 0,
  int completedGames = 1,
}) {
  return AchievementEvaluationContext(
    difficulty: difficulty,
    elapsedMilliseconds: elapsedMilliseconds,
    wrongTapCount: wrongTapCount,
    isDailyChallenge: isDailyChallenge,
    currentStreak: currentStreak,
    completedGames: completedGames,
  );
}
