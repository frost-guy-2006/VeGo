import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_test/flutter_test.dart' as ft;

class MockProductRepository implements ProductRepository {
  int fetchProductsCount = 0;
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  @override
  late final SupabaseClient _client;

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
  Future<Product?> fetchProductById(String id) async {
    return null;
  }

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async {
    return [];
  }

  @override
  Future<List<Product>> fetchProductsPaginated({
    int page = 0,
    int pageSize = 10,
    String? category,
  }) async {
    return [];
  }

  @override
  Future<bool> hasMoreProducts({
    int currentCount = 0,
    String? category,
  }) async {
    return false;
  }
}

class FakeSupabaseClient extends ft.Fake implements SupabaseClient {}


Widget createTestScreen(ProductRepository repo) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<CartProvider>(
          create: (_) => MockCartProvider()),
      ChangeNotifierProvider<WishlistProvider>(
          create: (_) => MockWishlistProvider()),
    ],
    child: MaterialApp(
      home: SearchScreen(productRepository: repo),
    ),
  );
}

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
  @override
  void dispose() {}
  @override
  void notifyListeners() {}
  @override
  bool get hasListeners => false;

  @override
  void addToCart(Product product) {}

  @override
  void clearCart() {}

  @override
  List<CartItem> get items => [];

  @override
  double get totalPrice => 0.0;

  @override
  void decreaseQuantity(String productId) {}

  @override
  void removeFromCart(String productId) {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  void addListener(VoidCallback listener) {}
  @override
  void removeListener(VoidCallback listener) {}
  @override
  void dispose() {}
  @override
  void notifyListeners() {}
  @override
  bool get hasListeners => false;

  @override
  Future<void> loadFromStorage() async {}

  @override
  bool isInWishlist(String productId) => false;

  @override
  int get itemCount => 0;

  @override
  List<Product> get wishlist => [];

  @override
  void toggleWishlist(Product product) {}

  @override
  void addToWishlist(Product product) {}

  @override
  void removeFromWishlist(String productId) {}

  @override
  void clearWishlist() {}
}

void main() {
  testWidgets('SearchScreen baseline benchmark', (WidgetTester tester) async {
    final repo = MockProductRepository();

    await tester.pumpWidget(createTestScreen(repo));

    // Initially, no search is made unless initialQuery is provided
    expect(repo.fetchProductsCount, 0);
    expect(repo.searchProductsCount, 0);
    expect(repo.searchProductsByColorCount, 0);

    // Enter some text
    await tester.enterText(find.byType(TextField), 'a');
    await tester.enterText(find.byType(TextField), 'ap');
    await tester.enterText(find.byType(TextField), 'app');
    await tester.enterText(find.byType(TextField), 'appl');
    await tester.enterText(find.byType(TextField), 'apple');

    // Due to debounce, it should not have triggered yet
    expect(repo.searchProductsCount, 0);
    expect(repo.fetchProductsCount, 0);

    // Fast forward time to trigger debounce
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Verify searchProducts was called exactly once after debounce
    expect(repo.searchProductsCount, 1);
    expect(repo.fetchProductsCount, 0); // Should no longer fetch all
    expect(repo.searchProductsByColorCount, 0);

    // Clear and verify Color search
    await tester.enterText(find.byType(TextField), 'red');

    // Fast forward to trigger debounce
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Should call searchProductsByColor once
    expect(repo.searchProductsByColorCount, 1);
  });
}
