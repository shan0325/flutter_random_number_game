import 'package:flutter/material.dart';

import '../l10n/domain_localizations.dart';
import '../l10n/l10n.dart';
import '../models/achievement_progress.dart';
import '../theme/game_theme.dart';
import '../widgets/game_scaffold.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({
    super.key,
    required this.achievements,
  });

  final List<AchievementProgress> achievements;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = context.l10n;
    final unlockedCount =
        achievements.where((achievement) => achievement.isUnlocked).length;

    return GameScaffold(
      appBar: AppBar(
        backgroundColor: colors.appBar,
        foregroundColor: colors.text,
        title: Text(l10n.achievements),
      ),
      body: ColoredBox(
        color: colors.screen,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              l10n.unlockedCount(unlockedCount, achievements.length),
              style: TextStyle(
                color: colors.text,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            ...achievements.map(_AchievementTile.new),
          ],
        ),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  const _AchievementTile(this.progress);

  final AchievementProgress progress;

  @override
  Widget build(BuildContext context) {
    final id = progress.id;
    final colors = context.gameColors;
    final l10n = context.l10n;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: progress.isUnlocked ? colors.surface : colors.completedTile,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(color: colors.border),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              progress.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              color: progress.isUnlocked ? colors.progress : colors.mutedText,
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id.localizedTitle(l10n),
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    id.localizedDescription(l10n),
                    style: TextStyle(color: colors.mutedText),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.fraction,
                    minHeight: 5,
                    color: colors.progress,
                    backgroundColor: colors.completedTile,
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress.isUnlocked
                        ? l10n.unlockedAt(progress.unlockedAt!)
                        : l10n.progressCount(
                            progress.current,
                            progress.target,
                          ),
                    style: TextStyle(
                      color: colors.mutedText,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
