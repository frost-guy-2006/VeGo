import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProductRepository implements ProductRepository {
  int fetchCallCount = 0;
  int searchCallCount = 0;
  int searchByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchCallCount++;
    return [
      Product(id: '1', name: 'Apple', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10),
    ];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCallCount++;
    return [
      Product(id: '1', name: 'Apple', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10),
    ];
  }

  // We will add searchProductsByColor later
  Future<List<Product>> searchProductsByColor(String query) async {
    searchByColorCallCount++;
    return [
      Product(id: '1', name: 'Apple', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10),
    ];
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
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen baseline benchmark', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    // Initial pump and a short delay
    await tester.pump(const Duration(milliseconds: 100));

    // Type "red apple" quickly to simulate user typing
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    await tester.enterText(textField, 'r');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(textField, 're');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(textField, 'red');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(textField, 'red ');
    await tester.pump(const Duration(milliseconds: 50));
    await tester.enterText(textField, 'red a');
    await tester.pump(const Duration(milliseconds: 50));

    // Wait for the debounce timer (500ms) and ongoing async operations
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500)); // second pump to allow Future to complete

    // Fast typing simulation
    // The previous implementation would fetch products 5 times for these 5 keystrokes

    // Check baseline numbers
    debugPrint('Fetch calls: ${mockRepo.fetchCallCount}');
    debugPrint('Search calls: ${mockRepo.searchCallCount}');
    debugPrint('Search by color calls: ${mockRepo.searchByColorCallCount}');

    expect(mockRepo.fetchCallCount, 0); // No more fetching all products
    expect(mockRepo.searchCallCount, 1); // 1 search call because the query "red a" does not exactly match a color

  });
}
