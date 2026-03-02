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
    final random = Random(42);
    final drops = List.generate(
      1000,
      (i) => RainDrop(
        x: random.nextDouble(),
        y: 0.99, // About to reset
        speed: 1.0, // High speed to ensure reset happens frequently
        length: 0.05,
      ),
    );

    // Initial painter
    final painter = RainPainter(drops: drops, progress: 0.5, random: random);
    final canvas = MockCanvas();
    final size = const Size(400, 800);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    print('Execution time for 10000 frames: ${stopwatch.elapsedMilliseconds} ms');
  });
}
