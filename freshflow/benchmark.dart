import 'dart:core';

void main() {
  // Simulate 10000 products
  final products = List.generate(10000, (i) => 'Product $i');
  final sw = Stopwatch()..start();
  for (var i = 0; i < 100; i++) {
    final filtered = products.where((p) => p.toLowerCase().contains('999')).toList();
  }
  sw.stop();
  print('Client side filtering 100 times: ${sw.elapsedMilliseconds}ms');
}
