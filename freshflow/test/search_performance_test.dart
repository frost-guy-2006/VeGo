import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Manual Mock
class MockProductRepository implements ProductRepository {
  int searchCallCount = 0;
  String? lastSearchQuery;
  int colorSearchCallCount = 0;
  String? lastColorQuery;
  int fetchAllCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchAllCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCallCount++;
    lastSearchQuery = query;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    colorSearchCallCount++;
    lastColorQuery = color;
    return [];
  }

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
  setUpAll(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Search debounces and uses optimized query', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter "a"
    await tester.enterText(textField, 'a');
    await tester.pump();

    // Should NOT search yet (debounce) or calling fetchAll
    // Note: If debounce is NOT implemented yet, this assertion might fail (if we were testing TDD style),
    // but here we are implementing the test to verify our FUTURE implementation.
    // If we run this now, it might fail (because currently it searches immediately and calls fetchProducts).
    expect(mockRepo.searchCallCount, 0, reason: 'Should not search immediately');
    expect(mockRepo.fetchAllCallCount, 0, reason: 'Should not fetch all products');

    // Enter "app"
    await tester.enterText(textField, 'app');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Now it should have searched
    expect(mockRepo.searchCallCount, 1, reason: 'Should have searched after debounce');
    expect(mockRepo.lastSearchQuery, 'app');
    expect(mockRepo.fetchAllCallCount, 0, reason: 'Should use optimized search');
  });

  testWidgets('Color search uses optimized query', (WidgetTester tester) async {
     final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    // Should use searchProductsByColor
    expect(mockRepo.colorSearchCallCount, 1, reason: 'Should use color search');
    expect(mockRepo.lastColorQuery, 'Red');
    expect(mockRepo.fetchAllCallCount, 0);
  });
}
