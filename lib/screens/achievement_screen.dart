import 'package:flutter/material.dart';

import '../models/achievement.dart';
import '../models/achievement_progress.dart';

class AchievementScreen extends StatelessWidget {
  const AchievementScreen({
    super.key,
    required this.achievements,
  });

  final List<AchievementProgress> achievements;

  @override
  Widget build(BuildContext context) {
    final unlockedCount =
        achievements.where((achievement) => achievement.isUnlocked).length;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBD2A4),
        foregroundColor: const Color(0xFF54473F),
        title: const Text('Achievements'),
      ),
      body: ColoredBox(
        color: const Color(0xFFE9EED9),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              '$unlockedCount / ${achievements.length} unlocked',
              style: const TextStyle(
                color: Color(0xFF54473F),
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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      color: progress.isUnlocked
          ? const Color(0xFFF2F3E4)
          : const Color(0xFFE1E3D4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: const BorderSide(color: Color(0xFFB8A395)),
      ),
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(
              progress.isUnlocked ? Icons.emoji_events : Icons.lock_outline,
              color: progress.isUnlocked
                  ? const Color(0xFF8B6F47)
                  : const Color(0xFF7A746F),
              size: 30,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    id.title,
                    style: const TextStyle(
                      color: Color(0xFF54473F),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    id.description,
                    style: const TextStyle(color: Color(0xFF6D625B)),
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progress.fraction,
                    minHeight: 5,
                    color: const Color(0xFF5F5147),
                    backgroundColor: const Color(0xFFCBC9BD),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    progress.isUnlocked
                        ? 'Unlocked ${progress.unlockedAt}'
                        : '${progress.current} / ${progress.target}',
                    style: const TextStyle(
                      color: Color(0xFF6D625B),
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
