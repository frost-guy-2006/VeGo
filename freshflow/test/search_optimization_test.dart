import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock ProductRepository
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
  testWidgets('SearchScreen optimizes search with debounce and server-side filtering', (WidgetTester tester) async {
    // Setup
    SharedPreferences.setMockInitialValues({});
    final mockRepo = MockProductRepository();

    // Pump widget
    // We pass the mock repository to the SearchScreen (after refactor)
    await tester.pumpWidget(
      MaterialApp(
        home: SearchScreen(productRepository: mockRepo),
      ),
    );

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // --- Test 1: Debounce & Text Search ---
    // Type 'bread' which shouldn't trigger color search
    await tester.enterText(textField, 'bread');
    await tester.pump(); // Rebuild with new text, timer starts

    // Should NOT call immediately (debounce)
    expect(mockRepo.fetchProductsCallCount, 0, reason: "Should not fetch all products");
    expect(mockRepo.searchProductsCallCount, 0, reason: "Should debounce search");

    // Fast forward 500ms
    await tester.pump(const Duration(milliseconds: 500));

    // Should call searchProducts
    expect(mockRepo.searchProductsCallCount, 1, reason: "Should call searchProducts after debounce");
    expect(mockRepo.fetchProductsCallCount, 0, reason: "Should NOT call fetchProducts (fetch all)");
    expect(mockRepo.searchProductsByColorCallCount, 0);

    // --- Test 2: Color Search ---
    // Type 'red' which triggers visual search
    await tester.enterText(textField, 'red');
    await tester.pump(); // Timer restart

    await tester.pump(const Duration(milliseconds: 500)); // Wait for debounce

    // Should call searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1, reason: "Should detect 'red' and call searchProductsByColor");
    // searchProductsCallCount should stay at 1 (from previous test)
    expect(mockRepo.searchProductsCallCount, 1);
  });
}
