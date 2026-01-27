import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProductRepository extends ProductRepository {
  // Override to prevent real DB calls and track usage
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
}

void main() {
  setUpAll(() async {
     // Mock Supabase init
    SharedPreferences.setMockInitialValues({});

    // We try to init, if it fails because already initialized, that's fine (maybe from other tests)
    try {
      await Supabase.initialize(
        url: 'https://example.supabase.co',
        anonKey: 'dummy',
        debug: false,
      );
    } catch (e) {
      // Ignore
    }
  });

  testWidgets('SearchScreen uses optimized queries and debounce', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    // Find the text field
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    // Enter text "apple" (normal search)
    await tester.enterText(textFieldFinder, 'apple');
    await tester.pump(); // This pumps the frame, but debounce timer is running.

    // Verify NOT called immediately due to debounce
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0);

    // Wait for debounce (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // Verify optimized search called
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0, reason: "Should not fetch all products");

    // Clear and search for "Red" (Color search)
    await tester.enterText(textFieldFinder, '');
    await tester.pump(const Duration(milliseconds: 600)); // debounce clear

    await tester.enterText(textFieldFinder, 'Red');
    await tester.pump(const Duration(milliseconds: 600)); // debounce

    // Verify color search called
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0);
  });
}
