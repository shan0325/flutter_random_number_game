// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Japanese (`ja`).
class AppLocalizationsJa extends AppLocalizations {
  AppLocalizationsJa([String locale = 'ja']) : super(locale);

  @override
  String get classicMode => '通常ゲーム';

  @override
  String get dailyMode => '今日の挑戦';

  @override
  String get start => 'スタート';

  @override
  String get difficultyEasy => 'かんたん';

  @override
  String get difficultyNormal => 'ふつう';

  @override
  String get difficultyHard => 'むずかしい';

  @override
  String get soundOff => 'サウンドをオフ';

  @override
  String get soundOn => 'サウンドをオン';

  @override
  String get themes => 'テーマ';

  @override
  String get achievements => '実績';

  @override
  String get statistics => '統計';

  @override
  String get records => '記録';

  @override
  String get todayChallenge => '今日の挑戦';

  @override
  String get todayChallengeMode => '今日の挑戦';

  @override
  String get todayBestEmpty => '今日のベスト --';

  @override
  String todayBest(String time) {
    return '今日のベスト $time';
  }

  @override
  String difficultyBest(String difficulty, String record) {
    return '$difficulty ベスト $record';
  }

  @override
  String currentStreak(int count) {
    return '現在 $count日';
  }

  @override
  String bestStreak(int count) {
    return '最高 $count日';
  }

  @override
  String get weekdayMonday => '月';

  @override
  String get weekdayTuesday => '火';

  @override
  String get weekdayWednesday => '水';

  @override
  String get weekdayThursday => '木';

  @override
  String get weekdayFriday => '金';

  @override
  String get weekdaySaturday => '土';

  @override
  String get weekdaySunday => '日';

  @override
  String get themeClassic => 'クラシック';

  @override
  String get themeMidnight => 'ミッドナイト';

  @override
  String get themeNeon => 'ネオン';

  @override
  String get unlockThreeAchievements => '実績を3個達成すると解除されます';

  @override
  String get completeSevenDayStreak => '7日連続チャレンジの実績を達成すると解除されます';

  @override
  String get newBest => '新記録！';

  @override
  String get gameOver => 'ゲーム終了';

  @override
  String get difficulty => '難易度';

  @override
  String get mode => 'モード';

  @override
  String get grade => '評価';

  @override
  String get best => 'ベスト';

  @override
  String get streak => '連続挑戦';

  @override
  String streakDays(int count) {
    return '$count日';
  }

  @override
  String get wrongTaps => 'ミスタップ';

  @override
  String get accuracy => '正確度';

  @override
  String get achievementUnlocked => '実績を達成';

  @override
  String get again => 'もう一度';

  @override
  String get gradePerfect => 'パーフェクト';

  @override
  String get gradeSharp => 'シャープ';

  @override
  String get gradeTryAgain => '再挑戦';

  @override
  String get firstRecord => '初記録';

  @override
  String secondsFaster(String seconds) {
    return '$seconds秒速い';
  }

  @override
  String secondsSlower(String seconds) {
    return '$seconds秒遅い';
  }

  @override
  String get sortRecord => '記録順';

  @override
  String get sortDate => '日付順';

  @override
  String recordSubtitle(String difficulty, String date) {
    return '$difficulty · $date';
  }

  @override
  String unlockedCount(int unlocked, int total) {
    return '$total個中$unlocked個達成';
  }

  @override
  String unlockedAt(String date) {
    return '$dateに達成';
  }

  @override
  String progressCount(int current, int target) {
    return '$current / $target';
  }

  @override
  String get achievementFirstClearTitle => '初クリア';

  @override
  String get achievementFirstClearDescription => 'ゲームを初めてクリアする。';

  @override
  String get achievementPerfectRunTitle => 'パーフェクトラン';

  @override
  String get achievementPerfectRunDescription => 'ミスタップなしでゲームをクリアする。';

  @override
  String get achievementNormalSprinterTitle => 'ノーマルスプリンター';

  @override
  String get achievementNormalSprinterDescription => 'ふつうを15.0秒以内にクリアする。';

  @override
  String get achievementHardClearTitle => 'ハードクリア';

  @override
  String get achievementHardClearDescription => 'むずかしいをクリアする。';

  @override
  String get achievementDailyDebutTitle => '今日の初挑戦';

  @override
  String get achievementDailyDebutDescription => '今日の挑戦をクリアする。';

  @override
  String get achievementThreeDayStreakTitle => '3日連続挑戦';

  @override
  String get achievementThreeDayStreakDescription => '今日の挑戦を3日連続でクリアする。';

  @override
  String get achievementSevenDayStreakTitle => '7日連続挑戦';

  @override
  String get achievementSevenDayStreakDescription => '今日の挑戦を7日連続でクリアする。';

  @override
  String get achievementVeteranTitle => 'ベテラン';

  @override
  String get achievementVeteranDescription => 'ゲームを100回クリアする。';

  @override
  String get dailyCompletions => '今日の挑戦クリア';

  @override
  String get statisticsBestStreak => '最高連続記録';

  @override
  String achievementFraction(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String noDifficultyRecords(String difficulty) {
    return '$difficultyの記録はまだありません';
  }

  @override
  String get games => 'プレイ';

  @override
  String get recentAverage => '最近の平均';

  @override
  String get recentTenGames => '最近の10ゲーム';

  @override
  String secondsValue(String seconds) {
    return '$seconds秒';
  }

  @override
  String get tapStatisticsUnavailable => 'このバージョンでプレイすると正確度とミスタップの統計が表示されます。';
}
