import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';

class FakeSupabaseClient extends Fake implements SupabaseClient {}

class MockProductRepository extends ProductRepository {
  MockProductRepository() : super(client: FakeSupabaseClient());

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

void main() {
  Widget buildTestableWidget(Widget widget) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: widget,
      ),
    );
  }

  group('SearchScreen Optimization Tests', () {
    testWidgets('Debounce works and uses server-side search', (WidgetTester tester) async {
      final mockRepo = MockProductRepository();

      await tester.pumpWidget(buildTestableWidget(SearchScreen(productRepository: mockRepo)));

      // Ensure fetchProducts is NOT called on init (it used to be)
      expect(mockRepo.fetchProductsCount, 0);

      // Enter text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'a');
      await tester.enterText(textField, 'ap');
      await tester.enterText(textField, 'app');
      await tester.enterText(textField, 'appl');
      await tester.enterText(textField, 'apple');

      // Should not have called search yet due to debounce
      expect(mockRepo.searchProductsCount, 0);

      // Wait for debounce timer (500ms)
      await tester.pump(const Duration(milliseconds: 500));

      // Should have called search exactly once with final query
      expect(mockRepo.searchProductsCount, 1);
      expect(mockRepo.fetchProductsCount, 0); // Still shouldn't use fetchAll
      expect(mockRepo.searchProductsByColorCount, 0);
    });

    testWidgets('Color search uses specialized method', (WidgetTester tester) async {
      final mockRepo = MockProductRepository();

      await tester.pumpWidget(buildTestableWidget(SearchScreen(productRepository: mockRepo)));

      // Enter color text
      final textField = find.byType(TextField);
      await tester.enterText(textField, 'red');

      // Wait for debounce timer (500ms)
      await tester.pump(const Duration(milliseconds: 500));

      // Should have called specialized color search
      expect(mockRepo.searchProductsByColorCount, 1);
      expect(mockRepo.searchProductsCount, 0);
      expect(mockRepo.fetchProductsCount, 0);
    });
  });
}
