import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:vibration/vibration.dart';

import '../models/game_record.dart';
import '../services/record_storage.dart';
import '../widgets/ad_mob_banner.dart';
import '../widgets/number_grid.dart';
import 'record_screen.dart';

class NumberGameScreen extends StatefulWidget {
  const NumberGameScreen({super.key, this.recordStorage});

  final RecordStorage? recordStorage;

  @override
  State<NumberGameScreen> createState() => _NumberGameScreenState();
}

class _NumberGameScreenState extends State<NumberGameScreen> {
  late final RecordStorage _recordStorage;

  List<int?> numbers = List.generate(25, (index) => index + 1)..shuffle();
  int currentNumber = 1;
  bool gameStarted = false;
  bool gamePaused = false;
  int timeElapsed = 0;
  Timer? timer;
  List<GameRecord> records = [];
  int countdown = 0;
  double bestRecord = 0;

  @override
  void initState() {
    super.initState();
    _recordStorage = widget.recordStorage ?? RecordStorage();
    _loadRecords();
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
    if (records.isEmpty) return;
    bestRecord = GameRecord.bestOf(records);
  }

  Future<void> _saveRecords() async {
    await _recordStorage.saveRecords(records);
  }

  void _sortRecordsByDate() {
    records.sort((a, b) => b.date.compareTo(a.date));
  }

  void startGame() {
    setState(() {
      countdown = 3;
    });

    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      if (countdown > 1) {
        setState(() {
          countdown--;
        });
      } else {
        timer.cancel();
        setState(() {
          gameStarted = true;
          gamePaused = false;
          timeElapsed = 0;
          currentNumber = 1;
          numbers = List.generate(25, (index) => index + 1)..shuffle();
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
    if (currentNumber > 25 && showRecord) {
      final record = formatTime(timeElapsed);
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
      setState(() {
        records.add(GameRecord(record: record, date: now));
        _sortRecordsByDate();
        _setBestRecord();
      });
      _saveRecords();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('GAME OVER'),
            content: Text(
              record,
              style: const TextStyle(fontSize: 30),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  setState(() {
                    gameStarted = false;
                  });
                },
                child: const Text('OK'),
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        gameStarted = false;
        currentNumber = 1;
        numbers = List.generate(25, (index) => index + 1)..shuffle();
      });
    }
  }

  void _onNumberPressed(int number, int index) {
    if (number == currentNumber) {
      _execVibrate();

      setState(() {
        numbers[index] = null;
        currentNumber++;
      });

      if (currentNumber > 25) {
        endGame();
      }
    }
  }

  Future<void> _execVibrate() async {
    final hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 10);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int milliseconds) {
    final seconds = (milliseconds / 1000).floor();
    final firstMilli = (milliseconds % 1000) ~/ 100;
    return '$seconds.$firstMilli';
  }

  @override
  Widget build(BuildContext context) {
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
          padding: const EdgeInsets.all(20),
          child: Stack(
            children: [
              if (!gameStarted && countdown == 0) ...[
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: const Icon(Icons.list),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RecordScreen(records: records),
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
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
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
                          'BEST $bestRecord',
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
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        formatTime(timeElapsed),
                        style: const TextStyle(
                          color: Color(0xFF54473F),
                          fontSize: 50,
                        ),
                      ),
                      const SizedBox(height: 20),
                      NumberGrid(
                        numbers: numbers,
                        gamePaused: gamePaused,
                        onNumberPressed: _onNumberPressed,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AdMobBanner(),
    );
  }
}
