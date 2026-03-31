import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

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

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Search Benchmark Test - verify debounce and server-side filtering', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => MockWishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Type rapidly to test debounce
    await tester.enterText(find.byType(TextField), 'r');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 're');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'red');

    // Wait for debounce timer (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Wait for async results
    await tester.pumpAndSettle();

    // Assert that we didn't call fetchProducts
    expect(mockRepo.fetchProductsCount, 0);

    // Assert that we called searchProductsByColor exactly once due to debounce
    // It should be searchProductsByColor since the final input was "red"
    expect(mockRepo.searchProductsByColorCount, 1);
    expect(mockRepo.searchProductsCount, 0);

    print('Search optimization confirmed: fetchProducts calls: ${mockRepo.fetchProductsCount}, searchProductsByColor calls: ${mockRepo.searchProductsByColorCount}, searchProducts calls: ${mockRepo.searchProductsCount}');
  });
}
