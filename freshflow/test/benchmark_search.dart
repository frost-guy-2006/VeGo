import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark parsing and filtering 10000 items vs 20 items', () {
    // Generate 10000 mock JSON items
    final List<Map<String, dynamic>> mockJsonData = List.generate(10000, (i) => {
      'id': i.toString(),
      'name': i % 2 == 0 ? 'Tomato $i' : 'Spinach $i',
      'image_url': '',
      'current_price': 1.0,
      'market_price': 2.0,
      'harvest_time': '',
      'stock': 10,
    });

    final stopwatch1 = Stopwatch()..start();

    // Simulate what the old code did: parse all, then filter client-side
    final allProducts = mockJsonData.map((item) => Product.fromJson(item)).toList();
    final lowerQuery = 'tomato';
    final filtered = allProducts
            .where((p) => p.name.toLowerCase().contains(lowerQuery))
            .toList();

    stopwatch1.stop();
    // ignore: avoid_print
    print('Baseline (Parse 10k + Client-side filter) took ${stopwatch1.elapsedMilliseconds} ms. Found ${filtered.length}');

    // Simulate new code: server-side filtering returns only 20 items, so we only parse 20
    final stopwatch2 = Stopwatch()..start();
    final List<Map<String, dynamic>> mockServerFilteredData = mockJsonData.where((item) => (item['name'] as String).toLowerCase().contains(lowerQuery)).take(20).toList();
    final serverFilteredProducts = mockServerFilteredData.map((item) => Product.fromJson(item)).toList();
    stopwatch2.stop();

    // ignore: avoid_print
    print('Optimized (Server-side filter + Parse 20) took ${stopwatch2.elapsedMilliseconds} ms. Found ${serverFilteredProducts.length}');
  });
}
