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
      1000,
      (index) => RainDrop(
        x: Random(index).nextDouble(),
        y: 1.05, // force y > 1.0 to trigger object creation in loop
        speed: 0.5,
        length: 0.05,
      ),
    );

    // Provide a random instance directly if possible, or test the baseline first.
    final painter = RainPainter(drops: drops, progress: 0.5, random: Random());
    final canvas = MockCanvas();
    final size = const Size(400, 800);

    // Warmup
    for (int i = 0; i < 5000; i++) {
      painter.paint(canvas, size);
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) { // Increase iteration count to see impact
      painter.paint(canvas, size);
    }
    stopwatch.stop();
    print('RainPainter paint() 10000 iterations (1000 drops each): ${stopwatch.elapsedMicroseconds} us');
  });
}
