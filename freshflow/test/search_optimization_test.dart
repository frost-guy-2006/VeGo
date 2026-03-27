import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';

// Mock Repository
class MockProductRepository extends Fake implements ProductRepository {
  int fetchProductsCallCount = 0;
  int searchProductsCallCount = 0;
  int searchProductsByColorCallCount = 0;

  String? lastSearchQuery;
  String? lastColorQuery;

  @override
  Future<List<Product>> fetchProducts() async {
    fetchProductsCallCount++;
    return [];
  }

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchProductsCallCount++;
    lastSearchQuery = query;
    return [];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    searchProductsByColorCallCount++;
    lastColorQuery = color;
    return [];
  }
}

void main() {
  late MockProductRepository mockRepository;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockRepository = MockProductRepository();
  });

  Widget createWidgetUnderTest() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => WishlistProvider()),
      ],
      child: MaterialApp(
        home: SearchScreen(productRepository: mockRepository),
      ),
    );
  }

  testWidgets('Text search calls searchProducts and uses debounce',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Clear initial calls from initState
    mockRepository.fetchProductsCallCount = 0;
    mockRepository.searchProductsCallCount = 0;
    mockRepository.searchProductsByColorCallCount = 0;

    // Type "apple"
    await tester.enterText(find.byType(TextField), 'apple');
    await tester.pump(); // Trigger onChanged, but debounce should hold it

    // Verify no immediate call
    expect(mockRepository.searchProductsCallCount, 0);
    expect(mockRepository.fetchProductsCallCount, 0);

    // Wait for debounce
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProducts was called
    expect(mockRepository.searchProductsCallCount, 1);
    expect(mockRepository.lastSearchQuery, 'apple');
    expect(mockRepository.fetchProductsCallCount, 0);
  });

  testWidgets('Color search calls searchProductsByColor',
      (WidgetTester tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    // Clear initial calls
    mockRepository.fetchProductsCallCount = 0;
    mockRepository.searchProductsCallCount = 0;
    mockRepository.searchProductsByColorCallCount = 0;

    // Type "Red"
    await tester.enterText(find.byType(TextField), 'Red');
    await tester.pump(const Duration(milliseconds: 600));

    // Verify searchProductsByColor was called
    expect(mockRepository.searchProductsByColorCallCount, 1);
    expect(mockRepository.lastColorQuery, 'Red');
    expect(mockRepository.fetchProductsCallCount, 0);
    expect(mockRepository.searchProductsCallCount, 0);
  });
}
