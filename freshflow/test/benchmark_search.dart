import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

// Extending Fake to mock the repository
class MockProductRepository extends Fake implements ProductRepository {
  @override
  Future<List<Product>> fetchProducts() async {
    // Simulate database latency
    await Future.delayed(const Duration(milliseconds: 50));
    // Return a dummy list
    return List.generate(
        1000,
        (index) => Product(
              id: '$index',
              name: 'Product $index',
              imageUrl: 'http://example.com',
              currentPrice: 10,
              marketPrice: 20,
              harvestTime: 'Now',
              stock: 5,
              color: index % 2 == 0 ? 'Red' : 'Blue',
            ));
  }
}

void main() {
  test('Mock query vs fetchAll benchmark', () async {
    // Generate a list of 10000 dummy products to represent the DB
    final allProducts = List.generate(
        10000,
        (index) => Product(
              id: '$index',
              name: 'Product $index ${index % 5 == 0 ? 'Tomato' : ''}',
              imageUrl: 'http://example.com',
              currentPrice: 10,
              marketPrice: 20,
              harvestTime: 'Now',
              stock: 5,
              color: index % 2 == 0 ? 'Red' : 'Blue',
            ));

    // Baseline: Client-side filtering
    final sw = Stopwatch()..start();
    List<Product> filtered = [];
    final lowerQuery = 'tomato';
    for (int i = 0; i < 100; i++) { // run 100 times to amplify
      filtered = allProducts.where((p) => p.name.toLowerCase().contains(lowerQuery)).toList();
    }
    sw.stop();
    // ignore: avoid_print
    print('Baseline (client-side filtering) time: ${sw.elapsedMilliseconds} ms for ${filtered.length} items');

    // New approach: simulate server-side filtering
    // Wait, the repository already has a searchProducts method!
    // Let's check ProductRepository.searchProducts.
  });
}
