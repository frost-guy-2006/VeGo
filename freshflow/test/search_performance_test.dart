import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

class MockProductRepository implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;

  // Future proofing for the update
  int searchProductsByColorCallCount = 0;
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [];
  }

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
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;
}

void main() {
  testWidgets('SearchScreen uses debounce and server-side search (optimized)', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Type "apple"
    await tester.enterText(textField, 'a');
    await tester.pump();

    await tester.enterText(textField, 'ap');
    await tester.pump();

    await tester.enterText(textField, 'app');
    await tester.pump();

    await tester.enterText(textField, 'appl');
    await tester.pump();

    await tester.enterText(textField, 'apple');
    await tester.pump();

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Verify it called searchProducts ONLY ONCE
    // and did NOT call fetchProducts

    print('fetchProducts calls: ${mockRepo.fetchProductsCallCount}');
    print('searchProducts calls: ${mockRepo.searchProductsCallCount}');

    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 1);
  });
}
