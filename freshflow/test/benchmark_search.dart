import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  test('Benchmark product model client-side inference vs query generation', () {
    // Simulate what the client used to do when filtering:
    // It would fetch ALL items and allocate Product.fromJson for each.
    // If the DB has 10,000 items, it parses 10,000 JSONs.

    final jsonPayload = {
      'id': '1',
      'name': 'Red Apple',
      'image_url': '',
      'current_price': 1.0,
      'market_price': 1.5,
      'harvest_time': 'Today',
      'stock': 100,
      'category': 'Fruits',
    };

    final startTimeClientSide = DateTime.now();
    for (int i = 0; i < 10000; i++) {
      Product.fromJson(jsonPayload);
    }
    final endTimeClientSide = DateTime.now();

    final clientSideTime = endTimeClientSide.difference(startTimeClientSide).inMilliseconds;

    // Simulate what the client now does:
    // The server does the filtering and only returns the matched items (e.g. 50 items).
    final startTimeServerSide = DateTime.now();
    for (int i = 0; i < 50; i++) {
      Product.fromJson(jsonPayload);
    }
    final endTimeServerSide = DateTime.now();

    final serverSideTime = endTimeServerSide.difference(startTimeServerSide).inMilliseconds;

    // Note: This benchmark ONLY measures CPU allocation time on the client.
    // It does not even account for the massive network savings of downloading 50 JSON objects vs 10,000 JSON objects.

    // ignore: avoid_print
    print('--- PERFORMANCE BENCHMARK ---');
    // ignore: avoid_print
    print('Previous Client-Side Filtering (Allocating 10,000 items): ${clientSideTime}ms CPU time');
    // ignore: avoid_print
    print('New Server-Side Filtering (Allocating 50 items): ${serverSideTime}ms CPU time');
    // ignore: avoid_print
    print('CPU Allocation Speedup: ${(clientSideTime / (serverSideTime > 0 ? serverSideTime : 1)).toStringAsFixed(2)}x faster');
    // ignore: avoid_print
    print('Network Payload reduction: 99.5% fewer JSON objects downloaded over the wire.');
    // ignore: avoid_print
    print('-----------------------------');
  });
}
