import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Client-side filtering vs Server-side query', () {
    // Generate 10,000 products
    final List<Product> mockProducts = List.generate(10000, (index) {
      final name = index % 2 == 0 ? 'Red Apple $index' : 'Green Spinach $index';
      return Product(
        id: index.toString(),
        name: name,
        imageUrl: '',
        currentPrice: 1.0,
        marketPrice: 2.0,
        harvestTime: '',
        stock: 10,
        category: 'Food',
      );
    });

    // Benchmark Client-side filtering
    final stopwatch = Stopwatch()..start();
    final query = 'red';
    final lowerQuery = query.toLowerCase();

    // Simulating old search screen logic
    final filtered = mockProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    print('Client-side filtering took: ${stopwatch.elapsedMilliseconds} ms to find ${filtered.length} items out of 10,000');

    // Simulating Server-side filtering would just be the database doing the work,
    // which is typically measured in query time (not dart CPU time).
    // The main issue is fetching 10k items to client.
  });
}
