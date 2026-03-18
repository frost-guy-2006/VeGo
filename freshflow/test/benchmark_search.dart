import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark: Search Screen Client-Side Filtering', () {
    // 1. Setup mock data simulating a large database response (10,000 items)
    final List<Map<String, dynamic>> mockDbResponse = List.generate(
      10000,
      (index) => {
        'id': index.toString(),
        'name': index % 10 == 0 ? 'Red Tomato $index' : 'Green Spinach $index',
        'image_url': '',
        'current_price': 2.0,
        'market_price': 3.0,
        'harvest_time': 'Today',
        'stock': 50,
        'category': index % 10 == 0 ? 'Fruits' : 'Vegetables',
      },
    );

    // 2. Measure the time taken by the current client-side filtering logic
    final stopwatch = Stopwatch()..start();

    // Map to Product (simulating fetchProducts)
    final allProducts = mockDbResponse.map((item) => Product.fromJson(item)).toList();

    // Simulate SearchScreen visual search logic for "red"
    String? activeColorFilter = 'Red';
    List<Product> filtered;
    if (activeColorFilter != null) {
      filtered = allProducts.where((p) => p.color == activeColorFilter).toList();
    } else {
      filtered = allProducts
          .where((p) => p.name.toLowerCase().contains('red'))
          .toList();
    }

    stopwatch.stop();

    print('Baseline client-side parsing and filtering (10,000 items) took: ${stopwatch.elapsedMilliseconds}ms');
    print('Filtered count: ${filtered.length}');

    // New optimized flow Simulation:
    // With server-side filtering, only the matched rows are returned over the network
    // Simulate server response returning only the 1000 matched rows
    final optimizedStopwatch = Stopwatch()..start();

    // Simulating `searchProductsByColor` returning 1000 parsed models directly
    final serverResponse = mockDbResponse.where((item) => item['name'].toString().toLowerCase().contains('red')).toList();
    final optimizedFiltered = serverResponse.map((item) => Product.fromJson(item)).toList();

    optimizedStopwatch.stop();
    print('Optimized server-side parsing (1000 matching items out of 10,000) took: ${optimizedStopwatch.elapsedMilliseconds}ms');

    expect(filtered.length, 1000);
    expect(optimizedFiltered.length, 1000);
  });
}
