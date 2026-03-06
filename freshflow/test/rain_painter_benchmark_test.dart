import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('RainPainter Benchmark', () {
    // Generate drops that are all at y > 1.0 to force the reset logic every time
    final drops = List.generate(
      1000,
      (index) => RainDrop(
        x: 0.5,
        y: 1.1, // Force y > 1.0
        speed: 1.0,
        length: 0.1,
      ),
    );

    final painter = RainPainter(drops: drops, progress: 0.5, random: Random());
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    // Warmup
    for (int i = 0; i < 100; i++) {
      for (var drop in drops) {
        drop.y = 1.1; // reset for next iteration
      }
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 1000; i++) {
      // reset y to 1.1 to ensure the condition inside is hit
      for (var drop in drops) {
        drop.y = 1.1;
      }
      painter.paint(canvas, size);
    }

    stopwatch.stop();
    print('Benchmark execution time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
