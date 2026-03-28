import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class TestCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter Loop', () {
    final drops = List.generate(
      100,
      (i) => RainDrop(
        x: 0.5,
        y: 0.9, // Start near bottom to trigger reset often
        speed: 10.0, // High speed to ensure they hit the bottom
        length: 0.1,
      ),
    );

    // Optimized implementation of RainPainter takes random in constructor.
    final painter = RainPainter(drops: drops, progress: 0, random: Random());
    final canvas = TestCanvas();
    final size = const Size(400, 800);

    final stopwatch = Stopwatch()..start();
    // 50,000 iterations to make the difference significant
    for (int i = 0; i < 50000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
