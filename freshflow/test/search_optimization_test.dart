import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock Repository
class MockProductRepository extends Fake implements ProductRepository {
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
          name: 'Test Product $query',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 20,
          harvestTime: 'Now',
          stock: 5)
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
          marketPrice: 20,
          harvestTime: 'Now',
          stock: 5)
    ];
  }
}

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  void addToCart(Product product) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String id) => false;

  @override
  void toggleWishlist(Product product) {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool get autoUncompress => true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }
}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // Return a valid 1x1 transparent PNG
    final List<int> onePixelPng = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
    ];
    return Stream.value(onePixelPng).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('Search debounces and calls optimized repository methods',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => MockWishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Simulate typing "Red" quickly
    await tester.enterText(textField, 'R');
    await tester.pump(const Duration(milliseconds: 100)); // less than debounce
    await tester.enterText(textField, 'Re');
    await tester.pump(const Duration(milliseconds: 100)); // less than debounce
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 600)); // wait for debounce

    // Wait for async search to complete
    await tester.pump(const Duration(seconds: 1));

    // Verify calls
    // Should NOT call fetchProducts (the old inefficient way)
    expect(mockRepo.fetchProductsCallCount, 0,
        reason: 'Should not call fetchProducts (inefficient)');

    // "Red" matches a color, so it should call searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1,
        reason: 'Should call searchProductsByColor exactly once');

    // Should NOT call searchProducts (by name) because "Red" is a color keyword
    expect(mockRepo.searchProductsCallCount, 0);

    // Verify UI shows "Visual Search Active" because "Red" was detected
    expect(find.text('Visual Search Active'), findsOneWidget);
  });

  testWidgets('Search debounces and calls name search for non-color queries',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => MockWishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    final textField = find.byType(TextField);

    // Simulate typing "Tomato"
    await tester.enterText(textField, 'Tomato');
    await tester.pump(const Duration(milliseconds: 600)); // wait for debounce
    await tester.pump(const Duration(seconds: 1));

    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.searchProductsByColorCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0);
  });
}
