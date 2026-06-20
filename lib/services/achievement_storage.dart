import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/achievement.dart';
import '../models/daily_challenge_record.dart';
import '../models/daily_challenge_stats.dart';
import '../models/game_difficulty.dart';
import '../models/game_record.dart';

class AchievementState {
  AchievementState({
    Map<AchievementId, String>? unlockDates,
    this.completedGames = 0,
  }) : unlockDates = unlockDates ?? {};

  final Map<AchievementId, String> unlockDates;
  final int completedGames;

  Set<AchievementId> get unlockedIds => unlockDates.keys.toSet();

  AchievementState copyWith({
    Map<AchievementId, String>? unlockDates,
    int? completedGames,
  }) {
    return AchievementState(
      unlockDates: unlockDates ?? Map.of(this.unlockDates),
      completedGames: completedGames ?? this.completedGames,
    );
  }
}

class AchievementStorage {
  static const unlocksKey = 'achievement_unlocks';
  static const completedGamesKey = 'achievement_completed_games';

  Future<AchievementState> loadState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final unlockDates = <AchievementId, String>{};

      for (final value in prefs.getStringList(unlocksKey) ?? []) {
        final separator = value.indexOf('::');
        if (separator <= 0) continue;

        final idName = value.substring(0, separator);
        final date = value.substring(separator + 2);
        final id = AchievementId.values
            .where((achievement) => achievement.name == idName)
            .firstOrNull;
        if (id != null && date.isNotEmpty) {
          unlockDates[id] = date;
        }
      }

      return AchievementState(
        unlockDates: unlockDates,
        completedGames: prefs.getInt(completedGamesKey) ?? 0,
      );
    } catch (error) {
      debugPrint('Achievements failed to load: $error');
      return AchievementState();
    }
  }

  Future<void> saveState(AchievementState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        unlocksKey,
        state.unlockDates.entries
            .map((entry) => '${entry.key.name}::${entry.value}')
            .toList(),
      );
      await prefs.setInt(completedGamesKey, state.completedGames);
    } catch (error) {
      debugPrint('Achievements failed to save: $error');
    }
  }

  Future<AchievementState> backfill({
    required List<GameRecord> normalRecords,
    required List<DailyChallengeRecord> dailyRecords,
    required DailyChallengeStats dailyStats,
    required DateTime now,
  }) async {
    final state = await loadState();
    final unlockDates = Map<AchievementId, String>.of(state.unlockDates);
    final totalRecords = normalRecords.length + dailyRecords.length;
    final completedGames = state.completedGames < totalRecords
        ? totalRecords
        : state.completedGames;
    final unlockDate = _formatDateTime(now);

    void unlock(AchievementId id, bool qualified) {
      if (qualified) {
        unlockDates.putIfAbsent(id, () => unlockDate);
      }
    }

    unlock(AchievementId.firstClear, totalRecords > 0);
    unlock(
      AchievementId.normalSprinter,
      normalRecords.any(
        (record) =>
            record.difficulty == GameDifficulty.normal &&
            (double.tryParse(record.record) ?? double.infinity) <= 15,
      ),
    );
    unlock(
      AchievementId.hardClear,
      normalRecords.any(
        (record) => record.difficulty == GameDifficulty.hard,
      ),
    );
    unlock(AchievementId.dailyDebut, dailyRecords.isNotEmpty);
    unlock(AchievementId.threeDayStreak, dailyStats.bestStreak >= 3);
    unlock(AchievementId.sevenDayStreak, dailyStats.bestStreak >= 7);
    unlock(AchievementId.veteran, completedGames >= 100);

    final updated = AchievementState(
      unlockDates: unlockDates,
      completedGames: completedGames,
    );
    await saveState(updated);
    return updated;
  }

  static String _formatDateTime(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '${date.year}-$month-$day $hour:$minute:$second';
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull {
    final iterator = this.iterator;
    return iterator.moveNext() ? iterator.current : null;
  }
}
