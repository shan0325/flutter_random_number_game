import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class NumberGrid extends StatelessWidget {
  const NumberGrid({
    super.key,
    required this.numbers,
    required this.gamePaused,
    required this.crossAxisCount,
    required this.onNumberPressed,
  });

  final List<int?> numbers;
  final bool gamePaused;
  final int crossAxisCount;
  final void Function(int number, int index) onNumberPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 500),
      child: GridView.count(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 5.0,
        mainAxisSpacing: 5.0,
        shrinkWrap: true,
        children: List.generate(numbers.length, (index) {
          final number = numbers[index];
          return ElevatedButton(
            onPressed: number != null && !gamePaused
                ? () => onNumberPressed(number, index)
                : null,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
              backgroundColor:
                  number == null ? Colors.grey[300] : const Color(0xFFCBD2A4),
              foregroundColor: const Color(0xFF54473F),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: AutoSizeText(
              number != null ? '$number' : '',
              style: const TextStyle(fontSize: 25),
              maxLines: 1,
              minFontSize: 20,
            ),
          );
        }),
      ),
    );
  }
}
