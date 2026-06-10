import 'package:flutter_test/flutter_test.dart';
import 'package:onetotwentyfive/app.dart';

void main() {
  testWidgets('shows the game start screen', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('1to25'), findsOneWidget);
    expect(find.text('START'), findsOneWidget);
    expect(find.text('Easy'), findsOneWidget);
    expect(find.text('Normal'), findsOneWidget);
    expect(find.text('Hard'), findsOneWidget);
  });
}
