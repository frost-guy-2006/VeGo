import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MockProductRepo implements ProductRepository {
  int fetchAllCalls = 0;
  int searchCalls = 0;
  int colorSearchCalls = 0;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchAllCalls++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCalls++;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    colorSearchCalls++;
    return [];
  }

  @override
  Future<Product?> fetchProductById(String id) async => null;

  @override
  Future<List<Product>> fetchProductsByCategory(String category) async => [];

  @override
  Future<List<Product>> fetchProductsPaginated(
          {int page = 0, int pageSize = 10, String? category}) async =>
      [];

  @override
  Future<bool> hasMoreProducts(
          {int currentCount = 0, String? category}) async =>
      false;
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createTestWidget(MockProductRepo repo) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: repo),
      ),
    );
  }

  testWidgets(
      'Debounce and server-side filtering significantly reduce redundant backend calls',
      (WidgetTester tester) async {
    final repo = MockProductRepo();

    await tester.pumpWidget(createTestWidget(repo));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Simulate typing "tomato" quickly
    await tester.enterText(textField, 't');
    await tester.enterText(textField, 'to');
    await tester.enterText(textField, 'tom');
    await tester.enterText(textField, 'toma');
    await tester.enterText(textField, 'tomat');
    await tester.enterText(textField, 'tomato');

    // Due to the 500ms debounce, no API calls should be made immediately
    expect(repo.fetchAllCalls, 0, reason: 'No longer fetching all products');
    expect(repo.searchCalls, 0, reason: 'Search should be debounced');

    // Wait for the debounce timer to elapse (500ms)
    await tester.pump(const Duration(milliseconds: 600));

    // One API call should now happen
    expect(repo.searchCalls, 1,
        reason: 'Only one search call should happen after debounce');
    expect(repo.fetchAllCalls, 0, reason: 'Should not fetch all products');
  });

  testWidgets('Typing a color keyword invokes searchProductsByColor once',
      (WidgetTester tester) async {
    final repo = MockProductRepo();

    await tester.pumpWidget(createTestWidget(repo));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);

    // Type "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    expect(repo.colorSearchCalls, 1,
        reason: 'Color search should be invoked exactly once');
    expect(repo.searchCalls, 0, reason: 'Normal search should not be invoked');
    expect(repo.fetchAllCalls, 0, reason: 'Should not fetch all products');
  });
}
