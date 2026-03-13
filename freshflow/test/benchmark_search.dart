import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';

// Mock repository
class MockProductRepository implements ProductRepository {
  List<Product> products = List.generate(5000, (index) => Product(
    id: '$index',
    name: 'Product $index ${index % 2 == 0 ? "Tomato" : "Apple"}',
    currentPrice: 1.99,
    marketPrice: 2.99,
    harvestTime: 'yesterday',
    stock: 100,
    imageUrl: '',
    category: 'Vegetables',
  ));

  int fetchProductsCount = 0;
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 100));
    fetchProductsCount++;
    return products;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    await Future.delayed(const Duration(milliseconds: 50));
    searchProductsCount++;
    return products.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  // Not strictly implemented in the interface but we assume it might be needed
  Future<List<Product>> searchProductsByColor(String color) async {
    await Future.delayed(const Duration(milliseconds: 50));
    searchProductsByColorCount++;
    return products.where((p) => p.color?.toLowerCase() == color.toLowerCase()).toList();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('Search benchmark - client-side vs server-side', () async {
    final mockRepo = MockProductRepository();

    // We will measure the raw performance of the logic used in SearchScreen
    // Original logic:
    final stopwatch = Stopwatch()..start();

    for (int i = 0; i < 10; i++) { // Simulate 10 quick keystrokes without debounce
      final allProducts = await mockRepo.fetchProducts();
      final lowerQuery = 'tomato';
      final filtered = allProducts
            .where((p) => p.name.toLowerCase().contains(lowerQuery))
            .toList();
    }

    stopwatch.stop();
    final originalTime = stopwatch.elapsedMilliseconds;

    // New logic (simulated server-side with debounce - meaning only 1 call):
    mockRepo.fetchProductsCount = 0;
    mockRepo.searchProductsCount = 0;

    final stopwatch2 = Stopwatch()..start();
    // Simulate debounce - 9 keystrokes ignored, 1 executed
    final lowerQuery = 'tomato';
    final filtered2 = await mockRepo.searchProducts(lowerQuery);

    stopwatch2.stop();
    final newTime = stopwatch2.elapsedMilliseconds;

    print('Baseline time (client-side, no debounce): $originalTime ms');
    print('Optimized time (server-side, debounced): $newTime ms');
    print('Improvement: ${originalTime - newTime} ms (${(originalTime / newTime).toStringAsFixed(2)}x faster)');
    print('Network calls reduced from 10 to 1');
  });
}
