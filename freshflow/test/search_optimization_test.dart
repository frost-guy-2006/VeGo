import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock Providers
class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  void addToCart(Product p) {}

  @override
  List<CartItem> get items => [];

  @override
  double get totalAmount => 0;

  @override
  int get itemCount => 0;

  @override
  void removeFromCart(String id) {}

  @override
  void clearCart() {}

  @override
  void removeSingleItem(String id) {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  double get totalPrice => 0.0;
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String id) => false;

  @override
  void toggleWishlist(Product p) {}

  @override
  List<Product> get items => [];

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

  @override
  List<Product> get wishlist => [];
}

class MockProductRepository implements ProductRepository {
  final List<String> log = [];

  @override
  Future<List<Product>> fetchProducts() async {
    log.add('fetchProducts');
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    log.add('searchProducts: $query');
    return [
      Product(id: '1', name: 'Test Product', imageUrl: 'http://example.com/img.jpg', currentPrice: 10, marketPrice: 20, harvestTime: 'Now', stock: 10)
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    log.add('searchProductsByColor: $color');
    return [
      Product(id: '2', name: 'Red Apple', imageUrl: 'http://example.com/img.jpg', currentPrice: 10, marketPrice: 20, harvestTime: 'Now', stock: 10)
    ];
  }

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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    // Mock HttpOverrides
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('SearchScreen uses debounce and optimized search methods', (WidgetTester tester) async {
    // Set screen size to avoid layout errors
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

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

    // Type "apple"
    await tester.enterText(textField, 'apple');
    await tester.pump(); // Rebuild with new text

    // Check that no search happened yet (debounce)
    expect(mockRepo.log, isEmpty);

    // Fast forward time by 500ms
    await tester.pump(const Duration(milliseconds: 500));

    // Now search should have happened
    expect(mockRepo.log, contains('searchProducts: apple'));
    expect(mockRepo.log, isNot(contains('fetchProducts')));

    // Clear log
    mockRepo.log.clear();

    // Type "Red" (Color search)
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.log, contains('searchProductsByColor: Red'));
    expect(mockRepo.log, isNot(contains('fetchProducts')));

    // Cleanup
    addTearDown(tester.view.resetPhysicalSize);
  });
}

// Mock HttpOverrides
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (cert, host, port) => true;
  }
}
