import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

class MockProductRepository implements ProductRepository {
  int fetchAllCalls = 0;
  int searchCalls = 0;
  int searchByColorCalls = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchAllCalls++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCalls++;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchByColorCalls++;
    return [];
  }

  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;
}

void main() {
  testWidgets('SearchScreen optimization verification', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    expect(mockRepo.fetchAllCalls, 0);

    // 1. Text Search: "Apple"
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Apple');

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));
    // Wait for async call
    await tester.pump();

    expect(mockRepo.fetchAllCalls, 0, reason: 'Should NOT fetch all products');
    expect(mockRepo.searchCalls, 1, reason: 'Should call searchProducts');
    expect(mockRepo.searchByColorCalls, 0);

    // Reset counters
    mockRepo.searchCalls = 0;

    // 2. Color Search: "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(mockRepo.fetchAllCalls, 0, reason: 'Should NOT fetch all products');
    expect(mockRepo.searchByColorCalls, 1, reason: 'Should call searchProductsByColor');
    expect(mockRepo.searchCalls, 0);

    // 3. Debounce Test
    mockRepo.searchByColorCalls = 0;
    mockRepo.searchCalls = 0;

    await tester.enterText(textField, 'B');
    await tester.pump(const Duration(milliseconds: 100)); // Less than 500ms
    await tester.enterText(textField, 'Ba');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'Banana');
    await tester.pump(const Duration(milliseconds: 600)); // Trigger
    await tester.pump();

    // Banana -> Color inference for Orange?
    // Product.fromJson maps "Banana" to Orange.
    // But SearchScreen only switches to Visual Mode if query is in ['red', 'blue', 'green', 'orange', 'yellow'].
    // "Banana" is NOT in that list. So it should be a text search.

    expect(mockRepo.searchCalls, 1, reason: 'Should only call once due to debounce');
    expect(mockRepo.searchByColorCalls, 0);
  });
}
