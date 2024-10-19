import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';  // 진동 패키지 추가

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          resizeToAvoidBottomInset: false,
          appBar: AppBar(
              title: const Text('랜덤 숫자 게임')
          ),
          body: const NumberGame(),
        )
    );
  }
}

class NumberGame extends StatefulWidget {
  const NumberGame({super.key});

  @override
  _NumberGameState createState() => _NumberGameState();
}

class _NumberGameState extends State<NumberGame> {
  List<int?> numbers = List.generate(25, (index) => index + 1); // 1부터 25까지 숫자 리스트
  int currentNumber = 1; // 클릭해야 하는 현재 숫자
  bool gameStarted = false; // 게임이 시작되었는지 여부
  bool gamePaused = false; // 게임이 일시정지되었는지 여부
  int timeElapsed = 0; // 경과 시간(초)
  Timer? timer; // 타이머
  List<Map<String, String>> records = []; // 기록을 저장할 리스트 (기록과 등록일자)
  int countdown = 0; // 카운트다운 상태를 저장
  double bestRecord = 0; // 최고기록

  // 오디오 플레이어 인스턴스 생성
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    numbers.shuffle(); // 숫자를 랜덤으로 섞기
    _loadRecords(); // 앱 시작 시 기록 불러오기
  }

  // 기록을 shared_preferences에서 불러오기
  void _loadRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recordStrings = prefs.getStringList('records') ?? [];
    setState(() {
      records = recordStrings.map((recordString) {
        List<String> parts = recordString.split('::');
        return {'record': parts[0], 'date': parts[1]};
      }).toList();
    });
    _sortRecordsByDate(); // 기록을 불러온 후에 날짜 기준으로 정렬
    _setBestRecord(); // 최고 기록 세팅
  }

  // 최고 기록 세팅
  void _setBestRecord() {
    if (records.isEmpty) return;

    List<double> recordDoubles = records.map((record) => double.parse(record['record']!)).toList();
    setState(() {
      bestRecord = recordDoubles.reduce(min);
    });
  }

  // 기록을 shared_preferences에 저장하기
  void _saveRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> recordStrings = records.map((record) => '${record['record']}::${record['date']}').toList();
    prefs.setStringList('records', recordStrings);
  }

  void _sortRecordsByDate() {
    records.sort((a, b) => b['date']!.compareTo(a['date']!)); // 등록일 기준으로 내림차순 정렬
  }

  void startGame() {
    setState(() {
      countdown = 3; // 카운트다운 시작
    });

    // 카운트다운을 3초 동안 보여주고 게임 시작
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
        startTimer(); // 타이머 시작
      }
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(milliseconds: 100), (timer) {
      if (!gamePaused) {
        setState(() {
          timeElapsed += 100; // 100 밀리초마다 증가
        });
      }
    });
  }

  void stopTimer() {
    timer?.cancel();
  }

  void pauseGame() {
    setState(() {
      gamePaused = true; // 일시정지 상태로 변경
    });
  }

  void resumeGame() {
    setState(() {
      gamePaused = false; // 일시정지 해제
    });
  }

  // 종료 버튼을 눌렀을 때 동작
  void endGame({bool showRecord = true}) {
    stopTimer();
    if (currentNumber > 25 && showRecord) {
      // 모든 숫자를 다 클릭했을 때 기록을 보여줌
      final record = formatTime(timeElapsed);
      final now = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now()); // 현재 시간 저장
      setState(() {
        records.add({'record': record, 'date': now}); // 기록과 등록일자 저장
      });
      _sortRecordsByDate(); // 기록을 등록일로 정렬 후 저장
      _saveRecords(); // 기록 저장 함수 호출
      _setBestRecord(); // 최고 기록 세팅

      // 기록을 다이얼로그로 보여주고 "확인"을 누르면 시작 화면으로 돌아감
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('게임 종료'),
            content: Text('기록: $record'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  setState(() {
                    gameStarted = false; // 게임 종료 후 시작 버튼을 보이도록 함
                  });
                },
                child: Text('확인'),
              ),
            ],
          );
        },
      );
    } else {
      // 모든 숫자를 다 클릭하지 않았을 때는 그냥 초기화
      setState(() {
        gameStarted = false; // 게임 초기화
        currentNumber = 1; // 현재 숫자 리셋
        numbers = List.generate(25, (index) => index + 1)..shuffle(); // 숫자 다시 섞기
      });
    }
  }

  void _onButtonPressed(int number, int index) {
    if (number == currentNumber) {
      // 버튼 클릭 시 소리 재생
      _playSound();

      // 진동 발생
      _execVibrate();

      setState(() {
        numbers[index] = null; // 맞는 숫자를 클릭하면 숫자를 null로 설정하여 빈 버튼으로 유지
        currentNumber++; // 다음 숫자로 넘어감
      });

      if (currentNumber > 25) {
        endGame(); // 모든 숫자를 클릭했다면 게임 종료
      }
    }
  }

  // 소리 재생
  void _playSound() async {
    await _audioPlayer.setAsset('assets/button_click.mp3');
    _audioPlayer.play();
  }

  // 진동 발생 (진동 기능이 기기에서 지원될 경우)
  void _execVibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 100); // 100ms 동안 진동
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String formatTime(int milliseconds) {
    int seconds = (milliseconds / 1000).floor(); // 초
    int firstMilli = (milliseconds % 1000) ~/ 100; // 밀리초의 첫 자릿수
    return '$seconds.$firstMilli';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/background.jpg'), // 배경 이미지 경로
          fit: BoxFit.cover, // 이미지가 컨테이너를 채우도록 설정
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (!gameStarted && countdown == 0) ...[
              if (bestRecord != 0)
                Text(
                  '최고기록 $bestRecord초',
                  style: TextStyle(
                    fontSize: 20,
                  ),
                ),
              const SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: startGame,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white, // 흰색 텍스트
                    textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12), // 부드러운 곡선
                    ),
                    elevation: 2,
                  ),
                  child: const Text('시작'),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RecordPage(records: records)),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  backgroundColor: Colors.grey[800],
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
                child: const Text('기록 보기'),
              ),
            ] else if (countdown > 0) ...[
              Center(
                child: Text(
                  '$countdown', // 카운트다운 표시
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 80,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ] else ...[
              Column(
                children: [
                  Text(
                    '시간: ${formatTime(timeElapsed)}초',
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 24
                    ),
                  ),
                  const SizedBox(height: 20),
                  GridView.count(
                    crossAxisCount: 5,
                    crossAxisSpacing: 2.0,
                    mainAxisSpacing: 2.0,
                    shrinkWrap: true,
                    children: List.generate(numbers.length, (index) {
                      final number = numbers[index];
                      return ElevatedButton(
                        onPressed: number != null && !gamePaused ? () => _onButtonPressed(number!, index) : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: number == null ? Colors.grey[300] : Colors.white, // 클릭된 버튼은 회색
                          foregroundColor: Colors.black54, // 검은색 텍스트
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          number != null ? '$number' : '',
                          style: const TextStyle(fontSize: 20),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: gamePaused ? resumeGame : pauseGame,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.grey[800],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: Text(gamePaused ? '재개' : '중지'),
                      ),
                      const SizedBox(width: 20),
                      ElevatedButton(
                        onPressed: () => endGame(showRecord: false),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          backgroundColor: Colors.grey[900],
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 2,
                        ),
                        child: const Text('종료'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class RecordPage extends StatelessWidget {
  final List<Map<String, String>> records;
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가

  RecordPage({required this.records});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('기록 보기'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '기록 목록',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: ListView.builder(
                controller: _scrollController, // 스크롤 컨트롤러 적용
                itemCount: records.length,
                itemBuilder: (context, index) {
                  final record = records[index];
                  return ListTile(
                    leading: Text('${records.length - index}', style: TextStyle(fontSize: 20)),
                    title: Text('기록: ${record['record']}초'),
                    subtitle: Text('등록일: ${record['date']}'),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}