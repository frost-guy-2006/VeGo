import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'dart:math';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final drops = List.generate(
      100,
      (index) => RainDrop(
        x: Random().nextDouble(),
        y: 0.99, // close to 1.0 to trigger the random assignment
        speed: 1.0,
        length: 0.1,
      ),
    );

    final canvas = MockCanvas();
    const size = Size(1000, 1000);

    // Initial warm up
    final random = Random();
    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    debugPrint('Benchmark time: ${stopwatch.elapsedMicroseconds} us');
  });
}
