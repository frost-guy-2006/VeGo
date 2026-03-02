import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Fake Supabase Client so we don't have to initialize Supabase
class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockProductRepository implements ProductRepository {
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

  // Provide other unimplemented methods using noSuchMethod or just empty since they aren't called here
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('Search benchmark test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

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

    // Initial query should not happen since initialQuery is null
    expect(mockRepo.fetchProductsCount, 0);
    expect(mockRepo.searchProductsCount, 0);

    // Type into search bar
    await tester.enterText(find.byType(TextField), 'toma');

    // Debounce timer is 500ms, pump halfway
    await tester.pump(const Duration(milliseconds: 200));
    expect(mockRepo.searchProductsCount, 0); // Should not have fired yet

    // Type more
    await tester.enterText(find.byType(TextField), 'tomato');

    // Pump another 200ms
    await tester.pump(const Duration(milliseconds: 200));
    expect(mockRepo.searchProductsCount, 0); // Still not fired

    // Pump past the 500ms debounce of the last input
    await tester.pump(const Duration(milliseconds: 500));

    // Should have fired EXACTLY ONCE
    expect(mockRepo.searchProductsCount, 1);
    expect(mockRepo.fetchProductsCount, 0); // We no longer fetch all

    // Type a color
    await tester.enterText(find.byType(TextField), 'red');
    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.searchProductsByColorCount, 1);
    expect(mockRepo.searchProductsCount, 1); // Unchanged
  });
}
