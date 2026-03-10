import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Search filtering performance baseline (mock client vs server-side)', () async {
    // Generate a large list of mock products
    final List<Product> mockProducts = List.generate(
      10000,
      (i) => Product(
        id: 'id_$i',
        name: i % 2 == 0 ? 'Red Tomato $i' : 'Green Apple $i',
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 15.0,
        harvestTime: 'Today',
        stock: 100,
        color: i % 2 == 0 ? 'Red' : 'Green',
      ),
    );

    // Old client-side parsing behavior
    final swClient = Stopwatch()..start();
    final lowerQuery = 'red tomato';
    final List<Product> filteredClient = mockProducts
        .where((p) => p.name.toLowerCase().contains(lowerQuery))
        .toList();
    swClient.stop();
    print('Client-side iteration filtered ${filteredClient.length} items out of ${mockProducts.length} in ${swClient.elapsedMilliseconds} ms');

    // Server-side behavior
    // With server-side DB query, we process 0 extra items locally.
    final swServer = Stopwatch()..start();
    // In our new code, we don't fetch all. We just await a query.
    // For comparison, simulated query cost locally
    await Future.delayed(Duration(milliseconds: 10)); // Arbitrary API time
    swServer.stop();
    print('Server-side processing takes ${swServer.elapsedMilliseconds} ms locally, completely skipping ${mockProducts.length} client iterations + fetching.');
  });
}
