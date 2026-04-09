import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'dart:math';

void main() {
  test('Benchmark Client-Side Filtering', () {
    // Generate 100,000 dummy products
    final random = Random(42);
    final names = [
      'Tomato',
      'Apple',
      'Banana',
      'Cucumber',
      'Carrot',
      'Spinach',
      'Strawberry',
      'Broccoli'
    ];

    final products = List.generate(100000, (i) {
      return Product.fromJson({
        'id': 'id_$i',
        'name': '${names[random.nextInt(names.length)]} $i',
        'image_url': 'url',
        'current_price': random.nextDouble() * 10,
        'market_price': random.nextDouble() * 10,
        'harvest_time': '1 day',
        'stock': 10,
        'category': 'Vegetables',
      });
    });

    final stopwatch = Stopwatch()..start();

    // Simulate what the old code did for color filtering
    final activeColorFilter = 'Red';
    final filteredColor =
        products.where((p) => p.color == activeColorFilter).toList();

    stopwatch.stop();
    print(
        'Client-side color filtering 100,000 items took: ${stopwatch.elapsedMilliseconds}ms. Found: ${filteredColor.length}');

    stopwatch.reset();
    stopwatch.start();

    // Simulate what the old code did for name filtering
    final lowerQuery = 'to'.toLowerCase();
    final filteredName = products
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();

    stopwatch.stop();
    print(
        'Client-side name filtering 100,000 items took: ${stopwatch.elapsedMilliseconds}ms. Found: ${filteredName.length}');
  });
}
