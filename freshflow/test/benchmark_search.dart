import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Client-side vs Server-side Filtering Simulation', () {
    final int totalItems = 10000;
    final int matchingItems = 100;

    // Generate dummy JSON data
    final List<Map<String, dynamic>> allJsonData = List.generate(totalItems, (i) => {
      'id': '$i',
      'name': i % 100 == 0 ? 'Tomato $i' : 'Product $i',
      'image_url': 'http://example.com/image.jpg',
      'current_price': 100.0,
      'market_price': 120.0,
      'harvest_time': 'Today',
      'stock': 10,
      'category': 'Vegetables'
    });

    final List<Map<String, dynamic>> filteredJsonData = allJsonData.where((json) => (json['name'] as String).contains('Tomato')).toList();

    // Baseline: Client-side approach (Parse all, then filter)
    final stopwatchClient = Stopwatch()..start();
    final allProducts = allJsonData.map((item) => Product.fromJson(item)).toList();
    final filteredClient = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();
    stopwatchClient.stop();

    // Improved: Server-side approach (Parse only filtered data returned by server)
    final stopwatchServer = Stopwatch()..start();
    final filteredServer = filteredJsonData.map((item) => Product.fromJson(item)).toList();
    stopwatchServer.stop();

    print('--- Benchmark Results ---');
    print('Client-side filtering (Parse 10000, filter locally): ${stopwatchClient.elapsedMicroseconds} μs');
    print('Server-side filtering (Parse 100, pre-filtered): ${stopwatchServer.elapsedMicroseconds} μs');
    print('Improvement factor: ${stopwatchClient.elapsedMicroseconds / stopwatchServer.elapsedMicroseconds}x faster');

    expect(filteredClient.length, filteredServer.length);
  });
}
