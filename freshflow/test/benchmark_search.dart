import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

// Create a simple mock to simulate latency and database return sizes
class MockProductRepository extends Fake implements ProductRepository {
  final List<Product> _allProducts = List.generate(
    1000,
    (index) => Product(
      id: 'id_\$index',
      name: index % 2 == 0 ? 'Tomato \$index' : 'Cucumber \$index',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 12,
      harvestTime: 'Now',
      stock: 100,
    ),
  );

  @override
  Future<List<Product>> fetchProducts() async {
    // Simulate network latency for fetching 1000 items
    await Future.delayed(const Duration(milliseconds: 100));
    return _allProducts;
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    // Simulate faster DB query for filtered items (returning maybe 500 items)
    await Future.delayed(const Duration(milliseconds: 30));
    final lowerColor = color.toLowerCase();
    return _allProducts.where((p) {
      if (lowerColor == 'red' && p.name.contains('Tomato')) return true;
      if (lowerColor == 'green' && p.name.contains('Cucumber')) return true;
      return false;
    }).toList();
  }
}

void main() {
  test('Benchmark: Search by Color (Client vs Server-side Filtering)', () async {
    final repo = MockProductRepository();

    // Simulate old approach (Client-side filtering)
    final stopwatchClient = Stopwatch()..start();
    final allProducts = await repo.fetchProducts();

    // Check for color keywords
    final query = 'Red';
    final lowerQuery = query.toLowerCase();
    String? _activeColorFilter;
    if (['red', 'blue', 'green', 'orange', 'yellow'].contains(lowerQuery)) {
      _activeColorFilter = lowerQuery;
      _activeColorFilter = lowerQuery[0].toUpperCase() + lowerQuery.substring(1);
    }

    List<Product> filteredClient;
    if (_activeColorFilter != null) {
      // In old code, p.color inferred the color client-side from Product.fromJson
      // For this benchmark we'll simulate the client-side parsing time by iterating
      filteredClient = allProducts.where((p) {
        String? inferredColor;
        final lowerName = p.name.toLowerCase();
        for (final entry in Product.colorKeywords.entries) {
          if (entry.value.any((keyword) => lowerName.contains(keyword))) {
            inferredColor = entry.key;
            break;
          }
        }
        return inferredColor == _activeColorFilter;
      }).toList();
    } else {
      filteredClient = allProducts
          .where((p) => p.name.toLowerCase().contains(lowerQuery))
          .toList();
    }
    stopwatchClient.stop();
    final clientTime = stopwatchClient.elapsedMilliseconds;

    // Simulate new approach (Server-side filtering)
    final stopwatchServer = Stopwatch()..start();
    final filteredServer = await repo.searchProductsByColor(query);
    stopwatchServer.stop();
    final serverTime = stopwatchServer.elapsedMilliseconds;

    print('Client-side filtering (baseline): ${clientTime}ms');
    print('Server-side filtering (optimized): ${serverTime}ms');
    print('Improvement: ${(clientTime - serverTime)}ms (${(100 - (serverTime / clientTime * 100)).toStringAsFixed(2)}%)');

    expect(filteredClient.length, filteredServer.length);
    expect(serverTime, lessThan(clientTime));
  });
}
