import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Client-side vs Server-side filtering simulation', () {
    // Generate 10,000 mock products
    final List<Product> mockDb = List.generate(10000, (index) {
      String name = 'Product $index';
      if (index % 100 == 0) name += ' Red';
      if (index % 50 == 0) name += ' Tomato';
      return Product(
        id: index.toString(),
        name: name,
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: 'Today',
        stock: 100,
        category: 'Vegetables',
      );
    });

    final stopwatch = Stopwatch()..start();
    // Simulate Client-side filtering: scan all
    final clientSideFiltered = mockDb.where((p) => p.name.toLowerCase().contains('tomato')).toList();
    stopwatch.stop();
    // ignore: avoid_print
    print('Client-side filtering took: ${stopwatch.elapsedMicroseconds} microseconds. Found: ${clientSideFiltered.length}');

    // Server-side filtering would ideally just be the DB querying time, but we can't benchmark DB directly here without a real DB.
    // The main issue is loading 10,000 items into memory and mapping them all to `Product` objects, then filtering.
    stopwatch.reset();
    stopwatch.start();
    // Simulation of what happens in current code:
    // 1. JSON parsing of 10,000 items
    final mockJsonDb = mockDb.map((p) => p.toJson()).toList();
    final allProductsParsed = mockJsonDb.map((json) => Product.fromJson(json)).toList();
    final clientSideFilteredFull = allProductsParsed.where((p) => p.name.toLowerCase().contains('tomato')).toList();
    stopwatch.stop();
    // ignore: avoid_print
    print('Client-side fetching+parsing+filtering took: ${stopwatch.elapsedMicroseconds} microseconds.');
  });
}
