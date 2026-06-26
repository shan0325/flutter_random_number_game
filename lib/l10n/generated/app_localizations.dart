import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ja'),
    Locale('ko')
  ];

  /// No description provided for @classicMode.
  ///
  /// In en, this message translates to:
  /// **'CLASSIC'**
  String get classicMode;

  /// No description provided for @dailyMode.
  ///
  /// In en, this message translates to:
  /// **'DAILY'**
  String get dailyMode;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'START'**
  String get start;

  /// No description provided for @difficultyEasy.
  ///
  /// In en, this message translates to:
  /// **'Easy'**
  String get difficultyEasy;

  /// No description provided for @difficultyNormal.
  ///
  /// In en, this message translates to:
  /// **'Normal'**
  String get difficultyNormal;

  /// No description provided for @difficultyHard.
  ///
  /// In en, this message translates to:
  /// **'Hard'**
  String get difficultyHard;

  /// No description provided for @soundOff.
  ///
  /// In en, this message translates to:
  /// **'Sound off'**
  String get soundOff;

  /// No description provided for @soundOn.
  ///
  /// In en, this message translates to:
  /// **'Sound on'**
  String get soundOn;

  /// No description provided for @themes.
  ///
  /// In en, this message translates to:
  /// **'Themes'**
  String get themes;

  /// No description provided for @achievements.
  ///
  /// In en, this message translates to:
  /// **'Achievements'**
  String get achievements;

  /// No description provided for @statistics.
  ///
  /// In en, this message translates to:
  /// **'Statistics'**
  String get statistics;

  /// No description provided for @records.
  ///
  /// In en, this message translates to:
  /// **'Records'**
  String get records;

  /// No description provided for @todayChallenge.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S CHALLENGE'**
  String get todayChallenge;

  /// No description provided for @todayChallengeMode.
  ///
  /// In en, this message translates to:
  /// **'Today\'s Challenge'**
  String get todayChallengeMode;

  /// No description provided for @todayBestEmpty.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S BEST --'**
  String get todayBestEmpty;

  /// No description provided for @todayBest.
  ///
  /// In en, this message translates to:
  /// **'TODAY\'S BEST {time}'**
  String todayBest(String time);

  /// No description provided for @difficultyBest.
  ///
  /// In en, this message translates to:
  /// **'{difficulty} BEST {record}'**
  String difficultyBest(String difficulty, String record);

  /// No description provided for @currentStreak.
  ///
  /// In en, this message translates to:
  /// **'STREAK {count}'**
  String currentStreak(int count);

  /// No description provided for @bestStreak.
  ///
  /// In en, this message translates to:
  /// **'BEST {count}'**
  String bestStreak(int count);

  /// No description provided for @weekdayMonday.
  ///
  /// In en, this message translates to:
  /// **'M'**
  String get weekdayMonday;

  /// No description provided for @weekdayTuesday.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayTuesday;

  /// No description provided for @weekdayWednesday.
  ///
  /// In en, this message translates to:
  /// **'W'**
  String get weekdayWednesday;

  /// No description provided for @weekdayThursday.
  ///
  /// In en, this message translates to:
  /// **'T'**
  String get weekdayThursday;

  /// No description provided for @weekdayFriday.
  ///
  /// In en, this message translates to:
  /// **'F'**
  String get weekdayFriday;

  /// No description provided for @weekdaySaturday.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySaturday;

  /// No description provided for @weekdaySunday.
  ///
  /// In en, this message translates to:
  /// **'S'**
  String get weekdaySunday;

  /// No description provided for @themeClassic.
  ///
  /// In en, this message translates to:
  /// **'Classic'**
  String get themeClassic;

  /// No description provided for @themeMidnight.
  ///
  /// In en, this message translates to:
  /// **'Midnight'**
  String get themeMidnight;

  /// No description provided for @themeNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get themeNeon;

  /// No description provided for @unlockThreeAchievements.
  ///
  /// In en, this message translates to:
  /// **'Unlock 3 achievements'**
  String get unlockThreeAchievements;

  /// No description provided for @completeSevenDayStreak.
  ///
  /// In en, this message translates to:
  /// **'Complete the 7 Day Streak achievement'**
  String get completeSevenDayStreak;

  /// No description provided for @newBest.
  ///
  /// In en, this message translates to:
  /// **'NEW BEST!'**
  String get newBest;

  /// No description provided for @gameOver.
  ///
  /// In en, this message translates to:
  /// **'GAME OVER'**
  String get gameOver;

  /// No description provided for @difficulty.
  ///
  /// In en, this message translates to:
  /// **'Difficulty'**
  String get difficulty;

  /// No description provided for @mode.
  ///
  /// In en, this message translates to:
  /// **'Mode'**
  String get mode;

  /// No description provided for @grade.
  ///
  /// In en, this message translates to:
  /// **'Grade'**
  String get grade;

  /// No description provided for @best.
  ///
  /// In en, this message translates to:
  /// **'Best'**
  String get best;

  /// No description provided for @streak.
  ///
  /// In en, this message translates to:
  /// **'Streak'**
  String get streak;

  /// No description provided for @streakDays.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 day} other{{count} days}}'**
  String streakDays(int count);

  /// No description provided for @wrongTaps.
  ///
  /// In en, this message translates to:
  /// **'Wrong taps'**
  String get wrongTaps;

  /// No description provided for @accuracy.
  ///
  /// In en, this message translates to:
  /// **'Accuracy'**
  String get accuracy;

  /// No description provided for @achievementUnlocked.
  ///
  /// In en, this message translates to:
  /// **'Achievement Unlocked'**
  String get achievementUnlocked;

  /// No description provided for @again.
  ///
  /// In en, this message translates to:
  /// **'Again'**
  String get again;

  /// No description provided for @gradePerfect.
  ///
  /// In en, this message translates to:
  /// **'Perfect'**
  String get gradePerfect;

  /// No description provided for @gradeSharp.
  ///
  /// In en, this message translates to:
  /// **'Sharp'**
  String get gradeSharp;

  /// No description provided for @gradeTryAgain.
  ///
  /// In en, this message translates to:
  /// **'Try Again'**
  String get gradeTryAgain;

  /// No description provided for @firstRecord.
  ///
  /// In en, this message translates to:
  /// **'First record'**
  String get firstRecord;

  /// No description provided for @secondsFaster.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s faster'**
  String secondsFaster(String seconds);

  /// No description provided for @secondsSlower.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s slower'**
  String secondsSlower(String seconds);

  /// No description provided for @sortRecord.
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get sortRecord;

  /// No description provided for @sortDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get sortDate;

  /// No description provided for @recordSubtitle.
  ///
  /// In en, this message translates to:
  /// **'{difficulty} · {date}'**
  String recordSubtitle(String difficulty, String date);

  /// No description provided for @unlockedCount.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total} unlocked'**
  String unlockedCount(int unlocked, int total);

  /// No description provided for @unlockedAt.
  ///
  /// In en, this message translates to:
  /// **'Unlocked {date}'**
  String unlockedAt(String date);

  /// No description provided for @progressCount.
  ///
  /// In en, this message translates to:
  /// **'{current} / {target}'**
  String progressCount(int current, int target);

  /// No description provided for @achievementFirstClearTitle.
  ///
  /// In en, this message translates to:
  /// **'First Clear'**
  String get achievementFirstClearTitle;

  /// No description provided for @achievementFirstClearDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete your first game.'**
  String get achievementFirstClearDescription;

  /// No description provided for @achievementPerfectRunTitle.
  ///
  /// In en, this message translates to:
  /// **'Perfect Run'**
  String get achievementPerfectRunTitle;

  /// No description provided for @achievementPerfectRunDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete a game without a wrong tap.'**
  String get achievementPerfectRunDescription;

  /// No description provided for @achievementNormalSprinterTitle.
  ///
  /// In en, this message translates to:
  /// **'Normal Sprinter'**
  String get achievementNormalSprinterTitle;

  /// No description provided for @achievementNormalSprinterDescription.
  ///
  /// In en, this message translates to:
  /// **'Finish Normal in 15.0 seconds or less.'**
  String get achievementNormalSprinterDescription;

  /// No description provided for @achievementHardClearTitle.
  ///
  /// In en, this message translates to:
  /// **'Hard Clear'**
  String get achievementHardClearTitle;

  /// No description provided for @achievementHardClearDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete Hard mode.'**
  String get achievementHardClearDescription;

  /// No description provided for @achievementDailyDebutTitle.
  ///
  /// In en, this message translates to:
  /// **'Daily Debut'**
  String get achievementDailyDebutTitle;

  /// No description provided for @achievementDailyDebutDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete Today\'s Challenge.'**
  String get achievementDailyDebutDescription;

  /// No description provided for @achievementThreeDayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'3 Day Streak'**
  String get achievementThreeDayStreakTitle;

  /// No description provided for @achievementThreeDayStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach a 3-day daily challenge streak.'**
  String get achievementThreeDayStreakDescription;

  /// No description provided for @achievementSevenDayStreakTitle.
  ///
  /// In en, this message translates to:
  /// **'7 Day Streak'**
  String get achievementSevenDayStreakTitle;

  /// No description provided for @achievementSevenDayStreakDescription.
  ///
  /// In en, this message translates to:
  /// **'Reach a 7-day daily challenge streak.'**
  String get achievementSevenDayStreakDescription;

  /// No description provided for @achievementVeteranTitle.
  ///
  /// In en, this message translates to:
  /// **'Veteran'**
  String get achievementVeteranTitle;

  /// No description provided for @achievementVeteranDescription.
  ///
  /// In en, this message translates to:
  /// **'Complete 100 games.'**
  String get achievementVeteranDescription;

  /// No description provided for @dailyCompletions.
  ///
  /// In en, this message translates to:
  /// **'Daily completions'**
  String get dailyCompletions;

  /// No description provided for @statisticsBestStreak.
  ///
  /// In en, this message translates to:
  /// **'Best streak'**
  String get statisticsBestStreak;

  /// No description provided for @achievementFraction.
  ///
  /// In en, this message translates to:
  /// **'{unlocked} / {total}'**
  String achievementFraction(int unlocked, int total);

  /// No description provided for @noDifficultyRecords.
  ///
  /// In en, this message translates to:
  /// **'No {difficulty} records yet'**
  String noDifficultyRecords(String difficulty);

  /// No description provided for @games.
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get games;

  /// No description provided for @recentAverage.
  ///
  /// In en, this message translates to:
  /// **'Recent avg'**
  String get recentAverage;

  /// No description provided for @recentTenGames.
  ///
  /// In en, this message translates to:
  /// **'Recent 10 games'**
  String get recentTenGames;

  /// No description provided for @secondsValue.
  ///
  /// In en, this message translates to:
  /// **'{seconds}s'**
  String secondsValue(String seconds);

  /// No description provided for @tapStatisticsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'Accuracy and wrong-tap statistics will appear after playing this version.'**
  String get tapStatisticsUnavailable;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ja', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
