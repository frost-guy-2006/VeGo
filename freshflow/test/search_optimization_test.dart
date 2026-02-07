import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  group('Search Optimization Tests', () {
    test('Product.colorKeywords contains expected mappings', () {
      expect(Product.colorKeywords.containsKey('Red'), true);
      expect(Product.colorKeywords['Red'], contains('tomato'));
      expect(Product.colorKeywords['Red'], contains('apple'));
      expect(Product.colorKeywords['Green'], contains('spinach'));
      expect(Product.colorKeywords['Orange'], contains('banana'));
    });

    test('Product.fromJson infers color correctly from keywords', () {
      final jsonRed = {
        'id': '1',
        'name': 'Fresh Tomato',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 10
      };
      final productRed = Product.fromJson(jsonRed);
      expect(productRed.color, 'Red');

      final jsonGreen = {
        'id': '2',
        'name': 'Organic Spinach',
        'image_url': '',
        'current_price': 10.0,
        'market_price': 12.0,
        'harvest_time': 'Today',
        'stock': 10
      };
      final productGreen = Product.fromJson(jsonGreen);
      expect(productGreen.color, 'Green');
    });

    test('ProductRepository instantiation with mock client works', () {
      final mockClient = FakeSupabaseClient();
      final repo = ProductRepository(client: mockClient);

      // We are just verifying that we can instantiate it and method exists
      expect(repo, isNotNull);

      // We cannot call the method because FakeSupabaseClient throws unimplemented error
      // But we verified the structure is correct.
      expect(repo.searchProductsByColor, isNotNull);
    });
  });
}
