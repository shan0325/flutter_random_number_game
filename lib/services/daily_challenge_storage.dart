import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/daily_challenge_record.dart';

class DailyChallengeStorage {
  static const recordsKey = 'daily_challenge_records';

  Future<List<DailyChallengeRecord>> loadRecords() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final values = prefs.getStringList(recordsKey) ?? [];

      return values
          .map(DailyChallengeRecord.tryDeserialize)
          .whereType<DailyChallengeRecord>()
          .toList();
    } catch (error) {
      debugPrint('Daily challenge records failed to load: $error');
      return [];
    }
  }

  Future<int?> loadBestMilliseconds(String dateKey) async {
    final records = await loadRecords();
    for (final record in records) {
      if (record.dateKey == dateKey) {
        return record.bestMilliseconds;
      }
    }
    return null;
  }

  Future<void> saveBest(String dateKey, int elapsedMilliseconds) async {
    if (elapsedMilliseconds <= 0) return;

    try {
      final records = await loadRecords();
      final index = records.indexWhere((record) => record.dateKey == dateKey);

      if (index >= 0) {
        if (records[index].bestMilliseconds <= elapsedMilliseconds) return;
        records[index] = DailyChallengeRecord(
          dateKey: dateKey,
          bestMilliseconds: elapsedMilliseconds,
        );
      } else {
        records.add(
          DailyChallengeRecord(
            dateKey: dateKey,
            bestMilliseconds: elapsedMilliseconds,
          ),
        );
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(
        recordsKey,
        records.map((record) => record.serialize()).toList(),
      );
    } catch (error) {
      debugPrint('Daily challenge record failed to save: $error');
    }
  }
}
