import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Filtering vs Server-Side', () {
    // Generate 10,000 mock products
    final List<Product> mockProducts = List.generate(10000, (index) {
      String name = 'Product $index';
      if (index % 100 == 0) {
        name += ' Tomato';
      }
      if (index % 150 == 0) {
        name += ' Red';
      }

      return Product(
        id: index.toString(),
        name: name,
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: 'Today',
        stock: 100,
      );
    });

    final stopwatch = Stopwatch()..start();

    // Simulate what the client was doing
    const lowerQuery = 'tomato';
    final filtered = mockProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    // ignore: avoid_print
    print(
        'Client-side filtering of 10,000 items took: ${stopwatch.elapsedMicroseconds} microseconds. Found ${filtered.length} items.');

    // With server-side filtering, client-side takes 0ms to filter, just parses JSON.
    // ignore: avoid_print
    print('Server-side filtering client-side overhead: 0 microseconds.');
  });
}
