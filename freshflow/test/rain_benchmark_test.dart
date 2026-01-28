import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'dart:math';

class FakeCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('RainPainter benchmark', () {
    final random = Random();
    // Initialize drops close to resetting to force Random() creation in the loop
    final drops = List.generate(1000, (index) => RainDrop(
      x: random.nextDouble(),
      y: 0.95 + random.nextDouble() * 0.05,
      speed: 2.0, // High speed to ensure they move fast
      length: 0.1,
    ));

    final painter = RainPainter(drops: drops, progress: 0.5, random: random);
    final canvas = FakeCanvas();
    const size = Size(800, 600);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 5000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    print('Benchmark Execution time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
