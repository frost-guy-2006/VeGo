import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side vs Server-Side Filtering', () {
    // Generate 10,000 dummy JSON products
    final List<Map<String, dynamic>> dummyJsonList = List.generate(
      10000,
      (index) => {
        'id': index.toString(),
        'name': index % 100 == 0 ? 'Red Apple $index' : 'Green Leaf $index',
        'image_url': '',
        'current_price': 1.0,
        'market_price': 2.0,
        'harvest_time': 'Today',
        'stock': 10,
        'category': 'Produce'
      },
    );

    // 1. Baseline: Client-side parsing and filtering (what currently happens)
    final stopwatchBaseline = Stopwatch()..start();

    // Simulating: final allProducts = (response as List).map((item) => Product.fromJson(item)).toList();
    final allProducts = dummyJsonList.map((item) => Product.fromJson(item)).toList();

    // Simulating: filtered = allProducts.where((p) => p.name.toLowerCase().contains(lowerQuery)).toList();
    final filteredBaseline = allProducts.where((p) => p.name.toLowerCase().contains('red')).toList();

    stopwatchBaseline.stop();

    // 2. Optimized: Server-side filtering (Simulating DB doing the work and returning 100 items)
    final List<Map<String, dynamic>> serverFilteredJsonList = dummyJsonList.where((item) => (item['name'] as String).toLowerCase().contains('red')).toList();

    final stopwatchOptimized = Stopwatch()..start();

    // Simulating: returning directly from searchProducts
    final filteredOptimized = serverFilteredJsonList.map((item) => Product.fromJson(item)).toList();

    stopwatchOptimized.stop();

    print('--- Benchmark Results ---');
    print('Baseline (Fetch all & client filter): ${stopwatchBaseline.elapsedMilliseconds} ms');
    print('Optimized (Server filter & parse small list): ${stopwatchOptimized.elapsedMilliseconds} ms');
    print('Speedup: ${(stopwatchBaseline.elapsedMicroseconds / stopwatchOptimized.elapsedMicroseconds).toStringAsFixed(2)}x');

    expect(filteredBaseline.length, filteredOptimized.length);
  });
}
