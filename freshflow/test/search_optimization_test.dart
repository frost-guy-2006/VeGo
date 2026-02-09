import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

// Fake Client for the Repository constructor if we were extending (not used with implements)
class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockProductRepository implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;
  String? lastSearchQuery;
  List<String>? lastColorKeywords;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    lastSearchQuery = query;
    return [];
  }

  // This method will be an override once added to the real repository
  Future<List<Product>> searchProductsByColor(List<String> keywords) async {
    searchProductsByColorCallCount++;
    lastColorKeywords = keywords;
    return [];
  }

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;
}

void main() {
  testWidgets('SearchScreen debounces and uses optimized search methods', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    // Pump the widget
    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // 1. Test Text Search (non-color)
    // Type "pixel"
    await tester.enterText(textField, 'p');
    await tester.pump(const Duration(milliseconds: 100)); // typing...
    await tester.enterText(textField, 'pi');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'pix');
    await tester.pump(const Duration(milliseconds: 100));

    // At this point, no search should have happened if debounce > 100ms
    // But current implementation has NO debounce, so it might have called fetchProducts 3 times.

    await tester.enterText(textField, 'pixel');
    await tester.pump(const Duration(milliseconds: 600)); // wait for debounce

    // EXPECTATIONS for OPTIMIZED behavior:
    // fetchProducts (fetch all) should NEVER be called.
    expect(mockRepo.fetchProductsCallCount, 0, reason: 'Should not fetch all products (client-side filter)');

    // searchProducts should be called ONCE
    expect(mockRepo.searchProductsCallCount, 1, reason: 'Should call searchProducts once after debounce');
    expect(mockRepo.lastSearchQuery, 'pixel');
  });

  testWidgets('SearchScreen uses color search for recognized colors', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // Type "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    // EXPECTATIONS for OPTIMIZED behavior:
    expect(mockRepo.fetchProductsCallCount, 0, reason: 'Should not fetch all products');

    // Should call searchProductsByColor
    // Note: Since we haven't implemented the call in SearchScreen yet, this will fail.
    expect(mockRepo.searchProductsByColorCallCount, 1, reason: 'Should call searchProductsByColor for "Red"');
    expect(mockRepo.lastColorKeywords, contains('tomato'));
  });

  testWidgets('SearchScreen performs search on init with initialQuery', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(
        initialQuery: 'initial',
        productRepository: mockRepo,
      ),
    ));

    // pump to trigger post frame callback
    await tester.pump();

    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.lastSearchQuery, 'initial');
  });
}
