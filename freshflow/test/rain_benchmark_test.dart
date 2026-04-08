import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final drops = List.generate(
      1000,
      (index) => RainDrop(x: 0.5, y: 1.1, speed: 0.5, length: 0.1),
    );
    final painter = RainPainter(drops: drops, progress: 0.5);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      // Each iteration resets all 1000 drops because y > 1.0 always due to our setup
      // wait, after the first iteration, y will be reset to -length, so it won't be > 1.0
      // Let's force it. Actually, just loop a lot and see.
      for (var drop in drops) {
        drop.y = 1.1; // Force reset
      }
      painter.paint(canvas, size);
    }
    stopwatch.stop();
    // ignore: avoid_print
    print('Benchmark time: ${stopwatch.elapsedMilliseconds} ms');
  });
}
