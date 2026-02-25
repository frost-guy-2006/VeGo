import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mocks
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

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];

  @override
  void addToCart(Product product) {}

  @override
  double get totalPrice => 0.0;

  @override
  void clearCart() {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  void removeFromCart(String productId) {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;

  @override
  void toggleWishlist(Product product) {}

  @override
  List<Product> get wishlist => [];

  @override
  int get itemCount => 0;

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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen uses server-side filtering and debounce', (WidgetTester tester) async {
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
    expect(mockRepo.fetchProductsCount, 0);

    // Enter text "test"
    final textField = find.byType(TextField);

    // Simulate typing
    await tester.enterText(textField, 't');
    await tester.pump();
    await tester.enterText(textField, 'te');
    await tester.pump();
    await tester.enterText(textField, 'tes');
    await tester.pump();
    await tester.enterText(textField, 'test');
    await tester.pump();

    // Fast forward time to trigger debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Verify optimization
    // 1. fetchProducts (inefficient client-side filter) should NOT be called.
    expect(mockRepo.fetchProductsCount, 0, reason: 'Should not fetch all products');

    // 2. searchProducts should be called ONCE (due to debounce).
    // Note: If debounce was not working, it would be called 4 times.
    expect(mockRepo.searchProductsCount, 1, reason: 'Should call searchProducts once');
  });

  testWidgets('SearchScreen uses server-side color search for color keywords', (WidgetTester tester) async {
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

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'red');
    await tester.pump(); // Trigger onChanged

    // Fast forward debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Verify:
    // fetchProducts should be 0.
    expect(mockRepo.fetchProductsCount, 0);
    // searchProductsByColor should be 1.
    expect(mockRepo.searchProductsByColorCount, 1);
    // searchProducts should be 0 (since it's a color keyword).
    expect(mockRepo.searchProductsCount, 0);
  });
}
