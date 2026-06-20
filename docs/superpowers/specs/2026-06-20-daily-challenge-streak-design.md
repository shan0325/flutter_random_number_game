# Daily Challenge Streak Design

## Goal

Increase daily challenge retention by showing current streak, best streak, and
completion status for the most recent seven local calendar days.

## Behavior

- Derive all statistics from existing `DailyChallengeRecord` entries.
- Do not store separate streak counters.
- Current streak ends today when today's challenge is complete.
- Before today's challenge is complete, current streak may end yesterday.
- Missing both today and yesterday results in a current streak of zero.
- Best streak is the longest consecutive sequence across all stored records.
- Recent activity covers today and the previous six local calendar days.
- Completing today's challenge refreshes the streak and recent activity
  immediately.
- Challenge result dialogs display the updated current streak.

## UI

Below the daily challenge button:

- show `CURRENT n DAYS` and `BEST n DAYS`
- show seven compact weekday indicators
- use a filled indicator for completed days and an outlined indicator for
  incomplete days

The indicators must use fixed dimensions so loading and state changes do not
move surrounding controls.

## Testing

- current streak includes today when complete
- current streak falls back to yesterday before today's completion
- a missed yesterday resets the current streak
- best streak finds the longest historical run
- recent seven-day statuses are ordered oldest to newest
- the start screen displays current and best values
- challenge completion updates the result dialog streak
