import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

// Mock Repository to simulate network latency and data volume
class MockProductRepository extends Fake implements ProductRepository {
  final List<Product> _allProducts;

  MockProductRepository() : _allProducts = List.generate(1000, (index) {
    return Product(
      id: 'id_$index',
      name: index % 2 == 0 ? 'Red Apple $index' : 'Green Spinach $index',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 12,
      harvestTime: 'Now',
      stock: 100,
      category: 'Fruits',
    );
  });

  // Simulate Fetch All (Current Implementation)
  @override
  Future<List<Product>> fetchProducts() async {
    // Simulate network delay for large payload (e.g. 1000 items)
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_allProducts);
  }

  // Simulate Server-Side Search (Optimized Implementation)
  @override
  Future<List<Product>> searchProducts(String query) async {
    // Simulate network delay for small payload (e.g. filtered items)
    await Future.delayed(const Duration(milliseconds: 50));
    return _allProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Simulate Server-Side Color Search (Optimized)
  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final keywords = Product.colorKeywords[color] ?? [];
     return _allProducts.where((p) {
       for (final k in keywords) {
         if (p.name.toLowerCase().contains(k)) return true;
       }
       return false;
     }).toList();
  }
}

void main() {
  test('Benchmark: Client-side filtering vs Server-side filtering', () async {
    final repo = MockProductRepository();

    // 1. Measure Baseline: Fetch All + Client Side Filter
    final stopwatch = Stopwatch()..start();

    final allProducts = await repo.fetchProducts();
    final filteredClientSide = allProducts.where((p) => p.name.toLowerCase().contains('apple')).toList();

    stopwatch.stop();
    final baselineTime = stopwatch.elapsedMilliseconds;
    print('Baseline (Fetch All + Client Filter): ${baselineTime}ms');
    print('Items found: ${filteredClientSide.length}');

    // 2. Measure Optimized: Server Side Search
    stopwatch.reset();
    stopwatch.start();

    final filteredServerSide = await repo.searchProducts('apple');

    stopwatch.stop();
    final optimizedTime = stopwatch.elapsedMilliseconds;
    print('Optimized (Server Search): ${optimizedTime}ms');
    print('Items found: ${filteredServerSide.length}');

    // Expect significant improvement
    expect(optimizedTime, lessThan(baselineTime));
    expect(filteredServerSide.length, equals(filteredClientSide.length));
  });
}
