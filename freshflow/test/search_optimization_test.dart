import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Fakes for Supabase
class FakeSupabaseClient extends Fake implements SupabaseClient {
  String? capturedOrQuery;

  @override
  SupabaseQueryBuilder from(String table) {
    return FakeSupabaseQueryBuilder(this);
  }
}

class FakeSupabaseQueryBuilder extends Fake implements SupabaseQueryBuilder {
  final FakeSupabaseClient client;
  FakeSupabaseQueryBuilder(this.client);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> select([String columns = '*']) {
    return FakePostgrestFilterBuilder(client);
  }
}

class FakePostgrestFilterBuilder extends Fake implements PostgrestFilterBuilder<List<Map<String, dynamic>>> {
  final FakeSupabaseClient client;
  FakePostgrestFilterBuilder(this.client);

  @override
  PostgrestFilterBuilder<List<Map<String, dynamic>>> or(String filters, {String? referencedTable}) {
    client.capturedOrQuery = filters;
    return this;
  }

  @override
  PostgrestTransformBuilder<List<Map<String, dynamic>>> order(String column, {bool ascending = true, bool nullsFirst = false, String? referencedTable}) {
    return FakePostgrestTransformBuilder();
  }
}

class FakePostgrestTransformBuilder extends Fake implements PostgrestTransformBuilder<List<Map<String, dynamic>>> {
  @override
  Future<R> then<R>(FutureOr<R> Function(List<Map<String, dynamic>> value) onValue, {Function? onError}) async {
    return onValue([]);
  }
}

// Mock HttpOverrides
class TestHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return _createMockHttpClient();
  }
}

HttpClient _createMockHttpClient() {
  final client = MockHttpClient();
  return client;
}

class MockHttpClient extends Fake implements HttpClient {
  @override
  bool get autoUncompress => false;

  @override
  Future<HttpClientRequest> getUrl(Uri url) async {
    return MockHttpClientRequest();
  }
}

class MockHttpClientRequest extends Fake implements HttpClientRequest {
  @override
  HttpHeaders get headers => MockHttpHeaders();

  @override
  Future<HttpClientResponse> close() async {
    return MockHttpClientResponse();
  }
}

class MockHttpHeaders extends Fake implements HttpHeaders {}

class MockHttpClientResponse extends Fake implements HttpClientResponse {
  @override
  int get statusCode => 404;

  @override
  int get contentLength => 0;

  @override
  HttpClientResponseCompressionState get compressionState => HttpClientResponseCompressionState.notCompressed;

  @override
  StreamSubscription<List<int>> listen(void Function(List<int> event)? onData, {Function? onError, void Function()? onDone, bool? cancelOnError}) {
    return const Stream<List<int>>.empty().listen(onData, onError: onError, onDone: onDone, cancelOnError: cancelOnError);
  }
}

// Mock repository
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [
      Product(
        id: '1',
        name: 'Red Apple',
        imageUrl: 'http://example.com/image.jpg',
        currentPrice: 10,
        marketPrice: 12,
        harvestTime: 'Now',
        stock: 100,
      ),
    ];
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

void main() {
  setUpAll(() {
    HttpOverrides.global = TestHttpOverrides();
  });

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Optimization: Zero immediate calls due to debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    final textField = find.byType(TextField);

    await tester.enterText(textField, 'a');
    await tester.pump();

    await tester.enterText(textField, 'ap');
    await tester.pump();

    await tester.enterText(textField, 'app');
    await tester.pump();

    await tester.enterText(textField, 'appl');
    await tester.pump();

    await tester.enterText(textField, 'apple');
    await tester.pump();

    // No wait for debounce here, just immediate pump
    await tester.pump(Duration.zero);

    // Verify calls - should be 0 because debounce hasn't triggered
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);
  });

  testWidgets('Optimization: Single search call after debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    final textField = find.byType(TextField);

    await tester.enterText(textField, 'apple');
    await tester.pump();

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 500));
    // Wait for async call
    await tester.pump(Duration.zero);

    // Verify calls
    expect(mockRepo.fetchProductsCallCount, 0); // No fetch all
    expect(mockRepo.searchProductsCallCount, 1); // One server search
  });

  testWidgets('Optimization: Visual search triggers searchProductsByColor', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => CartProvider()),
          ChangeNotifierProvider(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      ),
    );

    final textField = find.byType(TextField);

    await tester.enterText(textField, 'Red');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(Duration.zero);

    // Verify calls
    expect(mockRepo.fetchProductsCallCount, 0);
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.searchProductsByColorCallCount, 1);
  });

  test('searchProductsByColor constructs correct OR query', () async {
    final fakeClient = FakeSupabaseClient();
    final repo = ProductRepository(client: fakeClient);

    await repo.searchProductsByColor('Red');

    final expected = 'name.ilike.%red%,name.ilike.%tomato%,name.ilike.%apple%,name.ilike.%strawberry%';
    expect(fakeClient.capturedOrQuery, expected);
  });

  test('searchProductsByColor returns empty for unknown color', () async {
    final fakeClient = FakeSupabaseClient();
    final repo = ProductRepository(client: fakeClient);

    final result = await repo.searchProductsByColor('Purple');
    expect(result, isEmpty);
    expect(fakeClient.capturedOrQuery, null);
  });
}
