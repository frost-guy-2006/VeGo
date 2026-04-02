import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock ProductRepository to verify method calls
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [
      Product(
        id: '1',
        name: 'Red Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 100,
      ),
      Product(
        id: '2',
        name: 'Green Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 100,
      ),
    ];
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
}

void main() {
  testWidgets('SearchScreen calls optimized search methods',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(
        productRepository: mockRepo,
      ),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Test 1: Color Search "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump(); // trigger onChanged

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(mockRepo.fetchProductsCallCount, 0,
        reason: 'Should NOT call fetchProducts anymore');
    expect(mockRepo.searchProductsByColorCallCount, 1,
        reason: 'Should call searchProductsByColor for "Red"');
    expect(mockRepo.searchProductsCallCount, 0);

    // Test 2: Text Search "Apple"
    await tester.enterText(textField, 'Apple');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(mockRepo.searchProductsCallCount, 1,
        reason: 'Should call searchProducts for "Apple"');
    // Note: searchProductsByColorCallCount stays 1 from previous test
  });
}
