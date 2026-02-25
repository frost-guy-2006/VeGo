import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Fakes and Mocks
class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockProductRepository extends ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  MockProductRepository() : super(client: FakeSupabaseClient());

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    await Future.delayed(const Duration(milliseconds: 10));
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
}

// HttpOverrides to prevent network calls during image loading
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockImageHttpClient(context);
  }
}

// Returns a mock HTTP client that responds with a transparent 1x1 pixel PNG
HttpClient _createMockImageHttpClient(SecurityContext? _) {
  final client = _MockHttpClient();
  return client;
}

class _MockHttpClient extends Fake implements HttpClient {
  @override
  bool autoUncompress = false;

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
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return Stream<List<int>>.fromIterable([kTransparentImage]).listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

// 1x1 transparent PNG
final List<int> kTransparentImage = <int>[
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

  testWidgets('SearchScreen uses optimized search methods and debounce', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    // 1. Initial State
    expect(mockRepo.fetchProductsCallCount, 0);

    // 2. Name Search with Debounce
    await tester.enterText(find.byType(TextField), 'Ap');
    await tester.pump();
    // Wait short time (debounce active)
    await tester.pump(const Duration(milliseconds: 100));
    expect(mockRepo.searchProductsCallCount, 0, reason: "Should wait for debounce");

    // Wait full time
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.searchProductsByColorCallCount, 0);

    // Reset counts
    mockRepo.searchProductsCallCount = 0;

    // 3. Color Search
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump();

    await tester.pump(const Duration(milliseconds: 600));
    await tester.pumpAndSettle();

    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsByColorCallCount, 1);
    // Note: 'Red' is not 'red' in searchProductsByColor check inside SearchScreen?
    // SearchScreen: if (['red',...].contains(lowerQuery)) -> _activeColorFilter = lowerQuery (capitalized)
    // Then calls searchProductsByColor(_activeColorFilter)
  });
}
