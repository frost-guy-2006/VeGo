import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Fake Repository to track calls
class FakeProductRepository implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  List<Product> productsToReturn = [];

  FakeProductRepository() {
    // Populate with some dummy data
    productsToReturn = [
      Product(
          id: '1',
          name: 'Tomato',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 12,
          harvestTime: '',
          stock: 10),
      Product(
          id: '2',
          name: 'Potato',
          imageUrl: '',
          currentPrice: 8,
          marketPrice: 10,
          harvestTime: '',
          stock: 20),
    ];
  }

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return productsToReturn;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    // Simulate server side search
    return productsToReturn
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  // Helper methods to satisfy interface if needed, throwing unimplemented if they shouldn't be called
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('text search triggers fetchAll and client-side filtering (baseline)',
      (WidgetTester tester) async {
    final fakeRepo = FakeProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: fakeRepo),
    ));

    // Find the TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Enter text "tomato"
    await tester.enterText(textField, 'Tomato');
    await tester.pump(); // trigger onChanged

    // In current implementation, it calls _performSearch immediately
    // and calls fetchProducts()

    // Wait for async operations
    // We cannot use pumpAndSettle because CircularProgressIndicator in result cards (or loading state) might run forever
    // Also CachedNetworkImage placeholder is a progress indicator.
    await tester.pump(const Duration(seconds: 1));

    // Verify fetchProducts was NOT called (optimized)
    expect(fakeRepo.fetchProductsCallCount, 0);

    // Verify searchProducts WAS called (optimized)
    expect(fakeRepo.searchProductsCallCount, greaterThan(0));
  });

  testWidgets('rapid typing triggers single call due to debounce',
      (WidgetTester tester) async {
    final fakeRepo = FakeProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: fakeRepo),
    ));

    final textField = find.byType(TextField);

    // Type "t", "o", "m" rapidly
    await tester.enterText(textField, 't');
    await tester.pump(); // starts timer 1

    await tester.enterText(textField, 'to');
    await tester.pump(); // cancels timer 1, starts timer 2

    await tester.enterText(textField, 'tom');
    await tester.pump(); // cancels timer 2, starts timer 3

    // Wait for debounce
    await tester.pump(const Duration(seconds: 1));

    // Should have only 1 call
    expect(fakeRepo.searchProductsCallCount, 1);
    expect(fakeRepo.fetchProductsCallCount, 0);
  });

  testWidgets('color search uses fetchAll (client-side logic preserved)',
      (WidgetTester tester) async {
    final fakeRepo = FakeProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: fakeRepo),
    ));

    final textField = find.byType(TextField);

    // Enter "Red" which triggers color mode
    await tester.enterText(textField, 'Red');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(seconds: 1));

    // Verify fetchProducts WAS called (for client side filtering)
    expect(fakeRepo.fetchProductsCallCount, greaterThan(0));
    // Verify searchProducts was NOT called
    expect(fakeRepo.searchProductsCallCount, 0);
  });
}
