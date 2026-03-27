import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
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
  Future<List<Product>> fetchProductsByCategory(String category) async {
    return [];
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    return null;
  }

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async {
    return [];
  }

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async {
    return false;
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

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  bool isInCart(String productId) => false;

  @override
  int get itemCount => 0;

  @override
  double get totalAmount => 0.0;

  @override
  double get totalPrice => 0.0;

  // Implement other required getters/methods as dummy
  @override
  List<CartItem> get items => [];

  @override
  Future<void> addToCart(Product product, {int quantity = 1}) async {}

  @override
  Future<void> updateQuantity(String productId, int quantity) async {}

  @override
  Future<void> removeFromCart(String productId) async {}

  @override
  Future<void> clearCart() async {}

  @override
  void initForUser(String? userId) {}

  @override
  Future<void> syncCart() async {}

  @override
  Map<String, dynamic> get itemsMap => {};

  @override
  void decreaseQuantity(String productId) {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;

  @override
  int get itemCount => 0;

  @override
  List<Product> get items => [];

  @override
  List<Product> get wishlist => [];

  @override
  Future<void> toggleWishlist(Product product) async {}

  @override
  void initForUser(String? userId) {}

  @override
  void addToWishlist(Product product) {}

  @override
  void clearWishlist() {}

  @override
  Future<void> loadFromStorage() async {}

  @override
  void removeFromWishlist(String productId) {}
}

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
        ChangeNotifierProvider<WishlistProvider>(create: (_) => MockWishlistProvider()),
      ],
      child: MaterialApp(home: widget),
    );
  }

  testWidgets('SearchScreen debounces input and calls correct repository methods', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(buildTestableWidget(SearchScreen(
      productRepository: mockRepo,
    )));

    // Ensure we are mounted
    await tester.pumpAndSettle();

    // Type rapidly
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'a');
    await tester.enterText(textField, 'ap');
    await tester.enterText(textField, 'app');
    await tester.enterText(textField, 'appl');
    await tester.enterText(textField, 'apple');

    // Timer hasn't elapsed yet
    expect(mockRepo.searchProductsCount, 0);
    expect(mockRepo.searchProductsByColorCount, 0);

    // Wait for debounce timer (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Because 'apple' is not a mapped color, it should call searchProducts
    expect(mockRepo.searchProductsCount, 1);
    expect(mockRepo.searchProductsByColorCount, 0);

    // Now try a color
    await tester.enterText(textField, 'red');

    // Wait for debounce timer
    await tester.pump(const Duration(milliseconds: 600));

    // Because 'red' is a mapped color, it should call searchProductsByColor
    expect(mockRepo.searchProductsByColorCount, 1);
    expect(mockRepo.searchProductsCount, 1); // No change

    // Notice that fetchProducts is no longer called for searching!
    expect(mockRepo.fetchProductsCount, 0);
  });
}
