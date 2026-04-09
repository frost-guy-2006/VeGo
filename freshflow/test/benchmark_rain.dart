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
    final random = Random(42);
    final drops = List.generate(
      100,
      (i) => RainDrop(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 0.5,
        length: 0.05 + random.nextDouble() * 0.05,
      ),
    );

    final canvas = MockCanvas();
    const size = Size(1000, 1000);

    // Warmup
    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 50000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('RainPainter 50,000 frames: ${stopwatch.elapsedMilliseconds} ms');
  });
}
