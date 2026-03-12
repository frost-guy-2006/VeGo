import 'dart:math';
import 'dart:ui';
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

class RainPainterOriginal extends CustomPainter {
  final List<RainDrop> drops;
  final double progress;

  RainPainterOriginal({required this.drops, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var drop in drops) {
      drop.y += drop.speed * 0.02; // Move down
      if (drop.y > 1.0) {
        drop.y = -drop.length; // Reset to top
        drop.x = Random().nextDouble(); // Random new X
      }

      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endX = startX - (drop.length * size.height * 0.2);
      final endY = startY + (drop.length * size.height);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class RainPainterOptimized extends CustomPainter {
  final List<RainDrop> drops;
  final double progress;
  final Random random; // Passed in or reused

  RainPainterOptimized({required this.drops, required this.progress, required this.random});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var drop in drops) {
      drop.y += drop.speed * 0.02; // Move down
      if (drop.y > 1.0) {
        drop.y = -drop.length; // Reset to top
        drop.x = random.nextDouble(); // Reusing Random
      }

      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endX = startX - (drop.length * size.height * 0.2);
      final endY = startY + (drop.length * size.height);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

void main() {
  test('Benchmark RainPainter with and without Random instantiation', () {
    final size = const Size(400, 800);
    final canvas = MockCanvas();
    const iterations = 50000;

    // To ensure the if block is hit frequently, we set y slightly above 1.0
    // and let it keep resetting.
    List<RainDrop> generateDrops() => List.generate(
      100,
      (_) => RainDrop(x: 0, y: 0.99, speed: 1.0, length: 0.1),
    );

    int baselineMs = 0;
    {
      final drops = generateDrops();
      final painter = RainPainterOriginal(drops: drops, progress: 0.0);

      for (int i = 0; i < 1000; i++) painter.paint(canvas, size); // Warmup

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < iterations; i++) {
        painter.paint(canvas, size);
      }
      baselineMs = stopwatch.elapsedMilliseconds;
      print('Baseline (current): $baselineMs ms');
    }

    int optimizedMs = 0;
    {
      final drops = generateDrops();
      final painter = RainPainterOptimized(drops: drops, progress: 0.0, random: Random(42));

      for (int i = 0; i < 1000; i++) painter.paint(canvas, size); // Warmup

      final stopwatch = Stopwatch()..start();
      for (int i = 0; i < iterations; i++) {
        painter.paint(canvas, size);
      }
      optimizedMs = stopwatch.elapsedMilliseconds;
      print('Optimized: $optimizedMs ms');
    }

    print('Improvement: ${baselineMs - optimizedMs} ms (${((baselineMs - optimizedMs) / baselineMs * 100).toStringAsFixed(2)}%)');
  });
}
