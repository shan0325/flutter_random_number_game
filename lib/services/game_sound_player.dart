import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

enum GameSoundEffect {
  countdownTick,
  countdownGo,
  correct,
  wrong,
  complete,
}

abstract class GameSoundPlayer {
  Future<void> play(GameSoundEffect effect);

  Future<void> dispose();
}

class AssetGameSoundPlayer implements GameSoundPlayer {
  AssetGameSoundPlayer() {
    _players = {
      for (final effect in GameSoundEffect.values) effect: AudioPlayer(),
    };
    _ready = _initialize().catchError((Object error, StackTrace stackTrace) {
      debugPrint('Game sounds failed to initialize: $error');
    });
  }

  static const _assetPaths = {
    GameSoundEffect.countdownTick: 'assets/countdown_tick.wav',
    GameSoundEffect.countdownGo: 'assets/countdown_go.wav',
    GameSoundEffect.correct: 'assets/button_click.mp3',
    GameSoundEffect.wrong: 'assets/wrong_tap.wav',
    GameSoundEffect.complete: 'assets/game_complete.wav',
  };

  static const _volumes = {
    GameSoundEffect.countdownTick: 0.35,
    GameSoundEffect.countdownGo: 0.45,
    GameSoundEffect.correct: 0.45,
    GameSoundEffect.wrong: 0.4,
    GameSoundEffect.complete: 0.5,
  };

  late final Map<GameSoundEffect, AudioPlayer> _players;
  late final Future<void> _ready;

  Future<void> _initialize() async {
    await Future.wait(
      GameSoundEffect.values.map((effect) async {
        final player = _players[effect]!;
        await player.setAsset(_assetPaths[effect]!);
        await player.setVolume(_volumes[effect]!);
      }),
    );
  }

  @override
  Future<void> play(GameSoundEffect effect) async {
    try {
      await _ready;
      final player = _players[effect]!;
      await player.seek(Duration.zero);
      unawaited(player.play());
    } catch (error) {
      debugPrint('Game sound failed to play: $error');
    }
  }

  @override
  Future<void> dispose() async {
    await Future.wait(_players.values.map((player) => player.dispose()));
  }
}
