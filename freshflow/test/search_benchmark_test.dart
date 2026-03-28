import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/cart_provider.dart';

// Create a mock repository to count function calls.
class MockProductRepository implements ProductRepository {
  int fetchProductsCount = 0;
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCount++;
    return [
      Product(id: '1', name: 'Tomato', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10, color: 'Red'),
      Product(id: '2', name: 'Spinach', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10, color: 'Green'),
    ];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCount++;
    return [
      Product(id: '1', name: 'Tomato', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10, color: 'Red'),
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCount++;
    return [
      Product(id: '1', name: 'Tomato', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10, color: 'Red'),
    ];
  }

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async {
    return [];
  }

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async {
    return [];
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    return null;
  }

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async {
    return false;
  }
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String id) => false;
  @override
  List<Product> get items => [];
  @override
  int get itemCount => 0;
  @override
  Future<void> initForUser(String? userId) async {}
  @override
  Future<void> toggleWishlist(Product product) async {}

  @override
  void addToWishlist(Product product) {}

  @override
  void clearWishlist() {}

  @override
  Future<void> loadFromStorage() async {}

  @override
  void removeFromWishlist(String productId) {}

  @override
  List<Product> get wishlist => [];
}

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];
  @override
  int get itemCount => 0;
  @override
  double get totalAmount => 0.0;
  @override
  double get totalSavings => 0.0;
  @override
  bool get isEmpty => true;
  @override
  Future<void> initForUser(String? userId) async {}
  @override
  Future<void> addToCart(Product product, {int quantity = 1}) async {}
  @override
  Future<void> removeFromCart(String productId) async {}
  @override
  Future<void> updateQuantity(String productId, int quantity) async {}
  @override
  Future<void> clearCart() async {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  double get totalPrice => 0.0;
}

void main() {
  testWidgets('Debounce and client-side filtering check', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    // Test debounce timer by verifying that rapid typing does not trigger many calls
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<WishlistProvider>(create: (_) => MockWishlistProvider()),
          ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
        ],
        child: MaterialApp(home: SearchScreen(productRepository: mockRepo)),
      )
    );

    // Simulate typing
    final textField = find.byType(TextField);

    await tester.enterText(textField, 't');
    await tester.pump();
    await tester.enterText(textField, 'to');
    await tester.pump();
    await tester.enterText(textField, 'tom');
    await tester.pump();

    // Wait for debounce timer (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Due to the updated debounce logic, searchProducts should be called only once
    expect(mockRepo.searchProductsCount, 1);
    expect(mockRepo.fetchProductsCount, 0); // Not using fetch all anymore!
  });
}
