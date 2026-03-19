import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

// Create mock data generator
List<Map<String, dynamic>> generateMockProducts(int count) {
  final random = Random(42);
  final names = ['Tomato', 'Carrot', 'Spinach', 'Broccoli', 'Apple', 'Banana', 'Orange', 'Potato', 'Onion', 'Cucumber', 'Milk', 'Bread', 'Egg'];
  return List.generate(count, (index) {
    final name = names[random.nextInt(names.length)];
    return {
      'id': index.toString(),
      'name': '$name $index',
      'image_url': 'http://example.com/img$index.jpg',
      'current_price': 10.0 + random.nextInt(50),
      'market_price': 20.0 + random.nextInt(60),
      'harvest_time': 'Today',
      'stock': random.nextInt(100),
      'category': 'Fresh',
    };
  });
}

void main() {
  test('Benchmark Client Side Filtering', () {
    final mockJson = generateMockProducts(5000); // simulate 5000 items in db
    final lowerQuery = 'red';

    final stopwatch = Stopwatch()..start();

    // Simulate current behavior
    final allProducts = mockJson.map((item) => Product.fromJson(item)).toList();
    List<Product> filtered;

    // In current behavior it checks if 'red' is in colorKeywords list, else lowerQuery
    filtered = allProducts.where((p) => p.color == 'Red').toList();

    stopwatch.stop();
    print('Client-side parsing & filtering 5000 items took: ${stopwatch.elapsedMilliseconds} ms');
    print('Found ${filtered.length} items');
  });

  test('Benchmark Server Side Filtering Simulation', () {
    final mockJson = generateMockProducts(5000);

    final stopwatch = Stopwatch()..start();

    // Simulate what server returns (only matching items)
    // We do it before mapping because Supabase does it at DB level
    final serverFilteredJson = mockJson.where((json) {
       final name = (json['name'] as String).toLowerCase();
       return name.contains('tomato') || name.contains('apple') || name.contains('strawberry');
    }).toList();

    // Map only returned items
    final filtered = serverFilteredJson.map((item) => Product.fromJson(item)).toList();

    stopwatch.stop();
    print('Server-side (simulated) fetching & parsing matching items took: ${stopwatch.elapsedMilliseconds} ms');
    print('Found ${filtered.length} items');
  });
}
