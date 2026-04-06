import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('RainPainter benchmark', () {
    final List<RainDrop> drops = List.generate(
      10000,
      (i) => RainDrop(
        x: 0.5,
        y: 1.0,
        speed: 100.0,
        length: 0.1,
      ),
    );

    final painter = RainPainter(drops: drops, progress: 0.0);
    final canvas = MockCanvas();
    const size = Size(100, 100);

    // Warmup
    for (int i = 0; i < 100; i++) {
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('Baseline execution time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
