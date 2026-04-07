import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-side vs Server-side Filtering Simulation', () {
    // Generate 10,000 mock product JSONs
    final List<Map<String, dynamic>> allProductJsons = List.generate(10000, (index) {
      String name = 'Product $index';
      if (index % 10 == 0) name += ' Tomato';
      if (index % 15 == 0) name += ' Spinach';

      return {
        'id': index.toString(),
        'name': name,
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': '',
        'stock': 100,
        'category': 'Vegetables',
      };
    });

    final stopwatch = Stopwatch()..start();

    // Simulate Client-side filtering (fetch all, parse all, filter)
    final allProducts = allProductJsons.map((json) => Product.fromJson(json)).toList();
    final lowerQuery = 'tomato';
    final filtered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    // ignore: avoid_print
    print('Baseline Client-side filtering took: ${stopwatch.elapsedMilliseconds} ms for ${filtered.length} items');

    // Simulate Server-side filtering (filter JSONs first, parse only matched)
    stopwatch.reset();
    stopwatch.start();
    final serverFilteredJsons = allProductJsons
        .where((json) => (json['name'] as String).toLowerCase().contains(lowerQuery))
        .toList();
    final optimizedFiltered = serverFilteredJsons.map((json) => Product.fromJson(json)).toList();
    stopwatch.stop();
    // ignore: avoid_print
    print('Simulated Server-side filtering took: ${stopwatch.elapsedMilliseconds} ms for ${optimizedFiltered.length} items');
  });
}
