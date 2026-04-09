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
  test('benchmark rain painter', () {
    final random = Random();
    final drops = List.generate(100, (i) => RainDrop(
      x: random.nextDouble(),
      y: random.nextDouble(),
      speed: 0.5 + random.nextDouble() * 0.5,
      length: 0.05 + random.nextDouble() * 0.05,
    ));

    // Force some drops to go out of bounds to trigger the Random() call.
    for(var drop in drops) {
      drop.y = 1.0;
    }

    final painter = RainPainter(drops: drops, progress: 0.5, random: random);
    final canvas = MockCanvas();
    final size = const Size(400, 800);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 500000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
