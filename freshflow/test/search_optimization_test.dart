import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock ProductRepository extending Fake to avoid unimplemented methods
class MockProductRepository extends Fake implements ProductRepository {
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

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
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget createSearchScreen(ProductRepository repo, {String? initialQuery}) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
        ChangeNotifierProvider<WishlistProvider>(
            create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(
          initialQuery: initialQuery,
          productRepository: repo,
        ),
      ),
    );
  }

  testWidgets('SearchScreen debounces search input', (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createSearchScreen(mockRepo));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Type "a"
    await tester.enterText(textField, 'a');
    await tester.pump();
    // Wait less than debounce
    await tester.pump(const Duration(milliseconds: 100));

    // Type "ap"
    await tester.enterText(textField, 'ap');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    // Type "app"
    await tester.enterText(textField, 'app');
    await tester.pump();

    // Verify no calls yet due to debounce
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce to finish
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProducts was called exactly once
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.searchProductsByColorCallCount, 0);
  });

  testWidgets('SearchScreen calls searchProductsByColor for color queries',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createSearchScreen(mockRepo));
    await tester.pumpAndSettle();

    final textField = find.byType(TextField);

    // Type "Red"
    await tester.enterText(textField, 'Red');
    await tester.pump();

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProductsByColor was called
    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.searchProductsCallCount, 0);
  });

  testWidgets('SearchScreen executes initial query immediately',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createSearchScreen(mockRepo, initialQuery: 'test'));

    // Pump to let addPostFrameCallback run
    await tester.pump();

    // Since it's initial query, it might not be debounced or handled differently?
    // In current implementation, it is called directly in addPostFrameCallback.

    expect(mockRepo.searchProductsCallCount, 1);
  });
}
