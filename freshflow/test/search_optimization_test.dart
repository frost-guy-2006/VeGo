import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock implementation of ProductRepository to track calls
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
  testWidgets('SearchScreen optimizes search calls', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Simulate typing "Red" rapidly
    await tester.enterText(textField, 'R');
    await tester.pump(const Duration(milliseconds: 100)); // less than debounce
    await tester.enterText(textField, 'Re');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 100));

    // Verify no calls yet (debounce is 500ms)
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.searchProductsByColorCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0); // Should never be called

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // "Red" is a color keyword, so searchProductsByColor should be called
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0); // Optimization verified: fetchAll not called
  });

  testWidgets('SearchScreen uses text search for non-color terms', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Simulate typing "Apple"
    await tester.enterText(textField, 'Apple');
    await tester.pump(const Duration(milliseconds: 600));

    // "Apple" is not a color keyword (it's a mapped keyword FOR Red, but not a color name itself like "Red")

    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.searchProductsByColorCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0);
  });

  testWidgets('SearchScreen handles Blue search correctly (returns empty)', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Simulate typing "Blue"
    await tester.enterText(textField, 'Blue');
    await tester.pump(const Duration(milliseconds: 600));

    expect(mockRepo.searchProductsByColorCallCount, 1);
    // Since mock returns [], it should show "No items found".
    expect(find.text('No items found'), findsOneWidget);
  });
}
