import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/app_theme_id.dart';
import 'package:onetotwentyfive/services/theme_preference_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SharedPreferencesThemePreferenceStorage storage;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    storage = SharedPreferencesThemePreferenceStorage();
  });

  test('loads Classic when no preference exists', () async {
    expect(await storage.loadTheme(), AppThemeId.classic);
  });

  test('loads a known saved theme', () async {
    SharedPreferences.setMockInitialValues({'selected_theme': 'neon'});

    expect(await storage.loadTheme(), AppThemeId.neon);
  });

  test('falls back to Classic for an unknown saved theme', () async {
    SharedPreferences.setMockInitialValues({'selected_theme': 'unknown'});

    expect(await storage.loadTheme(), AppThemeId.classic);
  });

  test('saves the stable theme identifier', () async {
    await storage.saveTheme(AppThemeId.midnight);

    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('selected_theme'), 'midnight');
  });
}
