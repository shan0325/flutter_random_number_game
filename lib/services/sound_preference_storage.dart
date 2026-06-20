import 'package:shared_preferences/shared_preferences.dart';

abstract class SoundPreferenceStorage {
  Future<bool> loadSoundEnabled();

  Future<void> saveSoundEnabled(bool enabled);
}

class SharedPreferencesSoundPreferenceStorage
    implements SoundPreferenceStorage {
  static const _soundEnabledKey = 'sound_enabled';

  @override
  Future<bool> loadSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_soundEnabledKey) ?? true;
  }

  @override
  Future<void> saveSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_soundEnabledKey, enabled);
  }
}
