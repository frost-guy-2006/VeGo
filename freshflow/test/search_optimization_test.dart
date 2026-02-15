import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// Mock HttpOverrides to avoid network calls during tests
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

// Mock ProductRepository
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  String? lastSearchQuery;
  String? lastColorQuery;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    lastSearchQuery = query;
    return [
      Product(
        id: '1',
        name: 'Result for $query',
        imageUrl: 'https://example.com/image.jpg',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 10
      )
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    lastColorQuery = color;
    return [
      Product(
        id: '2',
        name: '$color Item',
        imageUrl: 'https://example.com/image.jpg',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 10
      )
    ];
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

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

  testWidgets('SearchScreen uses server-side search with debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    // Verify initial state
    expect(mockRepo.fetchProductsCallCount, 0);

    // Enter text "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(); // Start typing

    // Should not have called search yet (debounce)
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 500));

    // Should have called search now
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.lastSearchQuery, 'apple');
    expect(mockRepo.fetchProductsCallCount, 0); // Should NOT fetch all products

    // Verify results displayed
    await tester.pump(); // Rebuild with results
    expect(find.text('Result for apple'), findsOneWidget);
  });

  testWidgets('SearchScreen uses color search for color keywords', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    // Enter text "Red"
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 500));

    // Should call searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.lastColorQuery, 'Red');
    expect(mockRepo.searchProductsCallCount, 0);

    // Verify results displayed
    await tester.pump();
    expect(find.text('Red Item'), findsOneWidget);
  });

  testWidgets('Debounce prevents multiple calls', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createTestWidget(mockRepo));

    // Type "a"
    await tester.enterText(find.byType(TextField), 'a');
    await tester.pump(const Duration(milliseconds: 100)); // Wait less than debounce

    // Type "ap"
    await tester.enterText(find.byType(TextField), 'ap');
    await tester.pump(const Duration(milliseconds: 100));

    // Type "app"
    await tester.enterText(find.byType(TextField), 'app');
    await tester.pump(const Duration(milliseconds: 500)); // Wait full debounce

    // Should only have called search once for "app"
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.lastSearchQuery, 'app');
  });
}
