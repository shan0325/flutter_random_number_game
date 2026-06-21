import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/models/app_theme_id.dart';
import 'package:onetotwentyfive/theme/game_theme.dart';

void main() {
  test('every app theme provides semantic game colors', () {
    for (final themeId in AppThemeId.values) {
      expect(
        buildGameTheme(themeId).extension<GameThemeColors>(),
        isNotNull,
      );
    }
  });

  test('theme palettes use distinct screen and primary colors', () {
    final palettes = AppThemeId.values
        .map(
          (theme) => buildGameTheme(theme).extension<GameThemeColors>()!,
        )
        .toList();

    expect(palettes.map((palette) => palette.screen).toSet(), hasLength(3));
    expect(palettes.map((palette) => palette.primary).toSet(), hasLength(3));
  });
}
