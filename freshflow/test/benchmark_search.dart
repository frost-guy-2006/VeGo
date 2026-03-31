import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

void main() {
  test('Benchmark Client-side filtering vs Simulated Server-side filtering',
      () {
    // Generate mock products
    final List<Product> mockProducts = List.generate(
        10000,
        (i) => Product.fromJson({
              'id': 'id_$i',
              'name': 'Mock Product $i',
              'current_price': 10.0,
              'market_price': 12.0,
              'harvest_time': 'Today',
              'stock': 100,
            }));

    // Add some "red" items
    for (int i = 0; i < 500; i++) {
      mockProducts.add(Product.fromJson({
        'id': 'red_$i',
        'name': 'Red Tomato $i',
        'current_price': 5.0,
        'market_price': 6.0,
        'harvest_time': 'Today',
        'stock': 100,
      }));
    }

    final stopwatch = Stopwatch()..start();

    // Client-side filtering approach (Baseline)
    final lowerQuery = 'red';
    List<Product> clientFiltered = [];
    String? activeColorFilter;

    if (['red', 'blue', 'green', 'orange', 'yellow'].contains(lowerQuery)) {
      activeColorFilter = lowerQuery[0].toUpperCase() + lowerQuery.substring(1);
    }

    if (activeColorFilter != null) {
      clientFiltered =
          mockProducts.where((p) => p.color == activeColorFilter).toList();
    } else {
      clientFiltered = mockProducts
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .toList();
    }
    stopwatch.stop();

    final clientTime = stopwatch.elapsedMicroseconds;

    // Simulate server side filtering
    stopwatch.reset();
    stopwatch.start();
    // Simulate a pre-filtered list returned by DB
    final List<Product> serverFiltered =
        mockProducts.where((p) => p.color == 'Red').toList();
    stopwatch.stop();
    final serverTime = stopwatch.elapsedMicroseconds;

    // ignore: avoid_print
    print(
        'Client-side filtering time: $clientTime microseconds. Found: ${clientFiltered.length}');
    // ignore: avoid_print
    print(
        'Simulated Server-side filtering time: $serverTime microseconds. Found: ${serverFiltered.length}');
  });
}
