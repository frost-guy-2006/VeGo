import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'dart:math';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    // We want to force resets to hit the Random().nextDouble() path often

    final drops = List.generate(
        1000, (i) => RainDrop(x: 0, y: 1.1, speed: 1, length: 0.1));
    final painter = RainPainter(drops: drops, progress: 0.5, random: Random());
    final canvas = MockCanvas();
    final size = const Size(100, 100);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      // Force resets every iteration for the benchmark
      for (var drop in drops) {
        drop.y = 1.1;
      }
      painter.paint(canvas, size);
    }
    stopwatch.stop();
    print('Optimized time taken: ${stopwatch.elapsedMilliseconds} ms');
  });
}
