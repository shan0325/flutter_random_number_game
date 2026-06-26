# English, Korean, and Japanese Localization Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Localize every user-facing string into English, Korean, and Japanese using the device locale.

**Architecture:** Flutter `gen_l10n` generates `AppLocalizations` from three ARB files. Widgets read translations through `context.l10n`, while presentation extensions map stable domain enums and result values to localized strings without changing persisted identifiers.

**Tech Stack:** Flutter Material, flutter_localizations, gen_l10n, ARB, flutter_test

---

### Task 1: Localization Infrastructure

**Files:**
- Modify: `pubspec.yaml`
- Modify: `pubspec.lock`
- Create: `l10n.yaml`
- Create: `lib/l10n/app_en.arb`
- Create: `lib/l10n/app_ko.arb`
- Create: `lib/l10n/app_ja.arb`
- Create: `lib/l10n/l10n.dart`
- Modify: `lib/app.dart`
- Test: `test/localization/localization_test.dart`

- [ ] Add widget tests that pump Korean, Japanese, and unsupported locales and expect localized main controls.
- [ ] Run the focused tests and confirm they fail because localization delegates and ARB messages do not exist.
- [ ] Add `flutter_localizations`, enable code generation, and configure `l10n.yaml`.
- [ ] Define all static and parameterized messages in the three ARB files.
- [ ] Register `AppLocalizations.localizationsDelegates` and `supportedLocales`.
- [ ] Run `flutter gen-l10n` and the focused tests until locale selection passes.

### Task 2: Localized Domain Presentation

**Files:**
- Create: `lib/l10n/domain_localizations.dart`
- Modify: `lib/models/game_difficulty.dart`
- Modify: `lib/models/achievement.dart`
- Modify: `lib/models/app_theme_id.dart`
- Modify: `lib/models/game_result.dart`
- Test: `test/localization/domain_localizations_test.dart`

- [ ] Add tests for Korean and Japanese difficulty, achievement, theme, grade, and best-delta labels.
- [ ] Run the tests and confirm they fail because localized presentation mappings do not exist.
- [ ] Move display-only strings from models into localization-aware extensions.
- [ ] Keep enum names, storage values, unlock rules, targets, and numeric calculations unchanged.
- [ ] Run focused domain localization tests.

### Task 3: Localize Main Game and Theme Picker

**Files:**
- Modify: `lib/screens/number_game_screen.dart`
- Modify: `lib/widgets/theme_picker_sheet.dart`
- Modify: `test/widget_test.dart`

- [ ] Add Korean and Japanese widget tests for tooltips, modes, difficulties, daily labels, streaks, and theme picker requirements.
- [ ] Run the focused tests and confirm English-only labels fail.
- [ ] Replace main screen and theme picker literals with generated messages.
- [ ] Preserve `1to25`, widget keys, timers, and stored values.
- [ ] Run focused widget tests.

### Task 4: Localize Secondary Screens and Result Dialog

**Files:**
- Modify: `lib/screens/record_screen.dart`
- Modify: `lib/screens/achievement_screen.dart`
- Modify: `lib/screens/statistics_screen.dart`
- Modify: `lib/widgets/game_result_dialog.dart`
- Modify: `test/widget_test.dart`

- [ ] Add locale tests for records, achievements, statistics, result labels, actions, and dynamic values.
- [ ] Run tests and confirm untranslated labels fail.
- [ ] Replace all user-visible literals and localized model labels.
- [ ] Keep date storage format unchanged and display the stored date value as-is in this release.
- [ ] Run all widget tests.

### Task 5: Documentation and Verification

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`

- [ ] Document supported locales, fallback behavior, ARB files, and rules for adding user-facing strings.
- [ ] Run `flutter gen-l10n` and `dart format lib test`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter build appbundle --release`.
- [ ] Run `git diff --check`.
