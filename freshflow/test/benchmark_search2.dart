import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Filtering with Regex vs toLowerCase', () {
    // Generate 10000 mock products
    final products = List.generate(10000, (i) {
      String name = 'Product $i';
      if (i % 10 == 0) name += ' Tomato';
      if (i % 15 == 0) name += ' Spinach';

      return Product(
        id: i.toString(),
        name: name,
        imageUrl: '',
        currentPrice: 1.0,
        marketPrice: 1.0,
        harvestTime: '',
        stock: 10,
        color: i % 10 == 0 ? 'Red' : (i % 15 == 0 ? 'Green' : null),
      );
    });

    final lowerQuery = 'tomato';

    // toLowerCase
    final stopwatch1 = Stopwatch()..start();
    final filtered1 = products
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    stopwatch1.stop();
    // ignore: avoid_print
    print('toLowerCase took: ${stopwatch1.elapsedMilliseconds} ms');

    // RegExp
    final regex = RegExp(lowerQuery, caseSensitive: false);
    final stopwatch2 = Stopwatch()..start();
    final filtered2 = products
        .where((p) => regex.hasMatch(p.name))
        .toList();
    stopwatch2.stop();
    // ignore: avoid_print
    print('RegExp took: ${stopwatch2.elapsedMilliseconds} ms');
  });
}
