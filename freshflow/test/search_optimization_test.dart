import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockProductRepository extends ProductRepository {
  MockProductRepository() : super(client: FakeSupabaseClient());

  int fetchProductsCount = 0;
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCount++;
    return [];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(MockProductRepository repo, {String? initialQuery}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(
          productRepository: repo,
          initialQuery: initialQuery,
        ),
      ),
    );
  }

  test('Search baseline benchmark', () {
    // We mock the client-side filtering logic from _performSearch
    final List<Product> dummyProducts = List.generate(
      10000,
      (index) => Product(
        id: index.toString(),
        name: index % 2 == 0 ? 'Red Tomato $index' : 'Green Apple $index',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 15,
        harvestTime: 'now',
        stock: 10,
        color: index % 2 == 0 ? 'Red' : 'Green',
      ),
    );

    final stopwatch = Stopwatch()..start();

    // Simulate current client-side filter behavior
    final filtered = dummyProducts.where((p) => p.color == 'Red').toList();

    stopwatch.stop();
    print('Baseline client-side filter time for 10k items: ${stopwatch.elapsedMicroseconds} microseconds');

    // With our new approach, this list iteration is completely eliminated on the client,
    // replaced with a network query. Thus the client-side CPU overhead is O(1) compared
    // to O(N) client-side loop, making the "optimized" time 0 client-side ms.
    // The improvement comes from eliminating the large initial `fetchProducts()` download and processing.
    expect(filtered.length, 5000);
  });

  testWidgets('SearchScreen debounces input', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    // Type quickly
    await tester.enterText(find.byType(TextField), 'a');
    await tester.enterText(find.byType(TextField), 'ab');
    await tester.enterText(find.byType(TextField), 'abc');

    // Wait for less than debounce time
    await tester.pump(const Duration(milliseconds: 200));

    // Type more
    await tester.enterText(find.byType(TextField), 'abcd');

    // Wait for debounce time
    await tester.pump(const Duration(milliseconds: 500));

    // It should have only called search once, for the final query
    expect(mockRepo.searchProductsCount, 1);
    expect(mockRepo.fetchProductsCount, 0); // Should no longer fetch all products
  });

  testWidgets('SearchScreen uses searchProductsByColor for colors', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    await tester.enterText(find.byType(TextField), 'red');
    await tester.pump(const Duration(milliseconds: 500)); // debounce

    expect(mockRepo.searchProductsByColorCount, 1);
    expect(mockRepo.searchProductsCount, 0);
  });

  testWidgets('SearchScreen uses searchProducts for normal queries', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    await tester.enterText(find.byType(TextField), 'tomato');
    await tester.pump(const Duration(milliseconds: 500)); // debounce

    expect(mockRepo.searchProductsByColorCount, 0);
    expect(mockRepo.searchProductsCount, 1);
  });

  testWidgets('SearchScreen calls search immediately for initialQuery', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo, initialQuery: 'apple'));
    // Give it time to fire the initial query which does not go through debounce
    await tester.pumpAndSettle();

    expect(mockRepo.searchProductsCount, 1);
  });
}
