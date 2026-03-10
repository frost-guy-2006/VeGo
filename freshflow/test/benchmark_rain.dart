import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'dart:ui';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final random = Random();
    final drops = List.generate(100, (i) => RainDrop(x: random.nextDouble(), y: random.nextDouble(), speed: random.nextDouble(), length: random.nextDouble()));
    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    final size = const Size(800, 600);

    final canvas = MockCanvas();

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 100000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();
    print('Baseline: ${stopwatch.elapsedMilliseconds} ms');
  });
}
