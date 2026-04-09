import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';

void main() {
  test('RainPainter Benchmark', () {
    final drops = List.generate(
      100,
      (i) => RainDrop(
        x: 0.5,
        y: 1.1, // Set > 1.0 to trigger reset in every iteration
        speed: 1.0,
        length: 0.1,
      ),
    );

    final painter = RainPainter(drops: drops, progress: 0.5, random: Random());

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      final recorder = PictureRecorder();
      final canvas = Canvas(recorder);
      painter.paint(canvas, const Size(400, 800));
      for (var drop in drops) {
        drop.y = 1.1; // reset for next paint
      }
    }
    stopwatch.stop();

    print('Benchmark took ${stopwatch.elapsedMilliseconds} ms');
  });
}
