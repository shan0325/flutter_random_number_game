import 'package:flutter/material.dart';

import '../l10n/domain_localizations.dart';
import '../l10n/l10n.dart';
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
    final l10n = context.l10n;
    return AlertDialog(
      backgroundColor: colors.surface,
      title: Text(result.isNewBest ? l10n.newBest : l10n.gameOver),
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
              label: modeLabel == null ? l10n.difficulty : l10n.mode,
              value: modeLabel ?? difficulty.localizedLabel(l10n),
            ),
            _ResultRow(
              label: l10n.grade,
              value: result.localizedGrade(l10n),
            ),
            _ResultRow(
              label: l10n.best,
              value: result.localizedBestDelta(l10n),
            ),
            if (streakCount != null)
              _ResultRow(
                label: l10n.streak,
                value: l10n.streakDays(streakCount!),
              ),
            _ResultRow(
              label: l10n.wrongTaps,
              value: '${result.wrongTapCount}',
            ),
            _ResultRow(
              label: l10n.accuracy,
              value:
                  '${result.correctTapCount}/${result.totalTapCount} (${result.accuracyPercent}%)',
            ),
            if (unlockedAchievements.isNotEmpty) ...[
              const SizedBox(height: 14),
              Text(
                l10n.achievementUnlocked,
                style: TextStyle(
                  color: colors.progress,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              ...unlockedAchievements.map(
                (achievement) => Text(
                  achievement.localizedTitle(l10n),
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
            child: Text(l10n.records),
          ),
        TextButton(
          onPressed: onPlayAgain,
          child: Text(l10n.again),
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
