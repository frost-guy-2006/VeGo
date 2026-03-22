import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final random = Random(42);
    // Increase drops to make the overhead more obvious
    final drops = List.generate(
      10000,
      (i) => RainDrop(
        x: random.nextDouble(),
        // Make y close to 1.0 so that it wraps around frequently, triggering the Random() code
        y: 0.99 + random.nextDouble() * 0.02,
        speed: 0.5 + random.nextDouble() * 0.5,
        length: 0.05 + random.nextDouble() * 0.05,
      ),
    );

    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    debugPrint('RainPainter benchmark: ${stopwatch.elapsedMilliseconds}ms');
  });
}
