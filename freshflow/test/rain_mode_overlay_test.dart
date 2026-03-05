import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  testWidgets('RainModeOverlay draws RainPainter when enabled', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RainModeOverlay(isEnabled: true),
    ));

    expect(find.byType(CustomPaint), findsWidgets);
    expect(
        find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is RainPainter),
        findsOneWidget);
  });

  testWidgets('RainModeOverlay does nothing when disabled', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: RainModeOverlay(isEnabled: false),
    ));

    expect(
        find.byWidgetPredicate((widget) => widget is CustomPaint && widget.painter is RainPainter),
        findsNothing);
  });
}
