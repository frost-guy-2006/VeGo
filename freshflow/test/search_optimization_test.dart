import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// --- Mocks ---

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

  // Implement other members as needed (returning empty/null to satisfy interface)
  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;
}

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];
  @override
  double get totalPrice => 0;
  @override
  void addToCart(Product product) {}
  @override
  void removeFromCart(String productId) {}
  @override
  void decreaseQuantity(String productId) {}
  @override
  void clearCart() {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  List<Product> get wishlist => [];
  @override
  int get itemCount => 0;
  @override
  bool isInWishlist(String productId) => false;
  @override
  void toggleWishlist(Product product) {}
  @override
  void addToWishlist(Product product) {}
  @override
  void removeFromWishlist(String productId) {}
  @override
  void clearWishlist() {}
  @override
  Future<void> loadFromStorage() async {}
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context);
  }
}

// --- Test ---

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('SearchScreen optimization benchmark', (WidgetTester tester) async {
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

    // Initial pump
    await tester.pump();

    // Type "a"
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump();

    // Type "ap"
    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pump();

    // Type "app"
    await tester.enterText(find.byType(TextField), 'app');
    await tester.pump();

    // Wait for debounce timer (500ms) to fire
    await tester.pump(const Duration(milliseconds: 600));
    // Wait for the async search operation to complete and UI to update
    await tester.pump();

    debugPrint('fetchProducts calls: ${mockRepo.fetchProductsCount}');
    debugPrint('searchProducts calls: ${mockRepo.searchProductsCount}');

    // Optimized assertions:
    // fetchProducts (fetch all) should NEVER be called.
    expect(mockRepo.fetchProductsCount, 0, reason: 'Should NOT call fetchProducts anymore');
    // searchProducts (server-side) should be called exactly ONCE (after debounce).
    expect(mockRepo.searchProductsCount, 1, reason: 'Should utilize server-side search exactly once after debounce');
  });
}
