class DailyChallengeRecord {
  const DailyChallengeRecord({
    required this.dateKey,
    required this.bestMilliseconds,
  });

  final String dateKey;
  final int bestMilliseconds;

  String serialize() => '$dateKey::$bestMilliseconds';

  static DailyChallengeRecord? tryDeserialize(String value) {
    final parts = value.split('::');
    if (parts.length != 2) return null;

    final date = _tryParseDate(parts[0]);
    final milliseconds = int.tryParse(parts[1]);
    if (date == null || milliseconds == null || milliseconds <= 0) {
      return null;
    }

    return DailyChallengeRecord(
      dateKey: parts[0],
      bestMilliseconds: milliseconds,
    );
  }

  static DateTime? _tryParseDate(String value) {
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

  @override
  bool operator ==(Object other) {
    return other is DailyChallengeRecord &&
        other.dateKey == dateKey &&
        other.bestMilliseconds == bestMilliseconds;
  }

  @override
  int get hashCode => Object.hash(dateKey, bestMilliseconds);
}
