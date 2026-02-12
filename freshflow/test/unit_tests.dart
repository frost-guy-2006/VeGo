import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('Product Model Tests', () {
    test('Product.fromJson parses correctly', () {
      final json = {
        'id': '1',
        'name': 'Test Product',
        'image_url': 'http://example.com/image.jpg',
        'current_price': 100.0,
        'market_price': 120.0,
        'harvest_time': 'Today',
        'stock': 10
      };
      final product = Product.fromJson(json);
      expect(product.id, '1');
      expect(product.name, 'Test Product');
      expect(product.imageUrl, 'http://example.com/image.jpg');
    });

    test('Product.fromJson assigns default image for empty url', () {
      final json = {
        'id': '2',
        'name': 'Fresh Tomato',
        'image_url': '',
        'current_price': 50.0,
        'market_price': 60.0,
        'harvest_time': 'Yesterday',
        'stock': 20
      };
      final product = Product.fromJson(json);
      expect(product.name, 'Fresh Tomato');
      expect(product.imageUrl, contains('unsplash.com'));
      // Should pick up the hardcoded tomato url
    });

    test('Product.fromJson infers color correctly from name', () {
      final redProduct = Product.fromJson({'name': 'Red Apple', 'id': '1', 'current_price': 10.0, 'market_price': 10.0, 'harvest_time': '', 'stock': 1});
      expect(redProduct.color, 'Red');

      final greenProduct = Product.fromJson({'name': 'Fresh Spinach', 'id': '2', 'current_price': 10.0, 'market_price': 10.0, 'harvest_time': '', 'stock': 1});
      expect(greenProduct.color, 'Green');

      final orangeProduct = Product.fromJson({'name': 'Organic Carrots', 'id': '3', 'current_price': 10.0, 'market_price': 10.0, 'harvest_time': '', 'stock': 1});
      expect(orangeProduct.color, 'Orange');

      final otherProduct = Product.fromJson({'name': 'Milk', 'id': '4', 'current_price': 10.0, 'market_price': 10.0, 'harvest_time': '', 'stock': 1});
      expect(otherProduct.color, null);
    });
  });

  group('WishlistProvider Tests', () {
    test('Add and remove from wishlist', () async {
      SharedPreferences.setMockInitialValues({});

      final provider = WishlistProvider();
      final product = Product(
          id: '1',
          name: 'Test',
          imageUrl: 'url',
          currentPrice: 10,
          marketPrice: 20,
          harvestTime: 'Now',
          stock: 5);

      expect(provider.isInWishlist('1'), false);

      provider.toggleWishlist(product);
      expect(provider.isInWishlist('1'), true);
      expect(provider.itemCount, 1);

      provider.toggleWishlist(product);
      expect(provider.isInWishlist('1'), false);
      expect(provider.itemCount, 0);
    });
  });
}
