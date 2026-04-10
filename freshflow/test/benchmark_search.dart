import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark parsing and filtering', () {
    // Mock 10,000 JSON products
    final List<Map<String, dynamic>> largeJson = List.generate(10000, (index) => {
      'id': index.toString(),
      'name': 'Product $index ${index % 10 == 0 ? "Tomato" : "Apple"}',
      'category': 'Fruits',
      'price': 1.99,
      'original_price': 2.99,
      'unit': 'kg',
      'image_url': 'http://example.com/img.jpg',
      'stock_quantity': 100,
      'created_at': '2023-01-01T00:00:00.000Z',
      'is_flash_sale': false,
    });

    // Baseline: Parsing all + Client-side filter
    final sw1 = Stopwatch()..start();
    final allProducts = largeJson.map((item) => Product.fromJson(item)).toList();
    final filtered = allProducts.where((p) => p.name.toLowerCase().contains('tomato')).toList();
    sw1.stop();
    // ignore: avoid_print
    print('Baseline (Fetch All + Client Filter): ${sw1.elapsedMilliseconds} ms, Items: ${filtered.length}');

    // Optimized: Simulating Server-side filter returning only the 1000 matching JSON items
    final List<Map<String, dynamic>> smallJson = largeJson.where((item) => item['name'].toString().toLowerCase().contains('tomato')).toList();

    final sw2 = Stopwatch()..start();
    final serverFiltered = smallJson.map((item) => Product.fromJson(item)).toList();
    sw2.stop();
    // ignore: avoid_print
    print('Optimized (Server Filter + Parse Only Matches): ${sw2.elapsedMilliseconds} ms, Items: ${serverFiltered.length}');
  });
}
