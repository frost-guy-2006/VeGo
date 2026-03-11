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
    final drops = List.generate(100, (index) => RainDrop(
      x: 0.5,
      y: 1.1, // Force reset to trigger random.nextDouble()
      speed: 1.0,
      length: 0.1,
    ));

    final canvas = MockCanvas();
    const size = Size(100, 100);
    final random = Random();

    // Baseline: Creating Random inside loop (if not modified)
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      // Force y to be > 1.0 again to trigger reset
      for (var drop in drops) {
        drop.y = 1.1;
      }
      final painter = RainPainter(drops: drops, progress: 0.5, random: random);
      painter.paint(canvas, size);
    }
    stopwatch.stop();
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
