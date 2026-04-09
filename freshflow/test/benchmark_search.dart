import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

// Mock data to simulate large product list
List<Map<String, dynamic>> generateMockProducts(int count) {
  final products = <Map<String, dynamic>>[];
  final words = [
    'Tomato',
    'Apple',
    'Banana',
    'Spinach',
    'Carrot',
    'Broccoli',
    'Cucumber',
    'Strawberry',
    'Orange',
    'Lemon',
    'Berry',
    'Red',
    'Green',
    'Blue',
    'Yellow'
  ];

  for (int i = 0; i < count; i++) {
    final word = words[i % words.length];
    products.add({
      'id': 'id_$i',
      'name': 'Fresh $word $i',
      'imageUrl': '',
      'currentPrice': 2.99,
      'marketPrice': 3.99,
      'harvestTime': 'Today',
      'stock': 100,
      'category': 'Vegetables',
    });
  }
  return products;
}

void main() {
  test('Search filtering benchmark', () {
    final mockJson = generateMockProducts(10000);

    // Benchmark 1: Current client-side fromJson filtering
    final sw1 = Stopwatch()..start();
    final allProducts = mockJson.map((item) => Product.fromJson(item)).toList();
    final filtered = allProducts.where((p) => p.color == 'Red').toList();
    sw1.stop();

    print(
        'Baseline Client-side parsing and filtering 10k items: ${sw1.elapsedMilliseconds}ms');
    print('Filtered count: ${filtered.length}');

    // The optimized server-side filtering delegates this to Supabase,
    // so client only parses the already filtered ~10 items.
    final sw2 = Stopwatch()..start();
    final optimizedFilteredList = mockJson.where((item) {
      final name = (item['name'] as String).toLowerCase();
      return name.contains('red') ||
          name.contains('tomato') ||
          name.contains('apple') ||
          name.contains('strawberry');
    }).toList();
    final optimizedParsed =
        optimizedFilteredList.map((item) => Product.fromJson(item)).toList();
    sw2.stop();

    print(
        'Simulated Server-side DB return (parse only filtered): ${sw2.elapsedMilliseconds}ms');
    print('Filtered count: ${optimizedParsed.length}');
  });
}
