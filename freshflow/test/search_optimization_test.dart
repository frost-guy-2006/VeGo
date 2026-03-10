import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

void main() {
  test('ProductRepository methods signature check', () {
    // Pass a fake client to avoid Supabase.instance initialization check
    final repo = ProductRepository(client: FakeSupabaseClient());
    expect(repo, isNotNull);
  });

  test('Product.colorKeywords contains expected keys', () {
    expect(Product.colorKeywords.containsKey('Red'), true);
    expect(Product.colorKeywords['Red'], contains('tomato'));
    expect(Product.colorKeywords['Green'], contains('broccoli'));
    expect(Product.colorKeywords['Blue'], contains('berry'));
  });
}
