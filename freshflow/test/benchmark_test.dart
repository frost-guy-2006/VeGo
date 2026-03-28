import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter with new Random per frame vs reused Random', () {
    final drops = List.generate(
      1000,
      (index) => RainDrop(
        x: Random().nextDouble(),
        y: Random().nextDouble(),
        speed: 0.5 + Random().nextDouble() * 0.5,
        length: 0.05 + Random().nextDouble() * 0.05,
      ),
    );

    // Warm up
    final random = Random();
    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    final canvas = MockCanvas();
    const size = Size(400, 800);
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print(
        'Benchmark time (10000 iterations of 1000 drops): ${stopwatch.elapsedMilliseconds}ms');
  });
}
