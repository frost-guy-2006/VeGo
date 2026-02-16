import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';

// Mock HttpOverrides
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _MockHttpClient();
  }
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async => _MockHttpClientRequest();
}

class _MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  Future<HttpClientResponse> close() async => _MockHttpClientResponse();

  @override
  HttpHeaders get headers => _MockHttpHeaders();
}

class _MockHttpHeaders extends Fake implements HttpHeaders {
    @override
    void add(String name, Object value, {bool preserveHeaderCase = false}) {}

    @override
    void set(String name, Object value, {bool preserveHeaderCase = false}) {}
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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.value(kTransparentImage).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

final List<int> kTransparentImage = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49,
  0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06,
  0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44,
  0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00, 0x05, 0x00, 0x01, 0x0D,
  0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE, 0x42,
  0x60, 0x82,
];

// Mock Providers
class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];

  @override
  double get totalPrice => 0;

  @override
  void addToCart(Product product) {}

  @override
  void removeFromCart(String productId) {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  void clearCart() {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  List<Product> get wishlist => [];

  @override
  int get itemCount => 0;

  @override
  bool isInWishlist(String productId) => false;

  @override
  void toggleWishlist(Product product) {}

  @override
  void addToWishlist(Product product) {}

  @override
  void removeFromWishlist(String productId) {}

  @override
  void clearWishlist() {}

  @override
  Future<void> loadFromStorage() async {}
}

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
          name: 'Test Product',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 12,
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
          name: 'Red Apple',
          imageUrl: '',
          currentPrice: 10,
          marketPrice: 12,
          harvestTime: 'Now',
          stock: 10)
    ];
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('SearchScreen debounces and uses optimized search methods',
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

    // Verify initial state
    expect(find.byType(TextField), findsOneWidget);
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);

    // 1. Text Search Test
    // Enter "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(); // Rebuild with new text

    // Should NOT search yet (debounce)
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0);

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Should have searched now
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0); // KEY ASSERTION: No fetch all
    expect(mockRepo.searchProductsByColorCallCount, 0);

    // 2. Color Search Test
    // Enter "Red"
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump();

    // Reset counts for clarity (optional, but let's just track cumulative)
    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Should call searchProductsByColor
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0); // Still no fetch all

    // 3. Verify multiple fast inputs only trigger one search
    await tester.enterText(find.byType(TextField), 'b');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'ba');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(find.byType(TextField), 'banana');
    await tester.pump(const Duration(milliseconds: 600));

    // "banana" is NOT a color name, so it should be a normal search
    expect(mockRepo.searchProductsByColorCallCount, 1); // Only "Red" from before
    expect(mockRepo.searchProductsCallCount, 2); // "apple" + "banana"
  });
}
