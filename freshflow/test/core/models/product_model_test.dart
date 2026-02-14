import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';

void main() {
  group('Product Model Tests', () {
    test('Product.fromJson handles missing name by defaulting to Unknown Product', () {
      final json = {
        'id': '1',
        // 'name': missing
        'image_url': 'url',
        'current_price': 10.0,
        'market_price': 20.0,
        'harvest_time': 'Now',
        'stock': 5
      };
      final product = Product.fromJson(json);
      expect(product.name, 'Unknown Product');
    });

    test('Product.fromJson handles null name by defaulting to Unknown Product', () {
      final json = {
        'id': '1',
        'name': null,
        'image_url': 'url',
        'current_price': 10.0,
        'market_price': 20.0,
        'harvest_time': 'Now',
        'stock': 5
      };
      final product = Product.fromJson(json);
      expect(product.name, 'Unknown Product');
    });
  });
}
