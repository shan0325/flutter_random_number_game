# Statistics Design

## Goal

Show meaningful play trends while preserving every existing record format.

## Record format

New classic records use:

```text
difficulty::record::date::wrongTapCount::totalTapCount
```

The app continues to read:

- `record::date`
- `difficulty::record::date`

Legacy records have unknown accuracy and wrong-tap values. They remain valid for
play count, best time, averages, and time trends, but are excluded from accuracy
and wrong-tap averages.

## Statistics

For each classic difficulty:

- total completed games
- best time
- average of the most recent 10 games
- average wrong taps from records with tap data
- average accuracy from records with tap data
- recent 10-game time trend

Summary data:

- total daily challenges completed
- best daily challenge streak
- unlocked achievements count

## UI

- Add an analytics icon to the start toolbar.
- The statistics screen uses Easy, Normal, and Hard tabs.
- The selected tab shows compact summary metrics and a recent-time chart.
- A separate summary band shows Daily completions, best streak, and achievement
  completion.
- When no data exists, show an explicit empty state instead of zero-valued
  misleading metrics.

## Testing

- all legacy record formats still deserialize
- new record format round-trips tap data
- recent average uses at most ten newest records
- unknown tap data is excluded from tap statistics
- difficulty filters remain isolated
- statistics screen navigation and empty state work
