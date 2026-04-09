import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'dart:math';

void main() {
  test('Search benchmark: Client-side filtering overhead', () {
    // Generate a large list of mock products
    final random = Random(42);
    final names = ['Tomato', 'Apple', 'Banana', 'Carrot', 'Spinach', 'Broccoli', 'Cucumber', 'Potato', 'Onion', 'Milk', 'Bread', 'Egg', 'Strawberry', 'Orange'];

    final allProducts = List.generate(10000, (i) {
      final name = names[random.nextInt(names.length)] + ' ' + i.toString();
      return Product(
        id: i.toString(),
        name: name,
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: '',
        stock: 100,
      );
    });

    final query = 'red';
    final lowerQuery = query.toLowerCase();

    // Baseline: Client-side filtering
    final stopwatch = Stopwatch()..start();
    List<Product> filtered = [];

    // Check for color keywords
    String? activeColorFilter;
    if (['red', 'blue', 'green', 'orange', 'yellow'].contains(lowerQuery)) {
      activeColorFilter = lowerQuery[0].toUpperCase() + lowerQuery.substring(1);
    }

    for (int i = 0; i < 100; i++) {
      if (activeColorFilter != null) {
        filtered = allProducts.where((p) => p.color == activeColorFilter).toList();
      } else {
        filtered = allProducts.where((p) => p.name.toLowerCase().contains(lowerQuery)).toList();
      }
    }
    stopwatch.stop();
    print('Client-side filtering 100 times took: ${stopwatch.elapsedMilliseconds} ms');
    print('Filtered items count: ${filtered.length}');

    print('By moving this logic to the server, we eliminate the need to fetch all ${allProducts.length} products to the client and completely avoid the ${stopwatch.elapsedMilliseconds} ms filtering overhead.');
  });
}
