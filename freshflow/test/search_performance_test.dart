import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock class
class MockProductRepository implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  // This will track calls to searchProductsByColor once added to the interface
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [];
  }

  // Implement other methods as stubs to satisfy the implicit interface
  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;
}

void main() {
  testWidgets('SearchScreen debounces search inputs and uses optimized queries', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Simulate typing "tomato"
    await tester.enterText(textField, 't');
    await tester.pump(const Duration(milliseconds: 100)); // typing speed
    await tester.enterText(textField, 'to');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'tom');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'toma');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'tomat');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'tomato');

    // Wait for debounce (assuming 500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // For debugging/baseline check
    debugPrint('fetchProducts calls: ${mockRepo.fetchProductsCallCount}');
    debugPrint('searchProducts calls: ${mockRepo.searchProductsCallCount}');
    debugPrint('searchProductsByColor calls: ${mockRepo.searchProductsByColorCallCount}');

    // EXPECTATIONS for OPTIMIZED behavior:
    // 1. fetchProducts should NOT be called (except maybe once if initial query was passed, but here it wasn't)
    //    Actually, existing code calls fetchProducts on every performSearch.
    //    We want 0 calls to fetchProducts after optimization.
    // 2. searchProducts should be called ONCE (debounced).

    // Assertions
    expect(mockRepo.fetchProductsCallCount, 0, reason: 'Should use searchProducts instead of fetchProducts');
    expect(mockRepo.searchProductsCallCount, 1, reason: 'Should debounce calls');
  });

  testWidgets('SearchScreen uses visual search for color keywords', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Simulate typing "Red"
    await tester.enterText(textField, 'R');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'Re');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'Red');

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    debugPrint('fetchProducts calls: ${mockRepo.fetchProductsCallCount}');
    debugPrint('searchProducts calls: ${mockRepo.searchProductsCallCount}');
    debugPrint('searchProductsByColor calls: ${mockRepo.searchProductsByColorCallCount}');

    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.searchProductsByColorCallCount, 1);
  });
}
