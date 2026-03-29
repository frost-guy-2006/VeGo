import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  testWidgets('RainModeOverlay renders correctly when enabled', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: RainModeOverlay(isEnabled: true),
      ),
    ));

    expect(find.byType(RainModeOverlay), findsOneWidget);

    // Find CustomPaint specifically inside RainModeOverlay
    final customPaintFinder = find.descendant(
      of: find.byType(RainModeOverlay),
      matching: find.byType(CustomPaint),
    );
    expect(customPaintFinder, findsOneWidget);

    expect(find.text("It's raining outside 🌧️"), findsOneWidget);
  });

  testWidgets('RainModeOverlay does not render content when disabled', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: RainModeOverlay(isEnabled: false),
      ),
    ));

    expect(find.byType(RainModeOverlay), findsOneWidget);

    // Should find no CustomPaint inside RainModeOverlay
    final customPaintFinder = find.descendant(
      of: find.byType(RainModeOverlay),
      matching: find.byType(CustomPaint),
    );
    expect(customPaintFinder, findsNothing);

    expect(find.text("It's raining outside 🌧️"), findsNothing);
  });
}
