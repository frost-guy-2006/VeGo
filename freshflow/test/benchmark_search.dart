import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Filtering', () {
    // Generate 100000 dummy products to be more realistic with multiple calls
    final allProducts = List.generate(
        100000,
        (i) => Product(
              id: '$i',
              name: 'Product $i',
              imageUrl: 'url',
              currentPrice: 1.0,
              marketPrice: 2.0,
              harvestTime: '1 day',
              stock: 10,
              color: i % 2 == 0 ? 'Red' : 'Green',
            ));

    final stopwatch = Stopwatch()..start();

    // Simulate typing 10 characters quickly without debounce
    for (int i = 0; i < 10; i++) {
      allProducts
          .where((p) => p.name.toLowerCase().contains('product 500'))
          .toList();
    }

    stopwatch.stop();
    print(
        'Client-side filtering without debounce 10 times on 100,000 items took: ${stopwatch.elapsedMilliseconds} ms');
  });
}
