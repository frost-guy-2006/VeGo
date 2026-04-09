import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final drops = List.generate(
        100, (i) => RainDrop(x: 0.5, y: 1.1, speed: 0.5, length: 0.1));

    // We want all drops to trigger the if (drop.y > 1.0) condition to test Random() creation overhead.

    final stopwatch = Stopwatch()..start();

    final random = Random();
    for (int i = 0; i < 10000; i++) {
      // Create a new RainPainter for each frame to simulate Flutter's build cycle, or just call paint.
      final painter = RainPainter(drops: drops, progress: 0.5, random: random);
      painter.paint(MockCanvas(), const Size(800, 600));

      // Reset drops so they trigger the condition again in the next iteration
      for (var drop in drops) {
        drop.y = 1.1;
      }
    }

    stopwatch.stop();
    debugPrint('RainPainter benchmark took ${stopwatch.elapsedMilliseconds}ms');
  });
}
