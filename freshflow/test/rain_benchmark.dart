import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/home/widgets/rain_mode_overlay.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';

class MockCanvas extends Fake implements Canvas {
  @override
  void drawLine(Offset p1, Offset p2, Paint paint) {}

  @override
  void save() {}

  @override
  void restore() {}

  @override
  void translate(double dx, double dy) {}

  @override
  void scale(double sx, [double? sy]) {}

  @override
  void rotate(double radians) {}

  @override
  void clipRect(Rect rect, {ui.ClipOp clipOp = ui.ClipOp.intersect, bool doAntiAlias = true}) {}

  @override
  void clipRRect(RRect rrect, {bool doAntiAlias = true}) {}

  @override
  void clipPath(Path path, {bool doAntiAlias = true}) {}

  @override
  void drawColor(Color color, BlendMode blendMode) {}

  @override
  void drawPaint(Paint paint) {}

  @override
  void drawRect(Rect rect, Paint paint) {}

  @override
  void drawRRect(RRect rrect, Paint paint) {}

  @override
  void drawDRRect(RRect outer, RRect inner, Paint paint) {}

  @override
  void drawOval(Rect rect, Paint paint) {}

  @override
  void drawCircle(Offset c, double radius, Paint paint) {}

  @override
  void drawArc(Rect rect, double startAngle, double sweepAngle, bool useCenter, Paint paint) {}

  @override
  void drawPath(Path path, Paint paint) {}

  @override
  void drawImage(ui.Image image, Offset offset, Paint paint) {}

  @override
  void drawImageRect(ui.Image image, Rect src, Rect dst, Paint paint) {}

  @override
  void drawImageNine(ui.Image image, Rect center, Rect dst, Paint paint) {}

  @override
  void drawPicture(ui.Picture picture) {}

  @override
  void drawParagraph(ui.Paragraph paragraph, Offset offset) {}

  @override
  void drawPoints(ui.PointMode pointMode, List<Offset> points, Paint paint) {}

  @override
  void drawRawPoints(ui.PointMode pointMode, Float32List points, Paint paint) {}

  @override
  void drawVertices(ui.Vertices vertices, BlendMode blendMode, Paint paint) {}

  @override
  void drawAtlas(ui.Image atlas, List<ui.RSTransform> transforms, List<Rect> rects, List<Color>? colors, BlendMode? blendMode, Rect? cullRect, Paint paint) {}

  @override
  void drawShadow(Path path, Color color, double elevation, bool transparentOccluder) {}
}

void main() {
  test('Benchmark RainPainter', () {
    final random = Random();
    final drops = List.generate(
        100,
        (index) => RainDrop(
              x: random.nextDouble(),
              y: random.nextDouble(),
              speed: 0.5 + random.nextDouble() * 0.5,
              length: 0.05 + random.nextDouble() * 0.05,
            ));

    final painter = RainPainter(drops: drops, progress: 0.5);
    final canvas = MockCanvas();
    const size = Size(400, 800);

    // Warmup
    for (int i = 0; i < 1000; i++) {
      painter.paint(canvas, size);
    }

    final stopwatch = Stopwatch()..start();
    for (int i = 0; i < 10000; i++) {
      painter.paint(canvas, size);
    }
    stopwatch.stop();

    // ignore: avoid_print
    print(
        'RainPainter paint() x10000 took: ${stopwatch.elapsedMilliseconds} ms');
  });
}
