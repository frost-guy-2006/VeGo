import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:ui' as ui;

// Assuming package structure, using relative import
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(ui.Offset p1, ui.Offset p2, ui.Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final random = Random();
    final drops = List.generate(
        100,
        (i) => RainDrop(
              x: random.nextDouble(),
              y: random.nextDouble(),
              speed: 0.5 + random.nextDouble() * 0.5,
              length: 0.05 + random.nextDouble() * 0.05,
            ));

    final painter = RainPainter(drops: drops, progress: 0.5, random: random);
    final canvas = MockCanvas();
    const size = Size(400, 800);

    // Warmup
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('RainPainter benchmark: ${stopwatch.elapsedMilliseconds}ms');
  });
}
