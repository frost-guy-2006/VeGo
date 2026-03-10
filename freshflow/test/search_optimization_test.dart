import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock HttpOverrides
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

class MockHttpClient extends Fake implements HttpClient {
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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // Return a 1x1 transparent pixel
    return Stream<List<int>>.value([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
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
          name: 'Test Product $query',
          imageUrl: 'http://example.com/image.png',
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
          imageUrl: 'http://example.com/image.png',
          currentPrice: 10,
          marketPrice: 12,
          harvestTime: 'Now',
          stock: 10,
          color: 'Red')
    ];
  }
}

// Mock Providers
class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];

  @override
  double get totalPrice => 0.0;

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

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  testWidgets('SearchScreen uses server-side search and debounce',
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
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);

    // Enter text
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(); // Force frame but don't advance timer fully

    // Should NOT have searched yet (debounce)
    expect(mockRepo.searchProductsCallCount, 0);

    // Advance time by 500ms
    await tester.pump(const Duration(milliseconds: 500));

    // Should have searched now
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0); // Should NOT fetch all

    // Test Color Search
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.searchProductsByColorCallCount, 1);
  });
}
