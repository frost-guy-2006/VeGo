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
    final random = Random();
    final drops = List.generate(
      100,
      (index) => RainDrop(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 0.5,
        length: 0.05 + random.nextDouble() * 0.05,
      ),
    );

    // If RainPainter is modified, it might require 'random'
    // To support both pre-fix and post-fix, we can't do this elegantly without
    // changing benchmark between runs. But I'll create the benchmark to run before fix.
    final painter = RainPainter(drops: drops, progress: 0.5, random: random);
    final canvas = MockCanvas();
    const size = Size(400, 800);

    // Warmup
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }

    // Benchmark
    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    print('RainPainter 10000 iterations: ${stopwatch.elapsedMicroseconds} us');
  });
}
