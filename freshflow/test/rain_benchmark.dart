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
    final drops = List.generate(1000, (index) => RainDrop(
      x: 0.5,
      y: 1.1, // Force reset to trigger Random().nextDouble()
      speed: 0.5,
      length: 0.05,
    ));

    final canvas = MockCanvas();
    final size = const Size(800, 600);

    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 10000; i++) {
      final painter = RainPainter(drops: drops, progress: 1.0);
      painter.paint(canvas, size);

      // Reset drops for next iteration
      for (var drop in drops) {
        drop.y = 1.1;
      }
    }

    stopwatch.stop();
    // ignore: avoid_print
    print('Baseline Benchmark time: ${stopwatch.elapsedMilliseconds}ms');
  });
}
