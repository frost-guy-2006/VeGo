import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/order_provider.dart';

void main() {
  group('User Isolation Tests', () {
    late Product testProduct;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      testProduct = Product(
        id: 'p1',
        name: 'Test Product',
        imageUrl: 'test.png',
        currentPrice: 100,
        marketPrice: 120,
        harvestTime: 'Now',
        stock: 10,
        category: 'test',
        color: 'green',
      );
    });

    test('CartProvider isolates data between users', () async {
      final provider = CartProvider();

      // User 1
      await provider.initForUser('user1');
      await provider.addToCart(testProduct);
      expect(provider.items.length, 1);

      // User 2
      await provider.initForUser('user2');
      expect(provider.items.length, 0);

      // User 1 again
      await provider.initForUser('user1');
      expect(provider.items.length, 1);
    });

    test('WishlistProvider isolates data between users', () async {
      final provider = WishlistProvider();

      // User 1
      await provider.initForUser('user1');
      await provider.addToWishlist(testProduct);
      expect(provider.itemCount, 1);

      // User 2
      await provider.initForUser('user2');
      expect(provider.itemCount, 0);

      // User 1 again
      await provider.initForUser('user1');
      expect(provider.itemCount, 1);
    });

     test('OrderProvider isolates data between users', () async {
      final provider = OrderProvider();

      // Manually inject data into SharedPreferences to verify loading for user1
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('order_history_user1', '[{"id":"o1", "items":[], "totalAmount":100, "deliveryFee": 10.0, "status":4, "createdAt":"2023-01-01T00:00:00.000", "deliveryAddress":"addr1"}]');

      // User 1
      await provider.initForUser('user1');
      expect(provider.orderCount, 1);

      // User 2
      await provider.initForUser('user2');
      expect(provider.orderCount, 0);

      // User 1 again
      await provider.initForUser('user1');
      expect(provider.orderCount, 1);
    });

    test('CartProvider handles anonymous user correctly', () async {
      final provider = CartProvider();

      // Anonymous
      await provider.initForUser(null);
      await provider.addToCart(testProduct);
      expect(provider.items.length, 1);

      // User 1
      await provider.initForUser('user1');
      expect(provider.items.length, 0);

      // Anonymous again
      await provider.initForUser(null);
      expect(provider.items.length, 1);
    });
  });
}
