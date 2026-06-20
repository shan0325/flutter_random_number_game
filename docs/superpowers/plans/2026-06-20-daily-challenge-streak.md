# Daily Challenge Streak Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Derive and display daily challenge streaks and recent seven-day completion activity.

**Architecture:** A pure `DailyChallengeStats` model calculates all values from existing daily challenge records. The game screen loads the record list once, displays the derived summary, and recalculates it immediately after challenge completion.

**Tech Stack:** Flutter, Dart, flutter_test

---

### Task 1: Challenge Statistics

**Files:**
- Create: `lib/models/daily_challenge_stats.dart`
- Create: `test/models/daily_challenge_stats_test.dart`

- [ ] Write failing tests for current streak, best streak, and seven-day status.
- [ ] Run `flutter test test/models/daily_challenge_stats_test.dart`.
- [ ] Implement date normalization and consecutive-day calculations.
- [ ] Run the model test and confirm it passes.

### Task 2: Start and Result UI

**Files:**
- Modify: `lib/screens/number_game_screen.dart`
- Modify: `lib/widgets/game_result_dialog.dart`
- Modify: `test/widget_test.dart`

- [ ] Write failing widget tests for streak summary and result dialog.
- [ ] Load all challenge records and derive statistics.
- [ ] Add fixed-size recent-day indicators to the start screen.
- [ ] Display the current streak in challenge result dialogs.
- [ ] Run `flutter test test/widget_test.dart`.

### Task 3: Documentation and Verification

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`

- [ ] Document streak behavior and derived-state rule.
- [ ] Run `dart format lib test`.
- [ ] Run `flutter analyze`.
- [ ] Run `flutter test`.
- [ ] Run `flutter build appbundle --release`.
- [ ] Run `git diff --check`.
