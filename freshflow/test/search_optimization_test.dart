import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockProductRepository extends ProductRepository {
  MockProductRepository() : super(client: FakeSupabaseClient());

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
    return [
      Product(
        id: '1',
        name: 'Searched $query',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 20,
        harvestTime: 'Now',
        stock: 5,
      )
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [
      Product(
        id: '2',
        name: 'Color $color',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 20,
        harvestTime: 'Now',
        stock: 5,
        color: color,
      )
    ];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(ProductRepository repository) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: repository),
      ),
    );
  }

  testWidgets('SearchScreen uses optimized searchProducts instead of fetchProducts',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();
    await tester.pumpWidget(createTestWidget(mockRepo));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'apple');

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(); // Trigger the search

    expect(mockRepo.fetchProductsCallCount, 0,
        reason: 'Should not fetch all products');
    expect(mockRepo.searchProductsCallCount, 1,
        reason: 'Should call optimized search');
    expect(find.text('Searched apple'), findsOneWidget);
  });

  testWidgets('SearchScreen uses optimized searchProductsByColor for color queries',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();
    await tester.pumpWidget(createTestWidget(mockRepo));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Red');

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(find.text('Showing Red Products'), findsOneWidget);
  });

  testWidgets('SearchScreen debounces input', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();
    await tester.pumpWidget(createTestWidget(mockRepo));

    final textField = find.byType(TextField);

    // Type 'a'
    await tester.enterText(textField, 'a');
    await tester.pump(const Duration(milliseconds: 100)); // Less than 500ms

    // Type 'ap'
    await tester.enterText(textField, 'ap');
    await tester.pump(const Duration(milliseconds: 100));

    // Type 'app'
    await tester.enterText(textField, 'app');

    // Wait for full debounce
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    expect(mockRepo.searchProductsCallCount, 1, reason: 'Should only search once after typing stops');
  });
}
