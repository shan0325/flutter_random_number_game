# Achievement Theme Unlocks Design

## Goal

Add selectable visual themes that reward achievement progress without changing
game rules. Players can keep the current theme or unlock two additional themes,
and the selected theme persists across app restarts.

## Scope

This feature includes:

- Three application themes: Classic, Midnight, and Neon
- Achievement-based unlock rules
- A theme picker opened from the main screen
- Persistent theme selection
- Theme application across all application screens and dialogs
- Unit and widget tests for unlock, persistence, and selection behavior

This feature does not add new achievements, change existing achievement
conditions, or alter gameplay difficulty and scoring.

## Theme Definitions

### Classic

- Available to every player
- Preserves the current olive, cream, and brown appearance
- Used when no saved selection exists or a saved value is invalid

### Midnight

- Unlocked when at least three achievements are complete
- Uses a dark charcoal and navy surface with a gold accent
- Maintains sufficient contrast for number buttons, timers, navigation controls,
  penalties, and achievement progress

### Neon

- Unlocked only when `AchievementId.sevenDayStreak` is complete
- Uses a light neutral surface with teal and coral accents
- Represents the highest theme reward in this release

Unlocking Midnight does not unlock Neon. Each theme evaluates its own rule.

## User Experience

The main screen adds a palette icon to the existing utility controls. The icon
is visible only before a game starts, consistent with the sound, achievements,
statistics, and records controls.

Tapping the palette icon opens a modal bottom sheet containing one row per
theme. Each row shows:

- Theme name
- A compact color swatch preview
- Selected state
- Lock state
- Unlock requirement when locked

Unlocked rows can be selected. Selecting a theme applies it immediately, saves
the selection, and closes the sheet. Locked rows remain disabled and explain
the exact condition:

- Midnight: `Unlock 3 achievements`
- Neon: `Complete the 7 Day Streak achievement`

Only one theme can be active at a time. Players can switch back to any
previously unlocked theme.

## Architecture

### Theme Model

Add an application theme identifier with stable serialized values:

- `classic`
- `midnight`
- `neon`

Each identifier exposes its display name, unlock requirement, and color
palette. Unlock evaluation remains separate from widget rendering.

### Theme Palette

Define semantic colors rather than scattering theme-specific color constants:

- App bar background and foreground
- Screen background
- Primary action background and foreground
- Secondary control background and foreground
- Selected and unselected segment colors
- Number tile background, completed tile background, and tile foreground
- Primary and secondary text
- Border and progress colors
- Success, warning, and penalty colors

`ThemeData` supplies standard Material colors and text defaults. A dedicated
theme extension supplies game-specific semantic colors that Material
components do not cover.

### Unlock Policy

Theme availability is calculated from `AchievementState`:

- Classic always returns unlocked
- Midnight returns unlocked when `unlockedIds.length >= 3`
- Neon returns unlocked when `unlockedIds` contains
  `AchievementId.sevenDayStreak`

No duplicate theme unlock state is persisted. Achievement state is the source
of truth, preventing theme availability from becoming inconsistent with
achievements.

### Persistence

Store the selected theme identifier in `SharedPreferences` under a dedicated
key. Loading follows these rules:

1. Missing or unknown value resolves to Classic.
2. A saved but currently locked theme resolves to Classic.
3. Valid unlocked selections are restored.

Theme selection storage is independent from achievement storage.

### Application State

The selected theme must be owned above `MaterialApp` so changing it rebuilds
every route consistently. The root app state loads the preference, provides the
active theme, and exposes a selection callback to the game screen.

The game screen continues to own achievement refresh behavior. Before opening
the theme picker, it refreshes `AchievementState` so newly earned rewards are
immediately available.

## Screen Migration

Replace fixed palette colors in these surfaces with semantic theme colors:

- Main and active game screen
- Number grid
- Game result dialog
- Records screen
- Achievements screen
- Statistics screen and trend chart

AdMob content is not themed. Platform status/navigation bar behavior continues
to follow Flutter and Android defaults unless current application code already
configures it.

## Error Handling

- Preference read failure falls back to Classic.
- Preference write failure keeps the selected theme active for the current
  session and logs the failure through the existing debug logging pattern.
- Unknown stored identifiers never crash startup.
- A locked saved selection never bypasses the achievement rule.

## Testing

### Unit Tests

- Classic is always unlocked.
- Midnight unlocks at exactly three completed achievements.
- Neon unlocks only from the 7 Day Streak achievement.
- Unknown persisted values fall back to Classic.
- Stored unlocked selections are restored.
- Stored locked selections fall back to Classic.

### Widget Tests

- The palette button opens the theme picker.
- Locked themes show requirements and cannot be selected.
- Selecting an unlocked theme updates visible semantic colors.
- The selected theme is sent to persistence.
- Existing game, records, achievements, and statistics navigation still works
  under a non-Classic theme.

### Regression Verification

Run:

```bash
dart format lib test
flutter analyze
flutter test
flutter build appbundle --release
git diff --check
```

## Compatibility

Existing users have no theme preference, so they start with Classic. Existing
achievement progress is reused for unlock checks, including achievements
already backfilled from stored records. No existing SharedPreferences keys or
record formats are changed.
