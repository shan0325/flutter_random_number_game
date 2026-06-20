# Daily Challenge Design

## Goal

Add a daily challenge that gives users a reason to return each day without
requiring a server or changing the core 1to25 rules.

## Scope

- Add a `Today's Challenge` entry point on the start screen.
- Use the Normal 5x5 rules for every daily challenge.
- Generate one deterministic number layout per local calendar date.
- Allow unlimited attempts during the day.
- Save the best challenge time for each date.
- Show today's best challenge time on the start screen.
- Identify challenge results separately from normal game results.
- Keep normal difficulty records unchanged.

The first version does not include online rankings, attempt limits, streaks, or
past challenge browsing.

## Architecture

### Daily challenge

`DailyChallenge` owns the challenge date and deterministic 1-25 number layout.
The layout seed is derived from a stable `yyyyMMdd` integer, so the same local
date always produces the same layout across app restarts.

The implementation must not use `String.hashCode`, because its stability is not
part of the stored data contract.

### Challenge records

`DailyChallengeRecord` stores:

- challenge date as `yyyy-MM-dd`
- best elapsed time in milliseconds

`DailyChallengeStorage` stores records in a separate SharedPreferences key.
Normal `GameRecord` serialization remains unchanged.

Only a faster result replaces an existing record for the same date.

### Game screen

The game screen keeps one gameplay implementation and tracks whether the active
session is a normal game or daily challenge.

Starting a challenge:

- forces Normal difficulty
- uses the date-derived fixed layout
- uses the existing countdown, timer, penalties, sound, vibration, and result
  dialog

Retrying the challenge on the same date uses the same layout.

### Result dialog

The result dialog displays `Today's Challenge` instead of a difficulty label
for challenge sessions. Challenge completion updates only the daily challenge
record and does not add an entry to the normal record list.

## Date behavior

The challenge date is captured when the challenge starts. If midnight passes
during a game, that run remains associated with the date on which it started.
Returning to the start screen refreshes the current date before the next
challenge begins.

Dates use the device's local timezone.

## Error handling

- Missing challenge records are treated as no best time.
- Invalid stored challenge entries are ignored instead of preventing app
  startup.
- Storage failures do not block gameplay; they are reported with `debugPrint`.

## Testing

- Same date creates the same layout.
- Different dates create different layouts.
- Generated layouts contain every number from 1 through 25 exactly once.
- Faster challenge results replace the date's best result.
- Slower results do not replace the best result.
- Starting the challenge uses its fixed layout.
- Challenge completion is stored separately from normal records.
- Start screen exposes the challenge entry point and today's best time.
