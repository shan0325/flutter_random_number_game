import 'package:flutter/material.dart';

import '../models/app_theme_id.dart';

@immutable
class GameThemeColors extends ThemeExtension<GameThemeColors> {
  const GameThemeColors({
    required this.appBar,
    required this.screen,
    required this.primary,
    required this.onPrimary,
    required this.secondary,
    required this.onSecondary,
    required this.surface,
    required this.text,
    required this.mutedText,
    required this.border,
    required this.numberTile,
    required this.completedTile,
    required this.progress,
    required this.chart,
    required this.penalty,
  });

  final Color appBar;
  final Color screen;
  final Color primary;
  final Color onPrimary;
  final Color secondary;
  final Color onSecondary;
  final Color surface;
  final Color text;
  final Color mutedText;
  final Color border;
  final Color numberTile;
  final Color completedTile;
  final Color progress;
  final Color chart;
  final Color penalty;

  @override
  GameThemeColors copyWith({
    Color? appBar,
    Color? screen,
    Color? primary,
    Color? onPrimary,
    Color? secondary,
    Color? onSecondary,
    Color? surface,
    Color? text,
    Color? mutedText,
    Color? border,
    Color? numberTile,
    Color? completedTile,
    Color? progress,
    Color? chart,
    Color? penalty,
  }) {
    return GameThemeColors(
      appBar: appBar ?? this.appBar,
      screen: screen ?? this.screen,
      primary: primary ?? this.primary,
      onPrimary: onPrimary ?? this.onPrimary,
      secondary: secondary ?? this.secondary,
      onSecondary: onSecondary ?? this.onSecondary,
      surface: surface ?? this.surface,
      text: text ?? this.text,
      mutedText: mutedText ?? this.mutedText,
      border: border ?? this.border,
      numberTile: numberTile ?? this.numberTile,
      completedTile: completedTile ?? this.completedTile,
      progress: progress ?? this.progress,
      chart: chart ?? this.chart,
      penalty: penalty ?? this.penalty,
    );
  }

  @override
  GameThemeColors lerp(covariant GameThemeColors? other, double t) {
    if (other == null) return this;
    return GameThemeColors(
      appBar: Color.lerp(appBar, other.appBar, t)!,
      screen: Color.lerp(screen, other.screen, t)!,
      primary: Color.lerp(primary, other.primary, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      secondary: Color.lerp(secondary, other.secondary, t)!,
      onSecondary: Color.lerp(onSecondary, other.onSecondary, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      text: Color.lerp(text, other.text, t)!,
      mutedText: Color.lerp(mutedText, other.mutedText, t)!,
      border: Color.lerp(border, other.border, t)!,
      numberTile: Color.lerp(numberTile, other.numberTile, t)!,
      completedTile: Color.lerp(completedTile, other.completedTile, t)!,
      progress: Color.lerp(progress, other.progress, t)!,
      chart: Color.lerp(chart, other.chart, t)!,
      penalty: Color.lerp(penalty, other.penalty, t)!,
    );
  }
}

ThemeData buildGameTheme(AppThemeId themeId) {
  final colors = switch (themeId) {
    AppThemeId.classic => const GameThemeColors(
        appBar: Color(0xFFCBD2A4),
        screen: Color(0xFFE9EED9),
        primary: Color(0xFF54473F),
        onPrimary: Colors.white,
        secondary: Color(0xFF9A7E6F),
        onSecondary: Colors.white,
        surface: Color(0xFFF2F3E4),
        text: Color(0xFF54473F),
        mutedText: Color(0xFF6D625B),
        border: Color(0xFFB8A395),
        numberTile: Color(0xFFCBD2A4),
        completedTile: Color(0xFFD5D8CC),
        progress: Color(0xFF5F5147),
        chart: Color(0xFF9A7E6F),
        penalty: Colors.redAccent,
      ),
    AppThemeId.midnight => const GameThemeColors(
        appBar: Color(0xFF202B38),
        screen: Color(0xFF121922),
        primary: Color(0xFFD7A84B),
        onPrimary: Color(0xFF19130A),
        secondary: Color(0xFF456176),
        onSecondary: Colors.white,
        surface: Color(0xFF1D2934),
        text: Color(0xFFE7EDF3),
        mutedText: Color(0xFFB9C8D4),
        border: Color(0xFF58758A),
        numberTile: Color(0xFF263746),
        completedTile: Color(0xFF1A242E),
        progress: Color(0xFFD7A84B),
        chart: Color(0xFF79AFC5),
        penalty: Color(0xFFFF6B6B),
      ),
    AppThemeId.neon => const GameThemeColors(
        appBar: Color(0xFFB8E6DD),
        screen: Color(0xFFF4F8F7),
        primary: Color(0xFF173B3F),
        onPrimary: Colors.white,
        secondary: Color(0xFF176B70),
        onSecondary: Colors.white,
        surface: Colors.white,
        text: Color(0xFF173B3F),
        mutedText: Color(0xFF42666A),
        border: Color(0xFFE16F5C),
        numberTile: Color(0xFFB8E6DD),
        completedTile: Color(0xFFDCE9E6),
        progress: Color(0xFFE16F5C),
        chart: Color(0xFF176B70),
        penalty: Color(0xFFE34850),
      ),
  };

  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: colors.primary,
      brightness:
          themeId == AppThemeId.midnight ? Brightness.dark : Brightness.light,
    ),
    scaffoldBackgroundColor: colors.screen,
    extensions: [colors],
  );
}

extension GameThemeContext on BuildContext {
  GameThemeColors get gameColors =>
      Theme.of(this).extension<GameThemeColors>() ??
      buildGameTheme(
        AppThemeId.classic,
      ).extension<GameThemeColors>()!;
}
