import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockCartProvider extends CartProvider {
  @override
  int get itemCount => 0;
}

class MockWishlistProvider extends WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;
}

int fetchProductsCount = 0;
int searchProductsCount = 0;
int searchByColorCount = 0;

class MockProductRepository implements ProductRepository {
  final List<Product> dummyProducts = List.generate(
    1000,
    (i) => Product(
      id: 'id_$i',
      name: 'Product $i ${i % 2 == 0 ? "Red" : "Green"}',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 20,
      harvestTime: 'Today',
      stock: 10,
    ),
  );

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    return dummyProducts;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    return dummyProducts.where((p) => p.name.toLowerCase().contains(query.toLowerCase())).toList();
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchByColorCount++;
    await Future.delayed(const Duration(milliseconds: 50));
    return dummyProducts.where((p) => p.color == color).toList();
  }

  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    fetchProductsCount = 0;
    searchProductsCount = 0;
    searchByColorCount = 0;
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Search Screen optimized benchmark', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => MockWishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(repository: mockRepo),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final textField = find.byType(TextField);

    // Type 5 letters quickly with 100ms in between.
    // Debounce is 500ms, so it should only trigger ONE search at the very end.
    await tester.enterText(textField, 'A');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'Ap');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'App');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'Appl');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'Apple');

    // Wait for debounce + search delay
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    print('OPTIMIZED fetchAll products count: $fetchProductsCount');
    print('OPTIMIZED search text count: $searchProductsCount');
    print('OPTIMIZED search color count: $searchByColorCount');

    // We expect fetchProductsCount to be 0
    expect(fetchProductsCount, 0);
    // searchProductsCount to be 1
    expect(searchProductsCount, 1);
    expect(searchByColorCount, 0);
  });
}
