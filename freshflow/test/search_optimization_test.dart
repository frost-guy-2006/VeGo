import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  Future<void> addToCart(Product product) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;

  @override
  Future<void> toggleWishlist(Product product) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

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
  testWidgets('SearchScreen uses optimized search logic', (WidgetTester tester) async {
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

    // Initial state
    expect(mockRepo.fetchProductsCallCount, 0);

    // Enter text "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(); // Force a frame, should trigger search in unoptimized code

    // In current unoptimized code, this triggers fetchProducts immediately
    // expect(mockRepo.fetchProductsCallCount, 1);

    // With optimization, we expect:
    // 1. fetchProducts is NOT called.
    // 2. searchProducts is called (after debounce).

    // Check initial calls (should be 0 for searchProducts if debounce works, but if unoptimized it's 0 because it calls fetchProducts)
    // Actually, in unoptimized code, fetchProducts is called.
    // So if we assert fetchProductsCallCount == 0, it should FAIL currently.
    expect(mockRepo.fetchProductsCallCount, 0, reason: 'Should not fetch all products');

    // Pump for debounce duration (e.g. 500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Now searchProducts should be called
    expect(mockRepo.searchProductsCallCount, 1, reason: 'Should call searchProducts after debounce');
    expect(mockRepo.searchProductsByColorCallCount, 0);
  });

  testWidgets('SearchScreen uses color search for color keywords', (WidgetTester tester) async {
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

    // Enter text "red"
    await tester.enterText(find.byType(TextField), 'red');
    await tester.pump(const Duration(milliseconds: 600));

    expect(mockRepo.fetchProductsCallCount, 0, reason: 'Should not fetch all products');
    expect(mockRepo.searchProductsByColorCallCount, 1, reason: 'Should call searchProductsByColor for known color');
    expect(mockRepo.searchProductsCallCount, 0);
  });
}
