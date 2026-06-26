// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get classicMode => '일반 게임';

  @override
  String get dailyMode => '오늘의 도전';

  @override
  String get start => '시작';

  @override
  String get difficultyEasy => '쉬움';

  @override
  String get difficultyNormal => '보통';

  @override
  String get difficultyHard => '어려움';

  @override
  String get soundOff => '소리 끄기';

  @override
  String get soundOn => '소리 켜기';

  @override
  String get themes => '테마';

  @override
  String get achievements => '업적';

  @override
  String get statistics => '통계';

  @override
  String get records => '기록';

  @override
  String get todayChallenge => '오늘의 도전';

  @override
  String get todayChallengeMode => '오늘의 도전';

  @override
  String get todayBestEmpty => '오늘 최고 기록 --';

  @override
  String todayBest(String time) {
    return '오늘 최고 기록 $time';
  }

  @override
  String difficultyBest(String difficulty, String record) {
    return '$difficulty 최고 기록 $record';
  }

  @override
  String currentStreak(int count) {
    return '현재 $count일';
  }

  @override
  String bestStreak(int count) {
    return '최고 $count일';
  }

  @override
  String get weekdayMonday => '월';

  @override
  String get weekdayTuesday => '화';

  @override
  String get weekdayWednesday => '수';

  @override
  String get weekdayThursday => '목';

  @override
  String get weekdayFriday => '금';

  @override
  String get weekdaySaturday => '토';

  @override
  String get weekdaySunday => '일';

  @override
  String get themeClassic => '클래식';

  @override
  String get themeMidnight => '미드나이트';

  @override
  String get themeNeon => '네온';

  @override
  String get unlockThreeAchievements => '업적 3개를 달성하면 해금됩니다';

  @override
  String get completeSevenDayStreak => '7일 연속 도전 업적을 달성하면 해금됩니다';

  @override
  String get newBest => '새 최고 기록!';

  @override
  String get gameOver => '게임 종료';

  @override
  String get difficulty => '난이도';

  @override
  String get mode => '모드';

  @override
  String get grade => '등급';

  @override
  String get best => '최고 기록';

  @override
  String get streak => '연속 도전';

  @override
  String streakDays(int count) {
    return '$count일';
  }

  @override
  String get wrongTaps => '오답';

  @override
  String get accuracy => '정확도';

  @override
  String get achievementUnlocked => '업적 달성';

  @override
  String get again => '다시 하기';

  @override
  String get gradePerfect => '완벽';

  @override
  String get gradeSharp => '정확';

  @override
  String get gradeTryAgain => '다시 도전';

  @override
  String get firstRecord => '첫 기록';

  @override
  String secondsFaster(String seconds) {
    return '$seconds초 단축';
  }

  @override
  String secondsSlower(String seconds) {
    return '$seconds초 느림';
  }

  @override
  String get sortRecord => '기록순';

  @override
  String get sortDate => '날짜순';

  @override
  String recordSubtitle(String difficulty, String date) {
    return '$difficulty · $date';
  }

  @override
  String unlockedCount(int unlocked, int total) {
    return '$total개 중 $unlocked개 달성';
  }

  @override
  String unlockedAt(String date) {
    return '$date 달성';
  }

  @override
  String progressCount(int current, int target) {
    return '$current / $target';
  }

  @override
  String get achievementFirstClearTitle => '첫 클리어';

  @override
  String get achievementFirstClearDescription => '게임을 처음 완료하세요.';

  @override
  String get achievementPerfectRunTitle => '완벽한 플레이';

  @override
  String get achievementPerfectRunDescription => '오답 없이 게임을 완료하세요.';

  @override
  String get achievementNormalSprinterTitle => '보통 난이도 스프린터';

  @override
  String get achievementNormalSprinterDescription => '보통 난이도를 15.0초 이내에 완료하세요.';

  @override
  String get achievementHardClearTitle => '어려움 클리어';

  @override
  String get achievementHardClearDescription => '어려움 난이도를 완료하세요.';

  @override
  String get achievementDailyDebutTitle => '오늘의 첫 도전';

  @override
  String get achievementDailyDebutDescription => '오늘의 도전을 완료하세요.';

  @override
  String get achievementThreeDayStreakTitle => '3일 연속 도전';

  @override
  String get achievementThreeDayStreakDescription => '오늘의 도전을 3일 연속 완료하세요.';

  @override
  String get achievementSevenDayStreakTitle => '7일 연속 도전';

  @override
  String get achievementSevenDayStreakDescription => '오늘의 도전을 7일 연속 완료하세요.';

  @override
  String get achievementVeteranTitle => '베테랑';

  @override
  String get achievementVeteranDescription => '게임을 100회 완료하세요.';

  @override
  String get dailyCompletions => '오늘의 도전 완료';

  @override
  String get statisticsBestStreak => '최고 연속 기록';

  @override
  String achievementFraction(int unlocked, int total) {
    return '$unlocked / $total';
  }

  @override
  String noDifficultyRecords(String difficulty) {
    return '$difficulty 난이도 기록이 없습니다';
  }

  @override
  String get games => '플레이';

  @override
  String get recentAverage => '최근 평균';

  @override
  String get recentTenGames => '최근 10게임';

  @override
  String secondsValue(String seconds) {
    return '$seconds초';
  }

  @override
  String get tapStatisticsUnavailable => '이 버전에서 게임을 플레이하면 정확도와 오답 통계가 표시됩니다.';
}
