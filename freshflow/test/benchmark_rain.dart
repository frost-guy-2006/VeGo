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
    final drops = <RainDrop>[];
    final random = Random(42);
    for (int i = 0; i < 100; i++) {
      drops.add(RainDrop(
        x: random.nextDouble(),
        y: random.nextDouble(),
        speed: 0.5 + random.nextDouble() * 0.5,
        length: 0.05 + random.nextDouble() * 0.05,
      ));
    }

    final canvas = MockCanvas();
    const size = Size(1000, 1000);

    // Warmup
    for (int i = 0; i < 1000; i++) {
      final painter = RainPainter(drops: drops, progress: 0.0, random: random);
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    const iterations = 10000;
    for (int i = 0; i < iterations; i++) {
      final painter = RainPainter(drops: drops, progress: 0.0, random: random);
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('RainPainter benchmark ($iterations iterations): ${stopwatch.elapsedMilliseconds} ms');
  });
}
