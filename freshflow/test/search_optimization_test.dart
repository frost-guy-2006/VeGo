import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock Repository
class MockProductRepository extends Fake implements ProductRepository {
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
}

void main() {
  testWidgets('SearchScreen uses optimized search and debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // 1. Text Search with Debounce
    // Type "a", "ap", "app" quickly
    await tester.enterText(textField, 'a');
    await tester.pump(); // frame
    await tester.enterText(textField, 'ap');
    await tester.pump();
    await tester.enterText(textField, 'app');
    await tester.pump();

    // Verify no immediate search (due to debounce)
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0);

    // Fast forward past debounce time
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProducts called once with "app"
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0);

    // 2. Color Search
    // Type "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProductsByColor called
    // "Red" triggers color logic
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0);
  });
}
