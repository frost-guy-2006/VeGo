import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

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
  Future<List<Product>> fetchProductsByCategory(String category) async {
    return [];
  }

  @override
  Future<Product?> fetchProductById(String id) async {
    return null;
  }

  @override
  Future<List<Product>> fetchProductsPaginated(
      {int page = 0, int pageSize = 10, String? category}) async {
    return [];
  }

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async {
    return false;
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
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('SearchScreen debounces input and calls correct repository methods', (WidgetTester tester) async {
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

    // Initial load will try to fetch some queries if any
    expect(mockRepo.fetchProductsCount, 0);

    // Find the TextField
    final textField = find.byType(TextField);
    expect(textField, findsOneWidget);

    // Type a character
    await tester.enterText(textField, 'a');
    // It should not trigger immediately due to debounce
    expect(mockRepo.searchProductsCount, 0);

    // Wait slightly less than debounce time
    await tester.pump(const Duration(milliseconds: 300));
    // Type another character
    await tester.enterText(textField, 'ap');

    // Still should not trigger
    expect(mockRepo.searchProductsCount, 0);

    // Type the rest
    await tester.enterText(textField, 'apple');

    // Wait for debounce duration
    await tester.pump(const Duration(milliseconds: 500));

    // Now it should have triggered exactly once
    expect(mockRepo.searchProductsCount, 1);
    expect(mockRepo.searchProductsByColorCount, 0);

    // Test color logic
    await tester.enterText(textField, 'red');
    await tester.pump(const Duration(milliseconds: 500));

    expect(mockRepo.searchProductsByColorCount, 1);
  });
}
