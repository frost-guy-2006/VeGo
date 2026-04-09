import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('RainPainter benchmark', () {
    final drops = List.generate(
      10000,
      (i) => RainDrop(x: 0.5, y: 1.5, speed: 1.0, length: 0.1),
    );

    final random = Random();
    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    // Warmup
    for (int i = 0; i < 100; i++) {
      painter.paint(canvas, size);
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      // Re-trigger the random by setting y > 1.0
      for (var drop in drops) {
        drop.y = 1.5;
      }
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
