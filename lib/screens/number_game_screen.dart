import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

import '../models/achievement.dart';
import '../models/achievement_progress.dart';
import '../models/app_theme_id.dart';
import '../models/daily_challenge.dart';
import '../models/daily_challenge_record.dart';
import '../models/daily_challenge_stats.dart';
import '../models/game_difficulty.dart';
import '../models/game_record.dart';
import '../models/game_result.dart';
import '../services/achievement_evaluator.dart';
import '../services/achievement_storage.dart';
import '../services/daily_challenge_storage.dart';
import '../services/game_sound_player.dart';
import '../services/record_storage.dart';
import '../services/sound_preference_storage.dart';
import '../theme/game_theme.dart';
import '../widgets/ad_mob_banner.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/number_grid.dart';
import '../widgets/theme_picker_sheet.dart';
import 'achievement_screen.dart';
import 'record_screen.dart';
import 'statistics_screen.dart';

enum GameSessionType {
  normal,
  dailyChallenge,
}

enum StartMode {
  classic,
  daily,
}

class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({
    super.key,
    this.recordStorage,
    this.dailyChallengeStorage,
    this.achievementStorage,
    this.gameSoundPlayer,
    this.soundPreferenceStorage,
    this.dateProvider,
    this.selectedTheme = AppThemeId.classic,
    this.onThemeSelected,
  });

  final RecordStorage? recordStorage;
  final DailyChallengeStorage? dailyChallengeStorage;
  final AchievementStorage? achievementStorage;
  final GameSoundPlayer? gameSoundPlayer;
  final SoundPreferenceStorage? soundPreferenceStorage;
  final DateTime Function()? dateProvider;
  final AppThemeId selectedTheme;
  final ValueChanged<AppThemeId>? onThemeSelected;

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> {
  late final RecordStorage _recordStorage;
  late final DailyChallengeStorage _dailyChallengeStorage;
  late final AchievementStorage _achievementStorage;
  final AchievementEvaluator _achievementEvaluator = AchievementEvaluator();
  late final GameSoundPlayer _gameSoundPlayer;
  late final bool _ownsGameSoundPlayer;
  late final SoundPreferenceStorage _soundPreferenceStorage;
  late final DateTime Function() _dateProvider;
  Future<void> _achievementRefresh = Future.value();

  GameDifficulty selectedDifficulty = GameDifficulty.normal;
  StartMode startMode = StartMode.classic;
  GameSessionType sessionType = GameSessionType.normal;
  DailyChallenge? activeDailyChallenge;
  List<int?> numbers =
      List.generate(GameDifficulty.normal.maxNumber, (index) => index + 1)
        ..shuffle();
  int currentNumber = 1;
  bool gameStarted = false;
  bool gamePaused = false;
  int timeElapsed = 0;
  Timer? timer;
  Timer? countdownTimer;
  Timer? penaltyTimer;
  List<GameRecord> records = [];
  int countdown = 0;
  double bestRecord = 0;
  bool showPenalty = false;
  int correctTapCount = 0;
  int wrongTapCount = 0;
  bool soundEnabled = true;
  int? todayChallengeBestMilliseconds;
  List<DailyChallengeRecord> dailyChallengeRecords = [];
  late DailyChallengeStats dailyChallengeStats;
  AchievementState achievementState = AchievementState();

  @override
  void initState() {
    super.initState();
    _recordStorage = widget.recordStorage ?? RecordStorage();
    _dailyChallengeStorage =
        widget.dailyChallengeStorage ?? DailyChallengeStorage();
    _achievementStorage = widget.achievementStorage ?? AchievementStorage();
    _ownsGameSoundPlayer = widget.gameSoundPlayer == null;
    _gameSoundPlayer = widget.gameSoundPlayer ?? AssetGameSoundPlayer();
    _soundPreferenceStorage = widget.soundPreferenceStorage ??
        SharedPreferencesSoundPreferenceStorage();
    _dateProvider = widget.dateProvider ?? DateTime.now;
    dailyChallengeStats = DailyChallengeStats.fromRecords(
      const [],
      today: _dateProvider(),
    );
    _loadRecords();
    _loadSoundPreference();
    _loadTodayChallengeBest();
  }

  Future<void> _loadTodayChallengeBest() async {
    try {
      final challenge = DailyChallenge.forDate(_dateProvider());
      final loadedRecords = await _dailyChallengeStorage.loadRecords();
      if (!mounted) return;

      setState(() {
        _applyDailyChallengeRecords(
          loadedRecords,
          today: challenge.date,
        );
      });
      unawaited(_refreshAchievementState());
    } catch (error) {
      debugPrint('Daily challenge best failed to load: $error');
    }
  }

  Future<void> _loadSoundPreference() async {
    final enabled = await _soundPreferenceStorage.loadSoundEnabled();
    if (!mounted) return;

    setState(() {
      soundEnabled = enabled;
    });
  }

  Future<void> _loadRecords() async {
    final loadedRecords = await _recordStorage.loadRecords();
    if (!mounted) return;

    setState(() {
      records = loadedRecords;
      _sortRecordsByDate();
      _setBestRecord();
    });
    unawaited(_refreshAchievementState());
  }

  void _setBestRecord() {
    final selectedRecords = _selectedDifficultyRecords();
    bestRecord =
        selectedRecords.isEmpty ? 0 : GameRecord.bestOf(selectedRecords);
  }

  Future<void> _saveRecords() async {
    await _recordStorage.saveRecords(records);
  }

  void _sortRecordsByDate() {
    records.sort((a, b) => b.date.compareTo(a.date));
  }

  List<GameRecord> _selectedDifficultyRecords() {
    return records
        .where((record) => record.difficulty == selectedDifficulty)
        .toList();
  }

  void _selectDifficulty(GameDifficulty difficulty) {
    setState(() {
      sessionType = GameSessionType.normal;
      activeDailyChallenge = null;
      selectedDifficulty = difficulty;
      currentNumber = 1;
      numbers = List.generate(difficulty.maxNumber, (index) => index + 1)
        ..shuffle();
      showPenalty = false;
      _setBestRecord();
    });
  }

  void _selectStartMode(StartMode mode) {
    setState(() {
      startMode = mode;
    });
  }

  void startGame() {
    sessionType = GameSessionType.normal;
    activeDailyChallenge = null;
    _startCountdown();
  }

  Future<void> _startDailyChallenge() async {
    final challenge = DailyChallenge.forDate(_dateProvider());
    List<DailyChallengeRecord> loadedRecords = [];
    try {
      loadedRecords = await _dailyChallengeStorage.loadRecords();
    } catch (error) {
      debugPrint('Daily challenge best failed to load: $error');
    }
    if (!mounted) return;

    setState(() {
      sessionType = GameSessionType.dailyChallenge;
      activeDailyChallenge = challenge;
      selectedDifficulty = GameDifficulty.normal;
      currentNumber = 1;
      numbers = challenge.numbers.map<int?>((number) => number).toList();
      showPenalty = false;
      _applyDailyChallengeRecords(
        loadedRecords,
        today: challenge.date,
      );
    });
    _startCountdown();
  }

  void _startCountdown() {
    countdownTimer?.cancel();
    setState(() {
      countdown = 3;
    });
    _playSound(GameSoundEffect.countdownTick);

    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 1) {
        final nextCountdown = countdown - 1;
        setState(() {
          countdown = nextCountdown;
        });
        _playSound(
          nextCountdown == 1
              ? GameSoundEffect.countdownGo
              : GameSoundEffect.countdownTick,
        );
      } else {
        timer.cancel();
        setState(() {
          gameStarted = true;
          gamePaused = false;
          timeElapsed = 0;
          currentNumber = 1;
          correctTapCount = 0;
          wrongTapCount = 0;
          numbers = sessionType == GameSessionType.dailyChallenge
              ? activeDailyChallenge!.numbers
                  .map<int?>((number) => number)
                  .toList()
              : (List<int?>.generate(
                  selectedDifficulty.maxNumber,
                  (index) => index + 1,
                )..shuffle());
          countdown = 0;
        });
        startTimer();
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (!gamePaused) {
        setState(() {
          timeElapsed += 100;
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void endGame({bool showRecord = true}) {
    stopTimer();
    if (currentNumber > selectedDifficulty.maxNumber && showRecord) {
      _playSound(GameSoundEffect.complete);
      final record = formatTime(timeElapsed);
      final now = DateFormat(
        'yyyy-MM-dd HH:mm:ss',
      ).format(_dateProvider());
      final isDailyChallenge = sessionType == GameSessionType.dailyChallenge &&
          activeDailyChallenge != null;
      final previousBest = isDailyChallenge
          ? (todayChallengeBestMilliseconds ?? 0) / 1000
          : bestRecord;
      final result = GameResult(
        elapsedMilliseconds: timeElapsed,
        correctTapCount: correctTapCount,
        wrongTapCount: wrongTapCount,
        previousBest: previousBest,
      );
      if (isDailyChallenge) {
        final challenge = activeDailyChallenge!;
        final isFaster = todayChallengeBestMilliseconds == null ||
            timeElapsed < todayChallengeBestMilliseconds!;
        setState(() {
          _upsertDailyChallengeRecord(
            challenge.dateKey,
            timeElapsed,
            replaceExisting: isFaster,
          );
          _applyDailyChallengeRecords(
            dailyChallengeRecords,
            today: challenge.date,
          );
        });
        unawaited(
          _dailyChallengeStorage.saveBest(
            challenge.dateKey,
            timeElapsed,
          ),
        );
      } else {
        setState(() {
          records.add(
            GameRecord(
              record: record,
              date: now,
              difficulty: selectedDifficulty,
              wrongTapCount: wrongTapCount,
              totalTapCount: correctTapCount + wrongTapCount,
            ),
          );
          _sortRecordsByDate();
          _setBestRecord();
        });
        unawaited(_saveRecords());
      }
      final unlockedAchievements = _evaluateAchievements(
        isDailyChallenge: isDailyChallenge,
        now: now,
      );

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GameResultDialog(
            result: result,
            difficulty: selectedDifficulty,
            record: record,
            modeLabel: isDailyChallenge ? "Today's Challenge" : null,
            showRecords: !isDailyChallenge,
            streakCount:
                isDailyChallenge ? dailyChallengeStats.currentStreak : null,
            unlockedAchievements: unlockedAchievements,
            onPlayAgain: () {
              Navigator.of(context).pop();
              _returnToStart();
            },
            onViewRecords: () {
              Navigator.of(context).pop();
              _returnToStart();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecordScreen(
                    records: _selectedDifficultyRecords(),
                    difficulty: selectedDifficulty,
                  ),
                ),
              );
            },
          );
        },
      );
    } else {
      _returnToStart();
    }
  }

  void _returnToStart() {
    setState(() {
      gameStarted = false;
      currentNumber = 1;
      numbers =
          List.generate(selectedDifficulty.maxNumber, (index) => index + 1)
            ..shuffle();
    });
    unawaited(_loadTodayChallengeBest());
  }

  void _applyDailyChallengeRecords(
    List<DailyChallengeRecord> loadedRecords, {
    required DateTime today,
  }) {
    dailyChallengeRecords = [...loadedRecords];
    final todayKey = DailyChallenge.forDate(today).dateKey;
    todayChallengeBestMilliseconds = null;
    for (final record in dailyChallengeRecords) {
      if (record.dateKey == todayKey) {
        todayChallengeBestMilliseconds = record.bestMilliseconds;
        break;
      }
    }
    dailyChallengeStats = DailyChallengeStats.fromRecords(
      dailyChallengeRecords,
      today: today,
    );
  }

  void _upsertDailyChallengeRecord(
    String dateKey,
    int elapsedMilliseconds, {
    required bool replaceExisting,
  }) {
    final index = dailyChallengeRecords.indexWhere(
      (record) => record.dateKey == dateKey,
    );
    if (index >= 0) {
      if (replaceExisting) {
        dailyChallengeRecords[index] = DailyChallengeRecord(
          dateKey: dateKey,
          bestMilliseconds: elapsedMilliseconds,
        );
      }
      return;
    }
    dailyChallengeRecords.add(
      DailyChallengeRecord(
        dateKey: dateKey,
        bestMilliseconds: elapsedMilliseconds,
      ),
    );
  }

  Future<void> _refreshAchievementState() {
    _achievementRefresh = _achievementRefresh.then((_) async {
      final updated = await _achievementStorage.backfill(
        normalRecords: records,
        dailyRecords: dailyChallengeRecords,
        dailyStats: dailyChallengeStats,
        now: _dateProvider(),
      );
      if (!mounted) return;
      setState(() {
        achievementState = updated;
      });
    });
    return _achievementRefresh;
  }

  List<AchievementId> _evaluateAchievements({
    required bool isDailyChallenge,
    required String now,
  }) {
    final completedGames = max(
      achievementState.completedGames + 1,
      records.length + dailyChallengeRecords.length,
    );
    final newUnlocks = _achievementEvaluator.evaluate(
      AchievementEvaluationContext(
        difficulty: selectedDifficulty,
        elapsedMilliseconds: timeElapsed,
        wrongTapCount: wrongTapCount,
        isDailyChallenge: isDailyChallenge,
        currentStreak: dailyChallengeStats.currentStreak,
        completedGames: completedGames,
      ),
      unlockedIds: achievementState.unlockedIds,
    );
    final unlockDates = Map<AchievementId, String>.of(
      achievementState.unlockDates,
    );
    for (final achievement in newUnlocks) {
      unlockDates[achievement] = now;
    }
    achievementState = AchievementState(
      unlockDates: unlockDates,
      completedGames: completedGames,
    );
    final stateToSave = achievementState;
    _achievementRefresh = _achievementRefresh.then(
      (_) => _achievementStorage.saveState(stateToSave),
    );

    return AchievementId.values
        .where(newUnlocks.contains)
        .toList(growable: false);
  }

  List<AchievementProgress> _achievementProgress() {
    return _achievementEvaluator.buildProgress(
      state: achievementState,
      normalRecords: records,
      dailyRecords: dailyChallengeRecords,
      dailyStats: dailyChallengeStats,
    );
  }

  Future<void> _openAchievements() async {
    await _refreshAchievementState();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AchievementScreen(
          achievements: _achievementProgress(),
        ),
      ),
    );
  }

  Future<void> _openStatistics() async {
    await _refreshAchievementState();
    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => StatisticsScreen(
          records: records,
          dailyCompletionCount: dailyChallengeRecords.length,
          bestDailyStreak: dailyChallengeStats.bestStreak,
          unlockedAchievementCount: achievementState.unlockedIds.length,
          totalAchievementCount: AchievementId.values.length,
        ),
      ),
    );
  }

  Future<void> _openThemePicker() async {
    await _refreshAchievementState();
    if (!mounted) return;

    await showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => ThemePickerSheet(
        selectedTheme: widget.selectedTheme,
        unlockedAchievements: achievementState.unlockedIds,
        onSelected: (themeId) {
          widget.onThemeSelected?.call(themeId);
          Navigator.pop(sheetContext);
        },
      ),
    );
  }

  void _onNumberPressed(int number, int index) {
    if (number == currentNumber) {
      _execVibrate();
      _playSound(GameSoundEffect.correct);

      setState(() {
        numbers[index] = null;
        currentNumber++;
        correctTapCount++;
      });

      if (currentNumber > selectedDifficulty.maxNumber) {
        endGame();
      }
    } else {
      _applyWrongPenalty();
    }
  }

  void _applyWrongPenalty() {
    penaltyTimer?.cancel();
    _playSound(GameSoundEffect.wrong);
    setState(() {
      wrongTapCount++;
      timeElapsed += selectedDifficulty.wrongPenaltyMilliseconds;
      showPenalty = true;
    });
    penaltyTimer = Timer(const Duration(milliseconds: 700), () {
      if (!mounted) return;
      setState(() {
        showPenalty = false;
      });
    });
  }

  Future<void> _execVibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 10);
    }
  }

  void _playSound(GameSoundEffect effect) {
    if (soundEnabled) {
      unawaited(_gameSoundPlayer.play(effect));
    }
  }

  Future<void> _toggleSound() async {
    final enabled = !soundEnabled;
    setState(() {
      soundEnabled = enabled;
    });
    await _soundPreferenceStorage.saveSoundEnabled(enabled);
  }

  @override
  void dispose() {
    timer?.cancel();
    countdownTimer?.cancel();
    penaltyTimer?.cancel();
    if (_ownsGameSoundPlayer) {
      unawaited(_gameSoundPlayer.dispose());
    }
    super.dispose();
  }

  String formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final firstMilli = (milliseconds % 1000) ~/ 100;
    return '$seconds.$firstMilli';
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final colors = context.gameColors;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: colors.appBar,
        title: Text(
          '1to25',
          style: TextStyle(
            color: colors.text,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: colors.screen,
        ),
        child: Padding(
          padding: EdgeInsets.all(isLandscape ? 12 : 20),
          child: Stack(
            children: [
              if (!gameStarted && countdown == 0) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        key: const Key('sound-toggle'),
                        tooltip: soundEnabled ? 'Sound off' : 'Sound on',
                        icon: Icon(
                          soundEnabled ? Icons.volume_up : Icons.volume_off,
                        ),
                        onPressed: _toggleSound,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          backgroundColor: colors.secondary,
                          foregroundColor: colors.onSecondary,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        key: const Key('theme-picker-button'),
                        icon: const Icon(Icons.palette_outlined),
                        tooltip: 'Themes',
                        onPressed: _openThemePicker,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          backgroundColor: colors.secondary,
                          foregroundColor: colors.onSecondary,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        key: const Key('achievements-button'),
                        icon: const Icon(Icons.emoji_events),
                        tooltip: 'Achievements',
                        onPressed: _openAchievements,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          backgroundColor: colors.secondary,
                          foregroundColor: colors.onSecondary,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        key: const Key('statistics-button'),
                        icon: const Icon(Icons.insights),
                        tooltip: 'Statistics',
                        onPressed: _openStatistics,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          backgroundColor: colors.secondary,
                          foregroundColor: colors.onSecondary,
                          elevation: 0,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        icon: const Icon(Icons.list),
                        tooltip: 'Records',
                        onPressed: () {
                          final selectedRecords = _selectedDifficultyRecords();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecordScreen(
                                records: selectedRecords,
                                difficulty: selectedDifficulty,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          backgroundColor: colors.secondary,
                          foregroundColor: colors.onSecondary,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.only(top: 52, bottom: 8),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: 24),
                          SegmentedButton<StartMode>(
                            segments: const [
                              ButtonSegment(
                                value: StartMode.classic,
                                label: Text('CLASSIC'),
                              ),
                              ButtonSegment(
                                value: StartMode.daily,
                                label: Text('DAILY'),
                              ),
                            ],
                            selected: {startMode},
                            showSelectedIcon: false,
                            onSelectionChanged: (selection) {
                              _selectStartMode(selection.first);
                            },
                            style: SegmentedButton.styleFrom(
                              fixedSize: const Size(128, 42),
                              backgroundColor: colors.surface,
                              foregroundColor: colors.text,
                              selectedBackgroundColor: colors.primary,
                              selectedForegroundColor: colors.onPrimary,
                              side: BorderSide(color: colors.border),
                              textStyle: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          if (startMode == StartMode.classic)
                            _buildClassicStartContent()
                          else
                            _buildDailyStartContent(),
                        ],
                      ),
                    ),
                  ),
                ),
              ] else if (countdown > 0) ...[
                Center(
                  child: Text(
                    '$countdown',
                    style: TextStyle(
                      color: colors.text,
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ] else ...[
                if (isLandscape)
                  _buildLandscapeGameContent()
                else ...[
                  Align(
                    alignment: Alignment.topRight,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new),
                      onPressed: () => endGame(showRecord: false),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 10,
                        ),
                        backgroundColor: colors.secondary,
                        foregroundColor: colors.onSecondary,
                        elevation: 0,
                      ),
                    ),
                  ),
                  _buildPortraitGameContent(),
                ],
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }

  Widget _buildClassicStartContent() {
    final colors = context.gameColors;
    return Column(
      key: const ValueKey(StartMode.classic),
      mainAxisSize: MainAxisSize.min,
      children: [
        _DifficultySelector(
          selectedDifficulty: selectedDifficulty,
          onSelected: _selectDifficulty,
        ),
        const SizedBox(height: 24),
        _buildStartButton(onPressed: startGame),
        if (bestRecord != 0) ...[
          const SizedBox(height: 15),
          Text(
            '${selectedDifficulty.label} BEST $bestRecord',
            style: TextStyle(
              color: colors.text,
              fontSize: 20,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDailyStartContent() {
    final colors = context.gameColors;
    return Column(
      key: const ValueKey(StartMode.daily),
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.today,
              size: 20,
              color: colors.text,
            ),
            const SizedBox(width: 8),
            Text(
              "TODAY'S CHALLENGE",
              style: TextStyle(
                color: colors.text,
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        _buildStartButton(onPressed: _startDailyChallenge),
        const SizedBox(height: 14),
        Text(
          todayChallengeBestMilliseconds == null
              ? "TODAY'S BEST --"
              : "TODAY'S BEST ${formatTime(todayChallengeBestMilliseconds!)}",
          style: TextStyle(
            color: colors.text,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 14),
        _DailyChallengeSummary(stats: dailyChallengeStats),
      ],
    );
  }

  Widget _buildStartButton({required VoidCallback onPressed}) {
    final colors = context.gameColors;
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(192, 76),
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        textStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w500,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 0,
      ),
      child: const Text('START'),
    );
  }

  Widget _buildPortraitGameContent() {
    final colors = context.gameColors;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatTime(timeElapsed),
            style: TextStyle(
              color: colors.text,
              fontSize: 50,
            ),
          ),
          SizedBox(
            height: 24,
            child: Center(
              child: AnimatedOpacity(
                opacity: showPenalty ? 1 : 0,
                duration: const Duration(milliseconds: 120),
                child: Text(
                  '+${formatTime(selectedDifficulty.wrongPenaltyMilliseconds)}',
                  style: TextStyle(
                    color: colors.penalty,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          NumberGrid(
            numbers: numbers,
            gamePaused: gamePaused,
            crossAxisCount: selectedDifficulty.gridSize,
            onNumberPressed: _onNumberPressed,
          ),
        ],
      ),
    );
  }

  Widget _buildLandscapeGameContent() {
    final colors = context.gameColors;
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Stack(
            children: [
              Align(
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new),
                  onPressed: () => endGame(showRecord: false),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 10,
                    ),
                    backgroundColor: colors.secondary,
                    foregroundColor: colors.onSecondary,
                    elevation: 0,
                  ),
                ),
              ),
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      formatTime(timeElapsed),
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 42,
                      ),
                    ),
                    SizedBox(
                      height: 24,
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: showPenalty ? 1 : 0,
                          duration: const Duration(milliseconds: 120),
                          child: Text(
                            '+${formatTime(selectedDifficulty.wrongPenaltyMilliseconds)}',
                            style: TextStyle(
                              color: colors.penalty,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          flex: 3,
          child: Center(
            child: NumberGrid(
              numbers: numbers,
              gamePaused: gamePaused,
              crossAxisCount: selectedDifficulty.gridSize,
              onNumberPressed: _onNumberPressed,
            ),
          ),
        ),
      ],
    );
  }
}

class _DailyChallengeSummary extends StatelessWidget {
  const _DailyChallengeSummary({required this.stats});

  final DailyChallengeStats stats;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return SizedBox(
      width: 280,
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'STREAK ${stats.currentStreak}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  'BEST ${stats.bestStreak}',
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: colors.text,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: stats.recentDays.map((day) {
              return SizedBox(
                key: Key('daily-day-${day.dateKey}'),
                width: 28,
                height: 42,
                child: Column(
                  children: [
                    Text(
                      day.weekdayLabel,
                      style: TextStyle(
                        color: colors.text,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color:
                            day.completed ? colors.primary : Colors.transparent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.border,
                        ),
                      ),
                      child: day.completed
                          ? Icon(
                              Icons.check,
                              size: 14,
                              color: colors.onPrimary,
                            )
                          : null,
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.selectedDifficulty,
    required this.onSelected,
  });

  final GameDifficulty selectedDifficulty;
  final ValueChanged<GameDifficulty> onSelected;

  @override
  Widget build(BuildContext context) {
    final colors = context.gameColors;
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 8,
      runSpacing: 8,
      children: GameDifficulty.values.map((difficulty) {
        final selected = difficulty == selectedDifficulty;
        return ChoiceChip(
          label: Text(difficulty.label),
          selected: selected,
          onSelected: (_) => onSelected(difficulty),
          showCheckmark: false,
          selectedColor: colors.primary,
          backgroundColor: colors.surface,
          labelStyle: TextStyle(
            color: selected ? colors.onPrimary : colors.text,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: selected ? colors.primary : colors.border,
            ),
          ),
        );
      }).toList(),
    );
  }
}
