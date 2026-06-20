# 1to25 Random Number Game

Flutter로 만든 1부터 25까지 숫자를 순서대로 누르는 기록 측정 게임입니다.

## 주요 기능

- 1~25 숫자 랜덤 배치
- Easy, Normal, Hard 난이도 선택
- CLASSIC / DAILY 모드 전환
- 3초 카운트다운 후 게임 시작
- 0.1초 단위 기록 측정
- 오답 클릭 시 난이도별 시간 패널티
- 정답 숫자 클릭 시 진동
- 카운트다운, 정답, 오답, 게임 완료 효과음
- 저장되는 사운드 ON/OFF 설정
- 날짜별 고정 배치로 플레이하는 Today's Challenge
- Today's Challenge 날짜별 최고 기록 저장
- Today's Challenge 현재/최고 연속 참여 기록
- 최근 7일 챌린지 완료 상태 표시
- 8종 업적과 진행도, 달성 날짜 표시
- 새 업적 달성 시 결과 화면 알림
- 게임 완료 기록 저장
- 게임 완료 결과 화면 표시
- 오답 수, 정확도, 등급, BEST 대비 차이 표시
- 난이도별 최고 기록 표시
- 난이도별 기록 목록 조회 및 기록/날짜 기준 정렬
- AdMob 배너 광고 표시

## 프로젝트 구조

```text
lib/
  main.dart                         # Flutter/AdMob 초기화와 앱 실행
  app.dart                          # MaterialApp 루트
  models/
    achievement.dart                # 업적 정의와 목표
    achievement_progress.dart       # 업적 진행도와 달성 상태
    daily_challenge.dart            # 날짜 기반 고정 챌린지 배치 생성
    daily_challenge_record.dart     # 날짜별 챌린지 최고 기록
    daily_challenge_stats.dart      # 연속 참여와 최근 7일 상태 계산
    game_difficulty.dart            # 난이도별 grid size, 숫자 개수, 오답 패널티
    game_record.dart                # 게임 기록 모델, 직렬화, 최고 기록 계산
    game_result.dart                # 완료 결과, 정확도, 등급, BEST 대비 차이 계산
  screens/
    achievement_screen.dart         # 업적 목록과 진행도 화면
    number_game_screen.dart         # 1to25 게임 화면과 게임 상태
    record_screen.dart              # 기록 목록 화면
  services/
    achievement_evaluator.dart      # 게임 결과 기반 업적 판정
    achievement_storage.dart        # 업적 달성일과 완료 횟수 저장
    daily_challenge_storage.dart    # 날짜별 챌린지 최고 기록 저장/로드
    game_sound_player.dart          # 이벤트별 효과음 로드/재생
    record_storage.dart             # SharedPreferences 기록 저장/로드
    sound_preference_storage.dart   # 사운드 설정 저장/로드
  widgets/
    ad_mob_banner.dart              # AdMob 배너 위젯
    game_result_dialog.dart         # 게임 완료 결과 다이얼로그
    number_grid.dart                # 5x5 숫자 버튼 그리드

test/
  widget_test.dart                  # 시작 화면과 게임 사운드 동작 테스트
  models/
    daily_challenge_test.dart       # 날짜별 고정 배치 테스트
    daily_challenge_record_test.dart # 챌린지 기록 포맷 테스트
    game_record_test.dart           # 기록 모델 테스트
  services/
    daily_challenge_storage_test.dart # 날짜별 최고 기록 저장 테스트
```

## 기록 저장 방식

기록은 `SharedPreferences`의 `records` key에 문자열 리스트로 저장합니다.

```text
difficulty::record::date
```

예:

```text
normal::12.3::2026-06-11 10:20:30
```

기존 `record::date` 형식의 기록은 Normal 난이도 기록으로 읽습니다.

이 포맷은 [lib/models/game_record.dart](lib/models/game_record.dart)와 [lib/services/record_storage.dart](lib/services/record_storage.dart)에서 관리합니다.

Today's Challenge는 기기의 로컬 날짜를 기준으로 매일 동일한 Normal
5x5 배치를 생성합니다. 최고 기록은 일반 기록과 분리된
`daily_challenge_records` key에 `yyyy-MM-dd::milliseconds` 형식으로
저장합니다. 현재/최고 연속 참여일과 최근 7일 완료 상태는 이 기록에서
계산하며 별도 카운터로 저장하지 않습니다. 시작 화면에서는 CLASSIC과
DAILY 중 선택한 모드의 설정과 기록만 표시합니다.

업적은 `achievement_unlocks`와 `achievement_completed_games` key에 별도로
저장합니다. 기존 기록으로 확인할 수 있는 최초 완료, 속도, Hard 완료,
챌린지와 streak 업적은 소급 반영합니다. 기존 기록에는 오답 수와 정확한
플레이 횟수가 없으므로 Perfect Run은 업데이트 이후 플레이부터 판정하며,
Veteran의 기존 완료 횟수는 저장된 일반/챌린지 기록 수를 최소값으로
사용합니다.

## 주요 의존성

- `shared_preferences`: 기록 저장
- `intl`: 날짜 포맷
- `just_audio`: 게임 효과음 재생
- `vibration`: 정답 클릭 시 진동
- `auto_size_text`: 숫자 버튼 텍스트 크기 조절
- `google_mobile_ads`: AdMob 배너 광고

## 개발 명령

의존성 설치:

```bash
flutter pub get
```

정적 분석:

```bash
flutter analyze
```

테스트:

```bash
flutter test
```

Android debug APK 빌드:

```bash
flutter build apk --debug
```

포맷:

```bash
dart format lib test
```

효과음 에셋 재생성:

```bash
dart run tool/generate_sound_assets.dart
```

## 현재 검증 상태

최근 확인한 명령:

```bash
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

모두 통과했습니다.

## Android/빌드 참고

현재 Android debug 빌드는 성공하지만 Flutter가 다음 항목에 대해 향후 지원 중단 경고를 출력합니다.

- Gradle `8.7.0`: 향후 `8.14.0+` 권장
- Android Gradle Plugin `8.6.0`: 향후 `8.11.1+` 권장
- Kotlin Gradle Plugin: 향후 `2.2.20+` 권장
- Built-in Kotlin migration 필요 경고
- 일부 iOS/macOS 플러그인의 Swift Package Manager 미지원 경고

현재 실행 오류는 아니지만, Flutter 버전을 계속 올릴 계획이면 별도 작업으로 정리해야 합니다.
