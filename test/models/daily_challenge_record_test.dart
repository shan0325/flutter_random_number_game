import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/daily_challenge_record.dart';

void main() {
  test('serializes and deserializes a daily challenge record', () {
    const record = DailyChallengeRecord(
      dateKey: '2026-06-20',
      bestMilliseconds: 12300,
    );

    expect(record.serialize(), '2026-06-20::12300');
    expect(
      DailyChallengeRecord.tryDeserialize(record.serialize()),
      record,
    );
  });

  test('returns null for malformed records', () {
    expect(DailyChallengeRecord.tryDeserialize('invalid'), isNull);
    expect(
      DailyChallengeRecord.tryDeserialize('2026-02-30::12300'),
      isNull,
    );
    expect(
      DailyChallengeRecord.tryDeserialize('2026-06-20::-1'),
      isNull,
    );
  });
}
