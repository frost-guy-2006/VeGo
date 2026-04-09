import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

// We will mock Supabase responses for the benchmark
class MockProductRepository extends Fake implements ProductRepository {
  final List<Map<String, dynamic>> _allProductsJson;

  MockProductRepository(this._allProductsJson);

  @override
  Future<List<Product>> fetchProducts() async {
    // Simulate network delay and JSON parsing for all products
    await Future.delayed(const Duration(milliseconds: 10));
    return _allProductsJson.map((json) => Product.fromJson(json)).toList();
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    // Simulate network delay and JSON parsing for filtered products only
    await Future.delayed(const Duration(milliseconds: 10));
    final lowerQuery = query.toLowerCase();

    // In a real scenario, the DB filters and returns fewer JSON objects
    final filteredJson = _allProductsJson.where((json) {
      final name = json['name'] as String;
      return name.toLowerCase().contains(lowerQuery);
    }).toList();

    return filteredJson.map((json) => Product.fromJson(json)).toList();
  }
}

void main() {
  test('Benchmark search performance with JSON parsing', () async {
    // Generate 10000 dummy product JSONs
    final allProductsJson = List.generate(10000, (i) {
      return {
        'id': 'id_$i',
        'name': i % 2 == 0 ? 'Red Tomato $i' : 'Green Apple $i',
        'imageUrl': '',
        'currentPrice': 1.0,
        'marketPrice': 2.0,
        'harvestTime': '',
        'stock': 10,
        'category': 'Vegetable'
      };
    });

    final repo = MockProductRepository(allProductsJson);

    final stopwatch = Stopwatch()..start();

    // Old approach: fetch all and filter
    for (int i = 0; i < 10; i++) {
      final products = await repo.fetchProducts();
      final filtered = products.where((p) => p.color == 'Red').toList();
      expect(filtered.isNotEmpty, true);
    }

    final oldTime = stopwatch.elapsedMilliseconds;
    stopwatch.reset();

    // New approach: searchProducts (filtered at DB layer)
    for (int i = 0; i < 10; i++) {
      final filtered = await repo.searchProducts('Red');
      expect(filtered.isNotEmpty, true);
    }

    final newTime = stopwatch.elapsedMilliseconds;

    // ignore: avoid_print
    print('Old approach time (with JSON parsing): ${oldTime}ms');
    // ignore: avoid_print
    print('New approach time (with JSON parsing): ${newTime}ms');
  });
}
