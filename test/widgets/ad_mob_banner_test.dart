import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/widgets/ad_mob_banner.dart';

void main() {
  testWidgets('keeps the banner above the bottom system safe area', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          bottomNavigationBar: AdMobBanner(),
        ),
      ),
    );

    final safeArea = tester.widget<SafeArea>(find.byType(SafeArea));

    expect(safeArea.top, isFalse);
    expect(safeArea.bottom, isTrue);
  });
}
