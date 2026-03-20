import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-side vs Server-side filtering', () {
    final rawData = List.generate(10000, (i) => {
      'id': '$i',
      'name': 'Product $i',
      'image_url': '',
      'current_price': 10.0,
      'market_price': 12.0,
      'harvest_time': 'Now',
      'stock': 100,
    });

    rawData[5000]['name'] = 'Red Tomato';

    // Measure Client-side
    final sw1 = Stopwatch()..start();
    final allProducts = rawData.map((item) => Product.fromJson(item)).toList();
    final filtered = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();
    sw1.stop();
    print('Baseline Client-side filtering (CPU): ${sw1.elapsedMicroseconds}us');

    // Measure Server-side (simulated)
    final serverFilteredData = rawData.where((item) => (item['name'] as String).toLowerCase().contains('tomato')).toList();
    final sw2 = Stopwatch()..start();
    final optimizedProducts = serverFilteredData.map((item) => Product.fromJson(item)).toList();
    sw2.stop();
    print('Optimized Server-side filtering (CPU): ${sw2.elapsedMicroseconds}us');

    expect(filtered.length, optimizedProducts.length);
  });
}
