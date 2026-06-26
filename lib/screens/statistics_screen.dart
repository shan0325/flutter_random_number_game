import 'dart:math';

import 'package:flutter/material.dart';

import '../l10n/domain_localizations.dart';
import '../l10n/l10n.dart';
import '../models/game_difficulty.dart';
import '../models/game_record.dart';
import '../models/game_statistics.dart';
import '../theme/game_theme.dart';

class StatisticsScreen extends StatelessWidget {
  const StatisticsScreen({
    super.key,
    required this.records,
    required this.dailyCompletionCount,
    required this.bestDailyStreak,
    required this.unlockedAchievementCount,
    required this.totalAchievementCount,
  });

  final List<GameRecord> records;
  final int dailyCompletionCount;
  final int bestDailyStreak;
  final int unlockedAchievementCount;
  final int totalAchievementCount;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = context.l10n;
    return DefaultTabController(
      length: GameDifficulty.values.length,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: colors.appBar,
          foregroundColor: colors.text,
          title: Text(l10n.statistics),
          bottom: TabBar(
            labelColor: colors.text,
            indicatorColor: colors.primary,
            tabs: GameDifficulty.values
                .map(
                  (difficulty) => Tab(
                    text: difficulty.localizedLabel(l10n),
                  ),
                )
                .toList(),
          ),
        ),
        body: ColoredBox(
          color: colors.screen,
          child: Column(
            children: [
              _OverallSummary(
                dailyCompletionCount: dailyCompletionCount,
                bestDailyStreak: bestDailyStreak,
                unlockedAchievementCount: unlockedAchievementCount,
                totalAchievementCount: totalAchievementCount,
              ),
              Expanded(
                child: TabBarView(
                  children: GameDifficulty.values.map((difficulty) {
                    return _DifficultyStatisticsView(
                      statistics: GameStatistics.forDifficulty(
                        records,
                        difficulty,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _OverallSummary extends StatelessWidget {
  const _OverallSummary({
    required this.dailyCompletionCount,
    required this.bestDailyStreak,
    required this.unlockedAchievementCount,
    required this.totalAchievementCount,
  });

  final int dailyCompletionCount;
  final int bestDailyStreak;
  final int unlockedAchievementCount;
  final int totalAchievementCount;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: _SummaryValue(
              label: l10n.dailyCompletions,
              value: '$dailyCompletionCount',
            ),
          ),
          Expanded(
            child: _SummaryValue(
              label: l10n.statisticsBestStreak,
              value: '$bestDailyStreak',
            ),
          ),
          Expanded(
            child: _SummaryValue(
              label: l10n.achievements,
              value: l10n.achievementFraction(
                unlockedAchievementCount,
                totalAchievementCount,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryValue extends StatelessWidget {
  const _SummaryValue({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: colors.text,
            fontSize: 19,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          maxLines: 2,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.mutedText,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _DifficultyStatisticsView extends StatelessWidget {
  const _DifficultyStatisticsView({required this.statistics});

  final GameStatistics statistics;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    final l10n = context.l10n;
    if (!statistics.hasData) {
      return Center(
        child: Text(
          l10n.noDifficultyRecords(
            statistics.difficulty.localizedLabel(l10n),
          ),
          style: TextStyle(
            color: colors.mutedText,
            fontSize: 16,
          ),
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 8,
          runSpacing: 8,
          children: [
            _Metric(label: l10n.games, value: '${statistics.playCount}'),
            _Metric(
              label: l10n.best,
              value: l10n.secondsValue(
                statistics.bestSeconds!.toStringAsFixed(1),
              ),
            ),
            _Metric(
              label: l10n.recentAverage,
              value: l10n.secondsValue(
                statistics.recentAverageSeconds!.toStringAsFixed(1),
              ),
            ),
            _Metric(
              label: l10n.wrongTaps,
              value: statistics.averageWrongTaps == null
                  ? '--'
                  : statistics.averageWrongTaps!.toStringAsFixed(1),
            ),
            _Metric(
              label: l10n.accuracy,
              value: statistics.averageAccuracyPercent == null
                  ? '--'
                  : '${statistics.averageAccuracyPercent!.toStringAsFixed(1)}%',
            ),
          ],
        ),
        const SizedBox(height: 28),
        Text(
          l10n.recentTenGames,
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        AspectRatio(
          aspectRatio: 2,
          child: CustomPaint(
            painter: _TimeTrendPainter(statistics.recentTimes, colors),
          ),
        ),
        if (statistics.recordsWithTapData == 0) ...[
          const SizedBox(height: 16),
          Text(
            l10n.tapStatisticsUnavailable,
            style: TextStyle(
              color: colors.mutedText,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return SizedBox(
      width: 104,
      height: 58,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            value,
            style: TextStyle(
              color: colors.text,
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: colors.mutedText,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _TimeTrendPainter extends CustomPainter {
  const _TimeTrendPainter(this.times, this.colors);

  final List<double> times;
  final GameThemeColors colors;

  @override
  void paint(Canvas canvas, Size size) {
    const padding = 16.0;
    final chart = Rect.fromLTWH(
      padding,
      padding,
      size.width - padding * 2,
      size.height - padding * 2,
    );
    final gridPaint = Paint()
      ..color = colors.border.withValues(alpha: 0.45)
      ..strokeWidth = 1;
    for (var index = 0; index <= 3; index++) {
      final y = chart.top + chart.height * index / 3;
      canvas.drawLine(
        Offset(chart.left, y),
        Offset(chart.right, y),
        gridPaint,
      );
    }

    if (times.isEmpty) return;
    final minimum = times.reduce(min);
    final maximum = times.reduce(max);
    final range = max(1.0, maximum - minimum);
    final points = List.generate(times.length, (index) {
      final x = times.length == 1
          ? chart.center.dx
          : chart.left + chart.width * index / (times.length - 1);
      final normalized = (times[index] - minimum) / range;
      return Offset(x, chart.bottom - normalized * chart.height);
    });
    final linePaint = Paint()
      ..color = colors.progress
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      path.lineTo(point.dx, point.dy);
    }
    canvas.drawPath(path, linePaint);

    final pointPaint = Paint()..color = colors.chart;
    for (final point in points) {
      canvas.drawCircle(point, 4, pointPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _TimeTrendPainter oldDelegate) {
    return oldDelegate.times != times || oldDelegate.colors != colors;
  }
}
