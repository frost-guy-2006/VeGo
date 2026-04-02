import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('benchmark search filtering', () {
    // Generate 10,000 mock products
    final List<Product> allProducts = List.generate(
      10000,
      (index) => Product(
        id: 'id_$index',
        name: 'Product $index ${index % 2 == 0 ? "Tomato" : "Apple"}',
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: 'Today',
        stock: 100,
      ),
    );

    final stopwatch = Stopwatch()..start();

    // Simulate client-side filtering (baseline)
    const lowerQuery = 'tomato';
    final List<Product> filtered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();

    // ignore: avoid_print
    print(
        'Baseline client-side filtering took: ${stopwatch.elapsedMilliseconds}ms for 10,000 items (found ${filtered.length})');
  });
}
