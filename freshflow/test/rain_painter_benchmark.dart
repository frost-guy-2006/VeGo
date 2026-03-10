import 'dart:math';

void main() {
  const iterations = 1000000;

  // Baseline: New Random() inside loop
  final stopwatch1 = Stopwatch()..start();
  for (int i = 0; i < iterations; i++) {
    final r = Random();
    r.nextDouble();
  }
  stopwatch1.stop();
  print('Baseline (new Random() inside loop): ${stopwatch1.elapsedMicroseconds} us');

  // Optimization: Reused Random instance
  final stopwatch2 = Stopwatch()..start();
  final random = Random();
  for (int i = 0; i < iterations; i++) {
    random.nextDouble();
  }
  stopwatch2.stop();
  print('Optimized (reused Random instance): ${stopwatch2.elapsedMicroseconds} us');
}
