import 'dart:ui';
import 'dart:math';
import 'package:flutter/material.dart';

class RainDrop {
  double x;
  double y;
  double speed;
  double length;

  RainDrop({required this.x, required this.y, required this.speed, required this.length});
}

class RainPainterOriginal {
  final List<RainDrop> drops;
  final double progress;

  RainPainterOriginal({required this.drops, required this.progress});

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
      final endX = startX - (drop.length * size.height * 0.2); // Slanted slightly
      final endY = startY + (drop.length * size.height);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }
}

class RainPainterOptimized {
  final List<RainDrop> drops;
  final double progress;
  static final Random _random = Random();

  RainPainterOptimized({required this.drops, required this.progress});

  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.3)
      ..strokeWidth = 1.5
      ..strokeCap = StrokeCap.round;

    for (var drop in drops) {
      drop.y += drop.speed * 0.02; // Move down
      if (drop.y > 1.0) {
        drop.y = -drop.length; // Reset to top
        drop.x = _random.nextDouble(); // Random new X
      }

      final startX = drop.x * size.width;
      final startY = drop.y * size.height;
      final endX = startX - (drop.length * size.height * 0.2); // Slanted slightly
      final endY = startY + (drop.length * size.height);

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), paint);
    }
  }
}

void main() {
  final random = Random();
  final size = const Size(400, 800);

  // Create drops that will frequently reset to trigger the Random() call
  final dropsOriginal = List.generate(1000, (i) => RainDrop(
    x: random.nextDouble(),
    y: 0.99, // very close to bottom
    speed: 1.0,
    length: 0.1,
  ));

  final dropsOptimized = List.generate(1000, (i) => RainDrop(
    x: random.nextDouble(),
    y: 0.99, // very close to bottom
    speed: 1.0,
    length: 0.1,
  ));

  final painterOriginal = RainPainterOriginal(drops: dropsOriginal, progress: 0);
  final painterOptimized = RainPainterOptimized(drops: dropsOptimized, progress: 0);

  final recorderOriginal = PictureRecorder();
  final canvasOriginal = Canvas(recorderOriginal);

  final recorderOptimized = PictureRecorder();
  final canvasOptimized = Canvas(recorderOptimized);

  // Warmup
  for (int i = 0; i < 1000; i++) {
    painterOriginal.paint(canvasOriginal, size);
    painterOptimized.paint(canvasOptimized, size);
  }

  // Benchmark Original
  final watchOriginal = Stopwatch()..start();
  for (int i = 0; i < 10000; i++) {
    // reset y to trigger Random() again
    for (var d in dropsOriginal) d.y = 0.99;
    painterOriginal.paint(canvasOriginal, size);
  }
  watchOriginal.stop();

  // Benchmark Optimized
  final watchOptimized = Stopwatch()..start();
  for (int i = 0; i < 10000; i++) {
    // reset y to trigger Random() again
    for (var d in dropsOptimized) d.y = 0.99;
    painterOptimized.paint(canvasOptimized, size);
  }
  watchOptimized.stop();

  // ignore: avoid_print
  print("Original (10000 paints, 1000 drops each): ${watchOriginal.elapsedMilliseconds} ms");
  // ignore: avoid_print
  print("Optimized (10000 paints, 1000 drops each): ${watchOptimized.elapsedMilliseconds} ms");
}
