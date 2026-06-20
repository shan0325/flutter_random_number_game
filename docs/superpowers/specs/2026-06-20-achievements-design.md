# Achievements Design

## Goal

Add long-term goals without changing the core timing game or existing record
formats.

## Achievements

- First Clear: complete one game
- Perfect Run: complete a game with zero wrong taps
- Normal Sprinter: complete Normal in 15.0 seconds or less
- Hard Clear: complete Hard once
- Daily Debut: complete Today's Challenge once
- 3 Day Streak: reach a three-day daily challenge streak
- 7 Day Streak: reach a seven-day daily challenge streak
- Veteran: complete 100 games

Daily challenge completions count toward total completed games.

## Storage

Store achievement state separately from normal and daily challenge records.

- `achievement_unlocks`: string list using `achievementId::yyyy-MM-dd HH:mm:ss`
- `achievement_completed_games`: integer total

Existing records are used to backfill achievements that can be proven:

- First Clear
- Normal Sprinter
- Hard Clear
- Daily Debut
- 3 Day Streak
- 7 Day Streak

Perfect Run and an exact Veteran count cannot be reconstructed from old record
formats. Veteran counting starts with the number of existing normal and daily
challenge records, then increments for every new completion.

## Evaluation

Evaluate achievements after every completed normal or daily challenge game.
Return only newly unlocked achievements so the result dialog can announce them.
An achievement can only be unlocked once.

## UI

- Add a trophy icon to the start screen toolbar.
- Add an achievement screen listing all achievements.
- Show unlocked state, description, progress, and unlock date.
- Show newly unlocked achievement names in the game result dialog.

## Testing

- Each achievement condition unlocks at the exact threshold.
- Already unlocked achievements are not returned again.
- Unlocks and completed game count persist.
- Existing records backfill only provable achievements.
- Achievement screen shows locked and unlocked states.
- Result dialog announces newly unlocked achievements.
