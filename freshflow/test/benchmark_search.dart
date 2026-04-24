import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Filtering', () {
    // Generate 100,000 mock products
    final allProducts = List.generate(100000, (index) {
      return Product(
        id: index.toString(),
        name: index % 5 == 0 ? 'Red Apple $index' : 'Green Apple $index',
        imageUrl: '',
        currentPrice: 1.0,
        marketPrice: 2.0,
        harvestTime: '',
        stock: 10,
        color: index % 5 == 0 ? 'Red' : 'Green',
      );
    });

    final stopwatch = Stopwatch()..start();

    // Simulate client-side filtering
    final lowerQuery = 'red apple';
    final filtered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    // ignore: avoid_print
    print('Client-side filtering took: ${stopwatch.elapsedMilliseconds} ms for ${allProducts.length} items. Found ${filtered.length} items.');
  });
}
