import 'package:flutter/material.dart';

import '../l10n/domain_localizations.dart';
import '../l10n/l10n.dart';
import '../models/achievement.dart';
import '../models/app_theme_id.dart';
import '../theme/game_theme.dart';

class ThemePickerSheet extends StatelessWidget {
  const ThemePickerSheet({
    super.key,
    required this.selectedTheme,
    required this.unlockedAchievements,
    required this.onSelected,
  });

  final AppThemeId selectedTheme;
  final Set<AchievementId> unlockedAchievements;
  final ValueChanged<AppThemeId> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = context.l10n;
    return Material(
      color: colors.screen,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.themes,
                style: TextStyle(
                  color: colors.text,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ...AppThemeId.values.map((themeId) {
                final unlocked = themeId.isUnlocked(unlockedAchievements);
                final palette =
                    buildGameTheme(themeId).extension<GameThemeColors>()!;
                return ListTile(
                  key: Key('theme-${themeId.storageValue}'),
                  enabled: unlocked,
                  contentPadding: EdgeInsets.zero,
                  leading: _ThemeSwatches(colors: palette),
                  title: Text(themeId.localizedName(l10n)),
                  subtitle: unlocked
                      ? null
                      : Text(themeId.localizedUnlockDescription(l10n)!),
                  trailing: selectedTheme == themeId
                      ? const Icon(Icons.check_circle)
                      : Icon(unlocked ? Icons.circle_outlined : Icons.lock),
                  onTap: unlocked ? () => onSelected(themeId) : null,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}

class _ThemeSwatches extends StatelessWidget {
  const _ThemeSwatches({required this.colors});

  final GameThemeColors colors;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 48,
      child: Row(
        children: [
          for (final color in [
            colors.screen,
            colors.primary,
            colors.secondary,
          ])
            Container(
              width: 16,
              height: 32,
              color: color,
            ),
        ],
      ),
    );
  }
}
