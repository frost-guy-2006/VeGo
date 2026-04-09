import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];

  @override
  double get totalPrice => 0.0;

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

// Define a Fake Client to pass into the repository to avoid Supabase.instance lookup
class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    // Return dummy list
    return [
      Product(
        id: '1',
        name: 'Tomato',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Today',
        stock: 100,
      ),
      Product(
        id: '2',
        name: 'Potato',
        imageUrl: '',
        currentPrice: 5,
        marketPrice: 6,
        harvestTime: 'Yesterday',
        stock: 200,
      ),
    ];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    return [];
  }

  // To be tested after optimization
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [];
  }
}

void main() {
  testWidgets('SearchScreen fetches products efficiently with debounce (Optimized)', (WidgetTester tester) async {
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
    expect(mockRepo.searchProductsCallCount, 0);

    // Enter "t"
    await tester.enterText(find.byType(TextField), 't');
    await tester.pump();

    // Enter "o"
    await tester.enterText(find.byType(TextField), 'to');
    await tester.pump();

    // Enter "m"
    await tester.enterText(find.byType(TextField), 'tom');
    await tester.pump();

    // Because of debounce, it should not have searched yet
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for the debounce timer (500ms) to trigger
    await tester.pumpAndSettle(const Duration(milliseconds: 550));

    // Now it should have called the targeted search ONCE, not multiple times
    expect(mockRepo.searchProductsCallCount, 1);

    // And it should NOT have called the inefficient fetchProducts
    expect(mockRepo.fetchProductsCallCount, 0);
  });

  testWidgets('SearchScreen uses searchProductsByColor for color keywords', (WidgetTester tester) async {
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

    // Type a color
    await tester.enterText(find.byType(TextField), 'red');
    await tester.pumpAndSettle(const Duration(milliseconds: 550));

    // Verify it called searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0);
  });
}
