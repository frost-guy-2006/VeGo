import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark product deserialization vs filtered', () async {
    // Simulate a database with 100,000 products
    final List<Map<String, dynamic>> mockDb = List.generate(100000, (i) {
      String name = 'Apple $i';
      if (i % 10 == 0) name = 'Tomato $i';
      if (i % 10 == 1) name = 'Banana $i';

      return {
        'id': 'id_$i',
        'name': name,
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 100,
        'category': 'Test'
      };
    });

    // 1. Current approach: Fetch all, deserialize all, filter client side
    final stopwatch1 = Stopwatch()..start();

    // Deserialize all items
    final allProducts = mockDb.map((item) => Product.fromJson(item)).toList();

    // Filter client side for 'tomato'
    final filtered1 = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();

    stopwatch1.stop();
    print('Baseline (Fetch All + Client Filter): ${stopwatch1.elapsedMilliseconds} ms');
    print('Found ${filtered1.length} items');

    // 2. Optimized approach: Filter first (simulating DB query), then deserialize only the results
    final stopwatch2 = Stopwatch()..start();

    // Simulate database returning only matching rows
    final dbFiltered = mockDb.where((row) => (row['name'] as String).toLowerCase().contains('tomato')).toList();

    // Deserialize only the matching items
    final filtered2 = dbFiltered.map((item) => Product.fromJson(item)).toList();

    stopwatch2.stop();
    print('Optimized (DB Filter + Partial Deserialize): ${stopwatch2.elapsedMilliseconds} ms');
    print('Found ${filtered2.length} items');
  });
}
