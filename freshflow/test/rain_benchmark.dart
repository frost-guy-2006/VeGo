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
    final drops = List.generate(
        1000, (i) => RainDrop(x: 0.5, y: 1.5, speed: 0.5, length: 0.1));
    final canvas = MockCanvas();
    const size = Size(800, 600);

    final stopwatch = Stopwatch()..start();
    final random = Random();
    for (int i = 0; i < 10000; i++) {
      final painter = RainPainter(drops: drops, progress: 0.5, random: random);
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print(
        'Optimized RainPainter 10000 iterations: ${stopwatch.elapsedMilliseconds} ms');
  });
}
