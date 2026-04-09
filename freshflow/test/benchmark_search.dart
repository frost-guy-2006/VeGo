import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

class MockProductRepository extends Fake implements ProductRepository {
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;
  int fetchProductsCallCount = 0;

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

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [];
  }
}

class MockCartProvider extends Fake implements CartProvider {
  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void dispose() {}

  @override
  bool get hasListeners => false;

  @override
  void notifyListeners() {}
}

class MockWishlistProvider extends Fake implements WishlistProvider {
  @override
  bool isInWishlist(String productId) => false;

  @override
  void addListener(VoidCallback listener) {}

  @override
  void removeListener(VoidCallback listener) {}

  @override
  void dispose() {}

  @override
  bool get hasListeners => false;

  @override
  void notifyListeners() {}
}

void main() {
  Widget createWidgetUnderTest(ProductRepository mockRepo) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<CartProvider>(create: (_) => MockCartProvider()),
        ChangeNotifierProvider<WishlistProvider>(
            create: (_) => MockWishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: mockRepo),
      ),
    );
  }

  testWidgets('SearchScreen debounces input and uses server-side filtering',
      (WidgetTester tester) async {
    final mockRepo = MockProductRepository();

    await tester.pumpWidget(createWidgetUnderTest(mockRepo));

    // Initially no calls
    expect(mockRepo.searchProductsCallCount, 0);
    expect(mockRepo.fetchProductsCallCount, 0);

    // Enter text fast to simulate typing
    final textField = find.byType(TextField);
    await tester.enterText(textField, 'a');
    await tester.enterText(textField, 'ap');
    await tester.enterText(textField, 'app');
    await tester.enterText(textField, 'appl');
    await tester.enterText(textField, 'apple');

    // Timer hasn't elapsed, so no calls should be made
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce timer (500ms)
    await tester.pump(const Duration(milliseconds: 500));

    // Should only be called once after debouncing, and not using fetchProducts
    expect(mockRepo.fetchProductsCallCount, 0,
        reason: 'Should not use client-side filtering via fetchProducts');
    expect(mockRepo.searchProductsCallCount, 1,
        reason: 'Should use server-side searchProducts once');

    // Test color search
    await tester.enterText(textField, 'red');
    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.searchProductsByColorCallCount, 1,
        reason: 'Should use server-side searchProductsByColor for red');
    expect(mockRepo.searchProductsCallCount, 1,
        reason: 'searchProducts call count should remain unchanged');
  });
}
