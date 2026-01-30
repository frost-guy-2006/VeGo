import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock Repository
class MockProductRepository implements ProductRepository {
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    return [
       Product(
        id: '1',
        name: 'Test Product $query',
        imageUrl: '', // Requires valid URL or handled by CachedNetworkImage?
        // CachedNetworkImage in test might fail if it tries to fetch.
        // But we can just use empty or loopback.
        // Actually CachedNetworkImage usually needs a mock http client or wrapper.
        // Or we can use image_test_utils or similar.
        // But let's see. CachedNetworkImage might throw error in test environment.
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 10,
      )
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [
       Product(
        id: '2',
        name: 'Red Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 10,
        color: 'Red'
      )
    ];
  }

  @override
  Future<List<Product>> fetchProducts() async {
    throw UnimplementedError('Should not be called');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(ProductRepository repo) {
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

  testWidgets('SearchScreen debounces and calls correct repository method', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    // Set a surface size to ensure grid view has space
    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createTestWidget(mockRepo));

    // Verify initial state
    expect(find.byType(TextField), findsOneWidget);

    // Enter text "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(); // Rebuild with text change

    // Should NOT have called repository yet (debounce 500ms)
    expect(mockRepo.searchProductsCallCount, 0);

    // Enter more text "apple pie" before 500ms
    await tester.enterText(find.byType(TextField), 'apple pie');
    await tester.pump();

    // Still 0
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Should have called searchProducts ONCE
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.searchProductsByColorCallCount, 0);
  });

  testWidgets('SearchScreen calls searchProductsByColor for "Red"', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    tester.view.physicalSize = const Size(1080, 1920);
    tester.view.devicePixelRatio = 1.0;

    await tester.pumpWidget(createTestWidget(mockRepo));

    // Enter text "Red"
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    // Should have called searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.searchProductsCallCount, 0);

    // Verify Visual Search UI appears
    expect(find.text('Visual Search Active'), findsOneWidget);
  });
}
