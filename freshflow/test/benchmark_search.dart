import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Filtering', () {
    // Generate 10,000 dummy products
    final products = List.generate(10000, (i) => Product(
      id: i.toString(),
      name: 'Product $i ${i % 2 == 0 ? "Tomato" : "Apple"}',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 12,
      harvestTime: 'Today',
      stock: 100,
      color: i % 2 == 0 ? 'Red' : 'Green',
    ));

    final stopwatch = Stopwatch()..start();

    // Simulate what the UI was doing: client-side filtering
    for (int i = 0; i < 100; i++) {
      final lowerQuery = 'tomato';
      final filtered = products
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    stopwatch.stop();
    print('Client-side filtering 100 times took: ${stopwatch.elapsedMilliseconds}ms');

    stopwatch.reset();
    stopwatch.start();
    // Simulate what UI will do with RegExp (if we kept client side)
    final regExp = RegExp('tomato', caseSensitive: false);
    for (int i = 0; i < 100; i++) {
      final filtered = products
          .where((p) => regExp.hasMatch(p.name))
          .toList();
    }
    stopwatch.stop();
    print('RegExp filtering 100 times took: ${stopwatch.elapsedMilliseconds}ms');

    // Server-side filtering avoids this completely!
  });
}
