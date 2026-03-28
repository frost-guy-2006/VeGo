import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';

// Mock repository to track calls
class MockProductRepository implements ProductRepository {
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

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Benchmark / Baseline: Server-side filtering and debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Simulate rapid typing
    await tester.enterText(textField, 'r');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 're');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'red');

    // Wait for the debounce timer (500ms)
    await tester.pump(const Duration(milliseconds: 500));

    // The performSearch method is async, so we wait for the microtasks
    await tester.pumpAndSettle();

    // Verify that the fetchProducts method is not called (the old inefficient way)
    expect(mockRepo.fetchProductsCount, 0, reason: 'fetchProducts should no longer be called');

    // Verify that the searchProducts/searchProductsByColor methods are called
    // Since the debounce timer is 500ms and we pumped 100ms in between, it should only be called once
    expect(mockRepo.searchProductsCount + mockRepo.searchProductsByColorCount, 1,
           reason: 'Search should only trigger once due to debounce');

    // Specifically since we searched "red", it should trigger visual search
    expect(mockRepo.searchProductsByColorCount, 1,
           reason: 'Visual search should be triggered for "red"');
  });
}
