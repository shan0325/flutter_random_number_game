# Daily Challenge Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a serverless daily Normal 5x5 challenge with a deterministic layout and a separately stored daily best time.

**Architecture:** A pure `DailyChallenge` model generates a stable layout from the local calendar date. `DailyChallengeStorage` owns a separate SharedPreferences record format. `NumberGameScreen` reuses the current gameplay loop while tracking a normal or daily-challenge session.

**Tech Stack:** Flutter, Dart, SharedPreferences, flutter_test

---

### Task 1: Deterministic Daily Challenge

**Files:**
- Create: `lib/models/daily_challenge.dart`
- Create: `test/models/daily_challenge_test.dart`

- [ ] **Step 1: Write failing model tests**

Test that the same date returns the same layout, two dates return different
layouts, and each layout contains all numbers from 1 through 25 exactly once.

- [ ] **Step 2: Verify the tests fail**

Run:

```bash
flutter test test/models/daily_challenge_test.dart
```

Expected: compilation failure because `DailyChallenge` does not exist.

- [ ] **Step 3: Implement stable date-based generation**

Create `DailyChallenge.forDate(DateTime date)` with:

- a normalized `DateTime(date.year, date.month, date.day)`
- a stable integer seed of `year * 10000 + month * 100 + day`
- a shuffled `List<int>` containing 1 through 25 using `Random(seed)`
- a `dateKey` formatted as `yyyy-MM-dd` without locale dependencies

- [ ] **Step 4: Verify model tests pass**

Run:

```bash
flutter test test/models/daily_challenge_test.dart
```

Expected: all tests pass.

### Task 2: Daily Best Record Storage

**Files:**
- Create: `lib/models/daily_challenge_record.dart`
- Create: `lib/services/daily_challenge_storage.dart`
- Create: `test/models/daily_challenge_record_test.dart`
- Create: `test/services/daily_challenge_storage_test.dart`

- [ ] **Step 1: Write failing record and storage tests**

Cover:

- `yyyy-MM-dd::milliseconds` serialization
- invalid entries return `null`
- a first result is stored
- a faster result replaces the existing daily best
- a slower result leaves the existing best unchanged

Use `SharedPreferences.setMockInitialValues({})` for storage tests.

- [ ] **Step 2: Verify the tests fail**

Run:

```bash
flutter test test/models/daily_challenge_record_test.dart test/services/daily_challenge_storage_test.dart
```

Expected: compilation failure because the record and storage classes do not
exist.

- [ ] **Step 3: Implement record parsing and storage**

`DailyChallengeRecord.tryDeserialize` must validate the date and positive
milliseconds. `DailyChallengeStorage` stores the records under
`daily_challenge_records`, ignores malformed entries, and exposes:

```dart
Future<List<DailyChallengeRecord>> loadRecords();
Future<int?> loadBestMilliseconds(String dateKey);
Future<void> saveBest(String dateKey, int elapsedMilliseconds);
```

- [ ] **Step 4: Verify storage tests pass**

Run:

```bash
flutter test test/models/daily_challenge_record_test.dart test/services/daily_challenge_storage_test.dart
```

Expected: all tests pass.

### Task 3: Challenge Gameplay Integration

**Files:**
- Modify: `lib/screens/number_game_screen.dart`
- Modify: `lib/widgets/game_result_dialog.dart`
- Modify: `test/widget_test.dart`

- [ ] **Step 1: Write failing widget tests**

Cover:

- the start screen shows `TODAY'S CHALLENGE`
- tapping the button starts the existing countdown
- the challenge uses the deterministic date layout
- the result dialog labels the run as `Today's Challenge`
- challenge completion does not add a normal record

Inject a fixed clock callback and fake daily challenge storage into
`NumberGameScreen` so the tests do not depend on the real date.

- [ ] **Step 2: Verify widget tests fail**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: failures because the challenge entry point and session state do not
exist.

- [ ] **Step 3: Add session state and challenge start flow**

Add an internal session type:

```dart
enum GameSessionType { normal, dailyChallenge }
```

Track the active challenge date and layout. Starting a challenge forces Normal
difficulty, preserves the fixed layout through countdown and retries, and
reuses penalties, sound, vibration, and timing.

- [ ] **Step 4: Save and display challenge results**

On completion:

- play the existing completion sound
- save only the daily best for challenge sessions
- skip `GameRecord` insertion
- pass an optional result label to `GameResultDialog`
- refresh today's best when returning to the start screen

- [ ] **Step 5: Verify widget tests pass**

Run:

```bash
flutter test test/widget_test.dart
```

Expected: all widget tests pass.

### Task 4: Documentation and Full Verification

**Files:**
- Modify: `README.md`
- Modify: `AGENTS.md`

- [ ] **Step 1: Document the feature**

Add the daily challenge behavior, local-date rule, separate storage key, and
test files to project documentation.

- [ ] **Step 2: Format and analyze**

Run:

```bash
dart format lib test
flutter analyze
```

Expected: no analyzer issues.

- [ ] **Step 3: Run all tests**

Run:

```bash
flutter test
```

Expected: all tests pass.

- [ ] **Step 4: Build the Android release bundle**

Run:

```bash
flutter build appbundle --release
```

Expected: `build/app/outputs/bundle/release/app-release.aab` is created.

- [ ] **Step 5: Check the final diff**

Run:

```bash
git diff --check
git status --short
```

Expected: no whitespace errors; unrelated existing macOS changes remain
untouched.
