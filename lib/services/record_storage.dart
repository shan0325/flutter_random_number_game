import 'package:shared_preferences/shared_preferences.dart';

import '../models/game_record.dart';

class RecordStorage {
  static const _recordsKey = 'records';

  Future<List<GameRecord>> loadRecords() async {
    final prefs = await SharedPreferences.getInstance();
    final recordStrings = prefs.getStringList(_recordsKey) ?? [];

    return recordStrings.map(GameRecord.deserialize).toList();
  }

  Future<void> saveRecords(List<GameRecord> records) async {
    final prefs = await SharedPreferences.getInstance();
    final recordStrings = records.map((record) => record.serialize()).toList();

    await prefs.setStringList(_recordsKey, recordStrings);
  }
}
