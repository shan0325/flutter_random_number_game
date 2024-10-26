import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:just_audio/just_audio.dart';
import 'package:vibration/vibration.dart';  // 진동 패키지 추가
import 'package:flutter/services.dart';
import 'package:auto_size_text/auto_size_text.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: NumberGame(),
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
  final AudioPlayer audioPlayer = AudioPlayer();

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
            title: const Text('GAME OVER'),
            content: Text(
              '$record',
              style: const TextStyle(fontSize: 30),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // 다이얼로그 닫기
                  setState(() {
                    gameStarted = false; // 게임 종료 후 시작 버튼을 보이도록 함
                  });
                },
                child: const Text('OK'),
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
      // _playSound();

      // 진동 발생
      // HapticFeedback.lightImpact(); // 휴대폰 > 설정 > 소리 및 진동 > 시스템 진동 > 터치 피드백이 켜져야 가능
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
    await audioPlayer.setAsset('assets/button_click.mp3');
    audioPlayer.play();
  }

  // 진동 발생 (진동 기능이 기기에서 지원될 경우)
  void _execVibrate() async {
    bool? hasVibrator = await Vibration.hasVibrator();
    if (hasVibrator == true) {
      Vibration.vibrate(duration: 10); // 100ms 동안 진동
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
          /*image: DecorationImage(
            image: AssetImage('assets/background.jpg'), // 배경 이미지 경로
            fit: BoxFit.cover, // 이미지가 컨테이너를 채우도록 설정
          ),*/
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
                        MaterialPageRoute(builder: (context) => RecordPage(records: records)),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      backgroundColor: const Color(0xFF9A7E6F),
                      foregroundColor: Colors.white,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(12),
                      // ),
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
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 20),
                          backgroundColor: const Color(0xFF54473F),
                          foregroundColor: Colors.white, // 흰색 텍스트
                          textStyle: const TextStyle(fontSize: 30, fontWeight: FontWeight.w500),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12), // 부드러운 곡선
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
                    '$countdown', // 카운트다운 표시
                    style: const TextStyle(
                        color: Color(0xFF54473F),
                        fontSize: 80,
                        fontWeight: FontWeight.bold
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                      backgroundColor: const Color(0xFF9A7E6F),
                      foregroundColor: Colors.white,
                      // shape: RoundedRectangleBorder(
                      //   borderRadius: BorderRadius.circular(12),
                      // ),
                      elevation: 0,
                    ),
                  ),
                ),
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '${formatTime(timeElapsed)}',
                        style: const TextStyle(
                            color: Color(0xFF54473F),
                            fontSize: 50
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        constraints: const BoxConstraints(maxWidth: 500),
                        child: GridView.count(
                          crossAxisCount: 5,
                          crossAxisSpacing: 5.0,
                          mainAxisSpacing: 5.0,
                          shrinkWrap: true,
                          children: List.generate(numbers.length, (index) {
                            final number = numbers[index];
                            return ElevatedButton(
                              onPressed: number != null && !gamePaused ? () => _onButtonPressed(number, index) : null,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                backgroundColor: number == null ? Colors.grey[300] : const Color(0xFFCBD2A4), // 클릭된 버튼은 회색
                                foregroundColor: const Color(0xFF54473F), // 검은색 텍스트
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 0,
                              ),
                              child: AutoSizeText(
                                number != null ? '$number' : '',
                                style: const TextStyle(fontSize: 25),
                                maxLines: 1, // 한 줄에 맞게
                                minFontSize: 20, // 텍스트가 작아질 수 있는 최소 크기
                              ),
                            );
                          }),
                        ),
                      ),
                      /*const SizedBox(height: 20),
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
                              backgroundColor: const Color(0xFF54473F),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 0,
                            ),
                            child: const Text('종료'),
                          ),
                        ],
                      ),*/
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdMobComponent(),
    );
  }
}

class RecordPage extends StatefulWidget {
  final List<Map<String, String>> records;

  RecordPage({required this.records});

  @override
  _RecordPageState createState() => _RecordPageState();
}

class _RecordPageState extends State<RecordPage> {
  final ScrollController _scrollController = ScrollController(); // 스크롤 컨트롤러 추가
  String _sortOption = 'record'; // 초기 정렬 기준: 'record'

  // 정렬 함수
  void _sortRecords() {
    setState(() {
      if (_sortOption == 'record') {
        // 기록 기준으로 오름차순 정렬
        widget.records.sort((a, b) => double.parse(a['record']!).compareTo(double.parse(b['record']!)));
      } else if (_sortOption == 'date') {
        // 등록일 기준으로 내림차순 정렬
        widget.records.sort((a, b) => b['date']!.compareTo(a['date']!));
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _sortRecords(); // 페이지가 로드될 때 초기 정렬 수행
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFCBD2A4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
          color: const Color(0xFF54473F),
        ),
        title: const Text(
          'Records',
          style: TextStyle(
            color: Color(0xFF54473F),
          ),
        ),
        actions: [
          // 정렬 기준 선택을 위한 DropdownButton 추가
          DropdownButton<String>(
            value: _sortOption,
            icon: const Icon(Icons.sort, color: Color(0xFF54473F)),
            onChanged: (String? newValue) {
              setState(() {
                _sortOption = newValue!;
                _sortRecords(); // 정렬 기준 변경 시 정렬 실행
              });
            },
            items: <String>['record', 'date']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value == 'record' ? 'Record' : 'Date',
                  style: const TextStyle(color: Color(0xFF54473F)),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: Container(
          color: const Color(0xFFE9EED9),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scrollController, // 스크롤 컨트롤러 적용
                  itemCount: widget.records.length,
                  itemBuilder: (context, index) {
                    final record = widget.records[index];
                    return ListTile(
                      leading: Text(
                        '${widget.records.length - index}',
                        style: const TextStyle(
                          fontSize: 20,
                          color: Color(0xFF54473F),
                        ),
                      ),
                      title: Text(
                        '${record['record']}',
                        style: const TextStyle(
                          color: Color(0xFF54473F),
                        ),
                      ),
                      subtitle: Text(
                        '${record['date']}',
                        style: const TextStyle(
                          color: Color(0xFF54473F),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: AdMobComponent(),
    );
  }
}

class AdMobComponent extends StatefulWidget {
  @override
  _AdMobComponentState createState() => _AdMobComponentState ();
}

class _AdMobComponentState extends State<AdMobComponent> {
  BannerAd? _bannerAd;  // 배너 광고 객체 생성
  bool _isBannerAdLoaded = false; // 광고 로딩 여부 확인 변수

  @override
  void initState() {
    super.initState();
    _loadBannerAd();  // 배너 광고 로드
  }

  void _loadBannerAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-4660704022375249/6821128098',
      size: AdSize.fullBanner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isBannerAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          print('Banner Ad Failed to Load: $error');
        },
      ),
    )..load();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: _isBannerAdLoaded ? SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ) : const SizedBox(),
    );
  }
}