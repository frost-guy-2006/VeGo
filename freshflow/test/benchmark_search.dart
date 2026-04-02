import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Client-side vs Server-side Filtering Simulation', () async {
    // 1. Generate 10000 mock products to simulate the 'fetch all' payload
    final allProducts = List.generate(10000, (i) {
      String name = 'Product $i';
      if (i % 50 == 0) name += ' Tomato';

      return Product(
        id: i.toString(),
        name: name,
        imageUrl: '',
        currentPrice: 1.0,
        marketPrice: 1.0,
        harvestTime: '',
        stock: 10,
        color: null,
      );
    });

    final lowerQuery = 'tomato';

    // 2. Benchmark Client-Side Filtering (Current Approach)
    // Simulates: Fetching 10k items over network (ignored here), JSON parsing (ignored here), and memory filtering.
    // In reality, fetching 10k items is the real bottleneck. We're only measuring the CPU filtering time here.
    final clientStopwatch = Stopwatch()..start();
    final clientFiltered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    clientStopwatch.stop();
    // ignore: avoid_print
    print('Client-side in-memory filtering (10,000 items) took: ${clientStopwatch.elapsedMilliseconds} ms');

    // 3. Simulate Server-Side Filtering (New Approach)
    // The server does the filtering and returns only the relevant items.
    // For the benchmark, we just show the expected returned list size.
    // ignore: avoid_print
    print('Server-side filtering would return ${clientFiltered.length} items directly, avoiding fetching 10,000 items.');
  });
}
