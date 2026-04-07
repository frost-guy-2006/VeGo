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
      1000,
      (index) => RainDrop(
        x: Random().nextDouble(),
        y: 1.0, // Force the drop to reset
        speed: 1.0,
        length: 0.1,
      ),
    );

    final painter = RainPainter(drops: drops, progress: 0.5);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    final stopwatch = Stopwatch()..start();

    // Call paint many times to simulate frames
    for (var i = 0; i < 10000; i++) {
      // Keep y > 1.0 to trigger the random generation
      for (var drop in drops) {
        drop.y = 1.1;
      }
      painter.paint(canvas, size);
    }

    stopwatch.stop();
    // ignore: avoid_print
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
