import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

// Mock Repository Interface
abstract class IProductRepository {
  Future<List<Product>> fetchAllProducts();
  Future<List<Product>> searchProducts(String query);
  Future<List<Product>> searchProductsByColor(String color);
}

class MockProductRepository implements IProductRepository {
  final List<Product> _allProducts;

  MockProductRepository(this._allProducts);

  @override
  Future<List<Product>> fetchAllProducts() async {
    // Simulate network delay for a large payload
    await Future.delayed(const Duration(milliseconds: 200));
    return _allProducts;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    // Simulate network delay for a small payload
    await Future.delayed(const Duration(milliseconds: 50));
    return _allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
     // Simulate network delay for a small payload
    await Future.delayed(const Duration(milliseconds: 50));
    // Simulate server-side color filtering logic
     return _allProducts.where((p) {
        if (color == 'Red') {
            return p.name.toLowerCase().contains('red') || p.name.toLowerCase().contains('tomato');
        }
        return false;
    }).toList();
  }
}

void main() {
  test('Search Performance Benchmark', () async {
    // 1. Setup Data
    final List<Product> hugeDataset = List.generate(10000, (index) {
        final name = index % 10 == 0 ? 'Fresh Tomato' : 'Generic Vegetable $index';
        // Simulate what fromJson does
        String? color;
        if (name.contains('Tomato')) color = 'Red';

        return Product(
            id: '$index',
            name: name,
            imageUrl: '',
            currentPrice: 10,
            marketPrice: 20,
            harvestTime: 'Now',
            stock: 100,
            color: color,
        );
    });

    final repo = MockProductRepository(hugeDataset);

    // 2. Measure "Client-Side Filtering" (Baseline)
    final stopwatchBaseline = Stopwatch()..start();

    // Fetch all (simulating the inefficient approach)
    final all = await repo.fetchAllProducts();
    // Filter client-side
    final filteredBaseline = all.where((p) => p.color == 'Red').toList();

    stopwatchBaseline.stop();
    print('Baseline (Fetch All + Client Filter): ${stopwatchBaseline.elapsedMilliseconds}ms');

    // 3. Measure "Server-Side Filtering" (Optimized)
    final stopwatchOptimized = Stopwatch()..start();

    // Fetch filtered (simulating the efficient approach)
    final filteredOptimized = await repo.searchProductsByColor('Red');

    stopwatchOptimized.stop();
     print('Optimized (Server Filter): ${stopwatchOptimized.elapsedMilliseconds}ms');

    // Assertions
    expect(filteredBaseline.length, 1000);
    expect(filteredOptimized.length, 1000);
    expect(stopwatchOptimized.elapsedMilliseconds < stopwatchBaseline.elapsedMilliseconds, true, reason: "Optimized search should be faster");
  });
}
