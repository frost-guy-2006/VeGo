import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'dart:math';

// Simulating the old client-side filter approach vs the new server-side filter approach
void main() {
  test('Benchmark Client-side vs Server-side filtering simulation', () {
    // Generate 10,000 mock product JSONs
    final random = Random(42);
    final List<Map<String, dynamic>> mockDbProducts = List.generate(10000, (i) {
      final isRed = random.nextDouble() < 0.1; // 10% are red
      return {
        'id': i.toString(),
        'name': isRed ? 'Red Tomato $i' : 'Green Spinach $i',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 10,
        'category': 'Vegetable'
      };
    });

    // 1. Client-side filtering simulation (OLD approach)
    final clientSideStart = DateTime.now();
    // 1a. Fetch ALL (simulate JSON parse)
    final allProducts = mockDbProducts.map((item) => Product.fromJson(item)).toList();
    // 1b. Filter client side
    final lowerQuery = 'tomato';
    final filteredClient = allProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    final clientSideEnd = DateTime.now();
    final clientSideTime = clientSideEnd.difference(clientSideStart).inMicroseconds;

    // 2. Server-side filtering simulation (NEW approach)
    final serverSideStart = DateTime.now();
    // 2a. Filter DB side (simulate DB query)
    final dbFiltered = mockDbProducts
        .where((item) => (item['name'] as String).toLowerCase().contains(lowerQuery))
        .toList();
    // 2b. Fetch only filtered (simulate JSON parse for few items)
    final filteredServer = dbFiltered.map((item) => Product.fromJson(item)).toList();
    final serverSideEnd = DateTime.now();
    final serverSideTime = serverSideEnd.difference(serverSideStart).inMicroseconds;

    // ignore: avoid_print
    print('Client-side filtering took: $clientSideTime µs (Returned ${filteredClient.length})');
    // ignore: avoid_print
    print('Server-side filtering took: $serverSideTime µs (Returned ${filteredServer.length})');

    // Calculate speedup
    final speedup = clientSideTime / serverSideTime;
    // ignore: avoid_print
    print('Speedup: ${speedup.toStringAsFixed(2)}x');

    expect(serverSideTime, lessThan(clientSideTime));
  });
}
