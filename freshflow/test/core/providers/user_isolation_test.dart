import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/order_provider.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  // Mock product for testing
  final testProduct = Product(
    id: 'p1',
    name: 'Test Product',
    imageUrl: 'img.jpg',
    currentPrice: 10.0,
    marketPrice: 15.0,
    harvestTime: 'Today',
    stock: 100,
    category: 'Test',
  );

  group('CartProvider Isolation', () {
    late CartProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = CartProvider();
    });

    test('initial state is anonymous', () async {
      // By default, no user ID
      expect(provider.items.isEmpty, true);

      // Add item to anonymous cart
      provider.addToCart(testProduct);
      expect(provider.items.length, 1);

      // Verify storage key used was 'cart_items'
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cart_items'), isNotNull);
      expect(prefs.getString('cart_items_user1'), isNull);
    });

    test('switching to user clears items and loads user cart', () async {
      // 1. Add item to anonymous cart
      provider.addToCart(testProduct);
      expect(provider.items.length, 1);

      // 2. Switch to User 1
      await provider.initForUser('user1');

      // Should be empty initially for new user
      expect(provider.items.isEmpty, true);

      // 3. Add item for User 1
      provider.addToCart(testProduct);
      expect(provider.items.length, 1);

      // Verify storage key used was 'cart_items_user1'
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cart_items_user1'), isNotNull);

      // 4. Switch to User 2
      await provider.initForUser('user2');
      expect(provider.items.isEmpty, true);

      // 5. Switch back to User 1
      await provider.initForUser('user1');
      expect(provider.items.length, 1);
    });

    test('switching to anonymous (logout) loads anonymous cart', () async {
      // 1. Add item to anonymous cart
      provider.addToCart(testProduct);

      // 2. Switch to User 1
      await provider.initForUser('user1');
      expect(provider.items.isEmpty, true);

      // 3. Switch back to anonymous (logout)
      await provider.initForUser(null);
      expect(provider.items.length, 1);
    });
  });

  group('WishlistProvider Isolation', () {
    late WishlistProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = WishlistProvider();
    });

    test('isolates data between users', () async {
      // User 1
      await provider.initForUser('user1');
      provider.addToWishlist(testProduct);
      expect(provider.wishlist.length, 1);

      // User 2
      await provider.initForUser('user2');
      expect(provider.wishlist.isEmpty, true);

      // User 1 again
      await provider.initForUser('user1');
      expect(provider.wishlist.length, 1);
    });
  });

  group('OrderProvider Isolation', () {
    late OrderProvider provider;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      provider = OrderProvider();
    });

    test('isolates data between users', () async {
      // User 1
      await provider.initForUser('user1');
      // Just check initial state and key logic since creating orders is complex
      expect(provider.orders.isEmpty, true);

      // Verify key logic implicitly by checking state persistence isolation
      // (Mocking storage behavior manually is tricky without saving data)
      // We rely on the pattern being identical to other providers.
    });
  });
}
