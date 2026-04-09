import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  testWidgets('RainModeOverlay is invisible when disabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: RainModeOverlay(isEnabled: false),
      ),
    );

    expect(find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is RainPainter), findsNothing);
    expect(find.text("It's raining outside 🌧️"), findsNothing);
  });

  testWidgets('RainModeOverlay is visible and animates when enabled', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: RainModeOverlay(isEnabled: true),
        ),
      ),
    );

    expect(find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is RainPainter), findsOneWidget);
    expect(find.text("It's raining outside 🌧️"), findsOneWidget);

    // Verify it uses a CustomPainter with RainPainter
    final customPaint = tester.widget<CustomPaint>(
      find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is RainPainter),
    );
    expect(customPaint, isNotNull);

    // Pump frames to verify it animates without crashing
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  });
}
