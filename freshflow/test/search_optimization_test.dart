import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:vego/core/models/product_model.dart';
import 'package:vego/core/repositories/product_repository.dart';
import 'package:vego/features/search/screens/search_screen.dart';
import 'package:vego/core/providers/cart_provider.dart';
import 'package:vego/core/providers/wishlist_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

// Mock HttpOverrides to avoid network calls from CachedNetworkImage
class MockHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}

class MockProductRepository extends Fake implements ProductRepository {
  int searchCount = 0;
  int colorSearchCount = 0;

  @override
  Future<List<Product>> searchProducts(String query) async {
    searchCount++;
    return [
      Product(id: '1', name: 'Product $query', imageUrl: '', currentPrice: 10, marketPrice: 12, harvestTime: 'Now', stock: 10)
    ];
  }

  @override
  Future<List<Product>> searchProductsByColor(String color) async {
    colorSearchCount++;
    return [
      Product(id: '2', name: '$color Product', imageUrl: '', currentPrice: 10, marketPrice: 12, harvestTime: 'Now', stock: 10, color: color)
    ];
  }

  @override
  Future<List<Product>> fetchProducts() async {
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
}

void main() {
  setUpAll(() {
    HttpOverrides.global = MockHttpOverrides();
  });

  group('Product Model Tests', () {
    test('Product.colorKeywords structure is correct', () {
      expect(Product.colorKeywords.containsKey('Red'), isTrue);
      expect(Product.colorKeywords['Red'], contains('tomato'));
      expect(Product.colorKeywords['Green'], contains('broccoli'));
    });

    test('Product.fromJson infers color correctly', () {
      final redProduct = Product.fromJson({
        'id': '1',
        'name': 'Fresh Tomato',
        'currentPrice': 10,
        'marketPrice': 12,
        'stock': 10
      });
      expect(redProduct.color, equals('Red'));

      final greenProduct = Product.fromJson({
        'id': '2',
        'name': 'Green Spinach',
        'currentPrice': 10,
        'marketPrice': 12,
        'stock': 10
      });
      expect(greenProduct.color, equals('Green'));

      final otherProduct = Product.fromJson({
         'id': '3',
         'name': 'Unknown Thing',
         'currentPrice': 10,
         'marketPrice': 12,
         'stock': 10
      });
      expect(otherProduct.color, isNull);
    });
  });

  group('SearchScreen Tests', () {
    late MockProductRepository mockRepo;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      mockRepo = MockProductRepository();
    });

    Widget createWidgetUnderTests() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<CartProvider>(create: (_) => CartProvider()),
          ChangeNotifierProvider<WishlistProvider>(create: (_) => WishlistProvider()),
        ],
        child: MaterialApp(
          home: SearchScreen(productRepository: mockRepo),
        ),
      );
    }

    testWidgets('Entering text triggers debounce and search', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTests());

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      // Enter text
      await tester.enterText(textField, 'apple');

      // Should not have searched yet (debounce 500ms)
      expect(mockRepo.searchCount, 0);

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));

      // Should have searched now
      expect(mockRepo.searchCount, 1);
      expect(mockRepo.colorSearchCount, 0);
    });

    testWidgets('Entering color keyword triggers color search', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTests());

      final textField = find.byType(TextField);

      // Enter "Red"
      await tester.enterText(textField, 'Red');

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));

      // Should have called color search
      expect(mockRepo.colorSearchCount, 1);
      // And NOT normal search
      expect(mockRepo.searchCount, 0);
    });

    testWidgets('Entering "tomato" triggers normal search (as it is not a color key itself)', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTests());

      final textField = find.byType(TextField);

      // Enter "tomato"
      await tester.enterText(textField, 'tomato');

      // Wait for debounce
      await tester.pump(const Duration(milliseconds: 600));

      // Should have called normal search
      expect(mockRepo.searchCount, 1);
      expect(mockRepo.colorSearchCount, 0);
    });
  });
}
