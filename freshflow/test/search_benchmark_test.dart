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

  // To support step 4 where we add this method
  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #searchProductsByColor) {
      searchProductsByColorCallCount++;
      return Future.value(<Product>[]);
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Search Benchmark Test: simulate rapid typing', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    // Setup Providers required by SearchScreen widgets (e.g. PriceComparisonCard)
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

    await tester.pumpAndSettle();

    // Type rapidly "tomato" into the search field
    final textFieldFinder = find.byType(TextField);

    // Simulate user typing rapidly
    final characters = 'tomato'.split('');
    String currentText = '';

    for (var char in characters) {
      currentText += char;
      await tester.enterText(textFieldFinder, currentText);
      // Simulate typical typing delay between keystrokes
      await tester.pump(const Duration(milliseconds: 100));
    }

    // Allow debounce timer (if added) or active requests to finish
    await tester.pump(const Duration(milliseconds: 1000));

    print('--- Benchmark Results ---');
    print('fetchProducts calls: ${mockRepo.fetchProductsCallCount}');
    print('searchProducts calls: ${mockRepo.searchProductsCallCount}');
    print('searchProductsByColor calls: ${mockRepo.searchProductsByColorCallCount}');

    // We expect fetchProducts to be called many times before optimization
    // and fewer/zero times after optimization (with searchProducts being used instead)
  });
}
