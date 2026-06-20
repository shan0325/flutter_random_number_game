# Achievements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add eight persistent achievements, progress display, and unlock feedback.

**Architecture:** Pure achievement models and an evaluator define conditions. A SharedPreferences-backed repository stores unlock dates and completed game count. The game screen evaluates after completion and passes new unlocks to the result dialog; a separate screen displays all progress.

**Tech Stack:** Flutter, Dart, SharedPreferences, flutter_test

---

### Task 1: Models and Evaluation

**Files:**
- Create: `lib/models/achievement.dart`
- Create: `lib/models/achievement_progress.dart`
- Create: `lib/services/achievement_evaluator.dart`
- Create: `test/services/achievement_evaluator_test.dart`

- [ ] Write failing tests for all eight thresholds and duplicate prevention.
- [ ] Run the evaluator tests and confirm failure.
- [ ] Implement definitions, evaluation context, progress, and evaluator.
- [ ] Run the evaluator tests and confirm success.

### Task 2: Persistence and Backfill

**Files:**
- Create: `lib/services/achievement_storage.dart`
- Create: `test/services/achievement_storage_test.dart`

- [ ] Write failing tests for unlock and completed-game persistence.
- [ ] Implement SharedPreferences storage and malformed-entry handling.
- [ ] Test backfill from normal records and daily challenge records.
- [ ] Run storage tests.

### Task 3: Gameplay Integration

**Files:**
- Modify: `lib/screens/number_game_screen.dart`
- Modify: `lib/widgets/game_result_dialog.dart`
- Modify: `test/widget_test.dart`

- [ ] Write failing widget tests for unlock feedback.
- [ ] Evaluate and persist achievements after each completion.
- [ ] Pass newly unlocked achievement names to the result dialog.
- [ ] Run widget tests.

### Task 4: Achievement Screen

**Files:**
- Create: `lib/screens/achievement_screen.dart`
- Modify: `lib/screens/number_game_screen.dart`
- Modify: `test/widget_test.dart`

- [ ] Write failing tests for trophy navigation and locked/unlocked rows.
- [ ] Implement the achievement list screen and toolbar entry.
- [ ] Run widget tests.

### Task 5: Documentation and Verification

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`

- [ ] Document achievement storage and backfill limits.
- [ ] Run `dart format lib test`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter build appbundle --release`.
- [ ] Run `git diff --check`.
