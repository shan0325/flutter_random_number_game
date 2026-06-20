import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/app.dart';
import 'package:onetotwentyfive/screens/number_game_screen.dart';
import 'package:onetotwentyfive/services/game_sound_player.dart';
import 'package:onetotwentyfive/services/sound_preference_storage.dart';

void main() {
  testWidgets('shows the game start screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('1to25'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
  });

  testWidgets('plays countdown sounds for 3, 2, and 1', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );

    await tester.tap(find.text('START'));
    expect(
      soundPlayer.effects,
      [GameSoundEffect.countdownTick],
    );

    await tester.pump(const Duration(seconds: 1));
    expect(
      soundPlayer.effects,
      [
        GameSoundEffect.countdownTick,
        GameSoundEffect.countdownTick,
      ],
    );

    await tester.pump(const Duration(seconds: 1));
    expect(
      soundPlayer.effects,
      [
        GameSoundEffect.countdownTick,
        GameSoundEffect.countdownTick,
        GameSoundEffect.countdownGo,
      ],
    );

    await tester.pump(const Duration(seconds: 1));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('plays distinct sounds for correct and wrong numbers', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );

    await _startGame(tester);
    soundPlayer.effects.clear();

    await tester.tap(find.text('1'));
    await tester.pump();
    await tester.tap(find.text('3'));
    await tester.pump();

    expect(
      soundPlayer.effects,
      [
        GameSoundEffect.correct,
        GameSoundEffect.wrong,
      ],
    );

    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('plays a completion sound after the final number', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: _FakeSoundPreferenceStorage(),
        ),
      ),
    );

    await tester.tap(find.text('Easy'));
    await _startGame(tester);
    soundPlayer.effects.clear();

    for (var number = 1; number <= 16; number++) {
      await tester.tap(find.text('$number'));
      await tester.pump();
    }

    expect(soundPlayer.effects.last, GameSoundEffect.complete);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('sound toggle mutes effects and saves the preference', (
    WidgetTester tester,
  ) async {
    final soundPlayer = _FakeGameSoundPlayer();
    final preferenceStorage = _FakeSoundPreferenceStorage();

    await tester.pumpWidget(
      MaterialApp(
        home: NumberGameScreen(
          gameSoundPlayer: soundPlayer,
          soundPreferenceStorage: preferenceStorage,
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const Key('sound-toggle')));
    await tester.pump();
    await tester.tap(find.text('START'));

    expect(preferenceStorage.savedValues, [false]);
    expect(soundPlayer.effects, isEmpty);

    await tester.pumpWidget(const SizedBox.shrink());
  });
}

Future<void> _startGame(WidgetTester tester) async {
  await tester.tap(find.text('START'));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
  await tester.pump(const Duration(seconds: 1));
}

class _FakeGameSoundPlayer implements GameSoundPlayer {
  final effects = <GameSoundEffect>[];

  @override
  Future<void> play(GameSoundEffect effect) async {
    effects.add(effect);
  }

  @override
  Future<void> dispose() async {}
}

class _FakeSoundPreferenceStorage implements SoundPreferenceStorage {
  final savedValues = <bool>[];

  @override
  Future<bool> loadSoundEnabled() async => true;

  @override
  Future<void> saveSoundEnabled(bool enabled) async {
    savedValues.add(enabled);
  }
}
