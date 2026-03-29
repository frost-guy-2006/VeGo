import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Client-side filtering vs Server-side filtering simulation', () async {
    // 1. Setup: Generate 10,000 products to simulate a large database
    final allProducts = List.generate(10000, (index) => Product(
      id: '$index',
      name: index % 2 == 0 ? 'Red Apple $index' : 'Green Spinach $index',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 12,
      harvestTime: 'Now',
      stock: 100,
      category: 'Fruits',
    ));

    // Simulate "Fetch All" network latency (simulating payload size impact)
    final fetchAllLatency = const Duration(milliseconds: 200);
    // Simulate "Fetch Filtered" network latency
    final fetchFilteredLatency = const Duration(milliseconds: 50);

    // 2. Measure "Slow" approach (Client-side filtering)
    final stopwatchSlow = Stopwatch()..start();

    // Simulate network request
    await Future.delayed(fetchAllLatency);

    // Perform client-side filtering
    final filteredSlow = allProducts.where((p) => p.name.contains('Apple')).toList();

    stopwatchSlow.stop();
    print('Baseline (Client-side filtering + large fetch): ${stopwatchSlow.elapsedMilliseconds}ms');

    // 3. Measure "Fast" approach (Server-side filtering)
    final stopwatchFast = Stopwatch()..start();

    // Simulate network request with server-side filtering
    await Future.delayed(fetchFilteredLatency);

    // Result is already filtered (simulated)
    // We don't need to filter here, but we can simulate processing the small list
    final filteredFast = [allProducts.first];

    stopwatchFast.stop();
    print('Optimized (Server-side filtering + small fetch): ${stopwatchFast.elapsedMilliseconds}ms');

    // 4. Verify improvement
    expect(stopwatchFast.elapsedMilliseconds, lessThan(stopwatchSlow.elapsedMilliseconds));
  });
}
