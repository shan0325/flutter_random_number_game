import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/services/daily_challenge_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late DailyChallengeStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = DailyChallengeStorage();
  });

  test('stores the first result for a date', () async {
    await storage.saveBest('2026-06-20', 12300);

    expect(await storage.loadBestMilliseconds('2026-06-20'), 12300);
  });

  test('replaces a daily best with a faster result', () async {
    await storage.saveBest('2026-06-20', 12300);
    await storage.saveBest('2026-06-20', 11000);

    expect(await storage.loadBestMilliseconds('2026-06-20'), 11000);
  });

  test('keeps the daily best when a slower result is saved', () async {
    await storage.saveBest('2026-06-20', 11000);
    await storage.saveBest('2026-06-20', 12300);

    expect(await storage.loadBestMilliseconds('2026-06-20'), 11000);
  });

  test('ignores malformed stored entries', () async {
    SharedPreferences.setMockInitialValues({
      'daily_challenge_records': [
        'invalid',
        '2026-06-20::12300',
      ],
    });

    expect(await storage.loadBestMilliseconds('2026-06-20'), 12300);
  });
}
