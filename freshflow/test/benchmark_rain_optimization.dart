import 'dart:math';

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

void main() {
  final drops = List.generate(
      100,
      (index) => RainDrop(
            x: Random().nextDouble(),
            y: Random().nextDouble(),
            speed: 0.5 + Random().nextDouble() * 0.5,
            length: 0.05 + Random().nextDouble() * 0.05,
          ));

  final random = Random();
  const iterations = 1000000;

  // Warmup
  runInefficient(drops, 1000);
  runOptimized(drops, random, 1000);

  // Measure Inefficient
  final stopwatchInefficient = Stopwatch()..start();
  runInefficient(drops, iterations);
  stopwatchInefficient.stop();
  print('Inefficient time: ${stopwatchInefficient.elapsedMilliseconds} ms');

  // Measure Optimized
  final stopwatchOptimized = Stopwatch()..start();
  runOptimized(drops, random, iterations);
  stopwatchOptimized.stop();
  print('Optimized time: ${stopwatchOptimized.elapsedMilliseconds} ms');

  final improvement = stopwatchInefficient.elapsedMilliseconds -
      stopwatchOptimized.elapsedMilliseconds;
  final percent = (improvement / stopwatchInefficient.elapsedMilliseconds) * 100;
  print('Improvement: ${improvement} ms (${percent.toStringAsFixed(2)}%)');
}

void runInefficient(List<RainDrop> drops, int iterations) {
  for (int i = 0; i < iterations; i++) {
    for (var drop in drops) {
      drop.y += drop.speed * 0.02; // Move down
      if (drop.y > 1.0) {
        drop.y = -drop.length; // Reset to top
        drop.x = Random().nextDouble(); // Random new X
      }
    }
  }
}

void runOptimized(List<RainDrop> drops, Random random, int iterations) {
  for (int i = 0; i < iterations; i++) {
    for (var drop in drops) {
      drop.y += drop.speed * 0.02; // Move down
      if (drop.y > 1.0) {
        drop.y = -drop.length; // Reset to top
        drop.x = random.nextDouble(); // Random new X
      }
    }
  }
}
