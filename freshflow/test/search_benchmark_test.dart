import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';

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

  // Need to implement the rest of the interface to compile
  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  dynamic get _client => throw UnimplementedError();
}

void main() {
  testWidgets('SearchScreen Performance Benchmark', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    // Initial query should be empty, so no searches yet
    expect(mockRepo.searchProductsCount, 0);

    // Type a query rapidly (e.g. typing "apple")
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'a');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'ap');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'app');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'appl');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'apple');

    // Debounce timer hasn't expired yet
    expect(mockRepo.searchProductsCount, 0);

    // Wait for the debounce to expire
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Search should have been called exactly once
    expect(mockRepo.searchProductsCount, 1);
    expect(mockRepo.searchProductsByColorCount, 0);

    // Test a color search
    await tester.enterText(textField, 'red');
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Color search should have been called
    expect(mockRepo.searchProductsCount, 1); // no new text search
    expect(mockRepo.searchProductsByColorCount, 1);
  });
}
