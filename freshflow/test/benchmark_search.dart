import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-side Search', () {
    // Generate 10,000 items
    final List<Product> mockProducts = List.generate(10000, (index) {
      String name = 'Product $index';
      if (index % 100 == 0) name += ' Red Apple';
      return Product(
        id: index.toString(),
        name: name,
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 15.0,
        harvestTime: '',
        stock: 100,
        color: index % 50 == 0 ? 'Red' : null,
      );
    });

    final stopwatch = Stopwatch()..start();

    // Simulate current client-side filter logic
    final lowerQuery = 'red';
    List<Product> filtered;

    final activeColorFilter = 'Red';

    if (activeColorFilter != null) {
      filtered =
          mockProducts.where((p) => p.color == activeColorFilter).toList();
    } else {
      filtered = mockProducts
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    stopwatch.stop();
    // ignore: avoid_print
    print(
        'Client-side filtering took: ${stopwatch.elapsedMilliseconds} ms for 10000 items');
    expect(filtered.isNotEmpty, true);
  });
}
