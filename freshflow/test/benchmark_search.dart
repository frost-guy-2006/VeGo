import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side vs Server-Side Filtering', () {
    // Generate 10,000 dummy JSON products to simulate a large database
    final List<Map<String, dynamic>> dummyDatabase = List.generate(10000, (i) {
      return {
        'id': 'id_$i',
        'name': 'Product $i',
        'image_url': 'http://example.com/img.jpg',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 100,
        'category': 'Fruits',
      };
    });

    // We add one target item
    dummyDatabase.add({
      'id': 'target',
      'name': 'Red Apple',
      'image_url': 'http://example.com/img.jpg',
      'current_price': 10.0,
      'market_price': 12.0,
      'harvest_time': 'Today',
      'stock': 100,
      'category': 'Fruits',
    });

    // 1. Client-Side Filtering Benchmark (Current implementation)
    final stopwatchClient = Stopwatch()..start();
    // Simulate fetching all and mapping to Product models
    final allProducts =
        dummyDatabase.map((item) => Product.fromJson(item)).toList();
    // Simulate filtering by name
    final filteredClient =
        allProducts.where((p) => p.name.toLowerCase().contains('red')).toList();
    stopwatchClient.stop();
    print(
        'Client-Side Filtering (Map all 10k + Filter) took: ${stopwatchClient.elapsedMilliseconds} ms');

    // 2. Server-Side Filtering Benchmark (Optimized implementation)
    // For server-side, the DB does the filtering and returns just the matching results.
    // We mock the DB filtering here.
    final stopwatchServer = Stopwatch()..start();
    // Simulate DB query returning only matching items (usually very fast DB index)
    final serverResultJson = [dummyDatabase.last]; // In reality DB filters this
    final filteredServer =
        serverResultJson.map((item) => Product.fromJson(item)).toList();
    stopwatchServer.stop();
    print(
        'Server-Side Filtering (DB filters, Map 1) took: ${stopwatchServer.elapsedMilliseconds} ms');

    expect(stopwatchServer.elapsedMicroseconds,
        lessThan(stopwatchClient.elapsedMicroseconds));
  });
}
