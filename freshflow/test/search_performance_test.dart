import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

class MockProductRepository extends ProductRepository {
  int fetchAllCallCount = 0;
  int searchCallCount = 0;
  int colorSearchCallCount = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchAllCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    colorSearchCallCount++;
    return [];
  }
}

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await Supabase.initialize(url: 'https://example.com', anonKey: 'example');
  });

  testWidgets('SearchScreen debounce and server-side filtering test', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(MaterialApp(
      home: SearchScreen(productRepository: mockRepo),
    ));

    final textField = find.byType(TextField);

    // 1. Test Text Search Debounce
    // Type 'a', then 'ab', then 'abc' quickly
    await tester.enterText(textField, 'a');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'ab');
    await tester.pump(const Duration(milliseconds: 100));
    await tester.enterText(textField, 'abc');
    await tester.pump(const Duration(milliseconds: 100));

    // Verify no calls yet (debounce active)
    expect(mockRepo.fetchAllCallCount, 0, reason: "FetchAll should never be called");
    expect(mockRepo.searchCallCount, 0, reason: "Search should be debounced");

    // Wait for debounce to finish
    await tester.pump(const Duration(milliseconds: 600));

    // Wait for async search to complete
    await tester.pump();

    // Verify calls
    expect(mockRepo.fetchAllCallCount, 0, reason: "FetchAll should not be called in optimized version");
    expect(mockRepo.searchCallCount, 1, reason: "Should call searchProducts once for 'abc'");
    expect(mockRepo.colorSearchCallCount, 0);

    // 2. Test Color Search
    // Type 'red'
    await tester.enterText(textField, 'red');

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));
    await tester.pump();

    // Verify calls
    expect(mockRepo.fetchAllCallCount, 0);
    // searchCallCount is still 1 (from previous step)
    expect(mockRepo.searchCallCount, 1);
    expect(mockRepo.colorSearchCallCount, 1, reason: "Should call searchProductsByColor for 'red'");
  });
}
