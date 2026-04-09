import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock Classes
class MockProductRepository extends Fake implements ProductRepository {
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

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

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => []; // CartItem list
  @override
  double get totalAmount => 0.0;
  @override
  double get totalPrice => 0.0;

  @override
  Future<void> addToCart(Product product) async {}
  @override
  void clearCart() {}
  @override
  void decreaseQuantity(String productId) {}
  @override
  void removeFromCart(String productId) {}
  @override
  int get itemCount => 0;
  @override
  Future<void> loadFromStorage() async {}
  @override
  void increaseQuantity(String productId) {}
  @override
  void initForUser(String? userId) {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;
  @override
  void toggleWishlist(Product product) {}
  @override
  void addToWishlist(Product product) {}
  @override
  void clearWishlist() {}
  @override
  int get itemCount => 0;
  @override
  Future<void> loadFromStorage() async {}
  @override
  void removeFromWishlist(String productId) {}
  @override
  List<Product> get wishlist => [];
  @override
  void initForUser(String? userId) {}
}

void main() {
  late MockProductRepository mockRepository;
  late MockCartProvider mockCartProvider;
  late MockWishlistProvider mockWishlistProvider;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockProductRepository();
    mockCartProvider = MockCartProvider();
    mockWishlistProvider = MockWishlistProvider();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>.value(value: mockCartProvider),
        ChangeNotifierProvider<WishlistProvider>.value(value: mockWishlistProvider),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: mockRepository),
      ),
    );
  }

  testWidgets('Typing "apple" triggers search only ONCE after debounce (optimized)', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    final textField = find.byType(TextField);

    // Reset counts
    mockRepository.searchProductsCallCount = 0;
    mockRepository.searchProductsByColorCallCount = 0;

    // Simulate rapid typing
    await tester.enterText(textField, 'a');
    await tester.pump();
    await tester.enterText(textField, 'ap');
    await tester.pump();
    await tester.enterText(textField, 'app');
    await tester.pump();
    await tester.enterText(textField, 'appl');
    await tester.pump();
    await tester.enterText(textField, 'apple');
    await tester.pump();

    // Verify no calls yet (debounce period not elapsed)
    expect(mockRepository.searchProductsCallCount, 0);

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Expect 1 call
    expect(mockRepository.searchProductsCallCount, 1);
  });

  testWidgets('Typing "Red" triggers color search', (WidgetTester tester) async {
    await tester.pumpWidget(createTestWidget());
    final textField = find.byType(TextField);

    mockRepository.searchProductsCallCount = 0;
    mockRepository.searchProductsByColorCallCount = 0;

    // Type "Red"
    await tester.enterText(textField, 'Red');
    // Debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Expect searchProductsByColor to be called
    expect(mockRepository.searchProductsByColorCallCount, 1);
    expect(mockRepository.searchProductsCallCount, 0);
  });
}
