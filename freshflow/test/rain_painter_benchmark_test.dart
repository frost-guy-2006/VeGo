import 'dart:math';
import 'dart:ui';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  test('RainPainter benchmark - Random creation vs reuse', () {
    final drops = List.generate(
      1000,
      (index) => RainDrop(
        x: Random().nextDouble(),
        y: 1.1, // Force trigger reset logic
        speed: Random().nextDouble(),
        length: Random().nextDouble(),
      ),
    );

    final painter = RainPainter(drops: drops, progress: 0.5, random: Random());
    final canvas = FakeCanvas();
    final size = Size(400, 800);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    print('Paint execution time with 1000 loops: ${stopwatch.elapsedMilliseconds} ms');
  });
}

class FakeCanvas implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
