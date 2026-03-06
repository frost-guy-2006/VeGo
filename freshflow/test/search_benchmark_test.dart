import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProductRepository implements ProductRepository {
  int fetchProductsCalls = 0;
  int searchProductsCalls = 0;
  int searchProductsByColorCalls = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCalls++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCalls++;
    return [];
  }

  // Add the method signature even if it's not in the base class yet
  // It will be added in the next step.
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCalls++;
    return [];
  }

  // Stub other methods to satisfy interface
  @override
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async => [];

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async => false;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  get _client => throw UnimplementedError();

  @override
  static const int defaultPageSize = 10;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen baseline performance benchmark', (WidgetTester tester) async {
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

    // Initial pump
    await tester.pump();

    // Type "tomato" slowly, firing onChanged multiple times
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    final stopwatch = Stopwatch()..start();

    await tester.enterText(textField, 't');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'to');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'tom');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'toma');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'tomat');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'tomato');
    await tester.pump(const Duration(milliseconds: 100));

    // Pump one more time to let debounce timer finish
    await tester.pump(const Duration(milliseconds: 500));

    stopwatch.stop();

    // In the unoptimized version, fetchProducts is called on every keystroke
    debugPrint('fetchProducts calls: ${mockRepo.fetchProductsCalls}');
    debugPrint('searchProducts calls: ${mockRepo.searchProductsCalls}');
    debugPrint('searchProductsByColor calls: ${mockRepo.searchProductsByColorCalls}');
    debugPrint('Time taken: ${stopwatch.elapsedMilliseconds}ms');

    // Baseline assertions
    // expect(mockRepo.fetchProductsCalls, greaterThanOrEqualTo(6));

    // Improved assertions
    expect(mockRepo.fetchProductsCalls, 0); // Should no longer fetch all
    // Because of debounce (500ms), and our pumps are 100ms apart (600ms total),
    // only 1 call to searchProducts should happen.
    expect(mockRepo.searchProductsCalls, 1);
  });
}
