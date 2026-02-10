import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

// Mock ProductRepository
class MockProductRepository extends ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  MockProductRepository() : super(client: FakeSupabaseClient());

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    return [
      Product(
          id: '1',
          name: 'Mock Product $query',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 20,
          harvestTime: 'Now',
          stock: 10)
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [
      Product(
          id: '2',
          name: 'Mock $color Product',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 20,
          harvestTime: 'Now',
          stock: 10)
    ];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(ProductRepository repo) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: repo),
      ),
    );
  }

  testWidgets('SearchScreen calls searchProducts instead of fetchProducts', (tester) async {
    final mockRepo = MockProductRepository();
    await tester.pumpWidget(createTestWidget(mockRepo));

    // Verify initial state
    expect(find.byType(TextField), findsOneWidget);

    // Enter text
    await tester.enterText(find.byType(TextField), 'apple');

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Assert fetchProducts (old inefficient way) is NOT called
    expect(mockRepo.fetchProductsCallCount, 0);

    // Assert searchProducts (new efficient way) IS called
    // 'apple' is NOT in the color list logic in UI ('red', 'blue', etc).
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.searchProductsByColorCallCount, 0);
  });

  testWidgets('SearchScreen debounces input', (tester) async {
    final mockRepo = MockProductRepository();
    await tester.pumpWidget(createTestWidget(mockRepo));

    // Type 'a'
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 100)); // less than 500ms

    // Type 'ap'
    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pump(const Duration(milliseconds: 100));

    // Type 'app'
    await tester.enterText(find.byType(TextField), 'app');
    await tester.pump(const Duration(milliseconds: 600)); // wait for debounce

    // Should only trigger once for 'app'
    expect(mockRepo.searchProductsCallCount, 1);
  });

  testWidgets('SearchScreen uses visual search for colors', (tester) async {
    final mockRepo = MockProductRepository();
    await tester.pumpWidget(createTestWidget(mockRepo));

    // Type 'red'
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    // 'red' matches color list.
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.searchProductsCallCount, 0);
  });
}
