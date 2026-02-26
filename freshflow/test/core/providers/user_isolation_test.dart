import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Provider User Isolation Tests', () {
    final testProduct = Product(
      id: 'p1',
      name: 'Test Product',
      imageUrl: 'url',
      currentPrice: 10.0,
      marketPrice: 12.0,
      harvestTime: 'Today',
      stock: 10,
    );

    test('CartProvider isolates data for different users', () async {
      SharedPreferences.setMockInitialValues({});
      final cartProvider = CartProvider();

      // User 1
      await cartProvider.initForUser('user1');
      cartProvider.addToCart(testProduct);
      // Wait for async save
      await Future.delayed(Duration.zero);
      expect(cartProvider.items.length, 1);

      // User 2 (should be empty initially)
      await cartProvider.initForUser('user2');
      expect(cartProvider.items.length, 0);

      // Add item for User 2
      final testProduct2 = Product(
        id: 'p2',
        name: 'Test Product 2',
        imageUrl: 'url',
        currentPrice: 20.0,
        marketPrice: 22.0,
        harvestTime: 'Tomorrow',
        stock: 5,
      );
      cartProvider.addToCart(testProduct2);
      await Future.delayed(Duration.zero);
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.product.id, 'p2');

      // Switch back to User 1 (should restore User 1's cart)
      await cartProvider.initForUser('user1');
      expect(cartProvider.items.length, 1);
      expect(cartProvider.items.first.product.id, 'p1');
    });

    test('WishlistProvider isolates data for different users', () async {
      SharedPreferences.setMockInitialValues({});
      final wishlistProvider = WishlistProvider();

      // User A
      await wishlistProvider.initForUser('userA');
      wishlistProvider.addToWishlist(testProduct);
      await Future.delayed(Duration.zero);
      expect(wishlistProvider.wishlist.length, 1);

      // User B
      await wishlistProvider.initForUser('userB');
      expect(wishlistProvider.wishlist.length, 0);

      // Switch back to User A
      await wishlistProvider.initForUser('userA');
      expect(wishlistProvider.wishlist.length, 1);
      expect(wishlistProvider.wishlist.first.id, 'p1');
    });

    test('CartProvider uses anonymous key when userId is null', () async {
      SharedPreferences.setMockInitialValues({});
      final cartProvider = CartProvider();

      // Anonymous user
      await cartProvider.initForUser(null);
      cartProvider.addToCart(testProduct);
      await Future.delayed(Duration.zero);
      expect(cartProvider.items.length, 1);

      // Logged in user
      await cartProvider.initForUser('logged_in_user');
      expect(cartProvider.items.length, 0);

      // Back to anonymous
      await cartProvider.initForUser(null);
      expect(cartProvider.items.length, 1);
    });
  });
}
