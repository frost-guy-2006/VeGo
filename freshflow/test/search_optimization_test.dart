
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side vs Server-Side Filtering Logic', () {
    // Simulate a large dataset
    final largeDataset = List.generate(10000, (index) {
      final name = index % 3 == 0 ? 'Fresh Tomato $index' : 'Product $index';
      return {
        'id': '$index',
        'name': name,
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Now',
        'stock': 100
      };
    });

    // Client-side filtering benchmark
    final stopwatchClient = Stopwatch()..start();
    final allProducts = largeDataset.map((json) => Product.fromJson(json)).toList();
    final filteredClient = allProducts.where((p) => p.color == 'Red').toList();
    stopwatchClient.stop();
    print('Client-side filtering time: ${stopwatchClient.elapsedMicroseconds}us');
    print('Found ${filteredClient.length} items');

    // Simulated Server-side filtering (mocking the query construction overhead + parsing only filtered results)
    final stopwatchServer = Stopwatch()..start();
    // In a real scenario, the DB does the filtering. Here we simulate that by only parsing the relevant items.
    final keywords = Product.colorKeywords['Red'] ?? [];

    final serverResponse = largeDataset.where((json) {
      final name = (json['name'] as String).toLowerCase();
      return keywords.any((k) => name.contains(k));
    }).toList();

    final filteredServer = serverResponse.map((json) => Product.fromJson(json)).toList();
    stopwatchServer.stop();
    print('Server-side processing time (simulated): ${stopwatchServer.elapsedMicroseconds}us');
    print('Found ${filteredServer.length} items');
  });
}
