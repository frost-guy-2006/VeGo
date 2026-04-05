import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'dart:ui' as ui;

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final drops = List.generate(100, (i) => RainDrop(x: 0.5, y: 1.5, speed: 1.0, length: 0.1));
    final painter = RainPainter(drops: drops, progress: 0.0);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 100000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('Baseline: ${stopwatch.elapsedMilliseconds} ms');
  });
}
