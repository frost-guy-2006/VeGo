import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  testWidgets('RainModeOverlay builds when enabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RainModeOverlay(isEnabled: true),
        ),
      ),
    );

    expect(find.byType(RainModeOverlay), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is RainPainter), findsOneWidget);
    expect(find.textContaining('raining'), findsOneWidget);
  });

  testWidgets('RainModeOverlay empty when disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RainModeOverlay(isEnabled: false),
        ),
      ),
    );

    expect(find.byType(RainModeOverlay), findsOneWidget);
    expect(find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is RainPainter), findsNothing);
    expect(find.textContaining('raining'), findsNothing);
  });
}
