import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side Search', () {
    // Generate 10000 mock products
    final products = List.generate(10000, (i) => Product(
      id: i.toString(),
      name: 'Product $i ${i % 2 == 0 ? "Tomato" : "Cucumber"}',
      imageUrl: '',
      currentPrice: 1.0,
      marketPrice: 2.0,
      harvestTime: 'Today',
      stock: 10,
      color: i % 2 == 0 ? 'Red' : 'Green',
    ));

    final stopwatch = Stopwatch()..start();

    // Client side filtering for color 'Red'
    final filtered = products.where((p) => p.color == 'Red').toList();

    stopwatch.stop();
    // ignore: avoid_print
    print('Client-side filtering took: ${stopwatch.elapsedMilliseconds} ms for ${filtered.length} items out of ${products.length}');

    final stopwatch2 = Stopwatch()..start();
    final filteredText = products.where((p) => p.name.toLowerCase().contains('tomato')).toList();
    stopwatch2.stop();
    // ignore: avoid_print
    print('Client-side text filtering took: ${stopwatch2.elapsedMilliseconds} ms for ${filteredText.length} items');
  });
}
