import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock Repository that tracks calls
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCount = 0;
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCount++;
    return [];
  }
}

void main() {
  testWidgets('SearchScreen optimizes network calls with debounce and server-side filtering',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(repository: mockRepo),
    ));

    // Verify initial state
    expect(find.text('No items found'), findsOneWidget);

    // 1. Test Text Search
    // Enter "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    // Don't pump 500ms yet, just a bit to simulate typing
    await tester.pump(const Duration(milliseconds: 100));

    // Typing more...
    await tester.enterText(find.byType(TextField), 'apple p');
    await tester.pump(const Duration(milliseconds: 100));

    // Typing more...
    await tester.enterText(find.byType(TextField), 'apple pie');

    // Now wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));
    // And wait for async search to complete
    await tester.pump();

    // Verification:
    // fetchProducts (fetch all) should NEVER be called
    expect(mockRepo.fetchProductsCount, 0, reason: 'Should not fetch all products');

    // searchProducts should be called ONCE (due to debounce)
    expect(mockRepo.searchProductsCount, 1, reason: 'Should call searchProducts once after debounce');

    // searchProductsByColor should be 0
    expect(mockRepo.searchProductsByColorCount, 0);

    // 2. Test Color Search
    // Clear and type "Red"
    await tester.enterText(find.byType(TextField), '');
    await tester.pump(const Duration(milliseconds: 600)); // clear debounce

    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    // Verification:
    // searchProductsByColor should be called
    expect(mockRepo.searchProductsByColorCount, 1, reason: 'Should detect color and use color search');

    // searchProducts should still be 1 (from previous)
    expect(mockRepo.searchProductsCount, 1);
  });
}
