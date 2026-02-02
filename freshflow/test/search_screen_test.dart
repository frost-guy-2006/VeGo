import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock Repository
class MockProductRepository implements ProductRepository {
  final List<String> log = [];

  @override
  SupabaseClient get _client => throw UnimplementedError();

  @override
  Future<List<Product>> fetchProducts() async {
    log.add('fetchProducts');
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    log.add('searchProducts: $query');
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    log.add('searchProductsByColor: $color');
    if (color == 'Red') {
         return [
            Product(
                id: '1', name: 'Tomato', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10, color: 'Red'
            ),
             Product(
                id: '2', name: 'Green Apple', imageUrl: '', currentPrice: 1, marketPrice: 2, harvestTime: 'Now', stock: 10, color: 'Red'
            )
         ];
    }
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

  Widget createTestWidget(MockProductRepository repo) {
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

  testWidgets('SearchScreen calls searchProducts after debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'onion');

    // Should not call immediately (debounce)
    expect(mockRepo.log, isEmpty);

    // Wait for 500ms
    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.log, equals(['searchProducts: onion']));
  });

  testWidgets('SearchScreen calls searchProductsByColor for "Red"', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Red');

    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.log, contains('searchProductsByColor: Red'));
  });

  testWidgets('SearchScreen calls searchProducts (text) for "Blue" (unsupported color)', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Blue');

    await tester.pump(const Duration(milliseconds: 500));

    // Should call searchProducts, NOT searchProductsByColor
    expect(mockRepo.log, contains('searchProducts: Blue'));
    expect(mockRepo.log, isNot(contains('searchProductsByColor: Blue')));
  });

  testWidgets('Visual Search Mode filters correctly', (WidgetTester tester) async {
     final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    final textField = find.byType(TextField);
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 500));
    // Use pump(Duration) instead of pumpAndSettle to avoid timeout due to CachedNetworkImage or animations
    await tester.pump(const Duration(seconds: 2));

    // Should see "Visual Search Active"
    expect(find.text('Visual Search Active'), findsOneWidget);
    expect(find.text('Showing Red Products'), findsOneWidget);

    // We mocked return of 2 products.
    // PriceComparisonCard displays product name.
    expect(find.text('Tomato'), findsOneWidget);
    expect(find.text('Green Apple'), findsOneWidget);
  });
}
