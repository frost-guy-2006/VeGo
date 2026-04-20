import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  group('Product Color Inference', () {
    test('Red keywords map correctly', () {
      final keywords = ['red', 'tomato', 'apple', 'strawberry'];
      for (var kw in keywords) {
        final product = Product.fromJson({
          'id': '1',
          'name': 'Fresh $kw',
          'image_url': '',
          'current_price': 10,
          'market_price': 20,
          'harvest_time': 'Now',
          'stock': 10
        });
        expect(product.color, 'Red', reason: 'Keyword $kw should map to Red');
      }
    });

    test('Green keywords map correctly', () {
      final keywords = ['green', 'spinach', 'broccoli', 'cucumber'];
      for (var kw in keywords) {
        final product = Product.fromJson({
          'id': '1',
          'name': 'Fresh $kw',
          'image_url': '',
          'current_price': 10,
          'market_price': 20,
          'harvest_time': 'Now',
          'stock': 10
        });
        expect(product.color, 'Green', reason: 'Keyword $kw should map to Green');
      }
    });

    test('Orange keywords map correctly', () {
      final keywords = ['orange', 'carrot', 'banana'];
      for (var kw in keywords) {
        final product = Product.fromJson({
          'id': '1',
          'name': 'Fresh $kw',
          'image_url': '',
          'current_price': 10,
          'market_price': 20,
          'harvest_time': 'Now',
          'stock': 10
        });
        expect(product.color, 'Orange', reason: 'Keyword $kw should map to Orange');
      }
    });

    test('Precedence: Green Apple should be Red', () {
      // Existing logic puts Red block first.
      final product = Product.fromJson({
          'id': '1',
          'name': 'Green Apple',
          'image_url': '',
          'current_price': 10,
          'market_price': 20,
          'harvest_time': 'Now',
          'stock': 10
      });
      // "Green Apple" contains "green" (Green) and "apple" (Red).
      // Red is checked first in original logic. My loop iterates over colorKeywords.
      // If colorKeywords is ordered Red, Green, Orange, then Red should win.
      expect(product.color, 'Red');
    });

    test('Unknown color returns null', () {
       final product = Product.fromJson({
          'id': '1',
          'name': 'Blueberry',
          'image_url': '',
          'current_price': 10,
          'market_price': 20,
          'harvest_time': 'Now',
          'stock': 10
      });
      expect(product.color, isNull);
    });
  });
}
