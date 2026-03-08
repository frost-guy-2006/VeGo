import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

void main() {
  test('Search filtering benchmark', () {
    // Generate 100,000 mock products
    final List<Map<String, dynamic>> mockData = List.generate(100000, (index) {
      return {
        'id': index.toString(),
        'name': index % 100 == 0 ? 'Red Tomato $index' : 'Product $index',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 10,
        'category': 'Vegetables'
      };
    });

    final stopwatch = Stopwatch()..start();

    // Simulating old client-side behavior
    final allProducts = mockData.map((item) => Product.fromJson(item)).toList();
    final filtered = allProducts.where((p) => p.color == 'Red').toList();

    stopwatch.stop();
    print('Client-side filtering took: ${stopwatch.elapsedMilliseconds}ms for ${filtered.length} items');

    // The new server-side behavior will only parse the filtered JSON returned by DB
    final List<Map<String, dynamic>> serverFilteredData = mockData.where((item) => (item['name'] as String).contains('Tomato')).toList();

    final stopwatch2 = Stopwatch()..start();
    final newFiltered = serverFilteredData.map((item) => Product.fromJson(item)).toList();
    stopwatch2.stop();
    print('Server-side filtering (parsing only results) took: ${stopwatch2.elapsedMilliseconds}ms for ${newFiltered.length} items');
  });
}
