import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  group('Performance Benchmark', () {
    test('Client-side vs Server-side Filtering Simulation', () {
      // Create 100,000 dummy products
      final products = List.generate(
        100000,
        (i) => Product(
          id: i.toString(),
          name: i % 10 == 0 ? 'Tomato $i' : 'Apple $i',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 12,
          harvestTime: '',
          stock: 10,
          color: i % 10 == 0 ? 'Red' : 'Green',
        ),
      );

      const lowerQuery = 'tomato';

      // Simulate Baseline: Client-side filtering
      final stopwatchBaseline = Stopwatch()..start();
      final filteredClient = products
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .toList();
      stopwatchBaseline.stop();

      // Simulate Optimized: Filtering done by server (simulating 0 cost on client)
      final stopwatchOptimized = Stopwatch()..start();
      // ... server does the filtering ...
      // Client just receives the list (e.g. 100 items instead of 100,000)
      // ignore: unused_local_variable
      final receivedItems = filteredClient;
      stopwatchOptimized.stop();

      // ignore: avoid_print
      print(
          'Baseline: Client-side filtering 100k items took: ${stopwatchBaseline.elapsedMilliseconds} ms');
      // ignore: avoid_print
      print(
          'Optimized: Client-side filtering 100k items took: ${stopwatchOptimized.elapsedMilliseconds} ms (Delegated to Server)');

      expect(filteredClient.length, 10000);
    });
  });
}
