import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark client-side filtering', () {
    // Generate 10,000 mock product JSONs
    final List<Map<String, dynamic>> mockData = List.generate(10000, (index) {
      return {
        'id': index.toString(),
        'name': index % 10 == 0 ? 'Tomato $index' : 'Product $index',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 100,
        'category': 'Vegetable',
      };
    });

    final stopwatch = Stopwatch()..start();

    // Simulate what the client does now
    final allProducts = mockData.map((item) => Product.fromJson(item)).toList();

    final lowerQuery = 'tomato';
    final filtered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    print('Client-side processing of 10000 items took: ${stopwatch.elapsedMilliseconds}ms');
    print('Filtered count: ${filtered.length}');
  });
}
