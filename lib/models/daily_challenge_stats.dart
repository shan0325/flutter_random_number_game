import 'daily_challenge_record.dart';

class DailyChallengeDayStatus {
  const DailyChallengeDayStatus({
    required this.dateKey,
    required this.weekdayLabel,
    required this.completed,
  });

  final String dateKey;
  final String weekdayLabel;
  final bool completed;
}

class DailyChallengeStats {
  const DailyChallengeStats({
    required this.currentStreak,
    required this.bestStreak,
    required this.recentDays,
  });

  factory DailyChallengeStats.fromRecords(
    List<DailyChallengeRecord> records, {
    required DateTime today,
  }) {
    final normalizedToday = DateTime(today.year, today.month, today.day);
    final completedDates = records
        .map((record) => _parseDateKey(record.dateKey))
        .whereType<DateTime>()
        .map(_dayNumber)
        .toSet();

    final todayNumber = _dayNumber(normalizedToday);
    var currentDateNumber =
        completedDates.contains(todayNumber) ? todayNumber : todayNumber - 1;
    var currentStreak = 0;
    while (completedDates.contains(currentDateNumber)) {
      currentStreak++;
      currentDateNumber--;
    }

    final sortedDates = completedDates.toList()..sort();
    var bestStreak = 0;
    var runningStreak = 0;
    int? previousDateNumber;
    for (final dateNumber in sortedDates) {
      runningStreak =
          previousDateNumber != null && dateNumber == previousDateNumber + 1
              ? runningStreak + 1
              : 1;
      if (runningStreak > bestStreak) {
        bestStreak = runningStreak;
      }
      previousDateNumber = dateNumber;
    }

    final recentDays = List.generate(7, (index) {
      final date = normalizedToday.subtract(Duration(days: 6 - index));
      return DailyChallengeDayStatus(
        dateKey: _formatDateKey(date),
        weekdayLabel: _weekdayLabels[date.weekday - 1],
        completed: completedDates.contains(_dayNumber(date)),
      );
    });

    return DailyChallengeStats(
      currentStreak: currentStreak,
      bestStreak: bestStreak,
      recentDays: recentDays,
    );
  }

  final int currentStreak;
  final int bestStreak;
  final List<DailyChallengeDayStatus> recentDays;

  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  static int _dayNumber(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  static DateTime? _parseDateKey(String value) {
    final match = RegExp(r'^(\d{4})-(\d{2})-(\d{2})$').firstMatch(value);
    if (match == null) return null;

    final year = int.parse(match.group(1)!);
    final month = int.parse(match.group(2)!);
    final day = int.parse(match.group(3)!);
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return date;
  }

  static String _formatDateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
