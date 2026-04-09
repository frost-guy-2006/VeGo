import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

void main() {
  test('Benchmark Client-Side Search', () {
    // Generate 10000 mock products
    final List<Product> mockProducts = List.generate(
      10000,
      (index) => Product(
        id: index.toString(),
        name: 'Product $index ${index % 2 == 0 ? "Tomato" : "Apple"}',
        imageUrl: '',
        currentPrice: 1.0,
        marketPrice: 2.0,
        harvestTime: '',
        stock: 10,
        color: index % 2 == 0 ? 'Red' : 'Green',
      ),
    );

    final stopwatch = Stopwatch()..start();

    // Simulate client-side search
    final query = 'tomato';
    final lowerQuery = query.toLowerCase();

    final filtered = mockProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    // ignore: avoid_print
    print('Client-side filtering took: ${stopwatch.elapsedMilliseconds} ms. Found ${filtered.length} items.');
  });
}
