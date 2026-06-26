enum GameDifficulty {
  easy,
  normal,
  hard,
}

extension GameDifficultyConfig on GameDifficulty {
  int get gridSize {
    switch (this) {
      case GameDifficulty.easy:
        return 4;
      case GameDifficulty.normal:
        return 5;
      case GameDifficulty.hard:
        return 6;
    }
  }

  int get maxNumber => gridSize * gridSize;

  int get wrongPenaltyMilliseconds {
    switch (this) {
      case GameDifficulty.easy:
        return 300;
      case GameDifficulty.normal:
        return 500;
      case GameDifficulty.hard:
        return 800;
    }
  }
}
