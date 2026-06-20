import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

import '../models/game_difficulty.dart';
import '../models/game_record.dart';
import '../models/game_result.dart';
import '../services/game_sound_player.dart';
import '../services/record_storage.dart';
import '../services/sound_preference_storage.dart';
import '../widgets/ad_mob_banner.dart';
import '../widgets/game_result_dialog.dart';
import '../widgets/number_grid.dart';
import 'record_screen.dart';

class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({
    super.key,
    this.recordStorage,
    this.gameSoundPlayer,
    this.soundPreferenceStorage,
  });

  final RecordStorage? recordStorage;
  final GameSoundPlayer? gameSoundPlayer;
  final SoundPreferenceStorage? soundPreferenceStorage;

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> {
  late final RecordStorage _recordStorage;
  late final GameSoundPlayer _gameSoundPlayer;
  late final bool _ownsGameSoundPlayer;
  late final SoundPreferenceStorage _soundPreferenceStorage;

  GameDifficulty selectedDifficulty = GameDifficulty.normal;
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

  @override
  void initState() {
    super.initState();
    _recordStorage = widget.recordStorage ?? RecordStorage();
    _ownsGameSoundPlayer = widget.gameSoundPlayer == null;
    _gameSoundPlayer = widget.gameSoundPlayer ?? AssetGameSoundPlayer();
    _soundPreferenceStorage = widget.soundPreferenceStorage ??
        SharedPreferencesSoundPreferenceStorage();
    _loadRecords();
    _loadSoundPreference();
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
      selectedDifficulty = difficulty;
      currentNumber = 1;
      numbers = List.generate(difficulty.maxNumber, (index) => index + 1)
        ..shuffle();
      showPenalty = false;
      _setBestRecord();
    });
  }

  void startGame() {
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
          numbers =
              List.generate(selectedDifficulty.maxNumber, (index) => index + 1)
                ..shuffle();
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
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      final previousBest = bestRecord;
      final result = GameResult(
        elapsedMilliseconds: timeElapsed,
        correctTapCount: correctTapCount,
        wrongTapCount: wrongTapCount,
        previousBest: previousBest,
      );
      setState(() {
        records.add(
          GameRecord(
            record: record,
            date: now,
            difficulty: selectedDifficulty,
          ),
        );
        _sortRecordsByDate();
        _setBestRecord();
      });
      _saveRecords();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GameResultDialog(
            result: result,
            difficulty: selectedDifficulty,
            record: record,
            onPlayAgain: () {
              Navigator.of(context).pop();
              setState(() {
                gameStarted = false;
              });
            },
            onViewRecords: () {
              Navigator.of(context).pop();
              setState(() {
                gameStarted = false;
              });
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
      setState(() {
        gameStarted = false;
        currentNumber = 1;
        numbers =
            List.generate(selectedDifficulty.maxNumber, (index) => index + 1)
              ..shuffle();
      });
    }
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

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBD2A4),
        title: const Text(
          '1to25',
          style: TextStyle(
            color: Color(0xFF54473F),
          ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFE9EED9),
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
                          backgroundColor: const Color(0xFF9A7E6F),
                          foregroundColor: Colors.white,
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
                          backgroundColor: const Color(0xFF9A7E6F),
                          foregroundColor: Colors.white,
                          elevation: 0,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _DifficultySelector(
                      selectedDifficulty: selectedDifficulty,
                      onSelected: _selectDifficulty,
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: startGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 20,
                          ),
                          backgroundColor: const Color(0xFF54473F),
                          foregroundColor: Colors.white,
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
                      ),
                    ),
                    if (bestRecord != 0) ...[
                      const SizedBox(height: 15),
                      Center(
                        child: Text(
                          '${selectedDifficulty.label} BEST $bestRecord',
                          style: const TextStyle(
                            color: Color(0xFF54473F),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ] else if (countdown > 0) ...[
                Center(
                  child: Text(
                    '$countdown',
                    style: const TextStyle(
                      color: Color(0xFF54473F),
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
                        backgroundColor: const Color(0xFF9A7E6F),
                        foregroundColor: Colors.white,
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

  Widget _buildPortraitGameContent() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatTime(timeElapsed),
            style: const TextStyle(
              color: Color(0xFF54473F),
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
                  style: const TextStyle(
                    color: Colors.redAccent,
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
                    backgroundColor: const Color(0xFF9A7E6F),
                    foregroundColor: Colors.white,
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
                      style: const TextStyle(
                        color: Color(0xFF54473F),
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
                            style: const TextStyle(
                              color: Colors.redAccent,
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

class _DifficultySelector extends StatelessWidget {
  const _DifficultySelector({
    required this.selectedDifficulty,
    required this.onSelected,
  });

  final GameDifficulty selectedDifficulty;
  final ValueChanged<GameDifficulty> onSelected;

  @override
  Widget build(BuildContext context) {
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
          selectedColor: const Color(0xFF5F5147),
          backgroundColor: const Color(0xFFE3E7C8),
          labelStyle: TextStyle(
            color: selected ? Colors.white : const Color(0xFF54473F),
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color:
                  selected ? const Color(0xFF5F5147) : const Color(0xFF9A7E6F),
            ),
          ),
        );
      }).toList(),
    );
  }
}
