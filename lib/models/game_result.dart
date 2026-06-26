class GameResult {
  const GameResult({
    required this.elapsedMilliseconds,
    required this.correctTapCount,
    required this.wrongTapCount,
    required this.previousBest,
  });

  final int elapsedMilliseconds;
  final int correctTapCount;
  final int wrongTapCount;
  final double previousBest;

  int get totalTapCount => correctTapCount + wrongTapCount;

  double get elapsedSeconds => elapsedMilliseconds / 1000;

  int get accuracyPercent {
    if (totalTapCount == 0) return 0;
    return ((correctTapCount / totalTapCount) * 100).round();
  }

  bool get isNewBest => previousBest == 0 || elapsedSeconds < previousBest;
}
