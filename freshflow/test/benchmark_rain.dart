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
    final drops = List.generate(
      100,
      (_) => RainDrop(
          x: 0.5,
          y: 1.1,
          speed: 0.5,
          length: 0.1), // Ensure they trigger the random generation
    );
    final random = Random();
    final painter = RainPainter(drops: drops, progress: 0.0, random: random);
    final canvas = MockCanvas();
    final size = const Size(400, 800);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
      // Reset y to force branch entry again
      for (var drop in drops) {
        drop.y = 1.1;
      }
    }
    stopwatch.stop();
    // ignore: avoid_print
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
