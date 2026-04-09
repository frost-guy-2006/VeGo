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

class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  void addToCart(Product product) {}

  @override
  void clearCart() {}

  @override
  void decreaseQuantity(String productId) {}

  @override
  List<CartItem> get items => [];

  @override
  void removeFromCart(String productId) {}

  @override
  double get totalPrice => 0.0;

  @override
  Future<void> initForUser(String? userId) async {}
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

  @override
  Future<void> initForUser(String? userId) async {}
}

// Mock ProductRepository
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    // Simulate delay and large payload
    await Future.delayed(const Duration(milliseconds: 100));
    return List.generate(
      1000,
      (index) => Product(
        id: 'id_$index',
        name: 'Product $index',
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: 'Today',
        stock: 100,
        category: 'Vegetables',
      ),
    );
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    return [
      Product(
        id: '1',
        name: 'Apple',
        imageUrl: '',
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: 'Today',
        stock: 100,
        category: 'Fruits',
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
        currentPrice: 10.0,
        marketPrice: 12.0,
        harvestTime: 'Today',
        stock: 100,
        category: 'Fruits',
        color: color,
      )
    ];
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  Widget createWidgetUnderTest(ProductRepository repo) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
        ChangeNotifierProvider<WishlistProvider>(
            create: (_) => MockWishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: repo),
      ),
    );
  }

  testWidgets('Optimized: Search debounces and uses server-side search',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createWidgetUnderTest(mockRepo));

    // Enter "A"
    await tester.enterText(find.byType(TextField), 'A');
    await tester.pump();
    // Wait slightly less than debounce (500ms)
    await tester.pump(const Duration(milliseconds: 200));

    // Enter "Ap"
    await tester.enterText(find.byType(TextField), 'Ap');
    await tester.pump();
    // Wait slightly less than debounce
    await tester.pump(const Duration(milliseconds: 200));

    // Enter "App"
    await tester.enterText(find.byType(TextField), 'App');
    await tester.pump();

    // Verify no calls yet (debounce active)
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce to complete (500ms total)
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProducts called once
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 1);
  });

  testWidgets('Optimized: Visual search uses searchProductsByColor',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createWidgetUnderTest(mockRepo));

    // Enter "Red"
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProductsByColor called once
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.searchProductsByColorCallCount, 1);
  });
}

class TestHttpOverrides extends HttpOverrides {
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
  int get contentLength => kTransparentImage.length;

  @override
  HttpClientResponseCompressionState get compressionState =>
      HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([kTransparentImage])
        .listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

const List<int> kTransparentImage = [
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];
