import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'dart:math';

void main() {
  test('Benchmark Client-Side Search', () {
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

    // Simulate current client-side filtering
    const query = 'tomato';
    final lowerQuery = query.toLowerCase();

    // First, client side would fetch all products (simulated as already fetched)
    // and then filter
    final filtered = mockProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    // ignore: avoid_print
    print(
        'Client-side filtering took ${stopwatch.elapsedMicroseconds} microseconds for ${filtered.length} results');
  });
}
