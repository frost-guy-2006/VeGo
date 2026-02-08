import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

// Simulate network delay
Future<void> simulateNetworkDelay(int itemCount) async {
  // Base latency (50ms) + transfer time per item (0.5ms)
  // This simulates that fetching more data takes longer
  await Future.delayed(Duration(milliseconds: 50 + (itemCount * 1) ~/ 2));
}

void main() {
  group('Search Performance Benchmark', () {
    // Create 1000 dummy products
    final allProducts = List.generate(1000, (index) {
      return Product(
        id: '$index',
        name: index % 100 == 0 ? 'Red Tomato $index' : 'Product $index',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 20,
        harvestTime: 'Now',
        stock: 10,
      );
    });

    test('Benchmark: Client-side filtering (Fetch All)', () async {
      final stopwatch = Stopwatch()..start();

      // Simulate fetching all 1000 products from DB
      await simulateNetworkDelay(1000);
      final fetched = allProducts;

      // Client-side filter
      // Simulate the logic in SearchScreen: infer color, then filter
      final filtered = fetched.where((p) => p.name.contains('Tomato')).toList();

      stopwatch.stop();
      print('Client-side filtering took: ${stopwatch.elapsedMilliseconds}ms');
      expect(filtered.length, 10);
    });

    test('Benchmark: Server-side filtering (Fetch Filtered)', () async {
      final stopwatch = Stopwatch()..start();

      // Simulate fetching only 10 matching products from DB
      // In real app, we pass query to DB and it returns only matches
      await simulateNetworkDelay(10);

      // We don't need to filter here because the DB would have done it
      // But for this mock, we just take the result
      final filtered = allProducts.where((p) => p.name.contains('Tomato')).toList();

      stopwatch.stop();
      print('Server-side filtering took: ${stopwatch.elapsedMilliseconds}ms');
      expect(filtered.length, 10);
    });
  });
}
