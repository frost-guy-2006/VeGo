import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock ProductRepository
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
  Future<List<Product>> fetchProductsPaginated({int page = 0, int pageSize = 10, String? category}) async {
    return [];
  }

  @override
  Future<bool> hasMoreProducts({int currentCount = 0, String? category}) async {
    return false;
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockProductRepository mockRepo;

  setUp(() {
    mockRepo = MockProductRepository();
    SharedPreferences.setMockInitialValues({});
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: mockRepo),
      ),
    );
  }

  testWidgets('Optimized: SearchScreen uses server-side search and debounce', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Type in search box "apple"
    await tester.enterText(find.byType(TextField), 'apple');

    // Immediate pump: debounce timer started, but search not called yet
    await tester.pump();
    expect(mockRepo.searchProductsCallCount, 0);

    // Wait for debounce (500ms) + 1 frame
    await tester.pump(const Duration(milliseconds: 600));

    // Now search should have been called
    expect(mockRepo.searchProductsCallCount, 1);
    expect(mockRepo.fetchProductsCallCount, 0); // Verify fetch-all is NOT called
  });

  testWidgets('Optimized: SearchScreen uses searchProductsByColor for color keywords', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Type "Red"
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    expect(mockRepo.searchProductsByColorCallCount, 1);
    expect(mockRepo.searchProductsCallCount, 0);
  });
}
