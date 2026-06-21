# Achievement Theme Unlocks Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add persistent Classic, Midnight, and Neon themes whose availability is derived from achievement progress.

**Architecture:** `AppThemeId` defines stable identifiers and unlock rules, while `GameThemeColors` provides semantic colors through a `ThemeExtension`. The root `MyApp` owns the selected theme and persistence; `NumberGameScreen` refreshes achievements before opening a modal theme picker and delegates valid selections to the root.

**Tech Stack:** Flutter Material, Dart, SharedPreferences, flutter_test

---

### Task 1: Theme Rules and Persistence

**Files:**
- Create: `lib/models/app_theme_id.dart`
- Create: `lib/services/theme_preference_storage.dart`
- Test: `test/models/app_theme_id_test.dart`
- Test: `test/services/theme_preference_storage_test.dart`

- [ ] **Step 1: Write failing unlock-rule tests**

Test that Classic is always available, Midnight requires three unlocked
achievements, and Neon requires `AchievementId.sevenDayStreak`.

- [ ] **Step 2: Run the tests and verify RED**

Run: `flutter test test/models/app_theme_id_test.dart`

Expected: compilation failure because `AppThemeId` does not exist.

- [ ] **Step 3: Implement the theme identifier and unlock policy**

Add `classic`, `midnight`, and `neon` with stable storage values, display names,
locked descriptions, and `isUnlocked(Set<AchievementId>)`.

- [ ] **Step 4: Run the model tests and verify GREEN**

Run: `flutter test test/models/app_theme_id_test.dart`

Expected: all tests pass.

- [ ] **Step 5: Write failing persistence tests**

Use `SharedPreferences.setMockInitialValues` to verify default Classic, valid
identifier loading, invalid identifier fallback, and save behavior.

- [ ] **Step 6: Implement theme preference storage**

Add an injectable interface and SharedPreferences implementation using the
`selected_theme` key.

- [ ] **Step 7: Run persistence tests**

Run: `flutter test test/services/theme_preference_storage_test.dart`

Expected: all tests pass.

### Task 2: Semantic Theme Palettes

**Files:**
- Create: `lib/theme/game_theme.dart`
- Test: `test/theme/game_theme_test.dart`

- [ ] **Step 1: Write failing palette tests**

Verify every theme creates a `ThemeData` containing `GameThemeColors` and that
Classic, Midnight, and Neon use distinct screen and primary colors.

- [ ] **Step 2: Run the tests and verify RED**

Run: `flutter test test/theme/game_theme_test.dart`

Expected: compilation failure because the theme factory does not exist.

- [ ] **Step 3: Implement ThemeData and ThemeExtension**

Define semantic colors for application chrome, controls, number tiles, text,
borders, progress, charts, and penalty feedback. Implement `copyWith` and
`lerp`.

- [ ] **Step 4: Run palette tests and verify GREEN**

Run: `flutter test test/theme/game_theme_test.dart`

Expected: all tests pass.

### Task 3: Root Theme State and Picker

**Files:**
- Modify: `lib/app.dart`
- Modify: `lib/screens/number_game_screen.dart`
- Create: `lib/widgets/theme_picker_sheet.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing widget tests**

Verify the palette button opens the picker, locked themes are disabled with
requirements, an unlocked Neon selection calls persistence, and the visible
screen background changes.

- [ ] **Step 2: Run focused widget tests and verify RED**

Run: `flutter test test/widget_test.dart --plain-name "theme"`

Expected: failure because the palette button and picker do not exist.

- [ ] **Step 3: Implement root theme state**

Convert `MyApp` to a stateful widget, load the saved theme, validate it against
achievement state, and rebuild `MaterialApp` with the selected `ThemeData`.

- [ ] **Step 4: Implement the picker**

Add a palette icon to the pre-game utility row. Refresh achievements before
opening a modal bottom sheet and show swatches, selected state, lock state, and
requirements.

- [ ] **Step 5: Run focused widget tests and verify GREEN**

Run: `flutter test test/widget_test.dart --plain-name "theme"`

Expected: all theme widget tests pass.

### Task 4: Apply Semantic Colors Across Screens

**Files:**
- Modify: `lib/screens/number_game_screen.dart`
- Modify: `lib/screens/record_screen.dart`
- Modify: `lib/screens/achievement_screen.dart`
- Modify: `lib/screens/statistics_screen.dart`
- Modify: `lib/widgets/number_grid.dart`
- Modify: `lib/widgets/game_result_dialog.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Add a non-Classic navigation regression test**

Pump the app with Midnight selected and verify game, records, achievements, and
statistics surfaces can render with semantic colors.

- [ ] **Step 2: Run the test and verify RED**

Run: `flutter test test/widget_test.dart --plain-name "Midnight"`

Expected: failure while screens still use fixed Classic colors.

- [ ] **Step 3: Replace fixed palette colors**

Read `GameThemeColors` from context in every listed screen and widget. Preserve
layout, spacing, behavior, ad rendering, and the red penalty meaning.

- [ ] **Step 4: Run widget tests and verify GREEN**

Run: `flutter test test/widget_test.dart`

Expected: all widget tests pass.

### Task 5: Documentation and Full Verification

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Document themes and persistence**

Add the three themes, unlock conditions, picker behavior, semantic theme files,
and `selected_theme` preference key.

- [ ] **Step 2: Format and analyze**

Run: `dart format lib test`

Run: `flutter analyze`

Expected: no analysis issues.

- [ ] **Step 3: Run all tests**

Run: `flutter test`

Expected: all tests pass.

- [ ] **Step 4: Build the release bundle**

Run: `flutter build appbundle --release`

Expected: successful AAB at
`build/app/outputs/bundle/release/app-release.aab`.

- [ ] **Step 5: Check the diff**

Run: `git diff --check`

Expected: no whitespace errors.
