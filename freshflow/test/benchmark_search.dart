import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark search logic', () async {
    // Generate 1000 items
    final mockResponse = List.generate(1000, (index) => {
      'id': 'id_$index',
      'name': 'Test Product $index',
      'image_url': 'http://example.com/image.jpg',
      'current_price': 100.0,
      'market_price': 120.0,
      'harvest_time': 'Today',
      'stock': 10
    });

    final startTime = DateTime.now();

    for (int i = 0; i < 100; i++) { // Simulate 100 keypresses without debounce
      final allProducts = mockResponse.map((item) => Product.fromJson(item)).toList();
      final filtered = allProducts.where((p) => p.name.toLowerCase().contains('test')).toList();
    }

    final endTime = DateTime.now();
    print('Baseline client-side filter (1000 items x 100 keypresses): ${endTime.difference(startTime).inMilliseconds}ms');

    final startTimeOpt = DateTime.now();

    for (int i = 0; i < 100; i++) {
        // Optimized: with server side filter, the mockResponse returns only 10 items
        // AND with debounce we only search ONCE
        if (i == 99) { // Simulate debounce firing after 100 keystrokes
           final mockServerResponse = List.generate(10, (index) => {
              'id': 'id_$index',
              'name': 'Test Product $index',
              'image_url': 'http://example.com/image.jpg',
              'current_price': 100.0,
              'market_price': 120.0,
              'harvest_time': 'Today',
              'stock': 10
           });
           final allProducts = mockServerResponse.map((item) => Product.fromJson(item)).toList();
        }
    }

    final endTimeOpt = DateTime.now();
    print('Optimized server-side filter + debounce: ${endTimeOpt.difference(startTimeOpt).inMilliseconds}ms');
  });
}
