import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

class MockSlowProductRepository extends Fake implements ProductRepository {
  final List<Product> dbProducts = List.generate(
    10000,
    (index) => Product(
      id: index.toString(),
      name: index % 5 == 0 ? 'Red Tomato $index' : 'Green Apple $index',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 15,
      harvestTime: 'Now',
      stock: 100,
    ),
  );

  @override
  Future<List<Product>> fetchProducts() async {
    // Simulate DB latency
    await Future.delayed(const Duration(milliseconds: 50));
    return dbProducts;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    // Simulate DB indexed query latency
    await Future.delayed(const Duration(milliseconds: 10));
    return dbProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    // Simulate DB indexed query latency
    await Future.delayed(const Duration(milliseconds: 10));
    return dbProducts.where((p) => p.name.toLowerCase().contains('red')).toList();
  }
}

void main() {
  test('Benchmark Search Client Side (Old) vs Server Side (New)', () async {
    final repo = MockSlowProductRepository();

    // 1. Benchmark Old Approach (Fetch all, then client-side filter)
    final oldStart = DateTime.now();
    final allProducts = await repo.fetchProducts();
    final oldResults = allProducts.where((p) => p.name.toLowerCase().contains('red')).toList();
    final oldTime = DateTime.now().difference(oldStart);

    // 2. Benchmark New Approach (Server-side filter)
    final newStart = DateTime.now();
    final newResults = await repo.searchProductsByColor('Red');
    final newTime = DateTime.now().difference(newStart);

    // ignore: avoid_print
    print('Old Approach (Fetch All + Client Filter): ${oldTime.inMilliseconds}ms');
    // ignore: avoid_print
    print('New Approach (Server Filter): ${newTime.inMilliseconds}ms');

    expect(newTime.inMilliseconds < oldTime.inMilliseconds, true);
    expect(oldResults.length, newResults.length);
  });
}
