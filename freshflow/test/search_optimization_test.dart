import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock ProductRepository
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  final List<Product> _products = [
    Product(
        id: '1',
        name: 'Red Apple',
        imageUrl: '',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 10,
        color: 'Red'),
    Product(
        id: '2',
        name: 'Green Spinach',
        imageUrl: '',
        currentPrice: 5,
        marketPrice: 7,
        harvestTime: 'Now',
        stock: 5,
        color: 'Green'),
  ];

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return _products;
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    return _products
        .where((p) => p.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    // Simulate server-side filtering logic
    final keywords = Product.colorKeywords[color];
    if (keywords == null) return [];

    return _products.where((p) {
        final name = p.name.toLowerCase();
        return keywords.any((k) => name.contains(k));
    }).toList();
  }
}

// Mock Providers extending original classes to inherit implementation
class MockCartProvider extends CartProvider {
  // Override if needed, or leave as is since we use mock shared preferences
}

class MockWishlistProvider extends WishlistProvider {
  // Override if needed
}

// HttpOverrides to prevent network calls
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _TestHttpClientRequest();
  }
}

class _TestHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _TestHttpClientResponse();
  }
}

class _TestHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value([]).listen(
      onData,
      onError: onError,
      onDone: onDone,
      cancelOnError: cancelOnError,
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen uses server-side search and debounce',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(
              create: (_) => MockCartProvider()),
          ChangeNotifierProvider<WishlistProvider>(
              create: (_) => MockWishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    // Verify initial state
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);

    // Enter text "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(); // Trigger onChanged

    // Should NOT call search immediately (debounce)
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 500));
    // Wait for async search completion
    await tester.pump();

    // Should call searchProducts now
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0); // Should NOT fetch all products

    // Enter "Red" (color keyword)
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(); // Trigger onChanged logic
    await tester.pump(const Duration(milliseconds: 500)); // Wait for debounce
    await tester.pump(); // Wait for async search completion

    // Should call searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1);

    // Verify "Visual Search Active" UI appears
    expect(find.text('Visual Search Active'), findsOneWidget);
  });
}
