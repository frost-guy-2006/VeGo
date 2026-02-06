import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Fake Repository to verify method calls
class FakeProductRepository implements ProductRepository {
  int searchProductsCalls = 0;
  int searchProductsByColorCalls = 0;
  int fetchProductsCalls = 0;

  String? lastSearchQuery;
  String? lastColorQuery;

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCalls++;
    lastSearchQuery = query;
    return [
      Product(id: '1', name: 'Apple', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: '', stock: 1)
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String colorName) async {
    searchProductsByColorCalls++;
    lastColorQuery = colorName;
    return [
      Product(id: '2', name: 'Tomato (Red)', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: '', stock: 1)
    ];
  }

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCalls++;
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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen debounces and uses optimized queries', (WidgetTester tester) async {
    final fakeRepo = FakeProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: fakeRepo),
        ),
      ),
    );

    // Type "Apple"
    await tester.enterText(find.byType(TextField), 'Apple');
    await tester.pump(); // Trigger onChanged, start timer

    // Timer is 500ms. Pump for 200ms - should not call yet
    await tester.pump(const Duration(milliseconds: 200));
    expect(fakeRepo.searchProductsCalls, 0);

    // Pump remaining time
    await tester.pump(const Duration(milliseconds: 400)); // Total > 500ms
    expect(fakeRepo.searchProductsCalls, 1);
    expect(fakeRepo.lastSearchQuery, 'Apple');
    expect(fakeRepo.fetchProductsCalls, 0); // Should NOT call fetchProducts

    // Type "Red" (Color search)
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(); // Start new timer

    // Pump full duration
    await tester.pump(const Duration(milliseconds: 600));

    expect(fakeRepo.searchProductsByColorCalls, 1);
    expect(fakeRepo.lastColorQuery, 'Red');
    expect(fakeRepo.fetchProductsCalls, 0);
  });

  testWidgets('Rapid typing calls search only once', (WidgetTester tester) async {
    final fakeRepo = FakeProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: fakeRepo),
        ),
      ),
    );

    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField), 'Ap');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    await tester.enterText(find.byType(TextField), 'App');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    expect(fakeRepo.searchProductsCalls, 1); // Only once for "App"
    expect(fakeRepo.lastSearchQuery, 'App');
  });
}
