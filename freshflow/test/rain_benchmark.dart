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
    final drops = List.generate(
        1000,
        (i) => RainDrop(
              x: 0.5,
              y: 1.1, // Force reset on every paint call to trigger Random().nextDouble()
              speed: 1.0,
              length: 0.1,
            ));
    final painter = RainPainter(drops: drops, progress: 0.5);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    // Warmup
    for (int i = 0; i < 100; i++) {
      painter.paint(canvas, size);
      // Reset y to force trigger
      for (var drop in drops) drop.y = 1.1;
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
      // Reset y to force trigger
      for (var drop in drops) drop.y = 1.1;
    }
    stopwatch.stop();
    // ignore: avoid_print
    print('RainPainter benchmark: ${stopwatch.elapsedMilliseconds} ms');
  });
}
