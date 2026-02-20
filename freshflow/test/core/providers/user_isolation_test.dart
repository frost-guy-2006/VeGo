import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/order_provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/models/order_model.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('User Isolation Tests', () {
    test('CartProvider isolates data per user', () async {
      final provider = CartProvider();

      // User 1
      await provider.initForUser('user1');
      // Add item
      final product = Product(
        id: 'p1',
        name: 'Test Product',
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: '',
        stock: 10,
        category: 'c1',
      );
      await provider.addToCart(product);

      // Verify stored in user1 key
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('cart_items_user1'), isNotNull);
      expect(prefs.getString('cart_items_user2'), isNull);

      // Switch to User 2
      await provider.initForUser('user2');
      expect(provider.items, isEmpty);

      // Add item for User 2
      final product2 = Product(
        id: 'p2',
        name: 'Test Product 2',
        imageUrl: '',
        currentPrice: 20.0,
        marketPrice: 25.0,
        harvestTime: '',
        stock: 10,
        category: 'c1',
      );
      await provider.addToCart(product2);

      // Verify stored in user2 key
      expect(prefs.getString('cart_items_user2'), isNotNull);

      // Switch back to User 1
      await provider.initForUser('user1');
      expect(provider.items.length, 1);
      expect(provider.items.first.product.id, 'p1');
    });

    test('WishlistProvider isolates data per user', () async {
      final provider = WishlistProvider();
      final product = Product(
        id: 'p1',
        name: 'Test Product',
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: '',
        stock: 10,
        category: 'c1',
      );

      // User 1
      await provider.initForUser('user1');
      await provider.addToWishlist(product);

      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('user_wishlist_user1'), isNotNull);

      // User 2
      await provider.initForUser('user2');
      expect(provider.wishlist, isEmpty);

      // Switch back to User 1
      await provider.initForUser('user1');
      expect(provider.wishlist.length, 1);
    });

    test('OrderProvider isolates data per user', () async {
      final provider = OrderProvider();

      // Mock data for user1
      SharedPreferences.setMockInitialValues({
        'order_history_user1': '[{"id":"o1", "items":[], "totalAmount":10.0, "status":0, "createdAt":"2023-01-01T00:00:00.000", "deliveryAddress": "addr1", "deliveryFee": 0.0}]'
      });

      // User 1
      await provider.initForUser('user1');
      expect(provider.orders.length, 1);
      expect(provider.orders.first.id, 'o1');

      // User 2
      await provider.initForUser('user2');
      expect(provider.orders, isEmpty);

      // Switch back to User 1
      await provider.initForUser('user1');
      expect(provider.orders.length, 1);
    });
  });
}
