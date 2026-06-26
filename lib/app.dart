import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'l10n/generated/app_localizations.dart';
import 'models/app_theme_id.dart';
import 'screens/number_game_screen.dart';
import 'services/achievement_storage.dart';
import 'services/theme_preference_storage.dart';
import 'theme/game_theme.dart';

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    this.themePreferenceStorage,
    this.achievementStorage,
    this.locale,
  });

  final ThemePreferenceStorage? themePreferenceStorage;
  final AchievementStorage? achievementStorage;
  final Locale? locale;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ThemePreferenceStorage _themePreferenceStorage;
  late final AchievementStorage _achievementStorage;
  AppThemeId _themeId = AppThemeId.classic;

  @override
  void initState() {
    super.initState();
    _themePreferenceStorage = widget.themePreferenceStorage ??
        SharedPreferencesThemePreferenceStorage();
    _achievementStorage = widget.achievementStorage ?? AchievementStorage();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = await _themePreferenceStorage.loadTheme();
    final achievementState = await _achievementStorage.loadState();
    if (!mounted) return;
    setState(() {
      _themeId = savedTheme.isUnlocked(achievementState.unlockedIds)
          ? savedTheme
          : AppThemeId.classic;
    });
  }

  Future<void> _selectTheme(AppThemeId themeId) async {
    setState(() {
      _themeId = themeId;
    });
    await _themePreferenceStorage.saveTheme(themeId);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: widget.locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: AppLocalizations.supportedLocales,
      theme: buildGameTheme(_themeId),
      home: NumberGameScreen(
        achievementStorage: _achievementStorage,
        selectedTheme: _themeId,
        onThemeSelected: _selectTheme,
      ),
    );
  }
}
