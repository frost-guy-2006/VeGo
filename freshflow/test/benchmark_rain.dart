import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
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
              y: 1.1, // Force reset to trigger the Random() call
              speed: 1.0,
              length: 0.1,
            ));

    final canvas = MockCanvas();
    final size = const Size(400, 800);

    final stopwatch = Stopwatch()..start();

    // Create the painter
    final painter = RainPainter(drops: drops, progress: 0.5, random: Random());

    // Run multiple times
    for (int i = 0; i < 10000; i++) {
      // Keep forcing reset to measure the Random() creation
      for (var drop in drops) {
        drop.y = 1.1;
      }
      painter.paint(canvas, size);
    }

    stopwatch.stop();
    print('RainPainter Benchmark Time: ${stopwatch.elapsedMilliseconds}ms');
  });
}
