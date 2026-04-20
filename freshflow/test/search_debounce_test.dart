import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

class MockProductRepository implements ProductRepository {
  int searchCallCount = 0;
  String lastQuery = '';

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCallCount++;
    lastQuery = query;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchCallCount++;
    lastQuery = "Color: $color";
    return [];
  }

  @override
  Future<List<Product>> fetchProducts() async => [];

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
  testWidgets('SearchScreen debounces search requests', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Simulate typing "red" quickly
    await tester.enterText(textField, 'r');
    await tester.pump();
    expect(mockRepo.searchCallCount, 0);

    await tester.enterText(textField, 're');
    await tester.pump();
    expect(mockRepo.searchCallCount, 0);

    await tester.enterText(textField, 'red');
    await tester.pump();
    expect(mockRepo.searchCallCount, 0);

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 500));

    // Should have called search once
    expect(mockRepo.searchCallCount, 1);
    // 'red' matches 'Red' color keyword, so it should use color search
    expect(mockRepo.lastQuery, 'Color: Red');
  });

  testWidgets('SearchScreen calls text search for non-color queries', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'apple pie');
    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.searchCallCount, 1);
    expect(mockRepo.lastQuery, 'apple pie');
  });
}
