# AGENTS.md

이 저장소에서 작업하는 에이전트는 아래 지침을 따른다.

## 기본 원칙

- 추측하지 말고 실제 파일과 명령 출력 기준으로 판단한다.
- 애매한 요구사항은 구현 전에 사용자에게 확인한다.
- 기존 동작을 보존하는 작은 단위 변경을 선호한다.
- 관련 없는 리팩토링이나 포맷 변경을 섞지 않는다.
- 변경 후에는 가능한 한 `flutter analyze`, `flutter test`, `flutter build apk --debug`를 실행해 검증한다.

## 프로젝트 개요

이 프로젝트는 Flutter 기반 1to25 숫자 클릭 게임이다.

- 앱 시작: `lib/main.dart`
- 앱 루트: `lib/app.dart`
- 게임 화면: `lib/screens/number_game_screen.dart`
- 기록 화면: `lib/screens/record_screen.dart`
- 난이도 모델: `lib/models/game_difficulty.dart`
- 기록 모델: `lib/models/game_record.dart`
- 결과 모델: `lib/models/game_result.dart`
- 기록 저장소: `lib/services/record_storage.dart`
- 광고 배너: `lib/widgets/ad_mob_banner.dart`
- 결과 다이얼로그: `lib/widgets/game_result_dialog.dart`
- 숫자 그리드: `lib/widgets/number_grid.dart`

## 코드 구조 지침

- `main.dart`에는 초기화와 `runApp`만 둔다.
- 화면 단위 코드는 `lib/screens/`에 둔다.
- 재사용 가능한 UI는 `lib/widgets/`에 둔다.
- 저장소, 외부 API, local persistence 로직은 `lib/services/`에 둔다.
- 도메인 값과 순수 로직은 `lib/models/`에 둔다.
- 현재 규모에서는 상태관리 패키지를 추가하지 말고 `setState` 기반 구조를 유지한다.

## 기록 저장 규칙

기록은 `SharedPreferences`의 `records` key에 저장한다.

현재 포맷:

```text
difficulty::record::date
```

예:

```text
normal::12.3::2026-06-11 10:20:30
```

기존 `record::date` 형식은 `normal` 난이도로 읽는다.

이 포맷을 바꾸는 경우 기존 사용자 기록 마이그레이션을 반드시 고려한다.

## 게임 기능 지침

- 난이도 설정값은 `GameDifficulty` extension에서 관리한다.
- Easy는 4x4, Normal은 5x5, Hard는 6x6 구성을 유지한다.
- 오답 패널티는 난이도별 밀리초 값으로 관리한다.
- 기록 저장과 최고 기록 계산은 난이도별로 분리한다.
- 게임 완료 결과 계산은 `GameResult`에서 처리한다.
- 결과 화면에는 기록, 난이도, 등급, BEST 대비 차이, 오답 수, 정확도를 표시한다.
- 게임 효과음 종류와 재생은 `GameSoundPlayer`에서 관리한다.
- 사운드 설정은 `sound_enabled` key로 저장하며 기본값은 활성화 상태다.
- 효과음 에셋을 변경하면 `tool/generate_sound_assets.dart`와 `pubspec.yaml`을 함께 확인한다.

## 테스트 지침

- 모델/순수 로직은 unit test를 우선 작성한다.
- 위젯 테스트는 실제 앱 화면 기준으로 작성한다.
- 기본 Flutter 카운터 템플릿 테스트를 다시 도입하지 않는다.
- 기록 포맷 변경 시 `test/models/game_record_test.dart`를 반드시 갱신한다.

권장 검증 명령:

```bash
dart format lib test
flutter analyze
flutter test
flutter build apk --debug
git diff --check
```

## Android/빌드 주의사항

- `android/key.properties`가 없을 수 있으므로 release signing 설정은 null-safe하게 유지한다.
- Android debug APK 빌드는 현재 통과한다.
- Flutter는 Gradle, AGP, Kotlin Gradle Plugin, Built-in Kotlin migration 관련 향후 지원 중단 경고를 출력한다. 이 경고들은 현재 빌드 실패 원인은 아니지만, Flutter 업그레이드 전에 별도 정리 대상이다.

## 광고/외부 기능

- AdMob App ID는 Android manifest에 설정되어 있다.
- 배너 광고 단위는 `lib/widgets/ad_mob_banner.dart`에서 관리한다.
- 광고 설정을 바꾸는 경우 Android manifest와 위젯 코드의 ID를 함께 확인한다.
- 진동 기능은 `vibration` 패키지를 사용한다.

## 변경 전 확인

작업 시작 전 다음을 확인한다.

```bash
git status --short
rg --files
```

사용자가 만든 변경을 되돌리지 않는다. 같은 파일을 수정해야 한다면 먼저 현재 diff를 확인하고 그 위에 안전하게 변경한다.
