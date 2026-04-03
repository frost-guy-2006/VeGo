import 'dart:math';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  test('RainPainter Benchmark', () {
    final drops = List.generate(100, (i) => RainDrop(
      x: 0.5,
      y: 1.5, // Force reset and Random() creation
      speed: 1.0,
      length: 0.1,
    ));

    final painter = RainPainter(drops: drops, progress: 0.0, random: Random());

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    final size = const Size(800, 600);

    // Warm-up
    for (int i = 0; i < 10000; i++) {
      for (var drop in drops) {
        drop.y = 1.5;
      }
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 50000; i++) {
      for (var drop in drops) {
        drop.y = 1.5;
      }
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    print('--- BENCHMARK RESULT ---');
    print('Time: ${stopwatch.elapsedMilliseconds} ms');
    print('------------------------');
  });
}
