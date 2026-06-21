# English, Korean, and Japanese Localization Design

## Goal

Display all user-facing text in Korean on Korean devices, Japanese on Japanese
devices, and English on every other device while preserving `1to25` as the
application brand name.

## Locale Behavior

The application supports:

- `en`: English fallback and ARB template
- `ko`: Korean
- `ja`: Japanese

Flutter selects the best supported locale from the device preferences. The app
does not add a manual language selector in this release.

## Localization Mechanism

Use Flutter's official `gen_l10n` workflow:

- Add `flutter_localizations` from the Flutter SDK
- Enable generated localization code in `pubspec.yaml`
- Configure ARB input and generated class in `l10n.yaml`
- Add `app_en.arb`, `app_ko.arb`, and `app_ja.arb`
- Register generated delegates and supported locales in `MaterialApp`

Add a small `BuildContext` extension so widgets can use `context.l10n`.

## Translation Scope

Translate all user-visible application text:

- Main mode and difficulty controls
- Tooltips and theme picker
- Daily challenge labels and streak summaries
- Records screen and sort options
- Statistics screen, metrics, and empty states
- Achievement names, descriptions, progress, and unlock messages
- Result dialog labels, grades, actions, and best-time comparison
- Theme names and unlock requirements

Keep these values unchanged:

- Brand name `1to25`
- SharedPreferences keys and serialized enum values
- Record and date storage formats
- Debug log messages
- Test keys and widget keys

## Model Boundary

Models retain stable enum identifiers and numeric data. Localized labels move
out of model extensions when they are used only for display.

Create presentation extensions that accept generated `AppLocalizations` and
map:

- `GameDifficulty`
- `AchievementId`
- `AppThemeId`
- `GameResult` grade and best-delta text

This prevents locale-dependent strings from entering persistence or business
logic.

## Dynamic Messages

ARB placeholders handle dynamic values:

- Best record and elapsed seconds
- Achievement counts and progress
- Wrong-tap and accuracy values
- Daily streak day count
- Record dates and difficulty names
- Empty-state difficulty labels

English uses plural forms where appropriate. Korean and Japanese use natural
fixed suffixes without artificial English pluralization.

## Layout

Existing responsive layouts remain unchanged unless translated text overflows.
Compact controls use existing constrained sizes and allow text wrapping or
smaller text where necessary. The Japanese and Korean strings must not overlap
icons, controls, or adjacent content.

## Testing

Widget tests explicitly pump English, Korean, and Japanese locales and verify:

- Korean main controls and screen navigation labels
- Japanese main controls and result labels
- Unsupported locale fallback to English
- Dynamic achievement, statistics, and result messages
- Existing gameplay interactions still work with localized labels

Run:

```bash
flutter gen-l10n
dart format lib test
flutter analyze
flutter test
flutter build appbundle --release
git diff --check
```

## Compatibility

Localization does not change stored records, achievements, themes, or sound
preferences. Existing users receive the correct language from their device
locale after updating.
