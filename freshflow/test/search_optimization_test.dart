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
  int fetchProductsCount = 0;
  int searchProductsCount = 0;
  int searchProductsByColorCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCount++;
    return [];
  }
}

// Mock CartProvider
class MockCartProvider extends ChangeNotifier implements CartProvider {
  @override
  Future<void> addToCart(Product product) async {}

  @override
  List<CartItem> get items => [];

  @override
  double get totalAmount => 0;

  @override
  int get itemCount => 0;

  @override
  Future<void> initForUser(String? userId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// Mock WishlistProvider
class MockWishlistProvider extends ChangeNotifier implements WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;

  @override
  Future<void> toggleWishlist(Product product) async {}

  @override
  int get itemCount => 0;

  @override
  Future<void> initForUser(String? userId) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// HttpOverrides for NetworkImage
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = true;

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

  @override
  HttpHeaders get headers => _TestHttpHeaders();
}

class _TestHttpHeaders extends Fake implements HttpHeaders {}

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
    return Stream<List<int>>.fromIterable([
      [0] // Empty image
    ]).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen optimizes search with debounce and server-side filtering', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();
    final mockCart = MockCartProvider();
    final mockWishlist = MockWishlistProvider();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>.value(value: mockCart),
          ChangeNotifierProvider<WishlistProvider>.value(value: mockWishlist),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    // Initial state
    expect(mockRepo.fetchProductsCount, 0, reason: 'Should not fetch products initially');

    // 1. Test Text Search with Debounce
    // Type "Apple"
    await tester.enterText(find.byType(TextField), 'Apple');

    // Pump a short duration (less than debounce)
    await tester.pump(const Duration(milliseconds: 100));

    // Type more (simulating fast typing)
    await tester.enterText(find.byType(TextField), 'Apple Pie');
    await tester.pump(const Duration(milliseconds: 100));

    // Wait for debounce (simulating time passing > 500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Verify:
    // fetchProducts (fetch all) should NEVER be called in optimized version
    expect(mockRepo.fetchProductsCount, 0, reason: 'Should NOT call fetchProducts (fetch all)');

    // searchProducts should be called ONCE (for "Apple Pie")
    // If debounce is working, we shouldn't see a call for "Apple".
    expect(mockRepo.searchProductsCount, 1, reason: 'Should call searchProducts exactly once after debounce');


    // 2. Test Color Search
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    expect(mockRepo.searchProductsByColorCount, 1, reason: 'Should call searchProductsByColor for "Red"');
    expect(mockRepo.fetchProductsCount, 0, reason: 'Should still not fetch all products');
  });
}
