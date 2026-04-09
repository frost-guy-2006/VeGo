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

    // We want to make sure the reset block is hit EVERY time
    final List<RainDrop> drops = [];
    for (int i = 0; i < 1000; i++) {
      drops.add(RainDrop(
        x: random.nextDouble(),
        y: 1.0, // This will be > 1.0 after addition
        speed: 1.0,
        length: 0.1,
      ));
    }

    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      // Because painter.paint actually mutates drops, we need to ensure drop.y > 1.0 on every iteration for worst case benchmark
      for (var drop in drops) {
        drop.y = 1.0;
      }
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    debugPrint(
        'Baseline execution time for 10,000 paint calls (1000 drops each): ${stopwatch.elapsedMilliseconds}ms');
  });
}
