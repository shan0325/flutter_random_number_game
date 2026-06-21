import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/game_difficulty.dart';
import '../models/game_result.dart';
import '../theme/game_theme.dart';

class GameResultDialog extends StatelessWidget {
  const GameResultDialog({
    super.key,
    required this.result,
    required this.difficulty,
    required this.record,
    required this.onPlayAgain,
    required this.onViewRecords,
    this.modeLabel,
    this.showRecords = true,
    this.streakCount,
    this.unlockedAchievements = const [],
  });

  final GameResult result;
  final GameDifficulty difficulty;
  final String record;
  final VoidCallback onPlayAgain;
  final VoidCallback onViewRecords;
  final String? modeLabel;
  final bool showRecords;
  final int? streakCount;
  final List<AchievementId> unlockedAchievements;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(result.isNewBest ? 'NEW BEST!' : 'GAME OVER'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                record,
                style: const TextStyle(
                  fontSize: 38,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(height: 16),
            _ResultRow(
              label: modeLabel == null ? 'Difficulty' : 'Mode',
              value: modeLabel ?? difficulty.label,
            ),
            _ResultRow(label: 'Grade', value: result.gradeLabel),
            _ResultRow(label: 'Best', value: result.bestDeltaLabel),
            if (streakCount != null)
              _ResultRow(label: 'Streak', value: '$streakCount days'),
            _ResultRow(label: 'Wrong taps', value: '${result.wrongTapCount}'),
            _ResultRow(
              label: 'Accuracy',
              value:
                  '${result.correctTapCount}/${result.totalTapCount} (${result.accuracyPercent}%)',
            ),
            if (unlockedAchievements.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                'Achievement Unlocked',
                style: TextStyle(
                  color: colors.progress,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              ...unlockedAchievements.map(
                (achievement) => Text(
                  achievement.title,
                  style: TextStyle(
                    color: colors.text,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        if (showRecords)
          TextButton(
            onPressed: onViewRecords,
            child: const Text('Records'),
          ),
        TextButton(
          onPressed: onPlayAgain,
          child: const Text('Again'),
        ),
      ],
    );
  }
}

class _ResultRow extends StatelessWidget {
  const _ResultRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: colors.text),
          ),
          const SizedBox(width: 16),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.right,
              style: TextStyle(
                color: colors.text,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
