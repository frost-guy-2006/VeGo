import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Client-side vs Server-side filtering', () {
    // Generate large mock dataset
    final List<Map<String, dynamic>> mockData = [];
    for (int i = 0; i < 10000; i++) {
      mockData.add({
        'id': 'id_$i',
        'name': i % 3 == 0 ? 'Red Tomato $i' : 'Green Spinach $i',
        'current_price': 2.5,
        'market_price': 3.0,
      });
    }

    // 1. Client-side filtering approach
    final stopwatchClient = Stopwatch()..start();
    final allProducts = mockData.map((json) => Product.fromJson(json)).toList();
    final filteredClient = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();
    stopwatchClient.stop();
    // ignore: avoid_print
    print('Client-side filtering took: ${stopwatchClient.elapsedMilliseconds} ms. Found ${filteredClient.length} items.');

    // 2. Server-side filtering approach (simulated)
    final stopwatchServer = Stopwatch()..start();
    // In reality this is just the map operation on the smaller set returned by DB
    final serverReturnedData = mockData.where((json) => (json['name'] as String).toLowerCase().contains('tomato')).toList();
    final filteredServer = serverReturnedData.map((json) => Product.fromJson(json)).toList();
    stopwatchServer.stop();
    // ignore: avoid_print
    print('Server-side (simulated) filtering took: ${stopwatchServer.elapsedMilliseconds} ms. Found ${filteredServer.length} items.');
  });
}
