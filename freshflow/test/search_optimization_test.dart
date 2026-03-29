import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'dart:io';
import 'dart:async';

// Mock Providers

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  List<CartItem> get items => [];
  @override
  double get totalAmount => 0;

  @override
  double get totalPrice => 0;

  @override
  void addToCart(Product product, {int quantity = 1}) {}

  @override
  void removeFromCart(String productId) {}

  @override
  void updateQuantity(String productId, int quantity) {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  void clearCart() {}

  @override
  int get itemCount => 0;

  @override
  Future<void> loadCart() async {}
}

class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  List<Product> get items => [];

  @override
  List<Product> get wishlist => [];

  @override
  void toggleWishlist(Product product) {}

  @override
  void addToWishlist(Product product) {}

  @override
  void removeFromWishlist(String productId) {}

  @override
  void clearWishlist() {}

  @override
  bool isInWishlist(String productId) => false;

  @override
  int get itemCount => 0;

  @override
  Future<void> loadWishlist() async {}

  @override
  Future<void> loadFromStorage() async {}
}

// Mock repository
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    // Simulate delay
    await Future.delayed(const Duration(milliseconds: 50));
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
     await Future.delayed(const Duration(milliseconds: 50));
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
     searchProductsByColorCallCount++;
     await Future.delayed(const Duration(milliseconds: 50));
     return [];
  }
}

// Manual Http Mock
class MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

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

  @override
  HttpHeaders get headers => MockHttpHeaders();
}

class MockHttpHeaders extends Fake implements HttpHeaders {}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 200;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
     final List<int> transparentImage = [
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
      0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
      0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
      0x42, 0x60, 0x82
    ];
    return Stream.value(transparentImage).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return MockHttpClient();
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  testWidgets('Verify optimized repository calls (Debounce + Server Side)', (WidgetTester tester) async {
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

    final searchField = find.byType(TextField);
    expect(searchField, findsOneWidget);

    // Simulate typing quickly "Apple"
    await tester.enterText(searchField, 'A');
    await tester.pump();

    await tester.enterText(searchField, 'Ap');
    await tester.pump();

    await tester.enterText(searchField, 'App');
    await tester.pump();

    await tester.enterText(searchField, 'Appl');
    await tester.pump();

    await tester.enterText(searchField, 'Apple');
    await tester.pump();

    // Debounce is 500ms. We pump 1000ms.
    await tester.pump(const Duration(milliseconds: 1000));

    // Verify calls
    print('fetchProducts calls: ${mockRepo.fetchProductsCallCount}');
    print('searchProducts calls: ${mockRepo.searchProductsCallCount}');
    print('searchProductsByColor calls: ${mockRepo.searchProductsByColorCallCount}');

    // fetchProducts should be 0 because we don't fetch all anymore
    expect(mockRepo.fetchProductsCallCount, equals(0));

    // searchProducts should be 1 because of debounce
    expect(mockRepo.searchProductsCallCount, equals(1));
    expect(mockRepo.searchProductsByColorCallCount, equals(0));

    // Clear counters
    mockRepo.fetchProductsCallCount = 0;
    mockRepo.searchProductsCallCount = 0;
    mockRepo.searchProductsByColorCallCount = 0;

    // Test Color Search
    await tester.enterText(searchField, 'Red');
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 1000));

    print('fetchProducts calls: ${mockRepo.fetchProductsCallCount}');
    print('searchProducts calls: ${mockRepo.searchProductsCallCount}');
    print('searchProductsByColor calls: ${mockRepo.searchProductsByColorCallCount}');

    // Should call searchProductsByColor because "Red" matches logic
    expect(mockRepo.searchProductsByColorCallCount, equals(1));
    expect(mockRepo.searchProductsCallCount, equals(0));
  });
}
