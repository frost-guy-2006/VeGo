import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'dart:math';

void main() {
  test('Benchmark Client-Side Color Search', () {
    // Generate 10000 mock products
    final random = Random(42);
    final List<Product> mockProducts = [];
    final names = [
      'Tomato',
      'Apple',
      'Carrot',
      'Spinach',
      'Broccoli',
      'Banana',
      'Orange',
      'Strawberry',
      'Cucumber'
    ];

    for (int i = 0; i < 10000; i++) {
      final name = names[random.nextInt(names.length)];
      mockProducts.add(Product(
        id: i.toString(),
        name: '$name $i',
        imageUrl: 'url',
        currentPrice: 10.0,
        marketPrice: 15.0,
        harvestTime: 'Now',
        stock: 100,
        color: i % 2 == 0 ? 'Red' : 'Green',
      ));
    }

    final stopwatch = Stopwatch()..start();

    const activeColorFilter = 'Red';

    final filtered =
        mockProducts.where((p) => p.color == activeColorFilter).toList();

    stopwatch.stop();
    // ignore: avoid_print
    print(
        'Client-side color filtering took ${stopwatch.elapsedMicroseconds} microseconds for ${filtered.length} results');
  });
}
