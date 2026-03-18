import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Product client-side filtering overhead', () {
    // Generate 10000 dummy products
    final List<Map<String, dynamic>> rawData = List.generate(10000, (index) => {
      'id': index.toString(),
      'name': index % 2 == 0 ? 'Tomato $index' : 'Cucumber $index',
      'image_url': '',
      'current_price': 10.0,
      'market_price': 12.0,
      'harvest_time': 'Today',
      'stock': 100,
      'category': 'Vegetables'
    });

    final stopwatch = Stopwatch()..start();

    // Simulate what the old SearchScreen does:
    // 1. Map all items
    final allProducts = rawData.map((item) => Product.fromJson(item)).toList();
    // 2. Filter client-side
    final filtered = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();

    stopwatch.stop();
    print('Baseline parsing and client-side filtering took: ${stopwatch.elapsedMilliseconds} ms for 10000 items. Found ${filtered.length} items.');
  });
}
