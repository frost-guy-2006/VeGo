import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark search performance', () {
    // Generate large mock dataset for client-side filtering (10,000 items)
    final List<Map<String, dynamic>> largeDataset = List.generate(
      10000,
      (index) => {
        'id': index.toString(),
        'name': 'Product $index - ${index % 2 == 0 ? "Apple" : "Banana"}',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': '',
        'stock': 100,
        'category': 'Fruits',
      },
    );

    // Simulate Client-side filtering (baseline)
    final clientStopwatch = Stopwatch()..start();
    final List<Product> allProducts =
        largeDataset.map((item) => Product.fromJson(item)).toList();
    final List<Product> clientFiltered = allProducts
        .where((p) => p.name.toLowerCase().contains('apple'))
        .toList();
    clientStopwatch.stop();

    // Generate small mock dataset for server-side filtering (representing what the DB returns)
    final List<Map<String, dynamic>> smallDataset = largeDataset
        .where(
            (item) => (item['name'] as String).toLowerCase().contains('apple'))
        .take(10)
        .toList();

    // Simulate Server-side filtering
    final serverStopwatch = Stopwatch()..start();
    final List<Product> serverFiltered =
        smallDataset.map((item) => Product.fromJson(item)).toList();
    serverStopwatch.stop();

    // ignore: avoid_print
    print(
        'Client-side filtering took: ${clientStopwatch.elapsedMilliseconds} ms');
    // ignore: avoid_print
    print(
        'Server-side filtering took: ${serverStopwatch.elapsedMilliseconds} ms');

    expect(serverStopwatch.elapsedMilliseconds,
        lessThanOrEqualTo(clientStopwatch.elapsedMilliseconds));
  });
}
