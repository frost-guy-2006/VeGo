import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Fake implementation of ProductRepository
class FakeProductRepository extends Fake implements ProductRepository {
  int searchCount = 0;
  int colorSearchCount = 0;
  List<String> searchQueries = [];
  List<String> colorQueries = [];

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCount++;
    searchQueries.add(query);
    // Return dummy product
    return [
      Product(
          id: '1',
          name: 'Test Product matching $query',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 20,
          harvestTime: 'Now',
          stock: 5,
          color: 'Red') // Ensure color is set for visual search tests if needed
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    colorSearchCount++;
    colorQueries.add(color);
    return [
      Product(
          id: '2',
          name: 'Test Product matching $color',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 20,
          harvestTime: 'Now',
          stock: 5,
          color: color)
    ];
  }

  @override
  Future<List<Product>> fetchProducts() async {
    throw Exception(
        "fetchProducts should not be called in the optimized implementation");
  }
}

void main() {
  late FakeProductRepository repo;

  setUp(() {
    repo = FakeProductRepository();
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: repo),
      ),
    );
  }

  testWidgets('Search debounce works - only one call after rapid typing',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'a');
    await tester.pump(const Duration(milliseconds: 100)); // less than debounce
    await tester.enterText(textField, 'ap');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'app');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'appl');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'apple');

    // Wait for debounce to fire (500ms)
    await tester.pump(const Duration(milliseconds: 600));
    // Wait for async search to complete
    await tester.pump();

    // Should only have called search once with the final term
    expect(repo.searchCount, 1, reason: 'Search should be debounced');
    expect(repo.searchQueries.first, 'apple');

    // Verify results are displayed
    expect(find.text('Test Product matching apple'), findsOneWidget);
  });

  testWidgets('Server-side search is used instead of fetchAll',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'banana');

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(repo.searchCount, 1);
    expect(repo.searchQueries.first, 'banana');
    // Ensure fetchProducts was NOT called (it throws if called)
  });

  testWidgets('Visual Search triggers searchProductsByColor',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Red');

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(repo.colorSearchCount, 1);
    expect(repo.colorQueries.first, 'Red');
    expect(repo.searchCount, 0);

    // Verify visual search header appears (depends on logic inside SearchScreen)
    // The SearchScreen shows 'Visual Search Active' if _activeColorFilter is not null
    expect(find.text('Visual Search Active'), findsOneWidget);
  });
}
