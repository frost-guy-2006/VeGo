import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Fake Repository
class MockProductRepository extends Fake implements ProductRepository {
  int fetchAllCallCount = 0;
  int searchCallCount = 0;
  int searchByColorCallCount = 0;

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
    searchByColorCallCount++;
    return [];
  }
}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('SearchScreen debounces and uses server-side search (optimized)', (WidgetTester tester) async {
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

    // Find the text field
    final textFieldFinder = find.byType(TextField);
    expect(textFieldFinder, findsOneWidget);

    // 1. Test Debounce on regular search
    // Type "ap"
    await tester.enterText(textFieldFinder, 'ap');
    await tester.pump();

    // Type "app" rapidly
    await tester.enterText(textFieldFinder, 'app');
    await tester.pump();

    // Verify NO immediate calls
    expect(mockRepo.fetchAllCallCount, 0, reason: "Should NEVER call fetchProducts");
    expect(mockRepo.searchCallCount, 0, reason: "Should be debounced");
    expect(mockRepo.searchByColorCallCount, 0, reason: "Should be debounced");

    // Wait for debounce (500ms) - pump slightly more to be safe
    await tester.pump(const Duration(milliseconds: 600));

    // Now verify call
    expect(mockRepo.searchCallCount, 1, reason: "Should call searchProducts for 'app'");
    expect(mockRepo.searchByColorCallCount, 0);

    // 2. Test Color Search
    // Type "Red"
    await tester.enterText(textFieldFinder, 'Red');
    await tester.pump();

    // Verify NO immediate calls (debounce restart)
    // Note: searchCallCount is 1 from before
    expect(mockRepo.searchCallCount, 1);
    expect(mockRepo.searchByColorCallCount, 0);

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    expect(mockRepo.searchByColorCallCount, 1, reason: "Should call searchProductsByColor for 'Red'");
    // searchCallCount stays at 1
    expect(mockRepo.searchCallCount, 1);
  });
}
