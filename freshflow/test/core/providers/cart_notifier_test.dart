import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/providers/riverpod/cart_notifier.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  group('CartState', () {
    test('empty cart has zero total', () {
      const state = CartState();
      expect(state.totalPrice, 0);
      expect(state.itemCount, 0);
    });

    test('calculates total price correctly', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        imageUrl: 'https://example.com/image.jpg',
        currentPrice: 100,
        marketPrice: 150,
        harvestTime: 'Fresh',
        stock: 10,
        category: 'Test',
      );

      final state = CartState(items: [
        CartItem(product: product, quantity: 2),
      ]);

      expect(state.totalPrice, 200);
      expect(state.itemCount, 2);
    });
  });

  group('CartItem', () {
    test('serializes to JSON', () {
      final product = Product(
        id: '1',
        name: 'Test Product',
        imageUrl: 'https://example.com/image.jpg',
        currentPrice: 100,
        marketPrice: 150,
        harvestTime: 'Fresh',
        stock: 10,
        category: 'Test',
      );

      final item = CartItem(product: product, quantity: 3);
      final json = item.toJson();

      expect(json['quantity'], 3);
      expect(json['product']['id'], '1');
    });

    test('deserializes from JSON', () {
      final json = {
        'product': {
          'id': '2',
          'name': 'Another Product',
          'image_url': 'https://example.com/img.jpg',
          'current_price': 50,
          'market_price': 75,
          'harvest_time': 'Today',
          'stock': 20,
          'category': 'Demo',
        },
        'quantity': 5,
      };

      final item = CartItem.fromJson(json);

      expect(item.product.id, '2');
      expect(item.quantity, 5);
    });
  });
}
