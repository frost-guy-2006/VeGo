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
      100,
      (i) => RainDrop(
        x: 0.5,
        y: 1.1, // Set > 1.0 to trigger reset
        speed: 1.0,
        length: 0.1,
      ),
    );

    // Make y always reset to trigger the Random() call
    final painter = RainPainter(drops: drops, progress: 0.5, random: Random());
    final canvas = MockCanvas();
    const size = Size(800, 600);

    // Warmup
    for (int i = 0; i < 1000; i++) {
      for (var drop in drops) {
        drop.y = 1.1; // ensure reset
      }
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      for (var drop in drops) {
        drop.y = 1.1; // ensure reset
      }
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    debugPrint(
        'Elapsed time for 10000 frames: ${stopwatch.elapsedMilliseconds} ms');
  });
}
