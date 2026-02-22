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

// --- Mocks ---

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
    // Return dummy product to avoid empty list UI if needed
    return [
      Product(
        id: '1',
        name: 'Apple',
        imageUrl: 'http://example.com/apple.jpg',
        currentPrice: 100,
        marketPrice: 120,
        harvestTime: 'Today',
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
        imageUrl: 'http://example.com/red_apple.jpg',
        currentPrice: 100,
        marketPrice: 120,
        harvestTime: 'Today',
        stock: 10,
        color: 'Red',
      )
    ];
  }
}

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];

  @override
  double get totalPrice => 0;

  @override
  void addToCart(Product product) {}

  @override
  void clearCart() {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  void removeFromCart(String productId) {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;

  @override
  void toggleWishlist(Product product) {}

  @override
  void addToWishlist(Product product) {}

  @override
  void clearWishlist() {}

  @override
  int get itemCount => 0;

  @override
  Future<void> loadFromStorage() async {}

  @override
  void removeFromWishlist(String productId) {}

  @override
  List<Product> get wishlist => [];
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockHttpClient();
  }
}

HttpClient _createMockHttpClient() {
  final client = _MockHttpClient();
  return client;
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return _MockHttpClientRequest();
  }
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async {
    return _MockHttpClientResponse();
  }
}

class _MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(
    void Function(List<int> event)? onData, {
    Function? onError,
    void Function()? onDone,
    bool? cancelOnError,
  }) {
    return Stream<List<int>>.fromIterable([kTransparentImage])
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

const List<int> kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('SearchScreen uses debounce and optimized search methods',
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

    // Initial state: no search called
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);

    // Find the TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Simulate typing "app"
    await tester.enterText(textField, 'app');
    await tester.pump(); // Trigger onChanged

    // Wait for less than debounce (e.g. 200ms)
    await tester.pump(const Duration(milliseconds: 200));

    // Should NOT have searched yet
    expect(mockRepo.searchProductsCallCount, 0, reason: "Should debounce search");

    // Simulate typing "apple" (user continues typing)
    await tester.enterText(textField, 'apple');
    await tester.pump(); // Trigger onChanged reset

    // Wait for full debounce (e.g. 600ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Should have searched once with "apple"
    expect(mockRepo.searchProductsCallCount, 1, reason: "Should call searchProducts once after debounce");
    expect(mockRepo.fetchProductsCallCount, 0, reason: "Should NOT call fetchProducts (fetch all)");

    // Now test color search
    // Clear text
    await tester.enterText(textField, '');
    await tester.pump();

    // Type "red"
    await tester.enterText(textField, 'red');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Should use searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1, reason: "Should call searchProductsByColor for color keyword");
    expect(mockRepo.fetchProductsCallCount, 0);
  });
}
