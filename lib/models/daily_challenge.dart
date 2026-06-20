import 'dart:math';

class DailyChallenge {
  DailyChallenge._({
    required this.date,
    required this.dateKey,
    required this.numbers,
  });

  factory DailyChallenge.forDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final seed = date.year * 10000 + date.month * 100 + date.day;
    final numbers = List.generate(25, (index) => index + 1)
      ..shuffle(Random(seed));

    return DailyChallenge._(
      date: normalizedDate,
      dateKey: _formatDateKey(normalizedDate),
      numbers: List.unmodifiable(numbers),
    );
  }

  final DateTime date;
  final String dateKey;
  final List<int> numbers;

  static String _formatDateKey(DateTime date) {
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '${date.year}-$month-$day';
  }
}
