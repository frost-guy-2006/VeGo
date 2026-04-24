import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Filtering - Regex vs toLowerCase', () {
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

    final stopwatch1 = Stopwatch()..start();
    // Simulate current client-side filtering
    final lowerQuery = 'red apple';
    final filtered1 = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    stopwatch1.stop();
    // ignore: avoid_print
    print('Client-side filtering (toLowerCase) took: ${stopwatch1.elapsedMilliseconds} ms. Found ${filtered1.length} items.');

    final stopwatch2 = Stopwatch()..start();
    // Simulate optimized client-side filtering
    final regex = RegExp(RegExp.escape(lowerQuery), caseSensitive: false);
    final filtered2 = allProducts
        .where((p) => regex.hasMatch(p.name))
        .toList();
    stopwatch2.stop();
    // ignore: avoid_print
    print('Client-side filtering (RegExp) took: ${stopwatch2.elapsedMilliseconds} ms. Found ${filtered2.length} items.');
  });
}
