// ignore_for_file: avoid_print
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark client-side vs server-side filtering', () {
    final List<Map<String, dynamic>> mockData = List.generate(10000, (index) {
      return {
        'id': index.toString(),
        'name': index % 2 == 0 ? 'Red Apple $index' : 'Green Spinach $index',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 100,
        'category': 'Fruits'
      };
    });

    // Baseline: Client-side parsing and filtering
    final stopwatch1 = Stopwatch()..start();
    final allProducts = mockData.map((item) => Product.fromJson(item)).toList();
    final lowerQuery = 'red apple';
    final filteredClient = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    stopwatch1.stop();
    print(
        'Baseline - Client-side parsing and filtering 10000 items took: ${stopwatch1.elapsedMilliseconds}ms');

    // Optimized: Server-side filtering (only parse returned subset)
    final stopwatch2 = Stopwatch()..start();
    // Simulate DB query filtering to 5000 items
    final serverResults = mockData
        .where((item) =>
            (item['name'] as String).toLowerCase().contains(lowerQuery))
        .toList();
    final filteredServer =
        serverResults.map((item) => Product.fromJson(item)).toList();
    stopwatch2.stop();
    print(
        'Optimized - Server-side filtering (parsing subset) took: ${stopwatch2.elapsedMilliseconds}ms');

    expect(filteredClient.length, filteredServer.length);
  });
}
