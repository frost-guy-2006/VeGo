import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark Client-Side vs Server-Side Search Filtering', () {
    // Generate 10000 items
    final List<Map<String, dynamic>> mockJson = List.generate(10000, (index) {
      return {
        'id': index.toString(),
        'name': 'Product $index ${index % 2 == 0 ? "Tomato" : "Cucumber"}',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': '',
        'stock': 10,
        'category': 'Food',
      };
    });

    final stopwatch = Stopwatch()..start();

    // Simulate old approach: map all to objects then filter client-side
    final allProducts = mockJson.map((item) => Product.fromJson(item)).toList();
    final lowerQuery = 'tomato';
    final filtered = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    final clientSideTime = stopwatch.elapsedMilliseconds;
    // ignore: avoid_print
    print('Client-side parsing & filtering 10000 items took: $clientSideTime ms. Found ${filtered.length}');

    // Simulate new approach (Server-side): Assuming server returns only 5000 filtered json items
    final filteredJson = mockJson.where((json) => json['name'].toString().toLowerCase().contains(lowerQuery)).toList();

    stopwatch.reset();
    stopwatch.start();
    final serverSideFilteredProducts = filteredJson.map((item) => Product.fromJson(item)).toList();
    stopwatch.stop();
    final serverSideTime = stopwatch.elapsedMilliseconds;
    // ignore: avoid_print
    print('Server-side (client parses only filtered results) took: $serverSideTime ms.');

    expect(filtered.length, serverSideFilteredProducts.length);
  });
}
