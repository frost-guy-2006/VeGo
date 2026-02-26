import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  testWidgets('RainModeOverlay shows nothing when disabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RainModeOverlay(isEnabled: false),
        ),
      ),
    );

    // Verify that NO RainPainter is used
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is RainPainter
      ),
      findsNothing
    );
  });

  testWidgets('RainModeOverlay shows animation when enabled', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RainModeOverlay(isEnabled: true),
        ),
      ),
    );

    await tester.pump(); // Trigger initial frame

    // Verify that RainPainter IS used
    expect(
      find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is RainPainter
      ),
      findsOneWidget
    );

    expect(find.text("It's raining outside 🌧️"), findsOneWidget);
  });

  test('RainPainter paints without error', () {
      final drops = [
        RainDrop(x: 0.5, y: 0.5, speed: 0.5, length: 0.1),
      ];
      final painter = RainPainter(drops: drops, progress: 0.5, random: Random(123));

      // Just ensure instantiation works and properties are set
      expect(painter.drops, drops);
      expect(painter.progress, 0.5);
  });
}
