import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock ProductRepository
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

// Mock CartProvider
class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];

  @override
  void addToCart(Product product) {}

  @override
  double get totalAmount => 0;

  @override
  int get itemCount => 0;

  @override
  void removeFromCart(String productId) {}

  @override
  void clearCart() {}

  @override
  void updateQuantity(String productId, int quantity) {}

  @override
  bool isInCart(String productId) => false;

  @override
  void decreaseQuantity(String productId) {}

  @override
  double get totalPrice => 0.0;
}

// Mock WishlistProvider
class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  List<Product> get items => [];

  @override
  bool isInWishlist(String productId) => false;

  @override
  void toggleWishlist(Product product) {}

  @override
  int get itemCount => 0;

  @override
  void clearWishlist() {}

  @override
  void addToWishlist(Product product) {}

  @override
  Future<void> loadFromStorage() async {}

  @override
  void removeFromWishlist(String productId) {}

  @override
  List<Product> get wishlist => [];
}

void main() {
  late MockProductRepository mockRepo;
  late MockCartProvider mockCartProvider;
  late MockWishlistProvider mockWishlistProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepo = MockProductRepository();
    mockCartProvider = MockCartProvider();
    mockWishlistProvider = MockWishlistProvider();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: mockCartProvider),
        ChangeNotifierProvider<WishlistProvider>.value(value: mockWishlistProvider),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: mockRepo),
      ),
    );
  }

  testWidgets('Typing in search triggers searchProducts (optimized)', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter text
    await tester.enterText(find.byType(TextField), 'apple');
    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Verify optimized calls
    expect(mockRepo.fetchProductsCallCount, 0, reason: 'Should not fetch all products');
    expect(mockRepo.searchProductsCallCount, 1, reason: 'Should search products by name');
  });

  testWidgets('Typing "Red" triggers searchProductsByColor (optimized)', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter "Red"
    await tester.enterText(find.byType(TextField), 'Red');
    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Verify optimized calls
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsByColorCallCount, 1, reason: 'Should search products by color');
  });

  testWidgets('Rapid typing triggers only one call (debounce)', (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Enter "a"
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 100)); // Less than 500ms

    // Enter "ap"
    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pump(const Duration(milliseconds: 100));

    // Enter "app"
    await tester.enterText(find.byType(TextField), 'app');
    // Wait for full debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Should have only one call
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0);
  });
}
