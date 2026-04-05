import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'dart:ui' as ui;

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}
}

// Emulate Optimized version
class OptimizedRainPainter extends CustomPainter {
  final List<RainDrop> drops;
  final double progress;
  static final Random _random = Random();

  OptimizedRainPainter({required this.drops, required this.progress});

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
        drop.x = _random.nextDouble(); // Random new X - REUSED
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
  test('Benchmark OptimizedRainPainter', () {
    final drops = List.generate(100, (i) => RainDrop(x: 0.5, y: 1.5, speed: 1.0, length: 0.1));
    final painter = OptimizedRainPainter(drops: drops, progress: 0.0);
    final canvas = MockCanvas();
    final size = const Size(800, 600);

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 100000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print('Optimized: ${stopwatch.elapsedMilliseconds} ms');
  });
}
