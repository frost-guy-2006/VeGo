import 'dart:ui';
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
        1000, (i) => RainDrop(x: 0.5, y: 1.1, speed: 100.0, length: 0.1));

    final painter = RainPainter(drops: drops, progress: 0.0, random: Random());
    final canvas = MockCanvas();
    final size = const Size(400, 800);

    // Warm up
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
