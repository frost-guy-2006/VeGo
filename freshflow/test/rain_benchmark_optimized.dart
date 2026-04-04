import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

class RainDrop {
  double x;
  double y;
  double speed;
  double length;

  RainDrop(
      {required this.x,
      required this.y,
      required this.speed,
      required this.length});
}

class RainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final double progress;
  static final Random _random = Random(); // <--- OPTIMIZATION HERE

  RainPainter({required this.drops, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var drop in drops) {
      drop.y += drop.speed * 0.02; // Move down
      if (drop.y > 1.0) {
        drop.y = -drop.length; // Reset to top
        drop.x = _random.nextDouble(); // <--- USE CACHED RANDOM
      }

      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endX =
          startX - (drop.length * size.height * 0.2); // Slanted slightly
      final endY = startY + (drop.length * size.height);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void main() {
  test('RainPainter Benchmark', () {
    final drops = List.generate(
        1000,
        (i) => RainDrop(
              x: 0.5,
              y: 1.1, // Force reset on every paint call to trigger Random().nextDouble()
              speed: 1.0,
              length: 0.1,
            ));
    final painter = RainPainter(drops: drops, progress: 0.5);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    // Warmup
    for (int i = 0; i < 100; i++) {
      painter.paint(canvas, size);
      // Reset y to force trigger
      for (var drop in drops) drop.y = 1.1;
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
      // Reset y to force trigger
      for (var drop in drops) drop.y = 1.1;
    }
    stopwatch.stop();
    // ignore: avoid_print
    print(
        'RainPainter Optimized benchmark: ${stopwatch.elapsedMilliseconds} ms');
  });
}
