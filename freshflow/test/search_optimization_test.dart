import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/auth_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Mock CartProvider
class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];

  @override
  double get totalPrice => 0.0;

  @override
  void addToCart(Product product) {}

  @override
  void clearCart() {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  void removeFromCart(String productId) {}
}

// Mock WishlistProvider
class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  int get itemCount => 0;

  @override
  List<Product> get wishlist => [];

  @override
  void addToWishlist(Product product) {}

  @override
  void clearWishlist() {}

  @override
  bool isInWishlist(String productId) => false;

  @override
  Future<void> loadFromStorage() async {}

  @override
  void removeFromWishlist(String productId) {}

  @override
  void toggleWishlist(Product product) {}
}

// Mock AuthProvider
class MockAuthProvider extends ChangeNotifier implements AuthProvider {
  @override
  bool get isAuthenticated => false;

  @override
  User? get currentUser => null;

  @override
  bool get isLoading => false;

  @override
  Future<void> signInWithEmail(String email, String password) async {}

  @override
  Future<void> signInWithPhone(String phoneNumber) async {}

  @override
  Future<void> signOut() async {}

  @override
  Future<void> signUpWithEmail(String email, String password) async {}

  @override
  Future<void> verifyOtp(String phoneNumber, String otp) async {}
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
  setUp(() {
     SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen uses server-side search and debouncing', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => MockWishlistProvider()),
          ChangeNotifierProvider<AuthProvider>(create: (_) => MockAuthProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    // Initial state
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);

    // Type "appl"
    await tester.enterText(find.byType(TextField), 'appl');
    await tester.pump();

    // Wait for debounce (less than 500ms) - should NOT trigger yet
    await tester.pump(const Duration(milliseconds: 200));
    expect(mockRepo.searchProductsCallCount, 0, reason: "Search triggered before debounce");

    // Type "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump();

    // Wait for debounce to complete
    await tester.pump(const Duration(milliseconds: 600));

    // Should have triggered ONCE
    expect(mockRepo.searchProductsCallCount, 1, reason: "Debounce failed or search not triggered");
    expect(mockRepo.fetchProductsCallCount, 0, reason: "Still fetching all products");

    // Type "Red" (Color search)
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 600));

    expect(mockRepo.searchProductsByColorCallCount, 1, reason: "Color search not triggered");
    expect(mockRepo.fetchProductsCallCount, 0);
  });
}
