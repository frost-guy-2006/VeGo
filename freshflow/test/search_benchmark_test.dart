import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Search Performance Benchmark', () async {
    // Setup data - 1000 items
    final largeJsonList = List.generate(1000, (index) => {
      'id': '$index',
      'name': 'Product $index ${index % 2 == 0 ? "Apple" : "Banana"}',
      'image_url': 'http://example.com/img.png',
      'current_price': 10.0,
      'market_price': 12.0,
      'harvest_time': 'Now',
      'stock': 100,
    });

    const query = "Apple";

    // 1. Benchmark Old Approach (Fetch All + Filter)
    final stopwatchOld = Stopwatch()..start();

    // Simulate Fetch All (Network Latency)
    await Future.delayed(const Duration(milliseconds: 100));

    // Parse ALL items
    final allProducts = largeJsonList.map((j) => Product.fromJson(j)).toList();

    // Client-side Filter
    final filteredOld = allProducts.where((p) => p.name.contains(query)).toList();

    stopwatchOld.stop();
    print('Old Approach: ${stopwatchOld.elapsedMilliseconds}ms, Items: ${filteredOld.length}');

    // 2. Benchmark New Approach (Server-side Filter)
    final stopwatchNew = Stopwatch()..start();

    // Simulate Network Search (Network Latency)
    await Future.delayed(const Duration(milliseconds: 100));

    // Server returns only matching items (Simulated DB Filter)
    final matchingJson = largeJsonList.where((j) => (j['name'] as String).contains(query)).toList();

    // Parse ONLY matching items
    final filteredNew = matchingJson.map((j) => Product.fromJson(j)).toList();

    stopwatchNew.stop();
    print('New Approach: ${stopwatchNew.elapsedMilliseconds}ms, Items: ${filteredNew.length}');

    // Assertions
    expect(filteredNew.length, filteredOld.length);

    // New approach should be faster or at least use less resources
    // In a microbenchmark with only 1000 items and fast mock logic, the time diff might be small
    // but the object allocation diff is significant (1000 vs 500 created).
  });
}
