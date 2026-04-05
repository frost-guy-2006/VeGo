import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Search vs Server-Side Search logic', () {
    // Generate 100,000 mock products to simulate a larger dataset or less performant device
    final List<Map<String, dynamic>> mockData = List.generate(100000, (i) => {
      'id': 'id_$i',
      'name': i % 2 == 0 ? 'Fresh Tomato $i' : 'Green Spinach $i',
      'current_price': 10.0,
      'market_price': 12.0,
      'harvest_time': 'Today',
      'stock': 100,
    });

    final stopwatch = Stopwatch()..start();

    // Simulate what search_screen does right now
    final allProducts = mockData.map((item) => Product.fromJson(item)).toList();

    final lowerQuery = 'tomato';
    final filtered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    // ignore: avoid_print
    print('Client-side parsing and filtering took: ${stopwatch.elapsedMilliseconds}ms for ${filtered.length} items');
  });
}
