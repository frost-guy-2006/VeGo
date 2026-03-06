import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';

class MockProductRepository implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    return [];
  }

  // Once added, this will be tested
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [];
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Search Benchmark: typing simulation', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SearchScreen(productRepository: mockRepo),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    final stopwatch = Stopwatch()..start();

    // Simulate typing "tomato"
    final text = "tomato";
    for (int i = 1; i <= text.length; i++) {
      await tester.enterText(find.byType(TextField), text.substring(0, i));
      await tester.pump(const Duration(milliseconds: 50));
    }

    // Wait for debounce if any
    await tester.pump(const Duration(milliseconds: 600));

    stopwatch.stop();
    print('Benchmark time for typing simulation: ${stopwatch.elapsedMilliseconds} ms');
    print('fetchProducts calls: ${mockRepo.fetchProductsCallCount}');
    print('searchProducts calls: ${mockRepo.searchProductsCallCount}');
    print('searchProductsByColor calls: ${mockRepo.searchProductsByColorCallCount}');
  });
}
