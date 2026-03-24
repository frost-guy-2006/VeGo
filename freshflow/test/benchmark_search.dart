import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'dart:math';

// Generate mock products
List<Product> generateMockProducts(int count) {
  final random = Random(42);
  final List<String?> colors =
      ['Red', 'Green', 'Orange', 'Yellow', 'Blue', null];
  final List<String> names = [
    'Tomato',
    'Spinach',
    'Carrot',
    'Banana',
    'Blueberry',
    'Potato'
  ];

  return List.generate(count, (index) {
    return Product(
      id: index.toString(),
      name: '${names[random.nextInt(names.length)]} $index',
      imageUrl: 'http://example.com/image.jpg',
      currentPrice: 10.0,
      marketPrice: 15.0,
      harvestTime: 'Today',
      stock: 100,
      color: colors[random.nextInt(colors.length)],
      category: 'Vegetables',
    );
  });
}

void main() {
  test('Benchmark Client-Side vs Server-Side Simulation', () {
    const int productCount = 10000;
    final allProducts = generateMockProducts(productCount);

    // Simulate Client-Side Filtering (Old Approach)
    final stopwatchClient = Stopwatch()..start();

    // Simulate fetching ALL products (which we mock here as already loaded in memory for the benchmark,
    // but in reality involves a massive network payload)
    final lowerQuery = 'red';
    List<Product> filteredClient;
    if (['red', 'blue', 'green', 'orange', 'yellow'].contains(lowerQuery)) {
      final activeColorFilter =
          lowerQuery[0].toUpperCase() + lowerQuery.substring(1);
      filteredClient =
          allProducts.where((p) => p.color == activeColorFilter).toList();
    } else {
      filteredClient = allProducts
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .toList();
    }

    stopwatchClient.stop();

    // Simulate Server-Side Filtering (New Approach)
    // Server-side filtering would only return the matched products over the network,
    // so we simulate the client just receiving the filtered list.
    final stopwatchServer = Stopwatch()..start();

    // Simulate server processing (for benchmark purposes we use the same filtering logic,
    // but the point is the client doesn't do this work or receive the huge payload)
    final matchedColor = 'Red';
    List<Product> filteredServer;

    // Simulate server returning only the filtered list
    filteredServer = allProducts.where((p) => p.color == matchedColor).toList();

    stopwatchServer.stop();

    // In a real scenario, the network transfer time of 10000 items vs 10 items
    // would be the massive bottleneck. This benchmark shows even in memory,
    // client-side filtering of everything takes time.

    // ignore: avoid_print
    print(
        'Client-Side Filtering Time (Memory Only): ${stopwatchClient.elapsedMicroseconds} us');
    // ignore: avoid_print
    print(
        'Server-Side Processing Time Simulation (Memory Only): ${stopwatchServer.elapsedMicroseconds} us');
    // ignore: avoid_print
    print(
        'NOTE: The real performance gain is in Network I/O, which drops payload from $productCount items to ${filteredServer.length} items.');

    expect(filteredClient.length, filteredServer.length);
  });
}
