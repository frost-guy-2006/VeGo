import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/cart_provider.dart';

class MockProductRepository implements ProductRepository {
  int fetchProductsCount = 0;
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  final List<Product> _products = List.generate(
    10000,
    (index) => Product(
      id: index.toString(),
      name: index % 2 == 0 ? 'Tomato $index' : 'Cucumber $index',
      imageUrl: '',
      currentPrice: 10,
      marketPrice: 12,
      harvestTime: 'Today',
      stock: 10,
    ),
  );

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    return _products;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    return _products.where((p) => p.name.toLowerCase().contains(query)).toList();
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCount++;
    await Future.delayed(const Duration(milliseconds: 5));
    return _products.where((p) => p.color?.toLowerCase() == color.toLowerCase()).toList();
  }

  // Implement other methods to satisfy interface
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('SearchScreen Performance Benchmark', (WidgetTester tester) async {
    final repo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
          ChangeNotifierProvider(create: (_) => CartProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: repo),
        ),
      ),
    );

    final stopwatch = Stopwatch()..start();

    // Simulate fast typing 'tomato'
    for (var char in 'tomato'.split('')) {
      final text = (tester.widget<TextField>(find.byType(TextField)).controller?.text ?? '') + char;
      await tester.enterText(find.byType(TextField), text);
      await tester.pump();
    }

    // Wait for the final search to complete
    await tester.pump(const Duration(milliseconds: 600));

    stopwatch.stop();

    print('Time taken to type "tomato" and get results: ${stopwatch.elapsedMilliseconds} ms');
    print('fetchProducts called: ${repo.fetchProductsCount} times');
    print('searchProducts called: ${repo.searchProductsCount} times');
    print('searchProductsByColor called: ${repo.searchProductsByColorCount} times');

    // Test debounce by seeing if fetchProducts was called multiple times
    // Currently, it's probably called once per keystroke.

    // We expect fetchProducts to be high if no debounce/server-filtering, and low if optimized
  });
}
