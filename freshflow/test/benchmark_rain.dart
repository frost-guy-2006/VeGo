import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:math';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final drops = List.generate(
      100,
      (index) => RainDrop(
        x: 0.5,
        y: 1.1, // Set to > 1.0 to trigger the Random() call
        speed: 1.0,
        length: 0.1,
      ),
    );

    final painter = RainPainter(drops: drops, progress: 0.0, random: Random());
    final canvas = MockCanvas();
    final size = const Size(400, 800);

    // Warmup
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
      // Reset y to > 1.0 to trigger random call again
      for (var drop in drops) {
        drop.y = 1.1;
      }
    }

    // Measure
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 50000; i++) {
      painter.paint(canvas, size);
      for (var drop in drops) {
        drop.y = 1.1;
      }
    }
    stopwatch.stop();

    print('Baseline paint execution time for 50000 iterations: ${stopwatch.elapsedMilliseconds} ms');
  });
}
