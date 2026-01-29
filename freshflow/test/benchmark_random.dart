import 'dart:math';

void main() {
  const int iterations = 1000000;

  // Baseline: Creating new Random instance each time
  final stopwatch1 = Stopwatch()..start();
  double sum1 = 0;
  for (int i = 0; i < iterations; i++) {
    final random = Random();
    sum1 += random.nextDouble();
  }
  stopwatch1.stop();
  print('Creating new Random instance: ${stopwatch1.elapsedMicroseconds} µs');

  // Optimized: Reusing Random instance
  final stopwatch2 = Stopwatch()..start();
  final random = Random();
  double sum2 = 0;
  for (int i = 0; i < iterations; i++) {
    sum2 += random.nextDouble();
  }
  stopwatch2.stop();
  print('Reusing Random instance: ${stopwatch2.elapsedMicroseconds} µs');

  final improvement = (stopwatch1.elapsedMicroseconds - stopwatch2.elapsedMicroseconds) / stopwatch1.elapsedMicroseconds * 100;
  print('Improvement: ${improvement.toStringAsFixed(2)}%');
}
