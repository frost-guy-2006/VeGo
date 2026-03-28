import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Search filtering performance benchmark', () {
    // Generate 100,000 mock product JSONs
    final List<Map<String, dynamic>> mockDbData = List.generate(100000, (i) {
      return {
        'id': '$i',
        'name': i % 100 == 0 ? 'Red Tomato $i' : 'Green Spinach $i',
        'image_url': '',
        'current_price': 5.0,
        'market_price': 6.0,
        'harvest_time': 'Today',
        'stock': 10,
        'category': 'Vegetables',
      };
    });

    // 1. Baseline: Client-side filtering (Fetch all 100,000 and parse)
    final swBaseline = Stopwatch()..start();

    // Simulating fetching all items, parsing all, and filtering client side
    final allProducts =
        mockDbData.map((item) => Product.fromJson(item)).toList();
    final filteredBaseline =
        allProducts.where((p) => p.color == 'Red').toList();

    swBaseline.stop();
    // ignore: avoid_print
    print(
        'Baseline (Fetch All + Parse All + Client Filter): ${swBaseline.elapsedMilliseconds} ms. Found ${filteredBaseline.length}');

    // 2. Optimized: Server-side filtering (DB returns only 1000 items)
    final swOptimized = Stopwatch()..start();

    // Simulating DB filtering items BEFORE they hit the client
    final dbFilteredData = mockDbData.where((item) {
      final name = (item['name'] as String).toLowerCase();
      // DB handles the ilike '%red%' or '%tomato%'
      return name.contains('red') || name.contains('tomato');
    }).toList();

    // Only parse the items returned by the DB
    final optimizedFiltered =
        dbFilteredData.map((item) => Product.fromJson(item)).toList();

    swOptimized.stop();
    // ignore: avoid_print
    print(
        'Optimized (Server Filter + Parse Subset): ${swOptimized.elapsedMilliseconds} ms. Found ${optimizedFiltered.length}');

    // Basic sanity check to ensure the test ran successfully
    expect(filteredBaseline.length, equals(optimizedFiltered.length));
    expect(swOptimized.elapsedMilliseconds,
        lessThan(swBaseline.elapsedMilliseconds));
  });
}
