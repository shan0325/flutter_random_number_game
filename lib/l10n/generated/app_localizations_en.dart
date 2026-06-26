// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get classicMode => 'CLASSIC';

  @override
  String get dailyMode => 'DAILY';

  @override
  String get start => 'START';

  @override
  String get difficultyEasy => 'Easy';

  @override
  String get difficultyNormal => 'Normal';

  @override
  String get difficultyHard => 'Hard';

  @override
  String get soundOff => 'Sound off';

  @override
  String get soundOn => 'Sound on';

  @override
  String get themes => 'Themes';

  @override
  String get achievements => 'Achievements';

  @override
  String get statistics => 'Statistics';

  @override
  String get records => 'Records';

  @override
  String get todayChallenge => 'TODAY\'S CHALLENGE';

  @override
  String get todayChallengeMode => 'Today\'s Challenge';

  @override
  String get todayBestEmpty => 'TODAY\'S BEST --';

  @override
  String todayBest(String time) {
    return 'TODAY\'S BEST $time';
  }

  @override
  String difficultyBest(String difficulty, String record) {
    return '$difficulty BEST $record';
  }

  @override
  String currentStreak(int count) {
    return 'STREAK $count';
  }

  @override
  String bestStreak(int count) {
    return 'BEST $count';
  }

  @override
  String get weekdayMonday => 'M';

  @override
  String get weekdayTuesday => 'T';

  @override
  String get weekdayWednesday => 'W';

  @override
  String get weekdayThursday => 'T';

  @override
  String get weekdayFriday => 'F';

  @override
  String get weekdaySaturday => 'S';

  @override
  String get weekdaySunday => 'S';

  @override
  String get themeClassic => 'Classic';

  @override
  String get themeMidnight => 'Midnight';

  @override
  String get themeNeon => 'Neon';

  @override
  String get unlockThreeAchievements => 'Unlock 3 achievements';

  @override
  String get completeSevenDayStreak => 'Complete the 7 Day Streak achievement';

  @override
  String get newBest => 'NEW BEST!';

  @override
  String get gameOver => 'GAME OVER';

  @override
  String get difficulty => 'Difficulty';

  @override
  String get mode => 'Mode';

  @override
  String get grade => 'Grade';

  @override
  String get best => 'Best';

  @override
  String get streak => 'Streak';

  @override
  String streakDays(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count days',
      one: '1 day',
    );
    return '$_temp0';
  }

  @override
  String get wrongTaps => 'Wrong taps';

  @override
  String get accuracy => 'Accuracy';

  @override
  String get achievementUnlocked => 'Achievement Unlocked';

  @override
  String get again => 'Again';

  @override
  String get gradePerfect => 'Perfect';

  @override
  String get gradeSharp => 'Sharp';

  @override
  String get gradeTryAgain => 'Try Again';

  @override
  String get firstRecord => 'First record';

  @override
  String secondsFaster(String seconds) {
    return '${seconds}s faster';
  }

  @override
  String secondsSlower(String seconds) {
    return '${seconds}s slower';
  }

  @override
  String get sortRecord => 'Record';

  @override
  String get sortDate => 'Date';

  @override
  String recordSubtitle(String difficulty, String date) {
    return '$difficulty · $date';
  }

  @override
  String unlockedCount(int unlocked, int total) {
    return '$unlocked / $total unlocked';
  }

  @override
  String unlockedAt(String date) {
    return 'Unlocked $date';
  }

  @override
  String progressCount(int current, int target) {
    return '$current / $target';
  }

  @override
  String get achievementFirstClearTitle => 'First Clear';

  @override
  String get achievementFirstClearDescription => 'Complete your first game.';

  @override
  String get achievementPerfectRunTitle => 'Perfect Run';

  @override
  String get achievementPerfectRunDescription =>
      'Complete a game without a wrong tap.';

  @override
  String get achievementNormalSprinterTitle => 'Normal Sprinter';

  @override
  String get achievementNormalSprinterDescription =>
      'Finish Normal in 15.0 seconds or less.';

  @override
  String get achievementHardClearTitle => 'Hard Clear';

  @override
  String get achievementHardClearDescription => 'Complete Hard mode.';

  @override
  String get achievementDailyDebutTitle => 'Daily Debut';

  @override
  String get achievementDailyDebutDescription => 'Complete Today\'s Challenge.';

  @override
  String get achievementThreeDayStreakTitle => '3 Day Streak';

  @override
  String get achievementThreeDayStreakDescription =>
      'Reach a 3-day daily challenge streak.';

  @override
  String get achievementSevenDayStreakTitle => '7 Day Streak';

  @override
  String get achievementSevenDayStreakDescription =>
      'Reach a 7-day daily challenge streak.';

  @override
  String get achievementVeteranTitle => 'Veteran';

  @override
  String get achievementVeteranDescription => 'Complete 100 games.';

  @override
  String get dailyCompletions => 'Daily completions';

  @override
  String get statisticsBestStreak => 'Best streak';

  @override
  String achievementFraction(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String noDifficultyRecords(String difficulty) {
    return 'No $difficulty records yet';
  }

  @override
  String get games => 'Games';

  @override
  String get recentAverage => 'Recent avg';

  @override
  String get recentTenGames => 'Recent 10 games';

  @override
  String secondsValue(String seconds) {
    return '${seconds}s';
  }

  @override
  String get tapStatisticsUnavailable =>
      'Accuracy and wrong-tap statistics will appear after playing this version.';
}
