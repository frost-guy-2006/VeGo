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
    final drops = List.generate(1000, (i) => RainDrop(
      x: random.nextDouble(),
      y: 1.1, // Force reset logic to be triggered
      speed: 0.5 + random.nextDouble() * 0.5,
      length: 0.05 + random.nextDouble() * 0.05,
    ));

    final canvas = MockCanvas();
    final size = const Size(400, 800);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      // Re-create painter per frame like in real usage to see if any overhead, though we benchmark the paint method
      final painter = RainPainter(drops: drops, progress: 0.5, random: random);
      painter.paint(canvas, size);

      // Keep triggering the reset logic
      for(var drop in drops) {
         drop.y = 1.1;
      }
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('RainPainter benchmark time: ${stopwatch.elapsedMilliseconds}ms');
  });
}
