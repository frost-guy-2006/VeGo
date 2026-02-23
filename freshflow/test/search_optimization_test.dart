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

// Mock HttpOverrides to avoid network calls for images
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _TestHttpClient();
  }
}

class _TestHttpClient extends Fake implements HttpClient {
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
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData,
      {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    // 1x1 transparent pixel png
    final List<int> transparentPixel = [
      0x89,
      0x50,
      0x4E,
      0x47,
      0x0D,
      0x0A,
      0x1A,
      0x0A,
      0x00,
      0x00,
      0x00,
      0x0D,
      0x49,
      0x48,
      0x44,
      0x52,
      0x00,
      0x00,
      0x00,
      0x01,
      0x00,
      0x00,
      0x00,
      0x01,
      0x08,
      0x06,
      0x00,
      0x00,
      0x00,
      0x1F,
      0x15,
      0xC4,
      0x89,
      0x00,
      0x00,
      0x00,
      0x0A,
      0x49,
      0x44,
      0x41,
      0x54,
      0x78,
      0x9C,
      0x63,
      0x00,
      0x01,
      0x00,
      0x00,
      0x05,
      0x00,
      0x01,
      0x0D,
      0x0A,
      0x2D,
      0xB4,
      0x00,
      0x00,
      0x00,
      0x00,
      0x49,
      0x45,
      0x4E,
      0x44,
      0xAE,
      0x42,
      0x60,
      0x82,
    ];

    return Stream.value(transparentPixel).listen(onData,
        onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

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
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    return [];
  }

  @override
  Future<List<Product>> fetchProductsPaginated(
          {int page = 0, int pageSize = 10, String? category}) async =>
      [];

  @override
  Future<bool> hasMoreProducts(
          {int currentCount = 0, String? category}) async =>
      false;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<Product?> fetchProductById(String id) async => null;
}

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen debounces input and uses optimized search',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<WishlistProvider>(
              create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    final textField = find.byType(TextField);

    // Simulate typing 'a'
    await tester.enterText(textField, 'a');
    await tester.pump();
    // Short wait, less than debounce
    await tester.pump(const Duration(milliseconds: 100));

    // Should NOT have called anything yet
    expect(mockRepo.fetchProductsCallCount, 0,
        reason: "fetchProducts should not be called");
    expect(mockRepo.searchProductsCallCount, 0,
        reason: "searchProducts should wait for debounce");

    // Simulate typing 'ap'
    await tester.enterText(textField, 'ap');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Still nothing
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 500));

    // Now searchProducts should be called
    expect(mockRepo.searchProductsCallCount, 1,
        reason: "searchProducts called after debounce");
    expect(mockRepo.fetchProductsCallCount, 0,
        reason: "fetchProducts never called");
  });

  testWidgets('SearchScreen uses searchProductsByColor for color queries',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<WishlistProvider>(
              create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    final textField = find.byType(TextField);

    // Simulate typing 'red'
    await tester.enterText(textField, 'red');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    expect(mockRepo.searchProductsByColorCallCount, 1,
        reason: "searchProductsByColor called for 'red'");
    expect(mockRepo.searchProductsCallCount, 0,
        reason: "searchProducts not called for color query");
  });
}
