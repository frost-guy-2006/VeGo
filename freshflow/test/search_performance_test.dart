import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock Repository
class MockProductRepository implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
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

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<Product?> fetchProductById(String id) async => null;
}

void main() {
  setUpAll(() {
     SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Optimized: Rapid typing triggers single fetch with debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Simulate typing "Tomato"
    await tester.enterText(textField, 'T');
    await tester.pump();

    await tester.enterText(textField, 'To');
    await tester.pump();

    await tester.enterText(textField, 'Tom');
    await tester.pump();

    await tester.enterText(textField, 'Toma');
    await tester.pump();

    await tester.enterText(textField, 'Tomat');
    await tester.pump();

    await tester.enterText(textField, 'Tomato');
    await tester.pump();

    // Debounce is 500ms. Pump for 600ms to trigger it.
    await tester.pump(const Duration(milliseconds: 600));

    debugPrint('fetchProducts called ${mockRepo.fetchProductsCallCount} times');
    debugPrint('searchProducts called ${mockRepo.searchProductsCallCount} times');

    // Expect 0 calls to fetchProducts (deprecated path)
    expect(mockRepo.fetchProductsCallCount, equals(0));

    // Expect 1 call to searchProducts (optimized path)
    expect(mockRepo.searchProductsCallCount, equals(1));
  });

  testWidgets('Optimized: Color search uses server-side color filtering', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Simulate typing "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Expect searchProductsByColor called
    expect(mockRepo.searchProductsByColorCallCount, equals(1));
    expect(mockRepo.searchProductsCallCount, equals(0));
  });
}
