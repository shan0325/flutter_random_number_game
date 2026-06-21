import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_theme_id.dart';

abstract class ThemePreferenceStorage {
  Future<AppThemeId> loadTheme();

  Future<void> saveTheme(AppThemeId theme);
}

class SharedPreferencesThemePreferenceStorage
    implements ThemePreferenceStorage {
  static const selectedThemeKey = 'selected_theme';

  @override
  Future<AppThemeId> loadTheme() async {
    try {
      final preferences = await SharedPreferences.getInstance();
      return AppThemeId.fromStorageValue(
        preferences.getString(selectedThemeKey),
      );
    } catch (error) {
      debugPrint('Theme failed to load: $error');
      return AppThemeId.classic;
    }
  }

  @override
  Future<void> saveTheme(AppThemeId theme) async {
    try {
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString(selectedThemeKey, theme.storageValue);
    } catch (error) {
      debugPrint('Theme failed to save: $error');
    }
  }
}
