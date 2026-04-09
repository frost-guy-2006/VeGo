import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Filtering with RegExp', () {
    // Generate 100,000 mock products
    final List<Product> mockProducts = List.generate(
      100000,
      (index) => Product(
        id: index.toString(),
        name: index % 2 == 0 ? 'Tomato $index' : 'Cucumber $index',
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: 'Today',
        stock: 100,
        color: index % 2 == 0 ? 'Red' : 'Green',
      ),
    );

    final stopwatch = Stopwatch()..start();

    // Simulate Client-Side Filtering using RegExp
    final String lowerQuery = 'tomato';
    final regExp = RegExp(lowerQuery, caseSensitive: false);
    final List<Product> filtered = mockProducts
        .where((p) => regExp.hasMatch(p.name))
        .toList();

    stopwatch.stop();

    // ignore: avoid_print
    print('RegExp filtering of 100,000 products took: ${stopwatch.elapsedMilliseconds}ms. Found ${filtered.length} items.');
  });
}
